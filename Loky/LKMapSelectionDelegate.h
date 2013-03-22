//
//  LKMapSelectionDelegate.h
//  Loky
//
//  Created by Srikanth Sombhatla on 06/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol LKMapSelectionDelegate <NSObject>
@required
- (void)mapView:(MKMapView*)mapView coordinateSelected:(CLLocationCoordinate2D)coordinate;
@end
