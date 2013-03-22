//
//  AllRemindersViewController.m
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import <QuartzCore/CALayer.h>
#import "AllRemindersViewController.h"
#import "LKMediator.h"
#import "LKThemeProvider.h"
#import "LKReminderTableViewCell.h"
#import "DCPanGesture.h"
#import <objc/runtime.h>

// None of the row index is ready for editing
#define rowIndexReadyForEditingNone     -1
// Should be same as defined in nib file.
#define kCellHeight                     70
#define kCellHeightOffset               0
// From where origin.x of cell should start
#define kCellXOffset                    0

#define kTagForCommand              0x1024

// Row index of cell
static char* kCellReminder          =       "cellindex";

// Type of command currently being displayed
static char* kCommandType                 =       "ctype";
const int kCommandTypeEdit          =            1;
const int kCommandTypeDeactivate    =            2;
const int kCommandTypeRemove        =            3;

// Gesture commands used inline with LKPanGestureRecognizer
typedef enum {
    LKGestureCommandNone,
    LKGestureCommandEdit,
    LKGestureCommandDeactivate,
    LKGestureCommandRemove
} LKGestureCommand;

@interface AllRemindersViewController ()

- (LKGestureCommand)gestureCommandForCrossLevelPercent:(CGFloat)crossLevelPercent;
- (void)editRowAtIndex:(NSInteger)index;

@property (nonatomic) NSInteger rowIndexReadyForEditing;
@end

@implementation AllRemindersViewController

#pragma mark pimpl

- (LKGestureCommand)gestureCommandForCrossLevelPercent:(CGFloat)crossLevelPercent {
    
    static int editLevel = 15;
    static int deactiveLevel = 40;

    if(crossLevelPercent < -30)
        return LKGestureCommandRemove;
    
    if((crossLevelPercent > editLevel) && (crossLevelPercent < deactiveLevel))
        return LKGestureCommandEdit;
    else if(crossLevelPercent > deactiveLevel)
        return LKGestureCommandDeactivate;
    else
        return LKGestureCommandNone;
}

- (void)editRowAtIndex:(NSInteger)index {
    LKReminder* reminder = [[LKMediator sharedInstance].reminderModel reminderAtIndex:index];
    if(reminder)
        [[LKMediator sharedInstance].manager editReminder:reminder];
}


- (UILabel*)addCommandLabelWithText:(NSString*)text withCommandType:(int)commandType onCell:(UITableViewCell*)cell {
    CGRect frame = cell.backgroundView.bounds;
    UILabel* l = [[[UILabel alloc] initWithFrame:frame] autorelease];
    l.tag = kTagForCommand;
    // Used to delete this command when required (usually to show another command)
    objc_setAssociatedObject(l, kCommandType, [NSNumber numberWithInt:commandType], OBJC_ASSOCIATION_ASSIGN);
    l.text = text;
    [[LKThemeProvider defaultThemeProvider] themePanGestureCommandLabel:l];
    [cell.backgroundView addSubview:l];
    l.alpha = 0;
    CGPoint orignalCenter = l.center;
    CGPoint alteredCenter = orignalCenter;
    alteredCenter.y -= 30;
    l.center = alteredCenter;
    [UIView animateWithDuration:0.35 animations:^(void) {
        l.alpha = 1;
        l.center = orignalCenter;
    } completion:^(BOOL finished) {}];
    
    return l;
}


#pragma mark lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rowIndexReadyForEditing = rowIndexReadyForEditingNone;
    [LKMediator sharedInstance].reminderModel.delegate = self;
    
