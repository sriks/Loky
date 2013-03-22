//
//  LocationSelectionViewController.h
//  Loky
//
//  Created by Srikanth Sombhatla on 26/09/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKMapView.h>

@protocol LKMapSelectionDelegate;
@interface LocationSelectionViewController : UIViewController<MKMapViewDelegate,UIGestureRecognizerDelegate>

- (void)focusToCurrentLocation;
- (void)focusToCoordinate:(CLLocationCoordinate2D)coordinate;
@property (nonatomic,readwrite,assign) id<LKMapSelectionDelegate> delegate;

@end
