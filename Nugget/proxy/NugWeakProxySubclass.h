//
//  WeakProxySubclass.h
//  Pie
//
//  Created by Meiwin Fu on 7/11/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import "NugWeakProxy.h"

#ifndef Nugget_NugProxySubclass_h
#define Nugget_NugProxySubclass_h

@interface NugWeakProxy (Subclass)
- (void)setTarget:(id)target;
@end

#endif
