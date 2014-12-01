//
//  Event.h
//  Pie
//
//  Created by Meiwin Fu on 1/12/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint32_t, NugEventThread) {
  NugEventThreadCurrent = 0,
  NugEventThreadMain,
  NugEventThreadBackground,
  NugEventThreadUserDefined
};

/**
 *
 * High level API for publishing/subscribing notification.
 * It uses NSNotificationCenter and NSNotificationQueue internally.
 * - `publish` will post notification immediately using NSNotificationCenter
 * - `publishEventually` will post notification asynchronously using `NSPostASAP` with coalescing.
 *   IMPORTANT: please take note that if thread where a notification was published terminates before notification is sent, it will not be posted.
 *
 * For subscription, caller will be able to specify target thread in which method will be invoked.
 * - NugEventThreadCurrent, invoked in the same thread as thread from which notification was published.
 * - NugEventThreadMain, invoked in main thread.
 * - NugEventThreadBackground, invoked in default built-in background thread.
 * - NugEventThreadUserDefined, invoked in user-defined named background thread.
 *
 */
@interface NugEvent : NSObject

+ (instancetype)defaultEvent;

- (void)publish:(NSString *)name sender:(id)sender userInfo:(id)userInfo;
- (void)publishEventually:(NSString *)name sender:(id)sender userInfo:(id)userInfo;

- (void)subscribe:(NSString *)name object:(id)object target:(id)target selector:(SEL)selector;
- (void)subscribe:(NSString *)name object:(id)object target:(id)target selector:(SEL)selector thread:(NugEventThread)thread;
- (void)subscribe:(NSString *)name object:(id)object target:(id)target selector:(SEL)selector threadName:(NSString *)threadName;
- (void)unsubscribe:(id)target;

@end
