//
//  LKReminder.h
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LKConstants.h"

enum LKReminderState {
    // Reminder is in an invalid state 
    LKReminderStateInvalid = 0,
    // Reminder is active expected to be fired as per the condition
    LKReminderStateActive,
    // Reminder is inactive, where it is not fired even though the condition triggers.
    LKReminderStateInActive,
    // Reminder is expired on condition trigger.
    LKReminderStateExpired
};

// User preference of direction.
typedef enum {
    // These are inline with the segmented widget used for direction choice
    LKReminderDirectionNone = -1,
    LKReminderDirectionArrive,
    LKReminderDirectionNearby,
    LKReminderDirectionLeave
} LKDirection;

@interface LKReminder : NSObject <NSCoding>

/*!
 Activates the reminder.
 */
- (void)activate;
- (void)deactivate;
- (void)expired;
- (BOOL)isActive;
- (BOOL)isLocationBased;
- (BOOL)isDateBased;

- (void)setRegionWithCenter:(CLLocationCoordinate2D)center withRadius:(CLLocationDistance)radius;
- (void)dump;

@property (nonatomic,copy,readwrite)        NSString* subject;
@property (nonatomic,readonly)              NSString* locationDescription;
@property (nonatomic,readonly)              NSString* dateDescription;
@property (nonatomic,retain,readonly)       CLRegion* region;
@property (nonatomic,retain,readwrite)      CLPlacemark* placemark;
@property (nonatomic,readwrite)             LKDirection direction;
// TODO: Handle date properly http://oleb.net/blog/2011/11/working-with-date-and-time-in-cocoa-part-1/
@property (nonatomic,retain,readwrite)      NSDate* date;
@property (nonatomic,assign,readonly)       enum LKReminderState state;

// Provides unique ID for a reminder.
@property (nonatomic,copy,readonly)              NSString* reminderID;
// TODO:
/*
 Add snooze property. User enters/leaves a region and reminder is fired after a snooze period.
 */
@end
