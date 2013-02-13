//
//  LLFirstViewController.m
//  LuluLists
//
//  Created by Dingzhong Weng on 1/5/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import "LLShoppingListController.h"
#import <QuartzCore/QuartzCore.h>

@interface LLShoppingListController ()

@end

@implementation LLShoppingListController
@synthesize categoryEditor,entryEditor,mainView,shoppingList,addingView;
@synthesize entries,categories,trashedEntries,filteredData,allCategories;
@synthesize context;
@synthesize pickAnAmount,amountDecide,amountField,amountPicker,colorSelection;
@synthesize selectedEntry,selectedCategory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"First", @"First");
		self.tabBarItem.image = [UIImage imageNamed:@"first"];
	}
	return self;
}

//the loading is never saved yet.
- (void)viewDidLoad
{
//	NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//	
//	NSArray *fontNames;
//	NSInteger indFamily, indFont;
//	for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
//	{
//		NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//		fontNames = [[NSArray alloc] initWithArray:
//						 [UIFont fontNamesForFamilyName:
//						  [familyNames objectAtIndex:indFamily]]];
//		for (indFont=0; indFont<[fontNames count]; ++indFont)
//		{
//			NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
//		}
//	}
//	
	[super viewDidLoad];
	//set the title
	self.title = @"Shopping List";
	
	//load some test files
   [self loadingSampleCatagoriesPlist];
	
	LLAppDelegate* appDelegate = [[UIApplication sharedApplication]delegate];
	context = appDelegate.managedObjectContext;
	//create the fetch request for the entity.
	NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
	NSError* error= nil;
	NSEntityDescription* entity= nil;
	NSPredicate* predicate= nil;
	NSSortDescriptor* sortDescriptor= nil;
	
	//load category's colors
	NSString *rootPath = [[NSBundle mainBundle]bundlePath];
	//load colors plist
	NSString *colorsPath = [rootPath stringByAppendingPathComponent:@"ShoppingListColors.plist"];
	NSDictionary *colorsFromFile = [[NSDictionary dictionaryWithContentsOfFile:colorsPath]mutableCopy];
	//create a mutable array to load in all colors then copy them into the actual categoryColors array
	NSMutableArray* loadColors = [[NSMutableArray alloc]init];
	for (NSString* colorKey in [colorsFromFile allKeys]){
		NSDictionary* color = [colorsFromFile objectForKey:colorKey];
		[loadColors addObject:color];
		NSLog(@"%@",colorKey);
	}
	
	//bubble sort all colors by their order
	for (int i=0;i<[loadColors count];i++){
		for (int j=i+1;j<[loadColors count];j++){
			NSDictionary* iDic = (NSDictionary*)[loadColors objectAtIndex:i];
			NSDictionary* jDic = (NSDictionary*)[loadColors objectAtIndex:j];
			NSInteger iOrder = [[iDic objectForKey:@"Order"]integerValue];
			NSInteger jOrder = [[jDic objectForKey:@"Order"]integerValue];
			if (iOrder>jOrder)
				[loadColors exchangeObjectAtIndex:i withObjectAtIndex:j];
		}
	}
	
	//load all possible categories into the array
	allCategories = [loadColors copy];
	
	//load categories
	entity = [NSEntityDescription entityForName:@"SLCategory" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"frequency" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	NSArray* fetchedCategories = [context executeFetchRequest:fetchRequest error:&error];
	categories = [fetchedCategories copy];
	NSLog(@"%@",categories);
	
	//load entries(current)
	entity = [NSEntityDescription entityForName:@"SLEntry" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	predicate = [NSPredicate predicateWithFormat:@"trashed == NO"];
	[fetchRequest setPredicate:predicate];
	sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	NSArray* fetchedEntries = [context executeFetchRequest:fetchRequest error:&error];
	entries = [fetchedEntries copy];
	
	NSLog(@"colors has %i, categories has %i entries \nentries has %i entries.",[allCategories count],[categories count],[entries count]);
	
	//load entries(trashed)
	entity = [NSEntityDescription entityForName:@"SLEntry" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"trashedDate" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	predicate = [NSPredicate predicateWithFormat:@"trashed == YES"];
	[fetchRequest setPredicate:predicate];
	NSArray* fetchedTrashedEntries = [context executeFetchRequest:fetchRequest error:&error];
	trashedEntries = [fetchedTrashedEntries copy];
	
	
	//***test
	for (int i=0;i<[entries count];i++){
		SLEntry* entry = [entries objectAtIndex:i];
		//set entryCategory to be entry's parent (pickCategoryColor)
		SLCategory* parent= [categories objectAtIndex:i % 4];//test***
		[parent addSiblingsObject:entry];//test***
	}
	for (int i=0;i<[trashedEntries count];i++){
		SLEntry* entry = [trashedEntries objectAtIndex:i];
		//set entryCategory to be entry's parent (pickCategoryColor)
		SLCategory* parent= [categories objectAtIndex:i % 4];//test***
		[parent addSiblingsObject:entry];//test***
	}
	
	//initialize CategoryEditor (UIButton*)
	categoryEditor.layer.borderWidth = 1.0f;
	categoryEditor.layer.borderColor = [[UIColor blackColor]CGColor];
	//categoryEditor.backgroundColor = [UIColor whiteColor];
	categoryEditor.titleLabel.textColor = [UIColor lightGrayColor];
	categoryEditor.titleLabel.font = [UIFont fontWithName:LLStandardFont size:12];
	categoryEditor.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	[categoryEditor setTitleEdgeInsets:UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)];
	
	//initialize EntryEditor (UITextView*)
	//UIFont *font2= [UIFont fontWithName:@"governor" size:12];
	//[entryEditor setFont:font2];
	entryEditor.layer.borderWidth = 1.0f;
	entryEditor.layer.borderColor = [[UIColor blackColor]CGColor];
	[self setVerticalAlignment:LLVerticalAlignmentCenter InTextView:entryEditor];
	//entryEditor.backgroundColor = [UIColor whiteColor];
	entryEditor.textColor = [UIColor lightGrayColor];
	entryEditor.font = [UIFont fontWithName:LLStandardFont size:12];
	
	//clean the filteredData
	filteredData = [[NSArray alloc]init];
	
	//initialize shoppingList (UIScrollView*)
	shoppingList.layer.borderWidth = 1.0f;
	shoppingList.layer.borderColor = [[UIColor blackColor]CGColor];
	//for the first time update the shoppinglist, as well as its content size
	[self updateShoppingList];
	
	//load pickerview
	[[NSBundle mainBundle]loadNibNamed:@"pickAnAmount" owner:self options:nil];
	
	//load color selection tableview
	colorSelection = [[UITableView alloc]initWithFrame:categoryEditor.frame style:UITableViewStylePlain];
	colorSelection.dataSource = self;
	colorSelection.delegate = self;
	colorSelection.userInteractionEnabled = YES;
	colorSelection.delaysContentTouches = NO;
	colorSelection.scrollEnabled = NO;
	
	//addingview background color
   self.addingView.backgroundColor = [UIColor clearColor];
	
	// Observe keyboard hide and show notifications to resize the text view appropriately.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma Mics Funcs
-(void)loadingSampleCatagoriesPlist{
	NSString *rootPath = [[NSBundle mainBundle]bundlePath];
	//load the catagories plist
	NSString *categoriesPath = [rootPath stringByAppendingPathComponent:@"categories.plist"];
	NSDictionary *categoriesFromFile = [[NSDictionary dictionaryWithContentsOfFile:categoriesPath]copy];
	//create shoppingList catagories
	NSArray *shoppingListCategories = [[categoriesFromFile objectForKey:@"ShoppingList"]copy];
	NSLog(@"%@",shoppingListCategories);
	//add each category in shopping list to database
	LLAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
	context = appDelegate.managedObjectContext;
	NSInteger count =0;
   for (NSDictionary *cat in shoppingListCategories){
		SLCategory* aCategory = [NSEntityDescription insertNewObjectForEntityForName:@"SLCategory" inManagedObjectContext:context];
		aCategory.title = [cat objectForKey:@"Title"];
		aCategory.frequency = [cat objectForKey:@"Frequency"];
		aCategory.color = [NSNumber numberWithInt:count];
		count ++;
	}
	
	//load some sample entries
	for (int i=0;i<5;i++){
		SLEntry* aEntry = [NSEntityDescription insertNewObjectForEntityForName:@"SLEntry" inManagedObjectContext:context];
		aEntry.title = [NSString stringWithFormat:@"Sample %i",i];
		if (i == 4)
			aEntry.trashed = [NSNumber numberWithBool:YES];
		else
			aEntry.trashed = [NSNumber numberWithBool:NO];
		aEntry.frequency = [NSNumber numberWithInt:0];
		aEntry.createdDate = [NSDate date];
		aEntry.amount = [NSNumber numberWithInt:1];
	}
}

-(void)setVerticalAlignment:(NSInteger)alignment InTextView:(UITextView*)textView{
	UITextView *tv = textView;
	switch (alignment) {
		case LLVerticalAlignmentBottom:{
			//Bottom vertical alignment
			CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
			topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
			tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
			break;
		}
		case LLVerticalAlignmentCenter:{
			//Center vertical alignment
			CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
			//topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
			tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
			break;
		}
		default:
			break;
	}
	
}

-(IBAction)resignFirstResponder:(id)sender{
	[sender resignFirstResponder];
}

-(IBAction)decideThisAmount:(id)sender{
	//when user decides the amount that's shown on amountField, update entry's amount by setting it to the number shown in amountField
	selectedEntry.amount = [NSNumber numberWithInt:[amountField.text intValue]];
	
	//update the entire view
	[self updateShoppingList];
	
	//update its relating entry view  *** not at this point
	//[self makeAnEntryView:selectedEntry withRank:pickAnAmount.tag];
	
	//in case amount field is still the first responder
	[amountField resignFirstResponder];
	
	//remove picker view
	[pickAnAmount removeFromSuperview];
}

//when user has done entering his or her customized number, and pressed done, dismiss the keyboard
-(void)doneEnterTheAmount:(id)sender{
	[amountField resignFirstResponder];
	[sender removeFromSuperview];
}

-(void)pickAnAmount:(UIView*)entryView{
	//the function retrieves the entry data first
	NSInteger rank = entryView.tag;
	
	if ([filteredData count]==0)
		selectedEntry = [entries objectAtIndex:rank];
	else
		selectedEntry = [filteredData objectAtIndex:rank];
	
	//initial amountFieldText should be set to entry's amount;
	amountField.text = [NSString stringWithFormat:@"%i",[selectedEntry.amount integerValue]];
	
	//present pickerView
	UIView* pickerView = self.pickAnAmount;
	CGRect frame = pickerView.frame;
	frame.origin.y = self.view.frame.size.height-frame.size.height;
	pickerView.frame = frame;
	
	//assign picker view so that it belongs to the entry
	pickerView.tag = rank;
	
	[self.view addSubview:pickerView];
	
	//reset picker to choose the number shown on amount field
	[amountPicker selectRow:[selectedEntry.amount integerValue]-1 inComponent:0 animated:YES];
	
	//in case categoryEditor and entryEditor are still first responders, resign them
	[categoryEditor resignFirstResponder];
	[entryEditor resignFirstResponder];
	
	//use a button to finalise the decision, and a text field to enter a customized number
}

#pragma Pick An amount Accessory Functions
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return 99;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	NSString* title = [NSString stringWithFormat:@"%i",row+1];
	return title;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	//when an amount is selected, update the source entry with new amount
	amountField.text = [NSString stringWithFormat:@"%i",row+1];
	//[pickerView removeFromSuperview];
}

#pragma category color selection
-(void)dismissColorSelection{
	//if needed, resize the adding view to where categoryEditor is
	CGRect addingFrame = self.addingView.frame;
	addingFrame.origin.y = self.view.frame.size.height - self.categoryEditor.frame.size.height;
	addingFrame.size.height = categoryEditor.frame.size.height;
	self.addingView.frame = addingFrame;
	for (UIView* subview in [addingView subviews]){
		CGRect frame = subview.frame;
		frame.origin.y = 0;
		subview.frame = frame;
	}
	//remove it from the selection
	[colorSelection removeFromSuperview];
	
	//if entryEditor was the first responder, resign
	[entryEditor resignFirstResponder];
	
	//reenable categoryEditor if it was disabled
	categoryEditor.enabled = YES;
}

//table view creates a list of color derived from categories function
-(IBAction)showColorSelection:(id)sender{
	//remove if it was in the view already
	[self dismissColorSelection];
	
   CGRect addingFrame = self.addingView.frame;
	
	NSLog(@"Before resize adding view, its x %f,y %f, h %f,w %f, subviews are %@",addingFrame.origin.x,addingFrame.origin.y,addingFrame.size.height,addingFrame.size.width, [addingView subviews]);
	
	[self reloadTableView:colorSelection];
	
	//resize the addingview to fit colorSelection
	addingFrame = [self.mainView convertRect:self.addingView.frame toView:self.mainView];
	addingFrame.origin.y -=colorSelection.frame.size.height;
	addingFrame.size.height +=colorSelection.frame.size.height;
	self.addingView.frame = addingFrame;
	//reposition its original subview so their bottom is constrained
	for (UIView* subview in [addingView subviews]){
		if (![subview isKindOfClass:[UITableView class]]){
			CGRect frame = subview.frame;
			frame.origin.y = addingFrame.size.height-frame.size.height;
			subview.frame = frame;
		}
	}
	NSLog(@"the frame of addingview, x %f, y %f, h %f, w %f,subviews are %@",addingFrame.origin.x,addingFrame.origin.y,addingFrame.size.height,addingFrame.size.width,[addingView subviews]);
	
	//the button is temporarily disabled until dismissed
	categoryEditor.enabled = NO;
	
	//add the view to adding view
	[self.addingView addSubview:colorSelection];
}

//when table view is reloaded, its adding view needs to be resized as well, and then when table view is dismissed, the adding view shrinks to the size of category view
-(void)reloadTableView:(UITableView*)tableView{
	
	//make sure the data is loaded
	[tableView reloadData];
	
	//set its frame
	CGRect frame = [self.addingView convertRect:categoryEditor.frame toView:self.addingView];
	// create the frame for color selection, its height equals to the count of categories times by 24, its width equals to category editor's width, its x doesn't change, its y varies according to the height
	// if the button contains letters, show all colors, otherwise, show all colors expect the already selected one.
	
	// take into account of the plus sign
	frame.size.height = [tableView contentSize].height;
	//	if ([categoryEditor.titleLabel.text isEqualToString:@""])
	//		frame.size.height -= 24;
	frame.origin.y = 0;
	tableView.frame = frame;
	
	//display the result of colorselection reframe
	NSLog(@"the frame of tableview, x %f, y %f, h %f, w %f",tableView.frame.origin.x,tableView.frame.origin.y,tableView.frame.size.height,tableView.frame.size.width);
}

-(UIImageView*)determineCategoryColor:(LLCategoryColor)color{
	//NSLog(@"the color picked is %i",color);
	UIImageView* entryCategory =[[UIImageView alloc]initWithFrame:CGRectMake(10, 3, 24, 24)];
	NSString* hex = [[allCategories objectAtIndex:color]objectForKey:@"Hex"];
   entryCategory.backgroundColor = [self SKColorFromHexString:hex];
	
	return entryCategory;
}

//borrowed functions
-(void)SKScanHexColor:(NSString*)hexString WithRed:(float*)red AndGreen:(float*)green AndBlue:(float*) blue AndAlpha:(float*) alpha{
	hexString = [hexString stringByAppendingString:@"ff"];
	
	unsigned int baseValue;
	[[NSScanner scannerWithString:hexString] scanHexInt:&baseValue];
	
	if (red) { *red = ((baseValue >> 24) & 0xFF)/255.0f; }
	if (green) { *green = ((baseValue >> 16) & 0xFF)/255.0f; }
	if (blue) { *blue = ((baseValue >> 8) & 0xFF)/255.0f; }
	if (alpha) { *alpha = ((baseValue >> 0) & 0xFF)/255.0f; }
}

-(UIColor*)SKColorFromHexString:(NSString *)hexString {
	float red, green, blue, alpha;
	[self SKScanHexColor:hexString WithRed:&red AndGreen:&green AndBlue:&blue AndAlpha:&alpha];
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma Color Selection Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	NSLog(@"numberOfSections %i",1);
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSInteger numberOfRows = [categories count];
	// if there is still color available
	if ([categories count]<[allCategories count]){
		numberOfRows ++;
	}
	
	NSLog(@"numberOfRows %i",numberOfRows);
	
	return numberOfRows;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//the first entry of color selection is usually a plus sign if there are still avaiable colors in the inventory, namely, [categories count]<[allCategories count]
	static NSString *MyIdentifier = @"MyReuseIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:MyIdentifier];
	}
	//clean the subview and recreate
	for (UIView* view in [cell.contentView subviews]){
		if ([view isKindOfClass:[UILabel class]])
			[view removeFromSuperview];
	}
	
	//set background color
	cell.contentView.backgroundColor = [UIColor whiteColor];
	
	//add border
	cell.layer.borderColor = [[UIColor blackColor]CGColor];
	cell.layer.borderWidth = 1.0f;
	//set selection style
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if ([indexPath row] == 0 && [categories count]<[allCategories count]){
		//just write a plus sign in the middle
		//if plus sign is not included
		UILabel *plusSign = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, categoryEditor.frame.size.width,22)];
		plusSign.text = @"+";
		plusSign.font = [UIFont fontWithName:LLStandardPixelizedFont size:24];//arbitrary
		plusSign.textAlignment = NSTextAlignmentCenter;
		plusSign.textColor = [UIColor blackColor];
		plusSign.clipsToBounds = NO;
		[cell.contentView insertSubview:plusSign atIndex:0];
		NSLog(@"[categories count]%i,[allCategories count]%i",[categories count],[allCategories count]);
	} else {
		//if the cell creating is not the first one, determine its color using SKColorFromHexString
		NSInteger index = ([categories count]<[allCategories count])? [indexPath row]-1:[indexPath row];
		SLCategory* category = [categories objectAtIndex:index];
		//if the category equals to the selected category, show the text category instead
		if ([category isEqual:selectedCategory]){
			CGRect frame = cell.frame;
			frame.origin.y = 0;
			UILabel* label = [[UILabel alloc]initWithFrame:frame];
			label.text = @"Category";
			label.font = [UIFont fontWithName:LLStandardFont size:12];//BDZYZT.TTF does not work
			label.textAlignment = NSTextAlignmentCenter;
			label.textColor = [UIColor lightGrayColor];
			cell.contentView.backgroundColor = [UIColor whiteColor];
			[cell.contentView addSubview:label];
			NSLog(@"Letter Category is shown");
		} else {
			NSInteger colorOrder = [category.color integerValue];
			NSString* hex = [[allCategories objectAtIndex:colorOrder]objectForKey:@"Hex"];
			UIColor* color = [self SKColorFromHexString:hex];
			cell.contentView.backgroundColor = color;
		}
		
	}
	
	NSLog(@"cell's subviews are %@, the row is %i",[cell subviews], [indexPath row]);
	return cell;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
	//the relevant entry will be highlighted to its inverse color
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	UIColor* highlightColor = [self inverseColor:cell.contentView.backgroundColor];
	cell.contentView.backgroundColor = highlightColor;
	return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 24.0f;
}

