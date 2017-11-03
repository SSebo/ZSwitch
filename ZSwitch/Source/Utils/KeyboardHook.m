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

static bool (^callback)(int, int);

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type,
                             CGEventRef event, void *refcon) {
    
    int64_t keycode = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
    
    if (callback((int)keycode, (int)type)) {
        return event;
    }
    return nil;

}

+ (void) start: (bool(^)(int, int)) block {
    callback = block;
    CFRunLoopSourceRef runLoopSource;
    CGEventMask mask = CGEventMaskBit(kCGEventKeyDown)|
                       CGEventMaskBit(kCGEventKeyUp) |
                       CGEventMaskBit(kCGEventFlagsChanged);
    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap,kCGHeadInsertEventTap,
                                              kCGEventTapOptionDefault, mask,
                                              myCGEventCallback, NULL);
    
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
