//
//  LLFirstViewController.m
//  LuluLists
//
//  Created by Dingzhong Weng on 1/5/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "LLFirstViewController.h"

@interface LLFirstViewController ()

@end

@implementation LLFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"First", @"First");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