#pragma Color Selection Delegate
//if a color is selected

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

	[self dismissColorSelection];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSLog(@"the row selected is %i",[indexPath row]);
	//if the first row is selected when it contains the plus sign (TITS(that is to say),its background is white)
	UITableViewCell* cell= [tableView cellForRowAtIndexPath:indexPath];
	UIColor* color = cell.contentView.backgroundColor;
	
	NSLog(@"the selected background color is %@, white color is %@, cell subviews contain %@",color, [UIColor whiteColor], [cell.contentView subviews]);
	// if the view may be either the add cell or category cell
	for (UIView* view in [cell.contentView subviews]){
		//find the label through the cell
		if ([view isKindOfClass:[UILabel class]]){
			UILabel* label = (UILabel*)view;
			//if it is the text category, update categoryEditor to be empty
			if ([label.text isEqual:@"Category"]){
				categoryEditor.titleLabel.text = @"Category";
				categoryEditor.titleLabel.textColor = [UIColor lightGrayColor];
				categoryEditor.backgroundColor = [UIColor whiteColor];
				NSLog(@"Category Sign is Pressed!");
				//state that user does not select to any color
				selectedCategory = nil;
				filteredData = [[NSArray alloc]init];
				[self updateShoppingList];
			} else {
				//if user selects the add button, put next color from allCategories to the categories
				NSMutableArray* newCategories = [categories mutableCopy];
				SLCategory* category = [NSEntityDescription insertNewObjectForEntityForName:@"SLCategory" inManagedObjectContext:context];
				category.frequency = [NSNumber numberWithInt:0];
				NSInteger color = [categories count];
				category.color = [NSNumber numberWithInt:color];
				[newCategories addObject:category];
				categories = [newCategories copy];
				NSLog(@"Plus Sign is Pressed!");
				//it has done the job
				[self showColorSelection:self];
			}
			
			return;
		}
	}
		
	//if did not find the specific label
	//if it is an actual color, update the editor to be the same color and reload the data
	//a specific category is selected
	NSInteger row = [indexPath row];
	if ([categories count] == [allCategories count]){
		row ++;
	}
	
	selectedCategory = [categories objectAtIndex:row-1];
	categoryEditor.backgroundColor = color;
	categoryEditor.titleLabel.text = selectedCategory.title;
	categoryEditor.titleLabel.textColor = color;
	
	NSMutableArray* entryFilter = [[NSMutableArray alloc]init];
	entryFilter = [filteredData mutableCopy];
	
	NSLog(@"When filter starts, the entryFilter is %@",entryFilter);
	//if categoryEditor is not "Show all", remove all relevant entries to the filter if category editor's text does not include its belonging category, and the entry does not include its title either
	if (![categoryEditor.backgroundColor isEqual:[UIColor whiteColor]]){
		//store entry editor's text into a variable tv2Text,store category color into NSInteger bColor
		//bColor now should be the color user selected previously
		NSString* tv2Text = entryEditor.text;
		NSInteger bColor = [selectedCategory.color integerValue];
		//if categoryEditor is not empty, filter list according to its text
		for (SLEntry* entry in entryFilter){
			NSInteger parentColor = [entry.parent.color integerValue];
			if ((parentColor != bColor && tv2Text != @"" && [entry.title rangeOfString:tv2Text  options:NSCaseInsensitiveSearch].location == NSNotFound) || (parentColor == bColor)){
				[entryFilter removeObject:entry];
			}
		}
		
		
	}
	
	//if categoryEditor is not empty, add all relevant entries to the filter if category editor's text is included in its belonging category
	if (![categoryEditor.titleLabel.textColor isEqual:[UIColor lightGrayColor]]){
		//store category editor's color into a variable bColor
		NSInteger bColor = [selectedCategory.color integerValue];
		//if categoryEditor is not "show all", filter list according to its text
		//test if tv1Text and categoryTitle is read properly
		//add all entries with the same color to entryFilter
		for (SLEntry* entry in entries){
			NSInteger parentColor = [entry.parent.color integerValue];
			if (parentColor == bColor){
				[entryFilter addObject:entry];
			}
			NSLog(@"the bColor is %i, parentColor is %i, the entryfilter contains %@",bColor, parentColor, entryFilter);
		}
	}
	//copy entryFilter results back to filteredData
	filteredData = [entryFilter copy];
	//update shoppinglist
	[self updateShoppingList];
	
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
	//return the color back to its original
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	UIColor* originalColor = [self inverseColor:cell.contentView.backgroundColor];
	cell.contentView.backgroundColor = originalColor;
}

