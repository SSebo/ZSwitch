//
//  CollectionViewItem.swift
//  ZSwitch
//
//  Created by zhangshibo on 6/9/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Cocoa

class AppItemViewVC: NSViewController {

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    var appModel: AppModel?
    
//    override var nibName: String? {
//        get {
//            return "AppItemView"
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        
        if let appModel = appModel {
            imageView?.image = appModel.icon
            if let name = appModel.name {
                label?.stringValue = name
            }
        } else {
            imageView?.image = nil
            label?.stringValue = ""
        }
        
    }
    
}

