//
//  LKLocationDelegate.m
//  Loky
//
//  Created by Srikanth Sombhatla on 31/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "LKLocationDelegate.h"
#import "LKMediator.h"

@implementation LKLocationDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,[error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"%s %@ %@",__PRETTY_FUNCTION__,[region description],[error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"%s %@",__PRETTY_FUNCTION__,[region description]);
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%s %d %@",__PRETTY_FUNCTION__,self.launchedFromBackground,[region description]);
    [[LKMediator sharedInstance].manager userEnteredRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%s %d %@",__PRETTY_FUNCTION__,self.launchedFromBackground,[region description]);
    [[LKMediator sharedInstance].manager userExitedRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //NSLog(@"%s %@",__PRETTY_FUNCTION__,[newLocation description]);
}
@end
