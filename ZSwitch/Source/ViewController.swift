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
    var keyQdownCount = 0
    var _userInput = ""
    var backView: BackView?
    var circleCounter: JWGCircleCounter?
    var label: NSTextField?
    var timer = Timer()
    var orderedAppModels: [AppModel] = []
    var _appModels:[AppModel] = []
    var _appItemViews: [AppItemView] = []
    var clearUserInputWork: DispatchWorkItem = DispatchWorkItem { }
    var clearKeyQCountWork: DispatchWorkItem = DispatchWorkItem { }
    
    var userInput: String {
        get {
            return _userInput
        }
        set {
            _userInput = newValue
            if newValue == "" {
                orderedAppModels = _appModels
            } else {
                clearUserInputWork.cancel()
                orderedAppModels = _appModels.sorted {
                    ($0.name?.lcsDistance(self.userInput))! < ($1.name?.lcsDistance(self.userInput))!
                }
                self.circleCounter = getSingletonCircleCounter(
                    counter: self.circleCounter, left: (self.label?.stringValue.count)! * 4)
                self.view.addSubview(self.circleCounter!)
                self.circleCounter?.start(withSeconds: 1)
                
                clearUserInputWork = DispatchWorkItem {
                    self._userInput = ""
                    self.label?.removeFromSuperview()
                    self.circleCounter?.removeFromSuperview()
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: clearUserInputWork)
            }
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
                self.label = getInputLabel(label: self.label)
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

            if orderedAppModels.count > 0 {
                reCalculateSize(count: orderedAppModels.count)
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
        updateModifierKeyState(keycode)
        if (self.orderedAppModels.count <= 0) { return true }

        if isCommandPressing && keycode == Key.tab.carbonKeyCode {
            // TODO: current active app, if not in first order, should replace to first
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200), execute: {
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
        } else if isShowingUI {
            if !isCommandPressing {
                NSApp.windows[0].orderOut(nil)
                let v = appItemViews[currentAppIndex]
                v.appModel?.app.activate(options: .activateIgnoringOtherApps)
                afterSelectApp(appName: v.appModel?.name)
            } else if type == KeyDown && keycode == Key.grave.carbonKeyCode {
                NSApp.windows[0].orderFrontRegardless()
                if (appItemViews.count > 0) {
                    currentAppIndex = (currentAppIndex + appItemViews.count - 1) % appItemViews.count
                }
            } else if type == KeyDown && keycode == Key.q.carbonKeyCode {
                    processKeyQdown()
            } else if type == KeyDown && keycode == Key.delete.carbonKeyCode {
                if userInput.count > 0 {
                    let index = userInput.index(userInput.endIndex, offsetBy: -1)
                    userInput = String(userInput[..<index])
                }
            } else if type == KeyUp && Key.isAlphabetKey(code: UInt32(keycode)) {
                userInput += Key.toAlphabelt(keycode: UInt32(keycode))
            }
        }
        
        updateAppItemViews()
        if isShowingUI { return false }
        else { return true }
    }
    
    fileprivate func updateModifierKeyState(_ keycode: Int32) {
        if (UInt32(keycode) == Key.command.carbonKeyCode) {
            self.isCommandPressing = !self.isCommandPressing
        }
        if (UInt32(keycode) == Key.shift.carbonKeyCode) {
            self.isShiftPressing = !self.isShiftPressing
        }
        if (UInt32(keycode) == Key.option.carbonKeyCode) {
            self.isOptionPressing = !self.isOptionPressing
        }
    }
    
    fileprivate func processKeyQdown() {
        keyQdownCount += 1
        clearKeyQCountWork.cancel()
        clearKeyQCountWork = DispatchWorkItem { self.keyQdownCount = 0 }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: clearKeyQCountWork)
        if keyQdownCount > 5 {
            let name = orderedAppModels[currentAppIndex].name
            self._userInput = "hold 'Com+Q' 2s to quit '\(name!)'"
        }
        if keyQdownCount < 20 { return }
        keyQdownCount = 0
        _userInput = ""
        let pid = orderedAppModels[currentAppIndex].pid!
        terminateApp(pid: pid)
        orderedAppModels = orderedAppModels.filter{ $0.pid != pid }
        appModels = appModels.filter{ $0.pid != pid}
        currentAppIndex = currentAppIndex % appModels.count
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        NSApp.windows[0].orderOut(nil)
    }
}