-(UIColor*)inverseColor:(UIColor*)oldColor{
	const CGFloat *componentColors = CGColorGetComponents(oldColor.CGColor);
	UIColor *newColor = [[UIColor alloc]init];
	if ([oldColor isEqual:[UIColor whiteColor]]){
		newColor = [UIColor blackColor];
	} else {
		NSLog(@"the color processed is %f,%f,%f,%f",componentColors[0],componentColors[1],componentColors[2],componentColors[3]);
		
		newColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
													 green:(1.0 - componentColors[1])
													  blue:(1.0 - componentColors[2])
													 alpha:componentColors[3]];
	}
	
	return newColor;
}

#pragma Text View Searching
//to create a table view helping users select categories while editing the shopping list
-(void)textViewDidBeginEditing:(UITextView *)textView{
	[textView becomeFirstResponder];
	if (textView.tag == LLEntryEditorTag){
		//clear the prompt text
		if ([entryEditor.textColor isEqual:[UIColor lightGrayColor]]){
			entryEditor.textColor = [UIColor blackColor];
			entryEditor.text = @"";
		}
	}
}

//help customer find the most relevant entries to their typing for convinience
-(void)textViewDidChange:(UITextView *)textView{
	
	//new filtered shopping list
	NSMutableArray* entryFilter = [[NSMutableArray alloc]init];
	
	//remove all irrelevant entries from the filter if entry editor's text is not included in its title
	if (![entryEditor.textColor isEqual:[UIColor lightGrayColor]]){
		//store entry editor's text into a variable tv2Text
		NSString* tv2Text = entryEditor.text;
		//if entryEditor is not empty, filter list according to its text
		for (SLEntry* entry in entryFilter){
			NSString* entryTitle = entry.title;
			//using simplest model to detect if the title contains text from entryEditor
			if ([entryTitle rangeOfString:tv2Text options:NSCaseInsensitiveSearch].location == NSNotFound){
				[entryFilter removeObject:entry];
			}
		}
	}
	
	//add all relevant entries to the filter if entry editor's text is included in its title from both current and trashed entries
	if (![entryEditor.textColor isEqual:[UIColor lightGrayColor]]){
		//store entry editor's text into a variable tv2Text
		NSString* tv2Text = entryEditor.text;
		//if entryEditor is not empty, filter list according to its text
		for (SLEntry* entry in entries){
			NSString* entryTitle = entry.title;
			//using simplest model to detect if the title contains text from entryEditor
			if ([entryTitle rangeOfString:tv2Text options:NSCaseInsensitiveSearch].location !=NSNotFound){
				[entryFilter addObject:entry];
			}
		}
		
		//include all deleted entries that relate to the keyword in entryEditor
		for (SLEntry* entry in trashedEntries){
			NSString* entryTitle = entry.title;
			//using simplest model to detect if the title contains text from entryEditor
			if ([entryTitle rangeOfString:tv2Text options:NSCaseInsensitiveSearch].location !=NSNotFound){
				[entryFilter addObject:entry];
			}
		}
		
	}
	
	//update filteredData with the results from entryFilter
	NSLog(@"The filteredData is now %@",entryFilter);
	filteredData = [entryFilter copy];
	[self updateShoppingList];
}

