//
//  LKMediator.h
//  Loky
//
//  Created by Srikanth Sombhatla on 03/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKConstants.h"
#import "LKManager.h"
#import "LKReminderModel.h"

@interface LKMediator : NSObject
+ (LKMediator*)sharedInstance;

- (void)setupNavigationOnWindow:(UIWindow*)window;
- (void)loadViewWithIdentifier:(NSString*)viewId info:(NSDictionary*)info;
- (void)popView;
- (BOOL)saveState;
- (BOOL)restoreState;

@property (nonatomic,retain,readonly) LKManager* manager;
@property (nonatomic,retain,readonly) LKReminderModel* reminderModel;
@property (nonatomic,retain,readonly) CLLocationManager* locationManager;

@end
