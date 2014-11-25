//
//  NugCollectionUpdates.m
//  Nugget
//
//  Created by Meiwin Fu on 25/11/14.
//  Copyright (c) 2014 Nugget. All rights reserved.
//

#import "NugCollectionUpdates.h"

@interface NugCollectionUpdates ()
{
  NSArray * _indexPathsForInsertedRows;
  NSArray * _indexPathsForDeletedRows;
  NSIndexSet * _indexSetForInsertedSections;
  NSIndexSet * _indexSetForDeletedSections;
}
- (void)setIndexPathsForInsertedRows:(NSArray *)ips;
- (void)setIndexPathsForDeletedRows:(NSArray *)ips;
- (void)setIndexSetForInsertedSections:(NSIndexSet *)set;
- (void)setIndexSetForDeletedSections:(NSIndexSet *)set;
@end

@implementation NugCollectionUpdates

#pragma mark Private Methods
- (NSArray *)indexPathsForDeletedRows
{
  return _indexPathsForDeletedRows;
}
- (void)setIndexPathsForDeletedRows:(NSArray *)ips
{
  _indexPathsForDeletedRows = ips;
}
- (NSArray *)indexPathsForInsertedRows
{
  return _indexPathsForInsertedRows;
}
- (void)setIndexPathsForInsertedRows:(NSArray *)ips
{
  _indexPathsForInsertedRows = ips;
}
- (NSIndexSet *)indexSetForDeletedSections
{
  return _indexSetForDeletedSections;
}
- (void)setIndexSetForDeletedSections:(NSIndexSet *)set
{
  _indexSetForDeletedSections = set;
}
- (NSIndexSet *)indexSetForInsertedSections
{
  return _indexSetForInsertedSections;
}
- (void)setIndexSetForInsertedSections:(NSIndexSet *)set
{
  _indexSetForInsertedSections = set;
}

#pragma mark Public Methods
+ (NugCollectionUpdates *)empty
{
  static NugCollectionUpdates * _empty = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _empty = [[NugCollectionUpdates alloc] init];
  });
  return _empty;
}
+ (NugCollectionUpdates *)updates:(NugCollectionUpdatesOption)options
                             from:(id)from
                               to:(id)to
{
  
  // compute deleted sections
  NSMutableIndexSet * indexSetForDeletedSections = [NSMutableIndexSet indexSet];
  NSSet * toSectionsSet = [NSSet setWithArray:[to allSectionObjects]];
  for (NSInteger i = ([from numberOfSections]-1); i >= 0; i--)
  {
    id section = [from objectForSectionAtIndex:i];
    if (![toSectionsSet containsObject:section])
    {
      [indexSetForDeletedSections addIndex:i];
    }
  }

  // compute deleted rows
  NSMutableArray * indexPathsForDeletedRows = [NSMutableArray array];
  [to enumerateSections:^(NSUInteger toSection, id section, BOOL * stop) {
    NSInteger fromSection = [from indexForSection:section];
    if (fromSection == NSNotFound) return;
    
    NSSet * toRowsSet = [NSSet setWithArray:[to allRowObjectsAtIndex:toSection]];
    for (NSInteger i = [from numberOfRowsInSection:fromSection]-1; i >= 0; i--)
    {
      NSIndexPath * ip = [NSIndexPath indexPathForRow:i inSection:fromSection];
      id row = [from objectForRowAtIndexPath:ip];
      if (![toRowsSet containsObject:row])
      {
        [indexPathsForDeletedRows addObject:ip];
      }
    }
  }];
  
  // compute inserted sections and rows
  NSMutableIndexSet * indexSetForInsertedSections = [NSMutableIndexSet indexSet];
  NSMutableArray * indexPathsForInsertedRows = [NSMutableArray array];
  [to enumerateSections:^(NSUInteger toSection, id section, BOOL * stop) {
    NSInteger fromSection = [from indexForSection:section];
    if (fromSection == NSNotFound) // new section
    {
      [indexSetForInsertedSections addIndex:toSection];
    }
    else // existing section
    {
      NSSet * fromRowsSet = [NSSet setWithArray:[from allRowObjectsAtIndex:fromSection]];
      for (int i = 0; i < [to numberOfRowsInSection:toSection]; i++)
      {
        NSIndexPath * ip = [NSIndexPath indexPathForRow:i inSection:toSection];
        id row = [to objectForRowAtIndexPath:ip];
        if (![fromRowsSet containsObject:row])
        {
          [indexPathsForInsertedRows addObject:ip];
        }
      }
    }
  }];

  if (indexPathsForDeletedRows.count > 0
      || indexSetForDeletedSections.count > 0
      || indexPathsForInsertedRows.count > 0
      || indexSetForInsertedSections.count > 0)
  {
    NugCollectionUpdates * updates = [[NugCollectionUpdates alloc] init];
    updates.indexPathsForDeletedRows = indexPathsForDeletedRows;
    updates.indexPathsForInsertedRows = indexPathsForInsertedRows;
    updates.indexSetForDeletedSections = indexSetForDeletedSections;
    updates.indexSetForInsertedSections = indexSetForInsertedSections;
    return updates;
  }
  return [self empty];
}
@end
