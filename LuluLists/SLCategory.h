//
//  SLCategory.h
//  LuluLists
//
//  Created by Dingzhong Weng on 1/31/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SLEntry;

@interface SLCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *siblings;
@end

@interface SLCategory (CoreDataGeneratedAccessors)

- (void)addSiblingsObject:(SLEntry *)value;
- (void)removeSiblingsObject:(SLEntry *)value;
- (void)addSiblings:(NSSet *)values;
- (void)removeSiblings:(NSSet *)values;

@end
