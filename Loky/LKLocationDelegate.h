//
//  LKLocationDelegate.h
//  Loky
//
//  Created by Srikanth Sombhatla on 31/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LKLocationDelegate : NSObject <CLLocationManagerDelegate>
    
@property (nonatomic,readwrite) BOOL launchedFromBackground;
@end
