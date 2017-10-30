//
//  ViewController.swift
//  ZSwitch
//
//  Created by zhangshibo on 8/17/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

var itemExpectWidth = 100.0
var itemActualWidth = 100.0
let screenRect = NSScreen.main?.frame
let gapWidth = 4.0
let leftRightMinMargin = 10.0
var actualLeftRightMargin = 0.0
let KeyDown = 10
let KeyUp = 11
let ModifiersChange = 12

class ViewController: NSViewController {

    var isCommandPressing = false
    var isShiftPressing = false
    var isShowingUI = true
    var currentAppIndex = 0
    var backView: BackView?
    var timer = Timer()
    var _appModels:[AppModel] = []
    var _appItemViews: [AppItemView] = []
    var appItemViews:[AppItemView] {
        get {
            return _appItemViews
        }
        set {
            DispatchQueue.main.async {
                if self.backView != nil {
                    self.backView?.removeFromSuperview()
                }
                for item in self._appItemViews {
                    item.view.removeFromSuperview()
                }

                let backViewWidth = Double((screenRect?.width)!) - (2 * actualLeftRightMargin) + 20
                let backView = BackView()
                backView.frame = NSRect(x: actualLeftRightMargin - 20, y: (Double((screenRect?.height)!/2 - 60)), width: backViewWidth, height: 120.0)
                backView.wantsLayer = true
                backView.layer?.cornerRadius = 20
                backView.layer?.backgroundColor = NSColor(red:0.20, green:0.20, blue:0.20, alpha:1.00).cgColor
                self.backView = backView
                self.view.addSubview(self.backView!)
                
                self._appItemViews = newValue
                for (index,item) in self.appItemViews.enumerated() {
                    if index == self.currentAppIndex {
                        let activeSign = NSView()
                        activeSign.wantsLayer = true
                        activeSign.frame = NSRect(x: 38, y:96, width: 6, height: 6)
                        activeSign.layer?.cornerRadius = 3
                        activeSign.layer?.backgroundColor = NSColor(red:0.16, green:0.97, blue:0.18, alpha:1.00).cgColor
                        item.view.addSubview(activeSign)
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
                if _appModels.first(where: {$0.name == app.name}) == nil {
                    _appModels.append(app)
                }
            }
            for (index, app) in _appModels.enumerated() { // app quit
                if newValue.first(where: {$0.name == app.name}) == nil {
                    _appModels.remove(at: index)
                }
            }

            if _appModels.count > 0 {
                let totalUsedWidth = (Double(_appModels.count) - 1) * gapWidth + Double(_appModels.count) * itemExpectWidth
                if totalUsedWidth <= Double((screenRect?.width)!) + 2 * (leftRightMinMargin) {
                    actualLeftRightMargin = (Double((screenRect?.width)!) - totalUsedWidth) / 2.0
                    if actualLeftRightMargin < leftRightMinMargin {
                        actualLeftRightMargin = leftRightMinMargin
                    }
                } else {
                    actualLeftRightMargin = leftRightMinMargin
                    let totalGapWidth = (Double(_appModels.count) - 1) * gapWidth
                    itemActualWidth = (Double((screenRect?.width)!) - totalGapWidth - 2 * leftRightMinMargin) / Double(_appModels.count)
                }
            }
            updateAppItemViews()
        }
    }
    
    override func loadView() {
        let view = NSView(frame: screenRect!)
        view.wantsLayer = true
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_)  in
            self.updateAppModels()
        })
        
    }
    
    func updateAppItemViews() {
        var appItemViews:[AppItemView] = []
        for (index, appModel) in _appModels.enumerated() {
            appModel.width = itemActualWidth
            let appItem = AppItemView()
            appItem.appModel = appModel
            appItem.afterSelectApp = afterSelectApp
            
            appItem.view.frame = NSRect(x: Int(actualLeftRightMargin + Double(index) * (itemActualWidth + gapWidth)), y:Int((screenRect?.height)!/2-50), width: 80, height:114)
            appItemViews.append(appItem)
        }
        self.appItemViews = appItemViews
    }

    
    func updateAppModels() {
        if !isShowingUI {
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
    
    @objc func interceptKeyChange(_ keycode: Int32, _ type: Int32) -> Bool {

//        NSLog("current index: \(currentAppIndex)")
//        NSLog("keycode: \(keycode) type: \(type)")
        if (UInt32(keycode) == Key.command.carbonKeyCode) {
            self.isCommandPressing = !self.isCommandPressing
        }

        if appModels.count == 0 {
            return true
        }
        
        if !isCommandPressing && isShowingUI {
            NSApp.windows[0].orderOut(nil)
            let v = appItemViews[currentAppIndex]
            NSWorkspace.shared.launchApplication((v.appModel?.name!)!)
            afterSelectApp(appName: nil)
            
        } else if isCommandPressing && keycode == Key.tab.carbonKeyCode {
            NSApp.windows[0].orderFrontRegardless()
            isShowingUI = true
            if (type == KeyDown && appItemViews.count > 0) {
                currentAppIndex = (currentAppIndex + 1) % appItemViews.count
            }
        }
        else if isShowingUI && isCommandPressing && keycode == Key.grave.carbonKeyCode {
            NSApp.windows[0].orderFrontRegardless()
            if (type == KeyDown && appItemViews.count > 0) {
                currentAppIndex = (currentAppIndex + appItemViews.count - 1) % appItemViews.count
            }
        } else if isShowingUI && isCommandPressing && keycode == Key.q.carbonKeyCode {
            if (type == KeyDown && appItemViews.count > 0) {
                let appModel = appModels[currentAppIndex]
                let runingApp = NSWorkspace.shared.runningApplications.first(where: {$0.processIdentifier == appModel.pid})
                runingApp?.forceTerminate()
                appModels.remove(at: currentAppIndex)
                currentAppIndex = currentAppIndex % appModels.count
            }
        }
        
        updateAppItemViews()
        if isShowingUI {
            return false
        }
        return true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }

    override func mouseDown(with theEvent: NSEvent) {
        NSApp.windows[0].orderOut(nil)
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
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}

class BackView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

