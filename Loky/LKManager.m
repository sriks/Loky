//
//  LKManager.m
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/NSNotification.h>

#import "LKReminder.h"
#import "LKManager.h"
#import "LKMediator.h"

NSString* LKManagerUpdateAvailableNotification = @"com.loky.updateavailable";

@interface LKManager ()<CLLocationManagerDelegate> {
    CLGeocoder* _geoCoder;
    NSArray* _reminders; // model, owning
    CLLocationManager* _locMgr;
}

@end

@implementation LKManager

#pragma mark - pimpl

- (void)fireReminder:(LKReminder*)reminder {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,reminder);
    UILocalNotification* notif = [[[UILocalNotification alloc] init] autorelease];
    notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    notif.timeZone = [NSTimeZone defaultTimeZone];
    notif.alertBody = reminder.subject;
    notif.soundName = UILocalNotificationDefaultSoundName;
    NSLog(@"reminder id %@",reminder.reminderID);
    notif.userInfo = @{kLKReminderKeyID:reminder.reminderID};
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}

- (LKReminder*)findReminderForRegion:(CLRegion*)region {
    LKReminderModel* model = [LKMediator sharedInstance].reminderModel;
    for (LKReminder* reminder in model.reminders) {
        if([reminder.region.identifier isEqualToString:region.identifier]) {
            return reminder;
        }
    }
    return nil; // not found
}

- (LKReminder*)findReminderWithID:(NSString*)reminderID {
    LKReminderModel* model = [LKMediator sharedInstance].reminderModel;
    for (LKReminder* reminder in model.reminders) {
        if([reminder.reminderID isEqualToString:reminderID])
            return reminder;
    }
    return nil; // not found
}

#pragma mark - lifecycle
- (void)dealloc {
    [_geoCoder release];
    [super dealloc];
}

#pragma mark - Public Interface

- (CLLocation*)currentLocation {
    return _locMgr.location;
}

/*!
 Provides UI to create new reminder
 */
- (void)createReminder {
    [[LKMediator sharedInstance] loadViewWithIdentifier:kLKViewAddReminderView info:nil];
}

- (void)removeReminder:(LKReminder*)reminder {
    
}

- (void)showReminder:(LKReminder*)reminder {
    [[LKMediator sharedInstance] loadViewWithIdentifier:kLKViewReminderSummary info:nil];
}

- (void)editReminder:(LKReminder*)reminder {
    [[LKMediator sharedInstance] loadViewWithIdentifier:kLKViewEditReminderView info:@{kViewInfoKeyReminder:reminder}];
}

/*!
 Adds a reminder to reminder model
 */
- (void)addReminder:(LKReminder*)reminder {
    
    // test
    NSArray* reminders = [[LKMediator sharedInstance].reminderModel reminders];
    NSArray* allsubjects = [reminders valueForKeyPath:@"@unionOfObjects.subject"];
    NSLog(@"all subjects %@",allsubjects);
    // test
    
    [reminder dump];
    // add to reminder model
    [[LKMediator sharedInstance].reminderModel addReminder:reminder];

    // Check if reminder can be expired now!
    if([reminder isLocationBased] &&
       (LKReminderDirectionLeave != reminder.direction)) {
        CLLocation* currLocation = [LKMediator sharedInstance].locationManager.location;
        if([reminder.region containsCoordinate:currLocation.coordinate]) {
            NSLog(@"%s %s",__PRETTY_FUNCTION__,"User is in current location itself");
            [self userEnteredRegion:reminder.region];
        }
    } else {
        // check current time/date and fire reminder
    }
}

- (void)geoCodeLocation:(CLLocation*)location withCompletionBlock:(CLGeocodeCompletionHandler)completionBlock {
    if(!_geoCoder)
        _geoCoder = [[CLGeocoder alloc] init];
    [_geoCoder cancelGeocode];
    [_geoCoder reverseGeocodeLocation:location completionHandler:completionBlock];
}

- (void)updateLocation {
    if(!_locMgr) {
        _locMgr = [[CLLocationManager alloc] init];
        _locMgr.delegate = self;
        _locMgr.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    [_locMgr startUpdatingLocation];
}

- (void)userEnteredRegion:(CLRegion*)region {
    LKReminder* reminder = [self findReminderForRegion:region];
    if(LKReminderDirectionArrive == reminder.direction) {
        [self fireReminder:reminder];
    }
}

- (void)userExitedRegion:(CLRegion*)region {
    LKReminder* reminder = [self findReminderForRegion:region];
    if(LKReminderDirectionLeave == reminder.direction) {
        [self fireReminder:reminder];
    }
}

- (void)showAlertForReminderWithID:(NSString*)reminderID {
    LKReminder* reminder = [self findReminderWithID:reminderID];
    if(reminder) {
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:kLKProductName
                                                         message:reminder.subject
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
        [alert show];
    }
}

#pragma mark CLLocationManagerDelegate

// TODO: add significant location updates as well
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [[NSNotificationCenter defaultCenter] postNotificationName:LKManagerUpdateAvailableNotification object:newLocation];
    [manager stopUpdatingLocation];
}
@end
