//
//  Utril.swift
//  ZSwitch
//
//  Created by zhangshibo on 11/3/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

import Foundation

var itemExpectSize = 90
var itemActualSize = 90
let screenRect = NSScreen.main?.frame
let gapWidth = 4
let leftRightMinMargin = 50
var leftRightActualMargin = 50
let KeyDown = 10
let KeyUp = 11
let ModifiersChange = 12
let activeSignSize = 6

func createBackView() -> BackView {
    let backViewWidth = Int((screenRect?.width)!) - (2 * leftRightActualMargin) + 30
    let frame = NSRect(x: leftRightActualMargin - 20, y: Int((screenRect?.height)!/2 - 64), width: backViewWidth, height: 130)
    let backView = BackView()
    backView.frame = frame
    backView.wantsLayer = true
    backView.layer?.zPosition = -1
    backView.layer?.cornerRadius = 20
    backView.layer?.backgroundColor = NSColor(red:0.20, green:0.20, blue:0.20, alpha:1.00).cgColor
    return backView
}

func getSingletonCircleCounter(counter: JWGCircleCounter?, left: Int) -> JWGCircleCounter {
    let x = Int((screenRect?.width)!/2) - 16 - left
    let y = Int((screenRect?.height)!/2 + 54)
    let rect = NSRect(x:x, y:y, width: 10, height: 10)
    var c:JWGCircleCounter? = counter
    if (counter == nil) {
        c = JWGCircleCounter.init(frame: rect)
        c?.circleTimerWidth = 1.3
        c?.circleBackgroundColor = NSColor.clear
        c?.circleColor = NSColor(red:0.16, green:0.97, blue:0.18, alpha:1.00)
    } else {
        c?.stop() // otherwise will start lots of timer, comsume high cpu
        c?.reset()
        c?.setFrameOrigin(NSPoint(x: x, y: y))
    }
    c?.layer?.zPosition = 100
    
    return c!
}

func createActiveSign() -> NSView {
    let x = itemActualSize/2 - 3
    let y = itemActualSize + 28
    let activeSign = NSView()
    let frame = NSRect(x: x, y: y, width: activeSignSize, height: activeSignSize)
    activeSign.wantsLayer = true
    activeSign.frame = frame
    activeSign.layer?.cornerRadius = 3
    activeSign.layer?.backgroundColor = NSColor(red:0.16, green:0.97, blue:0.18, alpha:1.00).cgColor
    return activeSign
}

var totalAppItemViews: [AppItemView] = []

func createAppItem(appModel: AppModel, index: Int) -> AppItemView {
    var appItem = totalAppItemViews.first {$0.appModel?.name! == appModel.name}
    if appItem == nil {
        appItem = AppItemView()
        appItem?.appModel = appModel
        totalAppItemViews.append(appItem!)
    }
    appItem?.appModel = appModel
    appItem?.size = itemActualSize
    DispatchQueue.main.async {
        appItem?.view.frame = getAppItemFrame(index: index)
    }
    return appItem!
}

func getAppItemFrame(index: Int) -> NSRect {
    //    NSLog("index \(index) size: \(itemActualSize)")
    let x = Int(leftRightActualMargin + index * (itemActualSize + gapWidth))
    let y = Int((screenRect?.height)!)/2 -  3 * itemActualSize / 4
    return NSRect(x: x, y:y , width: Int(itemActualSize), height: itemActualSize + 34)
}

func getInputLabel(label: NSTextField?) -> NSTextField {
    let l: NSTextField
    if label != nil {
        l = label!
        l.stringValue = ""
    } else {
        l = NSTextField()
        l.textColor = NSColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)
        l.isBezeled = false
        l.drawsBackground = false
        l.isEditable = false
        l.isSelectable = false
        l.alignment = .center
        l.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize(for: l.controlSize))
    }
    let width = 400
    l.frame = NSRect(x: (Int((screenRect?.width)!) - width) / 2 , y: Int((screenRect?.height)!/2) + 50, width: width, height: 18)
    l.layer?.zPosition = 100
    
    return l
}

func reCalculateSize(count: Int) {
    let totalUsedWidth = (count - 1) * gapWidth + count * itemExpectSize
    if totalUsedWidth <= Int((screenRect?.width)!) - 2 * (leftRightMinMargin) {
        itemActualSize = itemExpectSize
        leftRightActualMargin = (Int((screenRect?.width)!) - totalUsedWidth) / 2
        if leftRightActualMargin < leftRightMinMargin {
            leftRightActualMargin = leftRightMinMargin
        }
    } else {
        leftRightActualMargin = leftRightMinMargin
        let totalGapWidth = (count - 1) * gapWidth
        itemActualSize = (Int((screenRect?.width)!) - totalGapWidth - 2 * leftRightMinMargin) / count
    }
}

func terminateApp(pid: pid_t) {
    let runingApp = NSWorkspace.shared.runningApplications.first(where: {$0.processIdentifier == pid})
    let res = runingApp?.forceTerminate()
    if !res! {
        NSLog("Failed to terminate \(runingApp?.localizedName ?? "")")
    }
}

func getNotRunningApps(runnings: [AppModel], norunnings: [AppModel]) -> [AppModel] {
    var apps:[AppModel] = norunnings
    
    let dirPaths = NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                       [.localDomainMask], true)
    let fileManager = FileManager.default
    for path in dirPaths {
        do {
            let filenames = try fileManager.contentsOfDirectory(atPath: path)
            
            for name in filenames {
                if !name.hasSuffix("app") {
                    continue
                }
                if name == "ZSwitch.app" {
                    continue
                }
                if runnings.first(where: {$0.name! + ".app" == name}) != nil {
                    continue
                }
                if norunnings.first(where: {$0.name! + ".app" == name}) != nil {
                    continue
                }
                
                let tmpPath = NSString.init(string: path).strings(byAppendingPaths: [name]).first!
                let contentsPath = tmpPath + "/Contents"
                let plist = NSDictionary.init(contentsOfFile: contentsPath + "/Info.plist")
                var iconName = plist?.object(forKey: "CFBundleIconFile") as? String ?? ""
                if iconName == "" {
//                    NSLog("\(contentsPath) icon name missing")
                } else {
                    if !iconName.hasSuffix("icns") {
                        iconName += ".icns"
                    }
                    let iconPath = contentsPath + "/Resources/" + String(describing: iconName)
                    let image = NSImage.init(byReferencingFile: iconPath)
//                    NSLog(iconPath)
//                    NSLog("icon \(image)")
                    let n = name[..<name.index(name.endIndex, offsetBy: -4)]
                    let app = AppModel(name: String(n), icon: image!)
                    apps.append(app)
                }
            }
        } catch {}
    }
    
    return apps
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}

class BackView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
}

class TextField: NSTextField {
    override var usesSingleLineMode: Bool {
        set {}
        get { return false }
    }
    
    override var lineBreakMode: NSParagraphStyle.LineBreakMode {
        set {}
        get { return .byWordWrapping }
    }
    
    override var frame: NSRect {
        didSet {
            //            NSLog("\(stringValue) \(stringValue.count) \(frame.width) \(bounds.width)")
            if stringValue.count * 7 > Int(frame.width) {
                self.cell?.font = NSFont.systemFont(ofSize: 10)
            }
        }
    }
}

