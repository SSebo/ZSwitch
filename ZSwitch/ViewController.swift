//
//  ViewController.swift
//  ZSwitch
//
//  Created by zhangshibo on 8/17/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    var appModels:[AppModel] = []

    override func loadView() {
        let view = NSView(frame: NSMakeRect(0,0,100,100))
        view.wantsLayer = true
        view.layer?.borderWidth = 2
        view.layer?.borderColor = NSColor.red.cgColor
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ws = NSWorkspace.shared
        for app in ws.runningApplications {
            if (app.activationPolicy == .regular) {
                self.appModels.append(AppModel(icon: app.icon, name: app.localizedName))
            }
        }

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

