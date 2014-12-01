//
//  WeakProxy.m
//  Pie
//
//  Created by Meiwin Fu on 7/11/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import "NugWeakProxy.h"
#import "NugWeakProxySubclass.h"

@interface NugWeakProxy ()
{
  __weak id _target;
}
@end

@implementation NugWeakProxy

- (void)setTarget:(id)target
{
  _target = target;
}

+ (instancetype)proxyWithTarget:(id)target
{
  NugWeakProxy * proxy = [[self alloc] init];
  proxy.target = target;
  return proxy;
}

- (id)safeTarget
{
  __strong id strongTarget = _target;
  return strongTarget;
}

- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[NugWeakProxy class]])
  {
    return ((NugWeakProxy *)object).safeTarget == self.safeTarget || object == self.safeTarget;
  }
  return NO;
}
@end
