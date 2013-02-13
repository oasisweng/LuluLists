//
//  SLCategory.h
//  LuluLists
//
//  Created by Dingzhong Weng on 1/19/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SLCategory : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * frequency;

@end
