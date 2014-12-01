//
//  WeakProxy.h
//  Pie
//
//  Created by Meiwin Fu on 7/11/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NugWeakProxy : NSObject
@property (nonatomic, readonly) id safeTarget;
+ (instancetype)proxyWithTarget:(id)target;
@end
