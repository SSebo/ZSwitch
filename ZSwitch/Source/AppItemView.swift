//
//  CollectionViewItem.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class AppItemView: NSViewController {

    @IBOutlet weak var label: TextField!
    @IBOutlet weak var imageView: NSImageView!
    var appModel: AppModel?
    var activeSign: NSView?
    var afterSelectApp: ((AppModel?) -> Void)?
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
                activeSign = createActiveSign()
                self.view.addSubview(activeSign!)
            } else {
                self.activeSign?.removeFromSuperview()
                label?.textColor = NSColor(red:0.45, green:0.45, blue:0.45, alpha:0.8)
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
            DispatchQueue.main.async {
                self.view.frame = NSRect(x:0, y: 0, width: self.self._size, height: self._size + 30)
                self.imageView.setFrameSize(NSSize(width: self._size, height: self._size))
                self.imageView.imageScaling = .scaleAxesIndependently
                self.label.frame = NSRect(x: 0, y: Int(self.imageView.frame.minY - 34) , width: self._size, height: 30)
            }
        }
    }

    override func mouseDown(with theEvent: NSEvent) {
        appModel?.runningApp?.activate(options: .activateIgnoringOtherApps)
        NSWorkspace.shared.launchApplication((self.appModel?.name)!)
        NSApp.windows[1].orderOut(nil)
        self.afterSelectApp?(self.appModel)
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


