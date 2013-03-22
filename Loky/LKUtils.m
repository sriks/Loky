//
//  LKUtils.m
//  Loky
//
//  Created by Srikanth Sombhatla on 13/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "LKUtils.h"

@implementation LKUtils

+ (LKAddress)addressForPlacemark:(CLPlacemark*)placemark {
    LKAddress addr;
    addr.addressLine1 = placemark.name;
    addr.addressLine2 = [NSString stringWithFormat:@"%@ %@",placemark.subLocality,placemark.locality];
    return addr;
}
@end
