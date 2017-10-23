//
//  AppIconName.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class AppModel {
    init(icon: NSImage?, name: String?) {
        self.icon = icon
        self.name = name
    }

    var icon: NSImage?
    var name: String?
}
