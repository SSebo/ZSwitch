//
//  NSEventModifierFlags+HotKey.swift
//  HotKey
//
//  Created by Sam Soffes on 7/21/17.
//  Copyright © 2017 Sam Soffes. All rights reserved.
//

import AppKit
import Carbon

extension NSEvent.ModifierFlags {
	public var carbonFlags: UInt32 {
		var carbonFlags: UInt32 = 0

		if contains(NSEvent.ModifierFlags.command) {
			carbonFlags |= UInt32(cmdKey)
		}

		if contains(NSEvent.ModifierFlags.option) {
			carbonFlags |= UInt32(optionKey)
		}

		if contains(NSEvent.ModifierFlags.control) {
			carbonFlags |= UInt32(controlKey)
		}

		if contains(NSEvent.ModifierFlags.shift) {
			carbonFlags |= UInt32(shiftKey)
		}

		return carbonFlags
	}

	public init(carbonFlags: UInt32) {
		self.init()

		if carbonFlags & UInt32(cmdKey) == UInt32(cmdKey) {
			insert(NSEvent.ModifierFlags.command)
		}

		if carbonFlags & UInt32(optionKey) == UInt32(optionKey) {
			insert(NSEvent.ModifierFlags.option)
		}

		if carbonFlags & UInt32(controlKey) == UInt32(controlKey) {
			insert(NSEvent.ModifierFlags.control)
		}

		if carbonFlags & UInt32(shiftKey) == UInt32(shiftKey) {
			insert(NSEvent.ModifierFlags.shift)
		}
	}
}
