//
//  ViewController.swift
//  ZSwitch
//
//  Created by zhangshibo on 8/17/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var isCommandPressing = false
    var isShiftPressing = false
    var isOptionPressing = false
    var isShowingUI = false
    var currentAppIndex = 0
    var _userInput = ""
    var backView: BackView?
    var label: NSTextField?
    var timer = Timer()
    var orderedAppModels: [AppModel] = []
    var _appModels:[AppModel] = []
    var _appItemViews: [AppItemView] = []
    var clearUserInputWork: DispatchWorkItem = DispatchWorkItem { }
    
    var userInput: String {
        get {
            return _userInput
        }
        set {
            if newValue == "" {
                orderedAppModels = _appModels
            } else {
                clearUserInputWork.cancel()
                _userInput = newValue
                orderedAppModels = _appModels.sorted {
                    let dis0 = $0.name?.lcsDistance(self.userInput)
                    let dis1 = $1.name?.lcsDistance(self.userInput)
//                    NSLog("\($0.name): \(dis0)")
//                    NSLog("\($1.name): \(dis1)")

                    return  dis0! < dis1!
                }
                clearUserInputWork = DispatchWorkItem { self._userInput = "" }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: clearUserInputWork)
//                orderedAppModels = orderedAppModels.filter {
//                    $0.name?.lcsDistance(self.userInput) == 2
//                }
            }
            _userInput = newValue
            currentAppIndex = 0
           
        }
    }
    
    var appItemViews:[AppItemView] {
        get {
            return _appItemViews
        }
        set {
            DispatchQueue.main.async {
                self.clearViews()
                self.backView = createBackView()
                self.label = createInputLabel()
                self.label?.stringValue = self.userInput
                self.view.addSubview(self.backView!)
                self.view.addSubview(self.label!)
                self._appItemViews = newValue
                for (index,item) in self.appItemViews.enumerated() {
                    if index == self.currentAppIndex {
                        item.isActive = true
                        item.view.addSubview(createActiveSign())
                    }
                    self.view.addSubview(item.view)
                }
            }
        }
    }
    
    var appModels:[AppModel] {
        get {
            return _appModels
        }
        set {
            for app in newValue { // app add
                let find = _appModels.first(where: {$0.name == app.name})
                if find == nil {
                    _appModels.append(app)
                    orderedAppModels.append(app)
                } else {
                    find?.pid = app.pid
                }
            }
            for (index, app) in _appModels.enumerated() { // app quit
                if newValue.first(where: {$0.name == app.name}) == nil {
                    _appModels.remove(at: index)
                }
            }
            for (index, app) in orderedAppModels.enumerated() { // app quit
                if newValue.first(where: {$0.name == app.name}) == nil {
                    orderedAppModels.remove(at: index)
                }
            }

            if _appModels.count > 0 {
                reCalculateSize(count: _appModels.count)
            }
            if !isShowingUI {
                orderedAppModels = _appModels
            }
            updateAppItemViews()
        }
    }
    
// MARK: - life cycle
    override func loadView() {
        let view = NSView(frame: screenRect!)
        view.wantsLayer = true
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateAppModels(force: true)
        orderedAppModels = appModels
        timer = Timer.scheduledTimer(withTimeInterval: 2,
                                     repeats: true,
                                     block: { (_)  in
            self.updateAppModels(force: false)
        })
    }

