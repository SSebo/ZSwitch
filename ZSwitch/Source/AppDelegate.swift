//
//  AppDelegate.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa
import FMDB

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?
    var controller: ViewController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(contentRect: NSMakeRect(0, 10, (screenRect?.width)!, (screenRect?.height)!), styleMask: .borderless, backing: NSWindow.BackingStoreType.buffered, defer: false)
        window?.collectionBehavior = .moveToActiveSpace
        window?.backgroundColor = NSColor.clear

        window?.isOpaque = false
        window?.ignoresMouseEvents = false
        
        acquirePrivilegesAndStart()
//        openDb()
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
            
            Open System Preferences > Security & Privicy > Accessibility (left panel) > Drag ZSwitch to right panel and checked,
            
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
    
    func openDb() {
        var fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("com.smart.zswitch")
        fileURL.appendPathComponent("switch_history.sqlite")
        
        let database = FMDatabase(url: fileURL)
        
        guard database.open() else {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("create table switch_history(x text, y text, z text)", values: nil)
            try database.executeUpdate("insert into switch_history (x, y, z) values (?, ?, ?)", values: ["a", "b", "c"])
            try database.executeUpdate("insert into switch_history (x, y, z) values (?, ?, ?)", values: ["e", "f", "g"])
            
            let rs = try database.executeQuery("select x, y, z from switch_history", values: nil)
            while rs.next() {
                if let x = rs.string(forColumn: "x"), let y = rs.string(forColumn: "y"), let z = rs.string(forColumn: "z") {
                    NSLog("x = \(x); y = \(y); z = \(z)")
                }
            }
        } catch {
            NSLog("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }

}


