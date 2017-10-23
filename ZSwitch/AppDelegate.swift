//
//  AppDelegate.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?
    var controller: NSViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let screenRect = NSScreen.main?.frame
        window = NSWindow(contentRect: NSMakeRect(0, 10, (screenRect?.width)!, (screenRect?.height)!), styleMask: .fullSizeContentView, backing: NSWindow.BackingStoreType.buffered, defer: false)
        window?.backgroundColor = NSColor.red
        controller = ViewController()
        let content = window!.contentView! as NSView
        let view = controller!.view
        content.addSubview(view)
        window!.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