//    UIBarButtonItem* addButton = [[[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:[LKMediator sharedInstance].manager action:@selector(createReminder)] autorelease];
    UIBarButtonItem* addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:[LKMediator sharedInstance].manager action:@selector(createReminder)] autorelease];

    [[LKThemeProvider defaultThemeProvider] themeBarButtonItem:addButton];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [[LKThemeProvider defaultThemeProvider] themeTableView:self.tableView];
    [[LKThemeProvider defaultThemeProvider] themeBackgroundImageForView:self.tableView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"count is %d", [LKMediator sharedInstance].reminderModel.count);
    return [LKMediator sharedInstance].reminderModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kLKReminderTableViewCellIdentifier];
    if(!cell) {
        NSLog(@"Creating new cell");
        // TODO: Use a nib getter rather than using file name.
        NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"LKReminderCell_iPhone" owner:self options:nil];
        cell = (LKReminderTableViewCell*)[views objectAtIndex:0];
        CGRect newFrame = cell.contentView.frame;
        newFrame.origin.x = kCellXOffset;
        newFrame.size.width     -= (2*kCellXOffset);
        //newFrame.size.height =  [self tableView:tableView heightForRowAtIndexPath:indexPath] - 10;
        cell.contentView.frame = newFrame;
        [[LKThemeProvider defaultThemeProvider] themeReminderCell:cell];
    }

	LKReminderTableViewCell* myCell = (LKReminderTableViewCell*)cell;
    LKReminder* reminder = [[LKMediator sharedInstance].reminderModel reminderAtIndex:indexPath.row];
    myCell.title.text = reminder.subject;
    
    if([reminder isActive]) {
       [[LKThemeProvider defaultThemeProvider] themeReminderCellTitle:myCell.title withStateEnabled:YES];
    } else {
        [[LKThemeProvider defaultThemeProvider] themeReminderCellTitle:myCell.title withStateEnabled:NO];
    }
    
    if([reminder isLocationBased]) {
        myCell.subtitle1.text = reminder.locationDescription;
        [[LKThemeProvider defaultThemeProvider] themeReminderCellSubtitle:myCell.subtitle1 withStateEnabled:YES];
    } else {
        myCell.subtitle1.text = NSLocalizedString(@"No location", nil);
        [[LKThemeProvider defaultThemeProvider] themeReminderCellSubtitle:myCell.subtitle1 withStateEnabled:NO];
    }

    if([reminder isDateBased]) {
        myCell.subtitle2.text = reminder.dateDescription;
        [[LKThemeProvider defaultThemeProvider] themeReminderCellSubtitle:myCell.subtitle2 withStateEnabled:YES];
    } else {
        myCell.subtitle2.text = NSLocalizedString(@"No date", nil);
        [[LKThemeProvider defaultThemeProvider] themeReminderCellSubtitle:myCell.subtitle2 withStateEnabled:YES];
    }
    
    objc_setAssociatedObject(cell, kCellReminder, reminder, OBJC_ASSOCIATION_ASSIGN);
    DCPanGesture* pan = [[DCPanGesture alloc] init];
    [pan installGestureOnCell:cell];
    pan.delegate = self;
    return (UITableViewCell*)myCell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
//    if(indexPath.row == self.rowIndexReadyForEditing) {
//        self.rowIndexReadyForEditing = rowIndexReadyForEditingNone;
//        return YES;
//    } else {
//        return NO;
//    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - UITableViewDelegate
	
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LKReminder* reminder = [[[LKMediator sharedInstance] reminderModel] reminderAtIndex:indexPath.row];
    [[[LKMediator sharedInstance] manager] showReminder:reminder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight + kCellHeightOffset;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray* gestures = [cell.contentView gestureRecognizers];
    for (UIGestureRecognizer* g in gestures) {
        NSLog(@"g:%@",g);
        [cell.contentView removeGestureRecognizer:g];
    }
    
//    CALayer* shadowLayer = cell.contentView.layer;
//    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:cell.contentView.bounds] CGPath];
//    shadowLayer.shadowColor = [[UIColor colorWithWhite:0.760 alpha:1.000] CGColor];
//    shadowLayer.shadowOpacity = 1;
//    shadowLayer.shadowRadius = 0;
//    shadowLayer.shadowOffset = CGSizeMake(0, 10);
//    shadowLayer.zPosition = -1;
//    [cell.contentView.layer addSublayer:shadowLayer];

    //[[LKThemeProvider defaultThemeProvider] themeReminderCell:cell];
}

#pragma mark LKReminderModelDelegate

