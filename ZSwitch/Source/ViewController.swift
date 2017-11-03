//
//  ViewController.swift
//  ZSwitch
//
//  Created by zhangshibo on 8/17/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

var itemExpectWidth = 80
var itemActualSize = 80
let screenRect = NSScreen.main?.frame
let gapWidth = 4
let leftRightMinMargin = 10
var leftRightActualMargin = 10
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
                    item.isActive = false
                }

                let backViewWidth = Int((screenRect?.width)!) - (2 * leftRightActualMargin) + 30
                let backView = BackView()
                backView.frame = NSRect(x: leftRightActualMargin - 20, y: Int((screenRect?.height)!/2 - 60), width: backViewWidth, height: 120)
                backView.wantsLayer = true
                backView.layer?.cornerRadius = 20
                backView.layer?.backgroundColor = NSColor(red:0.20, green:0.20, blue:0.20, alpha:1.00).cgColor
                self.backView = backView
                self.view.addSubview(self.backView!)
                
                self._appItemViews = newValue
                for (index,item) in self.appItemViews.enumerated() {
                    if index == self.currentAppIndex {
                        item.isActive = true
                        let activeSign = NSView()
                        activeSign.wantsLayer = true
                        activeSign.frame = NSRect(x: itemActualSize/2 - 3, y:itemActualSize + 22, width: 6, height: 6)
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
                let totalUsedWidth = (_appModels.count - 1) * gapWidth + _appModels.count * itemExpectWidth
                if totalUsedWidth <= Int((screenRect?.width)!) + 2 * (leftRightMinMargin) {
                    itemActualSize = itemExpectWidth
                    leftRightActualMargin = (Int((screenRect?.width)!) - totalUsedWidth) / 2
                    if leftRightActualMargin < leftRightMinMargin {
                        leftRightActualMargin = leftRightMinMargin
                    }
                } else {
                    leftRightActualMargin = leftRightMinMargin
                    let totalGapWidth = (appModels.count - 1) * gapWidth
                    itemActualSize = (Int((screenRect?.width)!) - totalGapWidth - 2 * leftRightMinMargin) / _appModels.count
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
        self.updateAppModels()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_)  in
            self.updateAppModels()
        })
        
    }
    
    func updateAppItemViews() {
        var appItemViews:[AppItemView] = []
        for (index, appModel) in _appModels.enumerated() {
            let appItem = AppItemView()
            appItem.appModel = appModel
            appItem.afterSelectApp = afterSelectApp
            appItem.size = itemActualSize
            let x = Int(leftRightActualMargin + index * (itemActualSize + gapWidth))
            let y = Int((screenRect?.height)!)/2 -  2 * itemActualSize / 3
            appItem.view.frame = NSRect(x: x, y:y , width: Int(itemActualSize), height:114)
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

        if currentAppIndex >= appModels.count {
            currentAppIndex = 0
            return true
        }
        
        if !isCommandPressing && isShowingUI {
            NSApp.windows[0].orderOut(nil)
            let v = appItemViews[currentAppIndex]
            v.appModel?.app.activate(options: .activateIgnoringOtherApps)
            afterSelectApp(appName: nil)
            
        } else if isCommandPressing && keycode == Key.tab.carbonKeyCode {
            // TODO: current active app, if not in first order, should replace to first
            
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

