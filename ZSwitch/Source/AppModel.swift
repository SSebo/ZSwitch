//
//  AppIconName.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class AppModel {
    init(app: NSRunningApplication?) {
        self.app = app!
        self.icon = app?.icon
        self.name = app?.localizedName
        self.pid = app?.processIdentifier
    }

    var icon: NSImage?
    var name: String?
    var width: Double?
    var pid: pid_t?
    var app: NSRunningApplication
}
