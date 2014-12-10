//
//  NugCollectionUpdatesTests.m
//  Nugget
//
//  Created by Meiwin Fu on 25/11/14.
//  Copyright (c) 2014 Nugget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NugCollection.h"
#import "NugCollectionUpdates.h"

@interface NugCollectionUpdatesTests : XCTestCase
{
}
@end

@implementation NugCollectionUpdatesTests

- (void)setUp
{
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testShouldProduceEmptyResult
{
  
  int section = -1;
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];
  
  section++;
  [col1 addSection:@"section 1"];
  [col1 addRow:@"row11" inSection:section];

  [col2 addSection:@"section 1"];
  [col2 addRow:@"row11" inSection:section];
  
  section++;
  [col1 addSection:@"section 2"];
  [col1 addRow:@"row21" inSection:section];
  [col1 addRow:@"row22" inSection:section];
  
  [col2 addSection:@"section 2"];
  [col2 addRow:@"row21" inSection:section];
  [col2 addRow:@"row22" inSection:section];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];
  XCTAssert(updates == [NugCollectionUpdates empty], @"should product empty result");
}
- (void)testShouldProduceInsertedRows
{
  int section = -1;
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];
  
  section++;
  [col1 addSection:@"section 1"];
  [col1 addRow:@"row11" inSection:section];
  
  [col2 addSection:@"section 1"];
  [col2 addRow:@"row10" inSection:section];
  [col2 addRow:@"row11" inSection:section];
  
  section++;
  [col1 addSection:@"section 2"];
  [col1 addRow:@"row21" inSection:section];
  [col1 addRow:@"row22" inSection:section];
  
  [col2 addSection:@"section 2"];
  [col2 addRow:@"row21" inSection:section];
  [col2 addRow:@"row22" inSection:section];
  [col2 addRow:@"row23" inSection:section];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];
  NSSet * result = [NSSet setWithArray:updates.indexPathsForInsertedRows];
  NSSet * expected = [NSSet setWithArray:@[
                                           [NSIndexPath indexPathForRow:0 inSection:0],
                                           [NSIndexPath indexPathForRow:2 inSection:1],
                                           ]];
  XCTAssert([expected isEqual:result], @"should produce inserted rows");
}
- (void)testShouldProduceDeletedRows
{
  int section = -1;
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];
  
  section++;
  [col1 addSection:@"section 1"];
  [col1 addRow:@"row11" inSection:section];
  [col1 addRow:@"row12" inSection:section];
  
  [col2 addSection:@"section 1"];
  [col2 addRow:@"row11" inSection:section];
  
  section++;
  [col1 addSection:@"section 2"];
  [col1 addRow:@"row21" inSection:section];
  [col1 addRow:@"row22" inSection:section];
  [col1 addRow:@"row23" inSection:section];
  [col1 addRow:@"row24" inSection:section];
  
  [col2 addSection:@"section 2"];
  [col2 addRow:@"row21" inSection:section];
  [col2 addRow:@"row23" inSection:section];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];
  NSSet * result = [NSSet setWithArray:updates.indexPathsForDeletedRows];
  NSSet * expected = [NSSet setWithArray:@[
                                           [NSIndexPath indexPathForRow:1 inSection:0],
                                           [NSIndexPath indexPathForRow:3 inSection:1],
                                           [NSIndexPath indexPathForRow:1 inSection:1],
                                           ]];
  XCTAssert([expected isEqual:result], @"should produce deleted rows");
}
- (void)testShouldProduceInsertedAndDeletedRows
{
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];
  
  [col1 addSection:@""];
  [col1 addRow:@"Arizona" inSection:0];
  [col1 addRow:@"California" inSection:0];
  [col1 addRow:@"Delaware" inSection:0];
  [col1 addRow:@"New Jersey" inSection:0];
  [col1 addRow:@"Washington" inSection:0];
  
  [col2 addSection:@""];
  [col2 addRow:@"Alaska" inSection:0];
  [col2 addRow:@"Arizona" inSection:0];
  [col2 addRow:@"California" inSection:0];
  [col2 addRow:@"Georgia" inSection:0];
  [col2 addRow:@"New Jersey" inSection:0];
  [col2 addRow:@"Virginia" inSection:0];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];
  NSSet * deletedResult = [NSSet setWithArray:updates.indexPathsForDeletedRows];
  NSSet * insertedResult = [NSSet setWithArray:updates.indexPathsForInsertedRows];
  NSSet * deletedExpected = [NSSet setWithArray:@[
                                                  [NSIndexPath indexPathForRow:2 inSection:0],
                                                  [NSIndexPath indexPathForRow:4 inSection:0],
                                                  ]];
  NSSet * insertedExpected = [NSSet setWithArray:@[
                                                   [NSIndexPath indexPathForRow:0 inSection:0],
                                                   [NSIndexPath indexPathForRow:3 inSection:0],
                                                   [NSIndexPath indexPathForRow:5 inSection:0],
                                                   ]];
  XCTAssert([deletedExpected isEqual:deletedResult], @"should produce deleted rows");
  XCTAssert([insertedExpected isEqual:insertedResult], @"should produce inserted rows");
}
- (void)testShouldProduceInsertedSections
{
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];
  
  [col1 addSection:@"1"];
  [col1 addSection:@"3"];
  
  [col2 addSection:@"1"];
  [col2 addSection:@"2"];
  [col2 addSection:@"3"];
  [col2 addSection:@"4"];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];
  NSIndexSet * result = updates.indexSetForInsertedSections;
  NSMutableIndexSet * expected = [NSMutableIndexSet indexSet];
  [expected addIndex:1];
  [expected addIndex:3];
  XCTAssert([expected isEqual:result], @"should produce inserted sections");
}
- (void)testShouldProduceDeletedSections
{
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];
  
  [col1 addSection:@"1"];
  [col1 addSection:@"2"];
  [col1 addSection:@"3"];
  [col1 addSection:@"4"];
  
  [col2 addSection:@"1"];
  [col2 addSection:@"3"];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];
  NSIndexSet * result = updates.indexSetForDeletedSections;
  NSMutableIndexSet * expected = [NSMutableIndexSet indexSet];
  [expected addIndex:3];
  [expected addIndex:1];
  XCTAssert([expected isEqual:result], @"should produce deleted sections");
}
- (void)testFullCombinations
{
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];
  
  // collection 1
  [col1 addSection:@"1"];
  [col1 addRow:@"1" inSection:0];
  [col1 addRow:@"2" inSection:0];
  
  [col1 addSection:@"2"];
  [col1 addRow:@"1" inSection:1];
  [col1 addRow:@"2" inSection:1];
  
  [col1 addSection:@"3"];
  [col1 addRow:@"1" inSection:2];
  [col1 addRow:@"2" inSection:2];
  
  [col1 addSection:@"4"];
  [col1 addRow:@"1" inSection:3];
  [col1 addRow:@"2" inSection:3];
  
  // collection 2
  [col2 addSection:@"1"];
  [col2 addRow:@"1" inSection:0];
  [col2 addRow:@"3" inSection:0];
  
  [col2 addSection:@"5"];
  [col2 addRow:@"1" inSection:1];
  [col2 addRow:@"2" inSection:1];
  
  [col2 addSection:@"7"];
  
  [col2 addSection:@"3"];
  [col2 addRow:@"1" inSection:3];
  [col2 addRow:@"2" inSection:3];
  
  [col2 addSection:@"6"];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];

  // deleted sections
  NSIndexSet * resultDeletedSections = updates.indexSetForDeletedSections;
  NSMutableIndexSet * expectedDeletedSections = [NSMutableIndexSet indexSet];
  [expectedDeletedSections addIndex:3];
  [expectedDeletedSections addIndex:1];
  XCTAssert([expectedDeletedSections isEqual:resultDeletedSections], @"should produce deleted sections");
  
  // deleted rows
  NSSet * resultDeletedRows = [NSSet setWithArray:updates.indexPathsForDeletedRows];
  NSSet * expectedDeletedRows = [NSSet setWithArray:@[
                                                      [NSIndexPath indexPathForRow:1 inSection:0]
                                                      ]];
  XCTAssert([expectedDeletedRows isEqual:resultDeletedRows], @"should produce deleted rows");

  // inserted sections
  NSIndexSet * resultInsertedSections = updates.indexSetForInsertedSections;
  NSMutableIndexSet * expectedInsertedSections = [NSMutableIndexSet indexSet];
  [expectedInsertedSections addIndex:1];
  [expectedInsertedSections addIndex:2];
  [expectedInsertedSections addIndex:4];
  XCTAssert([expectedInsertedSections isEqual:resultInsertedSections], @"should produce inserted sections");
  
  // inserted rows
  NSSet * resultInsertedRows = [NSSet setWithArray:updates.indexPathsForInsertedRows];
  NSSet * expectedInsertedRows = [NSSet setWithArray:@[
                                                       [NSIndexPath indexPathForRow:1 inSection:0]
                                                       ]];
  XCTAssert([expectedInsertedRows isEqual:resultInsertedRows], @"should produce inserted rows");
}
- (void)testMoves
{
  NugCollection * col1 = [NugCollection createCollection];
  NugCollection * col2 = [NugCollection createCollection];

  [col1 addSection:@"two"];
  [col1 addSection:@"three"];
  [col1 addRow:@"one" inSection:1];
  [col1 addRow:@"two" inSection:1];
  [col1 addRow:@"three" inSection:1];
  [col1 addSection:@"one"];
  
  [col2 addSection:@"one"];
  [col2 addSection:@"two"];
  [col2 addSection:@"three"];
  [col2 addRow:@"three" inSection:2];
  [col2 addRow:@"two" inSection:2];
  [col2 addRow:@"one" inSection:2];
  
  NugCollectionUpdates * updates = [NugCollectionUpdates updates:0 from:col1 to:col2];
  NSSet * sectionExpected = [NSSet setWithArray:@[
                                                  [NugCollectionUpdatesSectionMove moveFrom:2 to:0]
                                                  ]];
  XCTAssert([sectionExpected isEqual:[NSSet setWithArray:updates.sectionMoves]], @"should produce section moves");
  
  NSSet * rowExpected = [NSSet setWithArray:@[
                                              [NugCollectionUpdatesRowMove moveFrom:[NSIndexPath indexPathForRow:2 inSection:2]
                                                                                 to:[NSIndexPath indexPathForRow:0 inSection:2]],
                                              [NugCollectionUpdatesRowMove moveFrom:[NSIndexPath indexPathForRow:2 inSection:2]
                                                                                 to:[NSIndexPath indexPathForRow:1 inSection:2]],
                                              ]];
  XCTAssert([rowExpected isEqual:[NSSet setWithArray:updates.rowMoves]], @"should produce row moves");
}
@end