- (void)reminderModel:(LKReminderModel*)model didInsertReminder:(LKReminder*)reminder atIndex:(NSInteger)index {
    [self.tableView beginUpdates];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)reminderModel:(LKReminderModel*)model didUpdateReminder:(LKReminder*)reminder atIndex:(NSInteger)index {
    [self.tableView beginUpdates];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)reminderModel:(LKReminderModel*)model willRemoveRemainder:(LKReminder*)reminder atIndex:(NSInteger)index {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark LKPanGestureProtocol

- (void)cell:(UITableViewCell *)cell didCrossLevel:(CGFloat)level {
    // Create a backgrounview if required.
    if(!cell.backgroundView) {
        UIView* bkgView = [[[UIView alloc] initWithFrame:cell.frame] autorelease];
        bkgView.backgroundColor = [UIColor redColor];
        cell.backgroundView = bkgView;
    }
    
    CGFloat w = cell.frame.size.width;
    CGFloat percentCrossed = (level*100)/w;
    NSLog(@"percent %f",percentCrossed);
    UIView* v = [cell viewWithTag:kTagForCommand]; // view that shows command
    LKGestureCommand command = [self gestureCommandForCrossLevelPercent:percentCrossed];
    
    if(LKGestureCommandEdit == command) {
        if(!v) {
            UILabel* l = [self addCommandLabelWithText:NSLocalizedString(@"Edit", nil)
                          withCommandType:kCommandTypeEdit onCell:cell];
            CGRect newF = l.frame;
            newF.origin.x += 10;
            l.frame = newF;
            
//            CGRect frame = cell.backgroundView.frame;
//            frame.origin.x = 10;
//            UILabel* l = [[[UILabel alloc] initWithFrame:frame] autorelease];
//            l.tag = kTagForCommand;
//            // Used to delete this command when required (usually to show another command)
//            objc_setAssociatedObject(l, kCommandType, [NSNumber numberWithInt:kCommandTypeEdit], OBJC_ASSOCIATION_ASSIGN);
//            l.text = NSLocalizedString(@"Edit", nil);
//            [[LKThemeProvider defaultThemeProvider] themePanGestureCommandLabel:l];
//            [cell.backgroundView addSubview:l];
//            l.alpha = 0;
//            CGPoint orignalCenter = l.center;
//            CGPoint alteredCenter = orignalCenter;
//            alteredCenter.y -= 30;
//            l.center = alteredCenter;
//            [UIView animateWithDuration:0.35 animations:^(void) {
//                l.alpha = 1;
//                l.center = orignalCenter;
//            } completion:^(BOOL finished) {}];
            
        } else {
            NSNumber* commandType = objc_getAssociatedObject(v, kCommandType);
            if([commandType intValue] != kCommandTypeEdit) {
                [v removeFromSuperview];
            }
            CGFloat comp = (percentCrossed/100);
            cell.backgroundView.backgroundColor = [UIColor colorWithRed:comp green:0 blue:0.5 alpha:1];
        }
    } else if(LKGestureCommandDeactivate == command) {
        NSNumber* currentCommandType = objc_getAssociatedObject(v, kCommandType);
        if([currentCommandType intValue] != kCommandTypeDeactivate) {
            [UIView animateWithDuration:0.25 animations:^(void) {
                CATransform3D rotate = CATransform3DMakeRotation(DEGREES_TO_RADIANS(180), 1, 0, 0);
                v.layer.transform = rotate;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25 animations:^{
                    objc_setAssociatedObject(v, kCommandType, [NSNumber numberWithInt:kCommandTypeDeactivate], OBJC_ASSOCIATION_ASSIGN);
                    CATransform3D rotate = CATransform3DMakeRotation(DEGREES_TO_RADIANS(0), 1, 0, 0);
                    v.layer.transform = rotate;
                    UILabel* l = (UILabel*)v;
                    l.text = NSLocalizedString(@"Deactivate", nil);
                } completion:^(BOOL finished) {
                }];
            }];
            NSLog(@"Identified deactivate command");
        } else {
            CGFloat comp = (percentCrossed/100);
            cell.backgroundView.backgroundColor = [UIColor colorWithRed:comp green:0 blue:0.5 alpha:1];
            NSLog(@"Continue deactivate command");
        }
        
    } else if(LKGestureCommandRemove == command) {
        if(!v) {
            cell.backgroundView.backgroundColor = [UIColor redColor];
            UILabel* l = [self addCommandLabelWithText:NSLocalizedString(@"Remove", nil) withCommandType:kCommandTypeRemove onCell:cell];
            l.textAlignment = UITextAlignmentRight;
            CGRect newF = l.frame;
            newF.origin.x -= 10;
            l.frame = newF;
        }
    } else {
        
    }
    return;
}

- (BOOL)cell:(UITableViewCell*)cell shouldRestoreToOriginWithCrossLevel:(CGFloat)level {
    return YES;
}

- (void)cell:(UITableViewCell*)cell gestureEndedAtCrossLevel:(CGFloat)level {
    NSLog(@"%s %f",__PRETTY_FUNCTION__,level);
    CGFloat w = cell.frame.size.width;
    CGFloat percentCrossed = (level*100)/w;
    LKGestureCommand command = [self gestureCommandForCrossLevelPercent:percentCrossed];
    cell.backgroundView = nil;
    
    LKReminder* reminder = objc_getAssociatedObject(cell, kCellReminder);
    if(LKGestureCommandEdit == command) {
        [[LKMediator sharedInstance].manager editReminder:reminder];
    } else if(LKGestureCommandDeactivate == command) {
        
    } else if(LKGestureCommandRemove == command) {
        [[[LKMediator sharedInstance] reminderModel] removeReminder:reminder];
    }
}

- (void)cellRestoredToOrigin:(UITableViewCell*)cell {
    
}

@end
