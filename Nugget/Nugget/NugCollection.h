//
//  NugCollection.h
//  Nugget
//
//  Created by Meiwin Fu on 25/11/14.
//  Copyright (c) 2014 Nugget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NugCollection : NSObject
{
  NSMutableArray * _sectionArray;
  NSMutableArray * _dataArray;
}

// Creating instance
+ (instancetype) createCollection;

// Accessing data
- (NSUInteger) numberOfSections;
- (NSUInteger) numberOfRowsInSection:(NSUInteger)section;
- (NSUInteger) numberOfRows;
- (id) objectForSectionAtIndex:(NSUInteger)section;
- (id) objectForRowAtIndexPath:(NSIndexPath *)ip;
- (NSIndexPath *) indexPathForRow:(id)object;
- (NSUInteger) indexForSection:(id)sectionObject;
- (BOOL) isEmpty;
- (NSArray *)allSectionObjects;
- (NSArray *)allRowObjectsAtIndex:(NSUInteger)index;

// Inserting data
- (NSUInteger)addSection:(id)sectionObject;
- (NSUInteger)insertSection:(id)sectionObject atIndex:(NSUInteger)sectionIndex;
- (NSIndexPath *)addRow:(id)object inSection:(NSUInteger)sectionIndex;
- (NSIndexPath *)insertRow:(id)object atIndexPath:(NSIndexPath *)indexPath;

// Deleting data
- (NSIndexPath *)removeRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)removeSectionAtIndex:(NSUInteger)sectionIndex;

// Enumerate
- (void)enumerateItems:(void(^)(NSUInteger, NSUInteger, id, BOOL*))block;
- (void)enumerateSections:(void(^)(NSUInteger, id, BOOL *))block;
- (void)addFromArray:(NSArray *)array;
- (void)addFromArray:(NSArray *)array inSection:(NSUInteger)sectionIndex;
@end