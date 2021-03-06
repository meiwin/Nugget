//
//  NugCollection.m
//  Nugget
//
//  Created by Meiwin Fu on 25/11/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import "NugCollection.h"

@interface NugCollection ()
- (NSArray *) dataArray;
- (NSArray *) sectionArray;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@implementation NugCollection

+ (instancetype)createCollection
{
  NugCollection * col = [[NugCollection alloc] init];
  return col;
}
// Private Mehos
- (NSMutableArray *) $section:(NSUInteger)section;
{
  return (NSMutableArray *) [_dataArray objectAtIndex:section];
}

// Init
- (id)init {
  self = [super init];
  if (self) {
    _sectionArray = [[NSMutableArray alloc] init];
    _dataArray = [[NSMutableArray alloc] init];
  }
  return self;
}
- (NSString *)description
{
  NSMutableString * str = [NSMutableString string];
  [_sectionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger section, BOOL *stop) {
    [str appendString:[NSString stringWithFormat:@"(%@)\n", obj]];
    [_dataArray[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger row, BOOL *stop) {
      [str appendString:[NSString stringWithFormat:@"  (%@)\n", _dataArray[section][row]]];
    }];
  }];
  return str;
}
// Accessing data
- (NSUInteger) numberOfSections;
{
  return [_dataArray count];
}
- (NSUInteger) numberOfRowsInSection:(NSUInteger)section;
{
  return [self $section:section].count;
}
- (NSUInteger) numberOfRows;
{
  return [self numberOfRowsInSection:0];
}
- (id) objectForSectionAtIndex:(NSUInteger)section;
{
  return [_sectionArray objectAtIndex:section];
}
- (id)objectForRowAtIndexPath:(NSIndexPath *)ip;
{
  id object = nil;
  if (ip) {
    object = [[self $section:ip.section] objectAtIndex:ip.row];
  }
  return object;
}
- (NSIndexPath *) indexPathForRow:(id)object;
{
  NSUInteger section = 0;
  NSUInteger idx = NSNotFound;
  if (object) {
    for (NSArray * arr in [_dataArray copy]) {
      idx = [arr indexOfObject:object];
      if (idx != NSNotFound) break;
      section++;
    }
  }
  NSIndexPath * ip = nil;
  if (idx != NSNotFound) ip = [NSIndexPath indexPathForRow:idx inSection:section];
  return ip;
}
- (NSUInteger) indexForSection:(id)sectionObject;
{
  return [_sectionArray indexOfObject:sectionObject];
}
- (BOOL)isEmpty;
{
  for (NSArray * rows in [_dataArray copy]) {
    if ([rows count] > 0) return NO;
  }
  return YES;
}
- (NSArray *)allSectionObjects
{
  return _sectionArray;
}
- (NSArray *)allRowObjectsAtIndex:(NSUInteger)index
{
  return (NSArray *)_dataArray[index];
}

// Inserting data
- (NSUInteger)addSection:(id)sectionObject;
{
  NSUInteger section = NSNotFound;
  if (sectionObject) {
    [_sectionArray addObject:sectionObject];
    section = [_sectionArray count]-1;
    [_dataArray addObject:[[NSMutableArray alloc] init]];
  }
  return section;
}
- (NSUInteger)insertSection:(id)sectionObject atIndex:(NSUInteger)sectionIndex;
{
  NSUInteger section = NSNotFound;
  if (sectionObject) {
    [_sectionArray insertObject:sectionObject atIndex:sectionIndex];
    [_dataArray insertObject:[[NSMutableArray alloc] init] atIndex:sectionIndex];
    section = sectionIndex;
  }
  return section;
}
- (NSIndexPath *)addRow:(id)object inSection:(NSUInteger)sectionIndex;
{
  NSIndexPath * ip = nil;
  if (object) {
    NSMutableArray * arr = [self $section:sectionIndex];
    [arr addObject:object];
    ip = [NSIndexPath indexPathForRow:[arr count]-1 inSection:sectionIndex];
  }
  return ip;
}
- (NSIndexPath *)insertRow:(id)object atIndexPath:(NSIndexPath *)indexPath;
{
  NSIndexPath * ip = nil;
  if (object && indexPath) {
    NSMutableArray * arr = [self $section:indexPath.section];
    [arr insertObject:object atIndex:indexPath.row];
    ip = indexPath;
  }
  return ip;
}

