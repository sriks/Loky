//
//  LKReminder.m
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "LKReminder.h"
#import "LKMediator.h"
#import "LKConstants.h"

static char* regionKVOContext;
NSString* const LKReminderKeyID = @"reminderID";

// object keys identifying ivars to be archieved.
#define kObjKeyDate                 @"date"
#define kObjKeySubject              @"subject"
#define kObjKeyRegion               @"region"
#define kObjKeyDirection            @"direction"
#define kObjKeyReminderID           @"reminderID"

@interface LKReminder ()
@property (nonatomic,assign,readwrite) enum LKReminderState state;
@property (nonatomic,retain,readwrite) CLRegion* region;
@end

@implementation LKReminder

//@synthesize reminderID = _reminderID; // for sake of clarity

#pragma mark lifecycle

- (id)init {
    self = [super init];
    if(self) {
        self.direction = LKReminderDirectionNone;
        _reminderID = [[[NSDate date] description] copy];
        //[self addObserver:self forKeyPath:@"region" options:NSKeyValueObservingOptionNew context:regionKVOContext];
    }
    return self;
}

- (void)dealloc {
    [_date release];
    [_subject release];
    [_region release];
    [_reminderID release];
    [super dealloc];
}

#pragma mark public interface

/*!
 \brief Activates reminder. Call this method after populating the required properties of reminder.
 **/
- (void)activate {
    self.state = LKReminderStateActive;
    CLLocationManager* locMgr = [LKMediator sharedInstance].locationManager;
    [locMgr startUpdatingLocation];
    [locMgr startMonitoringForRegion:self.region desiredAccuracy:kCLLocationAccuracyBestForNavigation];
}

/*!
 \brief
 **/
- (void)deactivate {
    self.state = LKReminderStateInActive;
    CLLocationManager* locMgr = [LKMediator sharedInstance].locationManager;
    [locMgr stopMonitoringForRegion:self.region];
}

- (void)expired {
    [self deactivate];
    self.state = LKReminderStateExpired;
}

- (BOOL)isActive {
    return (LKReminderStateActive == self.state);
}

/*!
 \brief returns YES if the reminder is location based.
 **/
- (BOOL)isLocationBased {
    return (nil != self.region);
}

/*!
 \brief returns YES if the reminder is date based.
 **/
- (BOOL)isDateBased {
    return (nil != self.date);
}

- (NSString*)locationDescription {
    return [self.placemark description];
}

- (NSString*)dateDescription {
    return [self.date descriptionWithLocale:[NSLocale currentLocale]];
}

- (void)setRegionWithCenter:(CLLocationCoordinate2D)center withRadius:(CLLocationDistance)radius {
    self.region = [[CLRegion alloc] initCircularRegionWithCenter:center radius:radius identifier:self.reminderID];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.date forKey:kObjKeyDate];
    [encoder encodeObject:self.subject forKey:kObjKeySubject];
    [encoder encodeObject:self.region forKey:kObjKeyRegion];
    [encoder encodeInteger:self.direction forKey:kObjKeyDirection];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if(self = [super init]) {
        self.date = [decoder decodeObjectForKey:kObjKeyDate];
        self.subject = [decoder decodeObjectForKey:kObjKeySubject];
        self.region = [decoder decodeObjectForKey:kObjKeyRegion];
        self.direction = [decoder decodeIntegerForKey:kObjKeyDirection];
    }
    return self;
}

#pragma KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%s key is %@",__PRETTY_FUNCTION__,keyPath);
}

- (void)dump {
    NSLog(@"%s Subject %@\nLocation %@\nDate %@",__PRETTY_FUNCTION__,
          self.subject,
          self.region,
          self.date);
}

@end
