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
        let _ = acquirePrivileges()
        KeyboardHook.start()
        
        let screenRect = NSScreen.main?.frame
        window = NSWindow(contentRect: NSMakeRect(0, 10, (screenRect?.width)!, (screenRect?.height)!), styleMask: .borderless, backing: NSWindow.BackingStoreType.buffered, defer: false)
        window?.backgroundColor = NSColor.clear
        window?.isOpaque = false
        window?.ignoresMouseEvents = false
        controller = ViewController()
        let content = window!.contentView! as NSView
        let view = controller!.view
        content.addSubview(view)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func acquirePrivileges() -> Bool {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [trusted: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(privOptions)
//        if accessEnabled != true {
//            let alert = NSAlert()
//            alert.messageText = "Enable Maxxxro"
//            alert.informativeText = "Once you have enabled Maxxxro in System Preferences, click OK."
//            alert.beginSheetModal(for: self.window!, completionHandler: { response in
//                if AXIsProcessTrustedWithOptions(privOptions) == true {
////                    self.startup()
//                } else {
//                    NSApp.terminate(self)
//                }
//            })
//        }
        return accessEnabled == true
    }

}

