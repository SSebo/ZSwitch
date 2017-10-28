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
    var timer = Timer()
    var _appModels:[AppModel] = []
    var _appItemViews: [AppItemView] = []
    var appItemViews:[AppItemView] {
        get {
            return _appItemViews
        }
        set {
            DispatchQueue.main.async {
                for item in self._appItemViews {
                    item.view.removeFromSuperview()
                }
                self._appItemViews = newValue
                for item in self._appItemViews {
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
            _appModels = newValue
            if _appModels.count > 0 {
                let totalUsedWidth = (Double(_appModels.count) - 1) * gapWidth + Double(_appModels.count) * itemExpectWidth
                if totalUsedWidth <= Double((screenRect?.width)!) + 2 * (leftRightMinMargin) {
                    actualLeftRightMargin = (Double((screenRect?.width)!) - totalUsedWidth) / 2.0
                } else {
                    actualLeftRightMargin = leftRightMinMargin
                    let totalGapWidth = (Double(_appModels.count) - 1) * gapWidth
                    itemActualWidth = (Double((screenRect?.width)!) - totalGapWidth - 2 * leftRightMinMargin) / Double(_appModels.count)
                }
            }
            
            var appItemViews:[AppItemView] = []
            for (index, appModel) in _appModels.enumerated() {
                appModel.width = itemActualWidth
                let appItem = AppItemView()
                appItem.appModel = appModel
                
                appItem.view.frame = NSRect(x: Int(actualLeftRightMargin + Double(index) * (itemActualWidth + gapWidth)), y:Int((screenRect?.height)!/2-50), width: 80, height:100)
                appItemViews.append(appItem)
            }
            self.appItemViews = appItemViews
        }
    }

    override func loadView() {
        let view = NSView(frame: screenRect!)
        view.wantsLayer = true
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KeyboardHook.start(keyChange)
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_)  in
            let ws = NSWorkspace.shared
            var tmpModels:[AppModel] = []
            for app in ws.runningApplications {
                if (app.activationPolicy == .regular) {
                    let appModel = AppModel(icon: app.icon, name: app.localizedName, pid: app.processIdentifier)
                    tmpModels.append(appModel)
                }
            }
            self.appModels = tmpModels
        })
        
    }
    
    @objc func keyChange(_ keycode: Int32, _ type: Int32) -> Void {
        NSLog("keycode: \(keycode) type: \(type)")
        if (UInt32(keycode) == Key.command.carbonKeyCode) {
            self.isCommandPressing = !self.isCommandPressing
            NSLog("commmand status: \(self.isCommandPressing)")
        }
        
        NSLog("is active \(NSApp.isActive)")
        if !self.isCommandPressing {
            NSLog("de activate ---")
            NSApp.windows[0].orderOut(nil)
        } else if self.isCommandPressing && keycode == Key.tab.carbonKeyCode {
            NSLog("try launch ui ---")
            NSApp.windows[0].orderFrontRegardless()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }

    override func mouseDown(with theEvent: NSEvent) {
        NSLog("mouseDown on backGround View")
        NSApp.windows[0].orderOut(nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

