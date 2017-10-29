//
//  KeyboardHook.h
//  ZSwitch
//
//  Created by zhangshibo on 10/27/17.
//  Copyright © 2017 zhangshibo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^keyEventCallback)(int, int);

@interface KeyboardHook : NSObject

+ (void) start: (bool(^)(int, int)) block;
@end
