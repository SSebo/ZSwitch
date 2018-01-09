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
    var controller: ViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSMakeRect(0, 10, (screenRect?.width)!, (screenRect?.height)!),
                          styleMask: .borderless, backing: NSWindow.BackingStoreType.buffered, defer: false)
        window?.collectionBehavior = .moveToActiveSpace
        window?.backgroundColor = NSColor.clear
        window?.isOpaque = false
        window?.ignoresMouseEvents = false
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidChangeResolution),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        
        acquirePrivilegesAndStart()
//        LocationManager().getCurrentlocation()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func startup() {
        controller = ViewController()
        DispatchQueue.global().async {
            KeyboardHook.start(self.controller?.interceptKeyChange)
        }
        let content = window!.contentView! as NSView
        let view = controller!.view
        content.addSubview(view)
    }

    func acquirePrivilegesAndStart() -> Void {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [trusted: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(privOptions)
        if accessEnabled != true {
            let alert = NSAlert()
            alert.messageText = "Enable ZSwitch"
            alert.informativeText = """
            
            Open System Preferences > Security & Privicy > Accessibility (left panel)
            
            Drag ZSwitch to right panel and checked,
            
            then restart app.
            """
            alert.beginSheetModal(for: self.window!, completionHandler: { response in
                if AXIsProcessTrustedWithOptions(privOptions) == true {
                    self.startup()
                } else {
                    NSApp.terminate(self)
                }
            })
        } else {
            self.startup()
        }
    }
    
    @objc func appDidChangeResolution(notification: NSNotification) {
        self.window?.setFrame((NSScreen.main?.frame)!, display: true)
    }

}


