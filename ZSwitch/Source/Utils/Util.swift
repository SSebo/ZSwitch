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
        c?.setFrameOrigin(NSPoint(x: x, y: y))
    }
    c?.layer?.zPosition = 100
    
    return c!
}

func createActiveSign() -> NSView {
    let x = itemActualSize/2 - 3
    let y = itemActualSize + 22
    let activeSign = NSView()
    let frame = NSRect(x: x, y: y, width: activeSignSize, height: activeSignSize)
    activeSign.wantsLayer = true
    activeSign.frame = frame
    activeSign.layer?.cornerRadius = 3
    activeSign.layer?.backgroundColor = NSColor(red:0.16, green:0.97, blue:0.18, alpha:1.00).cgColor
    return activeSign
}

func createAppItem(appModel: AppModel, index: Int) -> AppItemView {
    let appItem = AppItemView()
    appItem.appModel = appModel
    appItem.size = itemActualSize
    appItem.view.frame = getAppItemFrame(index: index)
    return appItem
}

func getAppItemFrame(index: Int) -> NSRect {
    let x = Int(leftRightActualMargin + index * (itemActualSize + gapWidth))
    let y = Int((screenRect?.height)!)/2 -  2 * itemActualSize / 3
    return NSRect(x: x, y:y , width: Int(itemActualSize), height: itemActualSize + 30)
}

func getInputLabel(label: NSTextField?) -> NSTextField {
    let l: NSTextField
    if label != nil {
        l = label!
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
    runingApp?.forceTerminate()
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