// Deleting data
- (NSUInteger)removeSectionAtIndex:(NSUInteger)sectionIndex;
{
  NSUInteger section = NSNotFound;
  [_sectionArray removeObjectAtIndex:sectionIndex];
  [_dataArray removeObjectAtIndex:sectionIndex];
  section = sectionIndex;
  return section;
}
- (NSIndexPath *)removeRowAtIndexPath:(NSIndexPath *)indexPath;
{
  NSIndexPath * ip = nil;
  if (indexPath) {
    NSMutableArray * arr = [self $section:indexPath.section];
    [arr removeObjectAtIndex:indexPath.row];
    ip = indexPath;
  }
  return ip;
}

// Moving data
- (void)moveSectionFrom:(NSUInteger)from to:(NSUInteger)to
{
  id sectionData = _sectionArray[from];
  id rowData = _dataArray[from];
  
  [self removeSectionAtIndex:from];
  [self insertSection:sectionData atIndex:to];
  [self addFromArray:rowData inSection:to];
}
- (void)moveRowFrom:(NSIndexPath *)from to:(NSIndexPath *)to
{
  id tmpFrom = _dataArray[from.section][from.row];
  
  [self removeRowAtIndexPath:from];
  [self insertRow:tmpFrom atIndexPath:to];
}

// Update data
- (NSUInteger)updateSection:(id)object atIndex:(NSUInteger)section;
{
  NSUInteger s = NSNotFound;
  if (object) {
    [_sectionArray removeObjectAtIndex:section];
    [_sectionArray insertObject:object atIndex:section];
    s = section;
  }
  return s;
}
- (NSIndexPath *)updateRow:(id)object atIndexPath:(NSIndexPath *)indexPath;
{
  NSIndexPath * ip = nil;
  if (object && indexPath) {
    NSMutableArray * rows = [_dataArray objectAtIndex:indexPath.section];
    [rows removeObjectAtIndex:indexPath.row];
    [rows insertObject:object atIndex:indexPath.row];
    ip = indexPath;
  }
  return ip;
}

- (void)enumerateItems:(void(^)(NSUInteger section, NSUInteger row, id obj, BOOL* stop))block
{
  BOOL keepGoing = YES;
  NSUInteger section = 0;
  for (NSArray *rows in [_dataArray copy])
  {
    if (!keepGoing) break;
    
    NSUInteger row = 0;
    for (id obj in [rows copy])
    {
      if (!keepGoing) break;
      BOOL stop = NO;
      block(section, row, obj, &stop);
      keepGoing = !stop;
      row += 1;
    }
    section += 1;
  }
}
- (void)enumerateSections:(void (^)(NSUInteger, id, BOOL *))block
{
  BOOL keepGoing = YES;
  NSUInteger section = 0;
  for (id sectionItem in [_sectionArray copy])
  {
    if (!keepGoing) break;
    
    BOOL stop = NO;
    block(section, sectionItem, &stop);
    keepGoing = !stop;
    section += 1;
  }
}
- (void)addFromArray:(NSArray *)array
{
  [self addFromArray:array inSection:0];
}
- (void)addFromArray:(NSArray *)array inSection:(NSUInteger)sectionIndex
{
  NSMutableArray * arr = [self $section:sectionIndex];
  [arr addObjectsFromArray:array];
}
- (id)copy
{
  NugCollection * col = [NugCollection createCollection];
  col.sectionArray = self.sectionArray;
  col.dataArray = self.dataArray;
  return col;
}
#pragma mark Private Methods
// Private Methods
- (NSArray *) dataArray;
{
  return _dataArray;
}
- (void)setDataArray:(NSArray *)dataArray
{
  if (!dataArray) dataArray = @[];
  _dataArray = [NSMutableArray arrayWithArray:dataArray];
}
- (NSArray *) sectionArray;
{
  return _sectionArray;
}
- (void)setSectionArray:(NSArray *)sectionArray
{
  if (!sectionArray) sectionArray = @[];
  _sectionArray = [NSMutableArray arrayWithArray:sectionArray];
}
@end