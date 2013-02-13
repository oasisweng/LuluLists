//
//  LLFirstViewController.h
//  LuluLists
//
//  Created by Dingzhong Weng on 1/5/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "LLAppDelegate.h"
#include "SLEntry.h"
#include "SLCategory.h"

#define LLVerticalAlignmentCenter 0
#define LLVerticalAlignmentBottom 1
#define LLCategoryEditorTag 927
#define LLEntryEditorTag 625

#define LLCategoryColor NSInteger
#define LLCategoryColorIvory 0
#define LLCategoryColorBush 1
#define LLCategoryColorTomato 2
#define LLCategoryColorMarine 3
#define LLCategoryColorOrange 4
#define LLCategoryColorClay 5
#define LLCategoryColorViolet 6
#define LLCategoryColorSlate 7
#define LLCategoryColorAqua 8
#define LLCategoryColorForest 9
#define LLCategoryColorTan 10
#define LLCategoryColorPink 11
#define LLShoppingListMaxAmount 50

#define LLCategoryBackGroundColor [UIColor colorWithRed:1.0f green:215/255 blue:0 alpha:1]

@interface LLShoppingListController : UIViewController<UITextViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIScrollView *shoppingList;
@property (strong, nonatomic) IBOutlet UIButton *categoryEditor;
@property (strong, nonatomic) IBOutlet UITextView *entryEditor;
@property (strong, nonatomic) IBOutlet UIView *addingView;
//accessory view
@property (strong, nonatomic) UITableView* colorSelection;
@property (strong, nonatomic) IBOutlet UIView *pickAnAmount;
@property (strong, nonatomic) IBOutlet UITextField *amountField;
@property (weak, nonatomic) IBOutlet UIButton *amountDecide;
@property (weak, nonatomic) IBOutlet UIPickerView *amountPicker;

@property (strong, nonatomic) NSArray *allCategories;//order and hex
@property (strong, nonatomic) NSArray *entries;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSArray *trashedEntries;
@property (strong, nonatomic) NSArray *filteredData; //has relevant entries from entries and trashedEntries.
@property (strong, nonatomic) NSManagedObjectContext* context;

@property (strong, nonatomic) SLEntry* selectedEntry;//this property is meant to store the selected entry when user needs to update its amount. This property is set when amount button is pressed, and is modified and erased when user decide its new amount
@property (strong, nonatomic) SLCategory* selectedCategory;//this property is updated when user select a specific type of category and display on the category button. It is selected in the selectAColor function, update in the filterFunction

-(void)loadingSampleCatagoriesPlist;
-(void)setVerticalAlignment:(NSInteger)alignment InTextView:(UIView*)textView;
-(void)updateShoppingList;
-(void)pickAnAmount:(UIView*)entryView;
-(void)doneEnterTheAmount:(id)sender;
-(IBAction)decideThisAmount:(id)sender;
-(IBAction)resignFirstResponder:(id)sender;
-(IBAction)showColorSelection:(id)sender;//make tableview for categoryEditor
-(void)dismissColorSelection;
-(void)reloadTableView:(UITableView*)tableView;
-(UIImageView*)determineCategoryColor:(LLCategoryColor)color;
-(UIColor*)SKColorFromHexString:(NSString *)hexString;
-(void)SKScanHexColor:(NSString*)hexString WithRed:(float*)red AndGreen:(float*)green AndBlue:(float*) blue AndAlpha:(float*) alpha;
-(UIColor*)inverseColor:(UIColor*)oldColor;
-(UIView*)makeAnEntryView:(SLEntry*)entry withRank:(NSInteger)rank;
@end
