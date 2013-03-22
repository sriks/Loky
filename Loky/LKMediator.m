//
//  LKMediator.m
//  Loky
//
//  Created by Srikanth Sombhatla on 03/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "LKMediator.h"
#import "LKThemeProvider.h"
#import "LKConstants.h"
#import "LocationSelectionViewController.h"
#import "AllRemindersViewController.h"
#import "AddReminderViewController.h"
#import "LKLocationDelegate.h"
#import "LKReminderSummary.h"

@interface LKMediator () {
    // non-owning view controllers
    UINavigationController*                 _mainNavController;
    AllRemindersViewController*             _allRemindersViewController;
    LocationSelectionViewController*        _locationSelectionViewController;
    LKLocationDelegate*                     _locationDelegate;
}

- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated;

@property (nonatomic,retain,readwrite) LKManager* manager;
@property (nonatomic,retain,readwrite) LKReminderModel* reminderModel;
@property (nonatomic,retain,readwrite) CLLocationManager* locationManager;

@end

@implementation LKMediator

#pragma mark - pimpl
- (void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated {
    [_mainNavController pushViewController:viewController animated:animated];
}

- (NSString*)pathForReminderArchive {
    NSString* filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    filePath = [filePath stringByAppendingPathComponent:@"reminders.archive"];
    return filePath;
}

#pragma mark - lifecycle
- (void)dealloc {
    [self saveState];
    self.manager = nil;
    self.reminderModel = nil;
    [_locationSelectionViewController release];
    [_locationManager release];
    [_locationDelegate release];
    [super dealloc];
}


- (id)init {
    self = [super init];
    if(self) {
        self.manager = [[LKManager alloc] init];
        [self.manager updateLocation];
        self.reminderModel = [[LKReminderModel alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        _locationDelegate = [[LKLocationDelegate alloc] init];
        self.locationManager.delegate = _locationDelegate;
        [self.locationManager startUpdatingLocation]; // TODO: Move this to a more controllable place.
    }
    return self;
}

#pragma mark - public interface
+ (LKMediator*)sharedInstance {
    // TODO: How is this released?
    static LKMediator* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[LKMediator alloc] init];
    });
    return sharedInstance;
}

- (void)setupNavigationOnWindow:(UIWindow*)window {
    // Main view
    _allRemindersViewController = [[[AllRemindersViewController alloc]
                                     initWithNibName:@"AllRemindersView_iPhone" bundle:nil] autorelease];
    // Create nav controller
    _mainNavController = [[[UINavigationController alloc] initWithRootViewController:_allRemindersViewController] autorelease];
    
    [[LKThemeProvider defaultThemeProvider] themeNavigationController:_mainNavController];
    window.rootViewController = _mainNavController;
}

- (void)loadViewWithIdentifier:(NSString*)viewId info:(NSDictionary*)info {
    if([viewId isEqualToString:kLKViewAddReminderView]) {
        
        AddReminderViewController* newReminderViewController = [[AddReminderViewController alloc]
                                                                initWithNibName:@"AddReminderView_iPhone" reminder:nil];
        [self pushViewController:newReminderViewController animated:YES];
        [newReminderViewController release];
    } else if([viewId isEqualToString:kLKViewEditReminderView]) {
        LKReminder* reminder = [info objectForKey:kViewInfoKeyReminder];
        AddReminderViewController* editReminderViewController = [[AddReminderViewController alloc]      initWithNibName:@"AddReminderView_iPhone" reminder:reminder];
        [self pushViewController:editReminderViewController animated:YES];
    } else if([viewId isEqualToString:kLKViewReminderSummary]) {
        //LKReminder* reminder = [info objectForKey:kViewInfoKeyReminder];
        LKReminderSummary* summary = [[[LKReminderSummary alloc] initWithNibName:@"ReminderSummaryView_iPhone" bundle:nil] autorelease];
        [self pushViewController:summary animated:YES];
    }
}

- (void)popView {
    [_mainNavController popViewControllerAnimated:YES];
}

- (BOOL)saveState {
    if(self.reminderModel.count) {
        // TODO: delete existing archive if any
        NSString* filePath = [self pathForReminderArchive];
        BOOL b = [NSKeyedArchiver archiveRootObject:self.reminderModel.reminders toFile:filePath];
        NSLog(@"%s archieved %d",__PRETTY_FUNCTION__,b);
        return b;
    } else {
        return NO;
    }
}

- (BOOL)restoreState {
    NSString* filePath = [self pathForReminderArchive];
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if([fileMgr fileExistsAtPath:filePath]) {
        NSArray* arr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        NSLog(@"arr %@",arr);
        for (LKReminder* reminder in arr) {
            [self.reminderModel addReminder:reminder];
        }
        return (arr.count > 0);
    } else {
        return NO;
    }
}

@end
