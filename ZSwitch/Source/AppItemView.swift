//
//  CollectionViewItem.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class AppItemView: NSViewController {

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    var appModel: AppModel?
    var afterSelectApp: ((String?) -> Void)?
    var _size = 100
    var _isActive = false
    var isActive: Bool {
        get {
            return _isActive
        }
        set {
            if _isActive == newValue { return }
            
            _isActive = newValue
            if _isActive {
                label?.textColor = NSColor(red:0.92, green:0.93, blue:0.94, alpha:1.00)
            }
        }
    }
    var size: Int {
        get {
            return _size
        }
        set {
            if _size == newValue { return }
            
            _size = newValue
            self.view.frame = NSRect(x:0, y: 0, width: _size, height: _size + 30)
            self.imageView.setFrameSize(NSSize(width: _size, height: _size))
            self.imageView.imageScaling = .scaleAxesIndependently
            self.label.frame = NSRect(x: 0, y: Int(self.imageView.frame.minY - 20) , width: _size, height: 20)
        }
    }

    override func mouseDown(with theEvent: NSEvent) {
        appModel?.app.activate(options: .activateIgnoringOtherApps)
        NSWorkspace.shared.launchApplication((self.appModel?.name)!)
        NSApp.windows[0].orderOut(nil)
        self.afterSelectApp?(self.appModel?.name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appModel = appModel {
            imageView?.image = appModel.icon
            imageView?.imageScaling = .scaleAxesIndependently
            label?.stringValue = appModel.name!
        }
    }
}


