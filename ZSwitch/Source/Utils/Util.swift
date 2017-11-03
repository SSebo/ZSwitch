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
let leftRightMinMargin = 10
var leftRightActualMargin = 10
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
    let x = Int(leftRightActualMargin + index * (itemActualSize + gapWidth))
    let y = Int((screenRect?.height)!)/2 -  2 * itemActualSize / 3
    appItem.view.frame = NSRect(x: x, y:y , width: Int(itemActualSize), height: itemActualSize + 30)
    return appItem
}

func createInputLabel() -> NSTextField {
    let label = NSTextField()
    let width = 200
    label.frame = NSRect(x: (Int((screenRect?.width)!) - width) / 2 , y: Int((screenRect?.height)!/2) + 50, width: width, height: 18)
    label.textColor = NSColor(red:0.85, green:0.85, blue:0.85, alpha:1.00)
    label.isBezeled = false
    label.drawsBackground = false
    label.isEditable = false
    label.isSelectable = false
    label.alignment = .center
    label.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize(for: label.controlSize))
    return label
}

func reCalculateSize(count: Int) {
    let totalUsedWidth = (count - 1) * gapWidth + count * itemExpectSize
    if totalUsedWidth <= Int((screenRect?.width)!) + 2 * (leftRightMinMargin) {
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


