//
//  LKMapLocation.h
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>
#import "LKUtils.h"

// This struct holds data which is used to initialize LKMapLocation
typedef struct LKMapLocationData {
    CLLocationCoordinate2D  coordinate;
    CLPlacemark*            placemark;
    UIImage*                mapImage;
}LKMapLocationData;

@interface LKMapLocation : NSObject <NSCoding>

+ (id)mapLocationWithLocationData:(LKMapLocationData)locationData;

@property (nonatomic,assign,readonly)  CLLocationCoordinate2D coordinate;
@property (nonatomic,retain,readonly)  CLPlacemark* placemark;
@property (nonatomic,retain,readonly)  UIImage* mapImage;
@property (nonatomic,readonly)         LKAddress address;
@end
