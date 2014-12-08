//
//  NugStack.m
//  Nugget
//
//  Created by Meiwin Fu on 8/12/14.
//  Copyright (c) 2014 Nugget. All rights reserved.
//

#import "NugStack.h"

@interface NugStack ()
{
  NSMutableArray * _objects;
}
@end

@implementation NugStack
- (id)initWithArray:(NSArray *)array
{
  self = [super init];
  if (self)
  {
    _objects = [NSMutableArray arrayWithArray:array ?: @[]];
  }
  return self;
}
- (id)init
{
  self = [super init];
  if (self)
  {
    _objects = [NSMutableArray array];
  }
  return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
  NSArray * tmp = [aDecoder decodeObjectForKey:@"objects"];
  _objects = [NSMutableArray arrayWithArray:tmp ?: @[]];
  return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
  [aCoder encodeObject:_objects forKey:@"objects"];
}
- (NSUInteger)count
{
  return _objects.count;
}
- (void)pushObject:(id)object
{
  [_objects addObject:object];
}
- (id)popObject
{
  id obj = [_objects lastObject];
  if (obj)
  {
    [_objects removeLastObject];
  }
  return obj;
}
- (id)peekObject
{
  return [_objects lastObject];
}
- (void)removeAllObjects
{
  [_objects removeAllObjects];
}
#pragma mark NSFastEnumeration
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
  return [_objects countByEnumeratingWithState:state objects:buffer count:len];
}
@end