// MARK: - view manipulation
    fileprivate func clearViews() {
        if self.backView != nil {
            self.backView?.removeFromSuperview()
        }
        if self.label != nil {
            self.label?.removeFromSuperview()
        }
        for item in self._appItemViews {
            item.view.removeFromSuperview()
            item.isActive = false
        }
    }
    
    fileprivate func updateAppItemViews() {
        var appItemViews:[AppItemView] = []
        for (index, appModel) in orderedAppModels.enumerated() {
            let appItem = createAppItem(appModel: appModel, index: index)
            appItem.afterSelectApp = afterSelectApp
            appItemViews.append(appItem)
        }
        self.appItemViews = appItemViews
    }
    
    @objc func afterSelectApp(appName: String?) {
        if let name = appName {
            for (index, app) in appModels.enumerated() {
                if app.name == name {
                    self.currentAppIndex = index
                }
            }
        }
        
        _appModels.rearrange(from: currentAppIndex, to: 0)
        updateAppItemViews()
        currentAppIndex = 0
        isShowingUI = false
        userInput = ""
    }

    fileprivate func updateAppModels(force: Bool) {
        if !isShowingUI && !force {
            return
        }
        let ws = NSWorkspace.shared
        var tmpModels:[AppModel] = []
        for app in ws.runningApplications {
            if (app.activationPolicy == .regular) {
                let appModel = AppModel(app: app)
                tmpModels.append(appModel)
            }
        }
        self.appModels = tmpModels
    }
  
// MARK: - user interaction
    @objc func interceptKeyChange(keycode: Int32, type: Int32) -> Bool {

//        NSLog("current index: \(currentAppIndex)")
//        NSLog("keycode: \(keycode) type: \(type)")
        if (UInt32(keycode) == Key.command.carbonKeyCode) {
            self.isCommandPressing = !self.isCommandPressing
        }
        if (UInt32(keycode) == Key.shift.carbonKeyCode) {
            self.isShiftPressing = !self.isShiftPressing
        }
        if (UInt32(keycode) == Key.option.carbonKeyCode) {
            self.isOptionPressing = !self.isOptionPressing
        }

        if currentAppIndex >= appModels.count {
            currentAppIndex = 0
            return true
        }
        
        if !isCommandPressing && isShowingUI {
            NSApp.windows[0].orderOut(nil)
            let v = appItemViews[currentAppIndex]
            v.appModel?.app.activate(options: .activateIgnoringOtherApps)
            afterSelectApp(appName: v.appModel?.name)
            
        } else if isCommandPressing && keycode == Key.tab.carbonKeyCode {
            // TODO: current active app, if not in first order, should replace to first
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                if self.isShowingUI == false { return }
                NSApp.windows[0].orderFrontRegardless()
            })
            isShowingUI = true
            if (type == KeyDown && appItemViews.count > 0) {
                if (isShiftPressing) {
                    currentAppIndex = (currentAppIndex + appItemViews.count - 1) % appItemViews.count
                } else {
                    currentAppIndex = (currentAppIndex + 1) % appItemViews.count
                }
            }
        } else if isShowingUI && keycode == Key.grave.carbonKeyCode {
            NSApp.windows[0].orderFrontRegardless()
            if (type == KeyDown && appItemViews.count > 0) {
                currentAppIndex = (currentAppIndex + appItemViews.count - 1) % appItemViews.count
            }
        } else if isShowingUI && isOptionPressing && keycode == Key.q.carbonKeyCode {
            if (type == KeyDown && appItemViews.count > 0) {
                let pid = orderedAppModels[currentAppIndex].pid!
                terminateApp(pid: pid)
                orderedAppModels = orderedAppModels.filter{ $0.pid != pid }
                appModels = appModels.filter{ $0.pid != pid}
                currentAppIndex = currentAppIndex % appModels.count
            }
        } else if isShowingUI && Key.isAlphabetKey(code: UInt32(keycode)) {
            if type == KeyUp {
                userInput += Key.toAlphabelt(keycode: UInt32(keycode))
            }
        }  else if isShowingUI && keycode == Key.delete.carbonKeyCode {
            if userInput.count > 0 && type == KeyDown {
                let index = userInput.index(userInput.endIndex, offsetBy: -1)
                userInput = String(userInput[..<index])
            }
        }
        
        updateAppItemViews()
        if isShowingUI { return false }
        else { return true }
    }

    override func mouseDown(with theEvent: NSEvent) {
        NSApp.windows[0].orderOut(nil)
    }
}