#pragma Text View Finishing
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		if (textView.tag == LLCategoryEditorTag){//if user presses Next due to filling CategoryEditor, entryEditor starts to repsond to user.
			[entryEditor becomeFirstResponder];
		}
		return NO;
	}
	return YES;
}

#pragma Text View Adding
-(void)textViewDidEndEditing:(UITextView *)textView{
	// if text view is empty, filled in with prompt text
	if (textView.tag == LLEntryEditorTag && [entryEditor.text isEqualToString:@""]){
		entryEditor.textColor = [UIColor lightGrayColor];
		entryEditor.text = @"Entries";
	}
}

#pragma Table Content Programming
-(UIView*)makeAnEntryView:(SLEntry*)entry withRank:(NSInteger)rank{
	// When a entry view is creating, trashed results will be displayed as white color with letters striked through, background graphite, amount description disabled. later, restore function will be applied.
	
	//double check if the view is created twice
	if (rank < [[shoppingList subviews]count]){
		UIView* oldView = [[shoppingList subviews]objectAtIndex:rank];
	   [oldView removeFromSuperview];
	}
	
	bool trashed = [entry.trashed boolValue];
	bool irrelevant = NO;
	if (!([entryEditor.textColor isEqual:[UIColor lightGrayColor]]||[entryEditor.text isEqualToString:@""])){
		irrelevant = [entry.title rangeOfString:entryEditor.text].location == NSNotFound;
	}
	if (selectedCategory){
		irrelevant = irrelevant && [entry.parent.color integerValue] != [selectedCategory.color integerValue];
	}
	
	//initialize a entry view
	UIView* entryView = [[UIView alloc]initWithFrame:CGRectMake(0, rank*30, 320, 30)];
	
	//entryAmount stores the amount of item user wants to buy, it evokes a picker to pick an amount, or in the picker view containing a textfield, user may specify his or her own wanted amount.(pickAnAmount)
	UIButton* entryAmount = [UIButton buttonWithType:UIButtonTypeCustom];
	entryAmount.frame = CGRectMake(42, 5, 22, 20);
	NSInteger amount = [entry.amount integerValue];
	[entryAmount setTitle:[NSString stringWithFormat:@"%i",amount] forState:UIControlStateNormal];
	[entryAmount setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
	entryAmount.titleLabel.textColor = [UIColor blackColor];
	entryAmount.titleLabel.font = [UIFont fontWithName:LLStandardPixelizedFont size:11.0f];
	entryAmount.titleLabel.textAlignment = NSTextAlignmentCenter;
	
	//bordercolor is modified later
	//entryAmount.layer.borderColor = [[UIColor blackColor]CGColor];
	entryAmount.layer.borderWidth = 1.0f;
	//set entryAmount background color to be clear
	entryAmount.backgroundColor = [UIColor clearColor];
	//set entryAmount's title to white and background to black when it's pressed.
	[entryAmount setBackgroundImage:[UIImage imageNamed:@"blackPixel.gif"] forState:UIControlStateHighlighted];
	[entryAmount setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	//allow user to pick an amount or enter an amount itself. Using its rank information, user can retrieve the original entry view in order to update
	entryAmount.tag = rank;
	[entryAmount addTarget:self action:@selector(pickAnAmount:) forControlEvents:UIControlEventTouchUpInside];
	
	UIImageView* entryCategory =[self determineCategoryColor:[entry.parent
																				 .color integerValue]];
	entryCategory.layer.borderWidth = 1.0f;
	
	//set entryTitle to be entry's title
	UILabel* entryTitle = [[UILabel alloc]initWithFrame:CGRectMake(70, 3, 230, 24)];
	entryTitle.backgroundColor = [UIColor clearColor];
	NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString:entry.title];
	NSDictionary* fontAttrib = [[NSDictionary alloc]initWithObjectsAndKeys:[UIFont fontWithName:LLStandardFont size:10],NSFontAttributeName,nil];
	[attributedText addAttributes:fontAttrib range:NSMakeRange(0, [attributedText length])];
	//set font for entryAmount button
	entryAmount.titleLabel.font = [UIFont fontWithName:LLStandardPixelizedFont size:11];
	//if entry is trashed, title becomes white, using attributed text
	if (trashed || irrelevant){
		//set text to be striked through
		[attributedText addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithBool:YES] range:NSMakeRange(0, [attributedText length])];
		//set text color to be white
		[attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [attributedText length])];
		//modify entryAmount
		entryAmount.enabled = NO;
		entryAmount.layer.borderColor = [[UIColor whiteColor]CGColor];
		entryAmount.titleLabel.textColor = [UIColor whiteColor];
		//modify entryCategory
		entryCategory.layer.borderColor = [[UIColor whiteColor]CGColor];
		//modify the background color
		entryView.backgroundColor = [UIColor colorWithRed:45/255 green:45/255 blue:45/255 alpha:1];
		
		entryView.layer.borderColor = [[UIColor lightGrayColor]CGColor];
		
	} else {
		//set text not to be striked through
		[attributedText addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithBool:NO] range:NSMakeRange(0, [attributedText length])];
		//set text color to be black
		[attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [attributedText length])];
		//modify entryAmount
		entryAmount.enabled = YES;
		entryAmount.layer.borderColor = [[UIColor blackColor]CGColor];
		entryAmount.titleLabel.textColor = [UIColor blackColor];
		//modify entryCategory
		entryCategory.layer.borderColor = [[UIColor blackColor]CGColor];
		
		//modify the background color
		entryView.backgroundColor = [UIColor whiteColor];
		
		entryView.layer.borderColor = [[UIColor blackColor]CGColor];
	}
	
	//set entry title to be this attributed text
	entryTitle.attributedText = attributedText;
	
	//add all subview to entryView
	[entryView addSubview:entryTitle];
	[entryView addSubview:entryAmount];
	[entryView addSubview:entryCategory];
	
	//set entryView's border
	entryView.layer.borderWidth = 0.5f;
	
	return entryView;
}

