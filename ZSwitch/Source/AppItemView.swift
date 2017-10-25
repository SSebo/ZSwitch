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

    override func mouseDown(with theEvent: NSEvent) {
        NSLog("mouseDown on \(self.label.stringValue)")
        NSWorkspace.shared.launchApplication(self.label.stringValue)
        NSApp.windows[0].orderOut(nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.wantsLayer = true
//        view.layer?.backgroundColor = NSColor.init(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0).cgColor
        
        if let appModel = appModel {
            imageView?.image = appModel.icon
            imageView?.imageScaling = .scaleAxesIndependently
            if let name = appModel.name {
                label?.stringValue = name
            }
        } else {
            imageView?.image = nil
            label?.stringValue = ""
        }
        
    }
    
}

