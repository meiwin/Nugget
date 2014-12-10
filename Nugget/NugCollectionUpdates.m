//
//  NugCollectionUpdates.m
//  Nugget
//
//  Created by Meiwin Fu on 25/11/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import "NugCollectionUpdates.h"

#pragma mark -
@implementation NugCollectionUpdatesSectionMove
- (void)setFrom:(NSUInteger)from { _from = from; }
- (void)setTo:(NSUInteger)to { _to = to; }
+ (instancetype)moveFrom:(NSUInteger)from to:(NSUInteger)to
{
  NugCollectionUpdatesSectionMove * o = [NugCollectionUpdatesSectionMove new];
  o.from = from;
  o.to = to;
  return o;
}
- (NSUInteger)hash
{
  return [[NSString stringWithFormat:@"%ld-%ld", _from, _to] hash];
}
- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[NugCollectionUpdatesSectionMove class]])
  {
    NugCollectionUpdatesSectionMove * m = (NugCollectionUpdatesSectionMove *)object;
    return m.from == self.from && m.to == self.to;
  }
  return NO;
}
@end

#pragma mark -
@implementation NugCollectionUpdatesRowMove
- (void)setFrom:(NSIndexPath *)from { _from = from; }
- (void)setTo:(NSIndexPath *)to { _to = to; }
+ (instancetype)moveFrom:(NSIndexPath *)from to:(NSIndexPath *)to
{
  NugCollectionUpdatesRowMove * o = [NugCollectionUpdatesRowMove new];
  o.from = from;
  o.to = to;
  return o;
}
- (NSUInteger)hash
{
  return [[NSString stringWithFormat:@"%@-%@", _from, _to] hash];
}
- (BOOL)isEqual:(id)object
{
  if ([object isKindOfClass:[NugCollectionUpdatesRowMove class]])
  {
    NugCollectionUpdatesRowMove * m = (NugCollectionUpdatesRowMove *)object;
    return [m.from isEqual:_from] && [m.to isEqual:_to];
  }
  return NO;
}
@end

#pragma mark -
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
- (void)setSectionMoves:(NSArray *)sectionMoves
{
  _sectionMoves = sectionMoves;
}
- (void)setRowMoves:(NSArray *)rowMoves
{
  _rowMoves = rowMoves;
}
+ (NugCollection *)simulate:(NugCollection *)from
                         to:(NugCollection *)to
                    updates:(NugCollectionUpdates *)updates
{
  // calculate moves
  NugCollection * sim = [from copy];
  
  // apply section deletes
  if (updates.indexSetForDeletedSections.count > 0)
  {
    [updates.indexSetForDeletedSections enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
      [sim removeSectionAtIndex:idx];
    }];
  }
  
  // apply row deletes
  if (updates.indexPathsForDeletedRows.count > 0)
  {
    NSArray * reversed = [updates.indexPathsForDeletedRows sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath * ip1, NSIndexPath * ip2) {
      return [ip2 compare:ip1];
    }];
    [reversed enumerateObjectsUsingBlock:^(NSIndexPath * ip, NSUInteger idx, BOOL *stop) {
      [sim removeRowAtIndexPath:ip];
    }];
  }
  
  // apply section inserts
  if (updates.indexSetForInsertedSections)
  {
    [updates.indexSetForInsertedSections enumerateIndexesWithOptions:0 usingBlock:^(NSUInteger idx, BOOL *stop) {
      [sim insertSection:[to objectForSectionAtIndex:idx] atIndex:idx];
      [sim addFromArray:[to allRowObjectsAtIndex:idx] inSection:idx];
    }];
  }
  
  // apply row inserts
  if (updates.indexPathsForInsertedRows)
  {
    [updates.indexPathsForInsertedRows enumerateObjectsUsingBlock:^(NSIndexPath * ip, NSUInteger idx, BOOL *stop) {
      [sim insertRow:[to objectForRowAtIndexPath:ip] atIndexPath:ip];
    }];
  }
  
  return sim;
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
                             from:(NugCollection *)from
                               to:(NugCollection *)to
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

  // calculate moves
  
  BOOL hasChanges = NO;
  NugCollectionUpdates * updates = nil;
  
  if (indexPathsForDeletedRows.count > 0
      || indexSetForDeletedSections.count > 0
      || indexPathsForInsertedRows.count > 0
      || indexSetForInsertedSections.count > 0)
  {
    hasChanges = YES;
    updates = [[NugCollectionUpdates alloc] init];
    updates.indexPathsForDeletedRows = indexPathsForDeletedRows;
    updates.indexPathsForInsertedRows = indexPathsForInsertedRows;
    updates.indexSetForDeletedSections = indexSetForDeletedSections;
    updates.indexSetForInsertedSections = indexSetForInsertedSections;
  }
  else
  {
    updates = [self empty];
  }
  
  // apply the changes to `from` (simulation)
  NugCollection * sim = from;
  if (hasChanges)
  {
    sim = [self simulate:from to:to updates:updates];
  }
  
  // now calculate movements
  NSMutableArray * sectionMoves = [NSMutableArray array];
  NSMutableArray * rowMoves = [NSMutableArray array];
  for (NSInteger toSection = 0; toSection < to.numberOfSections; toSection++)
  {
    id sectionObj = [to objectForSectionAtIndex:toSection];
    NSInteger fromSection = [sim indexForSection:sectionObj];
    if (fromSection != toSection)
    {
      [sectionMoves addObject:[NugCollectionUpdatesSectionMove moveFrom:fromSection to:toSection]];
      [sim moveSectionFrom:fromSection to:toSection];
    }
  }
  
  for (NSInteger section = 0; section < to.numberOfSections; section++)
  {
    for (NSInteger row = 0; row < [to numberOfRowsInSection:section]; row++)
    {
      NSIndexPath * toIP = [NSIndexPath indexPathForRow:row inSection:section];
      id rowObject = [to objectForRowAtIndexPath:toIP];
      NSIndexPath * fromIP = [sim indexPathForRow:rowObject];
      if (![fromIP isEqual:toIP])
      {
        [rowMoves addObject:[NugCollectionUpdatesRowMove moveFrom:fromIP to:toIP]];
        [sim moveRowFrom:fromIP to:toIP];
      }
    }
  }
  if (sectionMoves.count > 0 || rowMoves.count > 0)
  {
    if (updates == [self empty]) updates = [[NugCollectionUpdates alloc] init];
    updates.sectionMoves = sectionMoves;
    updates.rowMoves = rowMoves;
  }
  
  return updates;
}
@end
