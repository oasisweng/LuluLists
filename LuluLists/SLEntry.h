//
//  SLEntry.h
//  LuluLists
//
//  Created by Dingzhong Weng on 1/25/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SLCategory;

@interface SLEntry : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * frequency;
@property (nonatomic, retain) NSNumber * trashed;
@property (nonatomic, retain) NSDate * trashedDate;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) SLCategory *parent;

@end