-(void)updateShoppingList{
	NSArray* displayEntries;
	//if filteredData contains zero entry, display regular entries;Otherwise, display filteredData, if in filteredData, entry is trashed, shown in darkGray color, otherwise, black.
	if ([filteredData count]==0)
		displayEntries = [entries copy];
	else
		displayEntries = [filteredData copy];
	
	//clean scroll view
   for (UIView* subview in [shoppingList subviews]){
		[subview removeFromSuperview];
	}
	
	NSLog(@"filteredData has %i entries,entries has %i entries",[filteredData count],[entries count]);
	
	//after selcect which array to display, the function makes all the entry and show'em on the scroll view
	for (int i=0;i<[displayEntries count];i++){
		SLEntry* entry = [displayEntries objectAtIndex:i];
		//create UILabel according to the entries, layout needs to be changed.
		UIView* entryView = [self makeAnEntryView:entry withRank:i];
		//add entryView to shoppingList
		[shoppingList addSubview:entryView];
	}
	//calculate the proper size of scroll view
	CGSize contentSize = shoppingList.contentSize;
	contentSize.height = [entries count]*20;
}


#pragma mark Responding to keyboard events
- (void)keyboardWillShow:(NSNotification *)notification {
	
	/*
	 Reduce the size of the text view so that it's not obscured by the keyboard.
	 Animate the resize so that it's in sync with the appearance of the keyboard.
	 */
	
	//if text views are being edited currently, lift text views
	if ([entryEditor isFirstResponder]){
		NSDictionary *userInfo = [notification userInfo];
		
		// Get the origin of the keyboard when it's displayed.
		NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
		
		// Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
		CGRect keyboardRect = [aValue CGRectValue];
		keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
		
		CGFloat keyboardTop = keyboardRect.origin.y;
		//calculating new frame, which is pixels above the keyboard
		CGRect newAddingViewFrame = [self.view convertRect:self.addingView.frame toView:nil];
		//the origin of the new adding view frame is keyboardTop minus its original orgin y.
		newAddingViewFrame.origin.y = keyboardTop-self.addingView.frame.size.height;
		NSLog(@"Keyboard origin y is %f ",keyboardRect.origin.y);
		
		// Get the duration of the animation.
		NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
		NSTimeInterval animationDuration;
		[animationDurationValue getValue:&animationDuration];
		
		// Animate the resize of the text view's frame in sync with the keyboard's appearance.
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:animationDuration-5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		self.addingView.frame = newAddingViewFrame;
		
		[UIView commitAnimations];
	}
	
}

