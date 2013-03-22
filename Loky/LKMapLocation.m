//
//  LKMapLocation.m
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "LKMapLocation.h"

// Keys for objects to be archieved
#define kObjKeyCoordinateLat        @"coordinatestruct.lat"
#define kObjKeyCoordinateLong       @"coordinatestruct.long"
#define kObjKeyPlacemark            @"placemark"
#define kObjKeyMapImage             @"mapImage"

@interface LKMapLocation ()

@property (nonatomic,assign,readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain,readwrite) CLPlacemark* placemark;
@property (nonatomic,retain,readwrite) UIImage* mapImage;

@end

@implementation LKMapLocation

@synthesize placemark = _placemark;
@synthesize coordinate = _coordinate;

+ (id)mapLocationWithLocationData:(LKMapLocationData)locationData {
    LKMapLocation* obj = [[[LKMapLocation alloc] init] autorelease];
    obj.coordinate = locationData.coordinate;
    obj.placemark = locationData.placemark;
    //obj.mapImage = locationData.mapImage;
    return obj;
}

- (void)dealloc {
    self.placemark = nil;
    self.mapImage = nil;
    [super dealloc];
}

# pragma mark publicinterface

- (LKAddress) address {
    return [LKUtils addressForPlacemark:self.placemark];
}

# pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.coordinate.latitude forKey:kObjKeyCoordinateLat];
    [aCoder encodeDouble:self.coordinate.longitude forKey:kObjKeyCoordinateLong];
    [aCoder encodeObject:self.placemark forKey:kObjKeyPlacemark];
    [aCoder encodeObject:self.mapImage forKey:kObjKeyMapImage];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    LKMapLocationData mapData;
    CLLocationCoordinate2D coord;
    coord.latitude = [aDecoder decodeDoubleForKey:kObjKeyCoordinateLat];
    coord.longitude = [aDecoder decodeDoubleForKey:kObjKeyCoordinateLong];
    mapData.coordinate = coord;
    mapData.placemark = [[aDecoder decodeObjectForKey:kObjKeyPlacemark] retain];
    mapData.mapImage = [[aDecoder decodeObjectForKey:kObjKeyMapImage] retain];
    return [[LKMapLocation mapLocationWithLocationData:mapData] retain];
}

@end
