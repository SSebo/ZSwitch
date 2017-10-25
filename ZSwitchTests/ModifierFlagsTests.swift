//
//  ModifierFlagsTests.swift
//  HotKey
//
//  Created by Sam Soffes on 7/21/17.
//  Copyright © 2017 Sam Soffes. All rights reserved.
//

import XCTest
import AppKit
import Carbon

final class ModiferFlagsTests: XCTestCase {
    func testCarbonToCocoaConversion() {
        var cocoa = NSEvent.ModifierFlags()
        cocoa.insert(NSEvent.ModifierFlags.command)
        XCTAssertEqual(NSEvent.ModifierFlags(carbonFlags: UInt32(cmdKey)), cocoa)

        cocoa.insert(NSEvent.ModifierFlags.control)
        cocoa.insert(NSEvent.ModifierFlags.option)
        XCTAssertEqual(NSEvent.ModifierFlags(carbonFlags: UInt32(cmdKey|controlKey|optionKey)), cocoa)
    }

    func testCocoaToCarbonConversion() {
        var cocoa = NSEvent.ModifierFlags()
        cocoa.insert(NSEvent.ModifierFlags.command)
        XCTAssertEqual(UInt32(cmdKey), cocoa.carbonFlags)

        cocoa.insert(NSEvent.ModifierFlags.control)
        cocoa.insert(NSEvent.ModifierFlags.option)
        XCTAssertEqual(UInt32(cmdKey|controlKey|optionKey), cocoa.carbonFlags)
    }
}

