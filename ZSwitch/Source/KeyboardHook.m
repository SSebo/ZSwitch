//
//  KeyboardHook.m
//  ZSwitch
//
//  Created by zhangshibo on 10/27/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

#import "KeyboardHook.h"

@interface KeyboardHook ()

@end

@implementation KeyboardHook

BOOL isCommandPressed = NO;

struct keyEvent {
    int64_t keycode;
    CGEventType type;
} KeyEvent;

//typedef void (^keyEventCallback)(int, int);

static void (^callback)(int, int);

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    int64_t keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    
//    if (type == kCGEventKeyUp) {
//        NSLog(@"key up %lld", keycode);
//    } else if (type == kCGEventKeyDown) {
//        NSLog(@"key down %lld", keycode);
//    } else if (type == kCGEventFlagsChanged){
//        NSLog(@"flag change %lld", keycode);
//    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"keychange"
//                                                        object: [NSString stringWithFormat:@"%lld %u", keycode, type]];
    callback((int)keycode, (int)type);
    if (keycode == 55) { // intercept macOS default behavior
        isCommandPressed = !isCommandPressed;
        NSLog(@"command pressed: %hhd", isCommandPressed);
    }
    
    // 48 is tab, 12 is q
    if (keycode == 48 && isCommandPressed) {
        return nil;
    }
    if (keycode == 12 && isCommandPressed && NSApp.active) {
        return nil;
    }
    
    return event;
}

+ (void) start: (void(^)(int, int)) block {
    callback = block;
    CFRunLoopSourceRef runLoopSource;
    CGEventMask mask = CGEventMaskBit(kCGEventKeyDown) | CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged);
    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault,                                                                                         mask, myCGEventCallback, NULL);
    
    if (!eventTap) {
        NSLog(@"Couldn't create event tap!");
    }
    
    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    CFRunLoopRun();
    
    CFRelease(eventTap);
    CFRelease(runLoopSource);
    
}

@end
