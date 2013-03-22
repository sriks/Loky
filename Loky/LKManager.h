//
//  LKManager.h
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LKMapSelectionDelegate.h"
#import "LKReminder.h"

extern NSString* LKManagerUpdateAvailableNotification;

@interface LKManager : NSObject
- (void)createReminder;
- (void)removeReminder:(LKReminder*)Reminder;
- (void)showReminder:(LKReminder*)reminder;
- (void)editReminder:(LKReminder*)Reminder;
- (void)addReminder:(LKReminder*)reminder;
- (void)geoCodeLocation:(CLLocation*)location withCompletionBlock:(CLGeocodeCompletionHandler)completionBlock;
- (void)updateLocation;
- (void)userEnteredRegion:(CLRegion*)region;
- (void)userExitedRegion:(CLRegion*)region;
- (void)showAlertForReminderWithID:(NSString*)reminderID;

- (LKReminder*)findReminderWithID:(NSString*)reminderID;

@property (nonatomic,readonly) CLLocation* currentLocation;
@end