-(void)keyboardDidShow:(NSNotification *)notification{
	if ([amountField isFirstResponder]){
		UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
		doneButton.frame = CGRectMake(0, 163, 106, 53);
		doneButton.adjustsImageWhenHighlighted = NO;
		[doneButton setImage:[UIImage imageNamed:@"DoneUp.png"] forState:UIControlStateNormal];
		[doneButton setImage:[UIImage imageNamed:@"DoneDown.png"] forState:UIControlStateHighlighted];
		[doneButton addTarget:self action:@selector(doneEnterTheAmount:) forControlEvents:UIControlEventTouchUpInside];
		
		// locate keyboard view, it should be called <UIPeripheralHostView>
		UIView* keyboard = [[[[[UIApplication sharedApplication] windows]objectAtIndex:1]subviews]objectAtIndex:0];
		//UIView* keyboard = [[keyboardWindow subviews]objectAtIndex:0];
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
			if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
				[keyboard addSubview:doneButton];
			NSLog(@"subviews %@",[keyboard subviews]);
		} else if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES) {
			[keyboard insertSubview:doneButton atIndex:100];
		}
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if ([entryEditor isFirstResponder]){
		// recovery
		NSDictionary* userInfo = [notification userInfo];
		
		CGRect newAddingViewFrame = self.addingView.frame;
		newAddingViewFrame.origin.y = self.view.frame.size.height-self.addingView.frame.size.height;
		
		//NSLog(@"keyboardWillHide: text view bounds' y is %f, titleField y is %f",newTextViewFrame.origin.y, titleField.frame.origin.y);
		/*
		 Restore the size of the text view (fill self's view).
		 Animate the resize so that it's in sync with the disappearance of the keyboard.
		 */
		NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
		NSTimeInterval animationDuration;
		[animationDurationValue getValue:&animationDuration];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:animationDuration-5];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		addingView.frame = newAddingViewFrame;
		
		[UIView commitAnimations];
	}
}

@end
