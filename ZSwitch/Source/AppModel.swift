//
//  AppIconName.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class AppModel {
    init(icon: NSImage?, name: String?, pid: pid_t?) {
        self.icon = icon
        self.name = name
        self.pid = pid
    }

    var icon: NSImage?
    var name: String?
    var width: Double?
    var pid: pid_t?
}
