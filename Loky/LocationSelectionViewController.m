//
//  LocationSelectionViewController.m
//  Loky
//
//  Created by Srikanth Sombhatla on 26/09/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LocationSelectionViewController.h"
#import "LKMediator.h"
#import "LKMapLocation.h"
#import "LKMapSelectionDelegate.h"
#import "LKManager.h"

@interface LocationSelectionViewController () {
    CLGeocoder* _geocoder;
    id<MKAnnotation> _addedAnnotation;
}

- (void)tappedOnMapView:(UITapGestureRecognizer*)sender;
- (void)alignVisibleMapRegionToUserLocation;
- (void)addAnnotationForCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)doneSelected;
- (void)cancelSelected;

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (assign, nonatomic, readwrite) CLLocationCoordinate2D selectedCoordinate;
@end

@implementation LocationSelectionViewController
@synthesize mapView = _mapView;
@synthesize delegate = _delegate;
@synthesize selectedCoordinate = _selectedCoordinate;

#pragma mark - pimpl

- (void)tappedOnMapView:(UITapGestureRecognizer*)sender {
    if(1 == sender.numberOfTapsRequired) {
        CGPoint tapPoint = [sender locationInView:self.mapView];
        NSLog(@"tapped on point %@",NSStringFromCGPoint(tapPoint));
        self.selectedCoordinate = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
        [self addAnnotationForCoordinate:self.selectedCoordinate];
        if(![self.navigationItem.rightBarButtonItem isEnabled])
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
}

- (void)alignVisibleMapRegionToUserLocation {}

- (void)addAnnotationForCoordinate:(CLLocationCoordinate2D)coordinate {
    MKPointAnnotation* pointAnnotation = [[[MKPointAnnotation alloc] init] autorelease];
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = @"foo";
    if(_addedAnnotation)
        [self.mapView removeAnnotation:_addedAnnotation];
    [self.mapView addAnnotation:pointAnnotation];
    _addedAnnotation = pointAnnotation;
}

- (void)doneSelected {
    [self.delegate mapView:self.mapView coordinateSelected:self.selectedCoordinate];
}

- (void)cancelSelected {
    [[LKMediator sharedInstance] popView];
}

#pragma mark - lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _geocoder = [[CLGeocoder alloc] init];
        _addedAnnotation = nil;
    }
    return self;
}

- (void)dealloc {
    self.mapView = nil;
    [_geocoder release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.showsUserLocation = YES;

    if([LKMediator sharedInstance].locationManager.location) {
        CLLocationCoordinate2D usercoordinate = [LKMediator sharedInstance].locationManager.location.coordinate;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(usercoordinate, 6000, 6000);
        [self.mapView setRegion:region animated:YES];
    }
    
    [self.navigationItem setTitle: NSLocalizedString(@"Select location", nil)];
    UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneSelected)] autorelease];
    [doneButton setEnabled:NO]; // enabled when user selects a location
    self.navigationItem.rightBarButtonItem = doneButton;
    UITapGestureRecognizer* doubleTapGesture = [[[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                        action:@selector(tappedOnMapView:)] autorelease];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delegate = self;
    [self.mapView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer* tapGesture = [[[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tappedOnMapView:)] autorelease];
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.mapView addGestureRecognizer:tapGesture];
    [self alignVisibleMapRegionToUserLocation];
}

- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark pulicinterface 
- (void)focusToCurrentLocation {
    CLLocation* loc = [LKMediator sharedInstance].manager.currentLocation;
    if(loc)
        [self focusToCoordinate:loc.coordinate];
}

- (void)focusToCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer  shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
