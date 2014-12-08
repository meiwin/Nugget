//
//  NugStack.h
//  Nugget
//
//  Created by Meiwin Fu on 8/12/14.
//  Copyright (c) 2014 Nugget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NugStack : NSObject <NSFastEnumeration, NSCoding>
@property (nonatomic, readonly) NSUInteger count;
- (id)initWithArray:(NSArray *)array;
- (void)pushObject:(id)object;
- (id)popObject;
- (id)peekObject;
- (void)removeAllObjects;
@end
