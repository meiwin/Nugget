//
//  NugCollectionUpdates.h
//  Nugget
//
//  Created by Meiwin Fu on 25/11/14.
//  Copyright (c) 2014 Piethis Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NugCollection.h"

typedef NS_ENUM(uint32_t, NugCollectionUpdatesOption) {
  NugCollectionUpdatesOptionNone = 0
};

@interface NugCollectionUpdates : NSObject

@property (nonatomic, strong, readonly) NSArray * indexPathsForInsertedRows;
@property (nonatomic, strong, readonly) NSArray * indexPathsForDeletedRows;
@property (nonatomic, strong, readonly) NSIndexSet * indexSetForInsertedSections;
@property (nonatomic, strong, readonly) NSIndexSet * indexSetForDeletedSections;

+ (NugCollectionUpdates *)empty;
+ (NugCollectionUpdates *)updates:(NugCollectionUpdatesOption)options
                             from:(NugCollection *)from
                               to:(NugCollection *)to;
@end
