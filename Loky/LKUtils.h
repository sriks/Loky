//
//  LKUtils.h
//  Loky
//
//  Created by Srikanth Sombhatla on 13/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LKConstants.h"

typedef struct {
    NSString* addressLine1;
    NSString* addressLine2;
}LKAddress ;

@interface LKUtils : NSObject

+ (LKAddress)addressForPlacemark:(CLPlacemark*)placemark;

@end
