//
//  AddReminderViewController.m
//  Loky
//
//  Created by Srikanth Sombhatla on 10/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "AddReminderViewController.h"
#import "LocationSelectionViewController.h"
#import "LKMediator.h"
#import "UIView+DCUIView.h"
#import "LKThemeProvider.h"

// TableView IDs
#define SECTION_SUBJECT             0
#define SECTION_SUBJECT_MAX_ROWS    1
#define CELL_SUBJECT                0

#define SECTION_DATE                SECTION_SUBJECT+1
#define ROW_ENABLE_REMIND_ON_DATE   0
#define ROW_REMIND_ON_THIS_DATE     1
#define SECTION_DATE_MAX_ROWS       2

#define SECTION_LOCATION            SECTION_DATE+1
#define ENABLE_REMIND_IN_LOCATION   0
#define REMIND_IN_LOCATION          1
#define SECTION_LOCATION_MAX_ROWS   2

// Direction choice of arriving, leaving or nearby the selected location
#define SECTION_DIRECTION_CHOICE    SECTION_LOCATION+1
#define ROW_DIRECTION_CHOICE        0
#define SECTION_DIRECTION_CHOICE_MAX_ROWS 1

#define SECTION_MAPIMAGE            SECTION_DIRECTION_CHOICE+1
#define LOCATION_MAPIMAGE           0

#define MAX_SECTIONS                5

#define ENTER_REGION                0
#define LEAVING_REGION              1

// Tags for controls of interest
#define TAG_SUBJECT_TEXTFIELD       0x2000
#define TAG_DATEPICKER              0x2001
#define TAG_DIRECTION_SEGMENT       0x2002
#define TAG_SWITCH_ENABLE_LOCATION  0x2003
#define TAG_SWITCH_ENABLE_DATE      0x2004


static char kSubjectContext;

// Key paths to observe
NSString* kKeyPathLocation = @"switchEnableDate.on";

// TODO: This is a crap implementation of static settings like table view.
// May be I should use Storyboards and other approach to build static table view.
@interface AddReminderViewController () <UITextFieldDelegate> {
    LocationSelectionViewController* _locSelectionViewController;
    LKDirection _directionChoice;
    BOOL _comitted; // user has made a choice which can be committed.
}

// private properties
@property (retain,nonatomic) UITextField* subjectTextField;

// Reminder's properties
@property (retain,nonatomic) UIImage* croppedImage;

// View 
@property (retain,nonatomic) IBOutlet UITableView*     tableView;
@property (retain,nonatomic) IBOutlet UITableViewCell* cellSubject;
@property (retain,nonatomic) IBOutlet UITableViewCell* cellNotes;
@property (retain,nonatomic) IBOutlet UITableViewCell* cellEnableRemindOnDate;
@property (retain,nonatomic) IBOutlet UITableViewCell* cellRemindDate;
@property (retain,nonatomic) IBOutlet UITableViewCell* cellEnableRemindInLocation;
@property (retain,nonatomic) IBOutlet UITableViewCell* cellRemindInLocation;
@property (retain,nonatomic) IBOutlet UITableViewCell* cellMapImage;
// TODO: These switches can be creates programatically
@property (retain,nonatomic) IBOutlet UISwitch*        switchEnableDate;
@property (retain,nonatomic) IBOutlet UISwitch*        switchEnableLocation;
@property (retain,nonatomic) IBOutlet UIImageView*     mapImage;

@property (retain,nonatomic) NSDate*                   selectedDate;
@end

@implementation AddReminderViewController
@synthesize reminder = _reminder;

#pragma mark pimpl

- (void)showSelectDateCell {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:ROW_REMIND_ON_THIS_DATE inSection:SECTION_DATE];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    self.selectedDate = [NSDate date];
}

- (void)hideSelectDateCell {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:ROW_REMIND_ON_THIS_DATE inSection:SECTION_DATE];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)showSelectLocationCell {
    [self.tableView reloadData];
}

- (void)hideSelectLocationCell {
        [self.tableView reloadData];
}

- (void)updateUIForReminder:(LKReminder*)reminder {
    [self.tableView reloadData];
}

- (void)loadLocationSelectionView {
    if(!_locSelectionViewController) {
        _locSelectionViewController = [[LocationSelectionViewController alloc] initWithNibName:@"LocationSelectionView_iPhone" bundle:nil];
        _locSelectionViewController.delegate = self;
    }
    [self.navigationController pushViewController:_locSelectionViewController animated:YES];
}

- (void)showDatePicker {
    UIDatePicker* datePicker = [[[UIDatePicker alloc] init] autorelease];
    datePicker.tag = TAG_DATEPICKER;
    datePicker.date = [NSDate dateWithTimeIntervalSinceNow:60];
    CGRect newFrame = datePicker.frame;
    newFrame.origin.y = self.view.frame.size.height - datePicker.frame.size.height;
    [self.view addSubview:datePicker];
    [datePicker addTarget:self action:@selector(handleUIControlEvent:) forControlEvents:UIControlEventValueChanged];
    [UIView animateWithDuration:0.25
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         datePicker.frame = newFrame;
                     } completion:^(BOOL finished){
                         UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(dateSelectionCommitted)] autorelease];
                         UIBarButtonItem* cancelButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonSystemItemCancel target:self action:@selector(dateSelectionCancelled)] autorelease];
                         UINavigationItem* navItem = self.navigationItem;
                         navItem.rightBarButtonItem = doneButton;
                         navItem.leftBarButtonItem =  cancelButton;
                     }];
}

- (void)addMasterDoneButtonAsRightSide {
    UIBarButtonItem* doneButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneSelected)] autorelease];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)doneSelected {
    // TODO: Move this to delegate
    if(0 == _subjectTextField.text.length) {
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:kLKProductName
                                                      message:NSLocalizedString(@"You forgot to tell me what to remind about?", nil)
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                            otherButtonTitles:nil] autorelease];
        [alert show];
    } else {
        self.reminder.subject = _subjectTextField.text;
        if(self.switchEnableLocation.isOn)
            self.reminder.direction = _directionChoice;
        else
            self.reminder.direction = -1;
        
        if(self.switchEnableDate.isOn)
            self.reminder.date = self.selectedDate;
        else
            self.reminder.date = nil;
        
        NSLog(@"subject %@",self.reminder.subject);
        [self.reminder activate];
        [[LKMediator sharedInstance].manager addReminder:self.reminder];
        [[LKMediator sharedInstance] popView];
    }
}

- (void)dateSelectionCommitted {
    UIDatePicker* datePicker = (UIDatePicker*)[self.view viewWithTag:TAG_DATEPICKER];
    if(datePicker) {
        NSDate* date = datePicker.date;
        NSLog(@"selected date %@",date);
        self.selectedDate = date;
        [datePicker removeFromSuperview];
    }
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    [self addMasterDoneButtonAsRightSide];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:ROW_REMIND_ON_THIS_DATE inSection:SECTION_DATE];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)dateSelectionCancelled {
    UIDatePicker* datePicker = (UIDatePicker*)[self.view viewWithTag:TAG_DATEPICKER];
    if(datePicker)
        [datePicker removeFromSuperview];
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    [self addMasterDoneButtonAsRightSide];
}

/*!
 Handles what should be done when location is committed.
 */
- (void)handleCommittedLocation:(CLLocation*)location {
    CLLocationCoordinate2D selectedCoord = location.coordinate;
    CLGeocodeCompletionHandler handler;
    handler = ^(NSArray* placemarks, NSError* error) {
        if(!error) {
            // Here we set location related data of the reminder
            CLPlacemark* p = [placemarks objectAtIndex:0];
            self.reminder.placemark = p;
            CLRegion* region = [[[CLRegion alloc] initCircularRegionWithCenter:selectedCoord
                                                                        radius:800
                                                                    identifier:@"Im testing"] autorelease];
            
            [self.reminder setRegionWithCenter:region.center withRadius:region.radius];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self updateUIForReminder:self.reminder];
        } else {
            NSLog(@"%s error %@",__PRETTY_FUNCTION__,[error localizedDescription]);
        }
    };
    
    CLLocation* loc = [[[CLLocation alloc]
                        initWithLatitude:selectedCoord.latitude longitude:selectedCoord.longitude] autorelease];
    [[LKMediator sharedInstance].manager geoCodeLocation:loc withCompletionBlock:handler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil reminder:(LKReminder*)reminder {
    self = [[AddReminderViewController alloc] initWithNibName:nibNameOrNil bundle:nil];
    if(self) {
        if(reminder)
            _reminder = reminder;
        else
            _reminder = [[LKReminder alloc] init];
    }
    return self;
}

- (void)dealloc {
    // TODO: release
    [_reminder release];
    [_locSelectionViewController release];
    [_subjectTextField release];
    [self setTableView:nil];
    [self setCellSubject:nil];
    [self setCellNotes:nil];
    [self setCellEnableRemindOnDate:nil];
    [self setCellRemindDate:nil];
    [self setCellEnableRemindInLocation:nil];
    [self setCellRemindInLocation:nil];
    [self setSwitchEnableDate:nil];
    [self setSwitchEnableLocation:nil];
    [self.cellMapImage release];
    [self.mapImage release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LKThemeProvider defaultThemeProvider] themeBackgroundImageForView:self.tableView];
    [self addMasterDoneButtonAsRightSide];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.switchEnableDate.on = (self.reminder.date)?(YES):(NO);
    self.switchEnableLocation.on = ([self.reminder isLocationBased])?(YES):(NO);
    [self updateUIForReminder:self.reminder];
    self.switchEnableDate.tag = TAG_SWITCH_ENABLE_DATE;
    [self.switchEnableDate addTarget:self action:@selector(handleUIControlEvent:)
                    forControlEvents:UIControlEventValueChanged];
    self.switchEnableLocation.tag = TAG_SWITCH_ENABLE_LOCATION;
    [self.switchEnableLocation addTarget:self action:@selector(handleUIControlEvent:)
                        forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload {
    [self viewDidUnload];
    self.tableView = nil;
    self.cellEnableRemindOnDate = nil;
    self.cellRemindDate = nil;
    self.cellEnableRemindInLocation = nil;
    self.cellRemindInLocation = nil;
    self.switchEnableDate = nil;
    self.switchEnableLocation = nil;
    self.cellMapImage = nil;
    self.mapImage = nil;
}

#pragma mark publicinterface

- (void)setReminder:(LKReminder *)reminder {
    if(_reminder != reminder)
        [_reminder release];
    _reminder = [reminder retain];
    
    // TODO: use KVO
    // update ui
    [self updateUIForReminder:self.reminder];
}

#pragma mark UIControl callbacks

- (void)handleUIControlEvent:(id)sender {
    if([sender isKindOfClass:[UISwitch class]]) {
        UISwitch* sw = (UISwitch*)sender;
        if(TAG_SWITCH_ENABLE_DATE == sw.tag) {
            if(sw.isOn) {
                [self showSelectDateCell];
            } else {
                [self hideSelectDateCell];
            }
        } else if (TAG_SWITCH_ENABLE_LOCATION == sw.tag) {
            if(sw.isOn) {
                [self showSelectLocationCell];
            } else {
                [self hideSelectLocationCell];
            }
        }
    self.navigationItem.rightBarButtonItem.enabled = sw.isOn;
    } else if([sender isKindOfClass:[UISegmentedControl class]] && TAG_DIRECTION_SEGMENT == ((UIView*)sender).tag) {
        UISegmentedControl* seg = (UISegmentedControl*)sender;
        _directionChoice = seg.selectedSegmentIndex;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int section = indexPath.section;
    if(SECTION_DATE == section) {
        if(ROW_REMIND_ON_THIS_DATE == row)
            [self showDatePicker];
    } else if((SECTION_LOCATION == section && REMIND_IN_LOCATION == row) || SECTION_MAPIMAGE == section) {
        [self loadLocationSelectionView];
        if([self.reminder isLocationBased])
            [_locSelectionViewController focusToCoordinate:self.reminder.region.center];
        else
            [_locSelectionViewController focusToCurrentLocation];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(SECTION_DIRECTION_CHOICE == section && self.switchEnableLocation.isOn) {
        return NSLocalizedString(@"Remind me when I", nil);
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    int section = indexPath.section;
    UITableViewCell* cell = nil;
    
    if(SECTION_SUBJECT == section) {
        if(CELL_SUBJECT == row) {
            cell = self.cellSubject;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
            if (!self.subjectTextField) {
                // TODO: Do styling in theme class
                CGRect frame = CGRectMake(10, 10, cell.frame.size.width-40, cell.frame.size.height-10);
                self.subjectTextField = [[[UITextField alloc]initWithFrame:frame] autorelease];
                self.subjectTextField.highlighted = YES;
                self.subjectTextField.borderStyle = UITextBorderStyleRoundedRect;
                self.subjectTextField.clearButtonMode = UITextFieldViewModeAlways;
                self.subjectTextField.placeholder = NSLocalizedString(@"Get milk", nil);
                self.subjectTextField.text = self.reminder.subject;
                self.subjectTextField.delegate = self;
            }
            [cell.contentView addSubview:_subjectTextField];
        }
    } else if(SECTION_DATE == section) {
        if(ROW_ENABLE_REMIND_ON_DATE == row) {
            cell = self.cellEnableRemindOnDate;
            cell.textLabel.font = [[LKThemeProvider defaultThemeProvider] mediumFontWithBold:YES andItalic:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if(ROW_REMIND_ON_THIS_DATE == row) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"cellIdentifierSelectedDate"];
            if(!cell) {
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifierSelectedDate"];
            }
            
            if(self.reminder.date) {
                NSString* dateString = [self.reminder.date description];
                cell.textLabel.text = dateString;
    
            } else {
                NSString* dateString = [[NSDate date] description];
                cell.textLabel.text = dateString;
            }
            
            cell.textLabel.font = [[LKThemeProvider defaultThemeProvider] mediumFontWithBold:YES andItalic:NO];
        }
    } else if(SECTION_LOCATION == section) {
        if(ENABLE_REMIND_IN_LOCATION == row) {
            cell = self.cellEnableRemindInLocation;
            cell.textLabel.font = [[LKThemeProvider defaultThemeProvider] mediumFontWithBold:YES andItalic:NO];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else if(REMIND_IN_LOCATION == row) {
            cell = self.cellRemindInLocation;
            if([self.reminder isLocationBased]) {
                // TODO: fix it.
                cell.textLabel.text = @"Test address";
                cell.detailTextLabel.text = @"Test addess";
                //cell.textLabel.text = self.reminder.mapLocation.address.addressLine1;
                //cell.detailTextLabel.text = self.reminder.mapLocation.address.addressLine1;
            } else {
                cell.textLabel.text = NSLocalizedString(@"Current location", nil);
                cell.detailTextLabel.text = NSLocalizedString(@"Loading ...", nil);
                CLLocation* currLoc = [LKMediator sharedInstance].manager.currentLocation;
                [self handleCommittedLocation:currLoc];
            }
            
            cell.textLabel.font = [[LKThemeProvider defaultThemeProvider] mediumFontWithBold:YES andItalic:NO];
            cell.detailTextLabel.font = [[LKThemeProvider defaultThemeProvider] smallFontWithBold:NO andItalic:NO];
        }
    } else if (SECTION_DIRECTION_CHOICE == section) {
        if(ROW_DIRECTION_CHOICE == row) {
            cell = [[UITableViewCell alloc] init];
            UISegmentedControl* seg = [[[UISegmentedControl alloc] initWithItems:@[
                NSLocalizedString(@"Arrive", nil),NSLocalizedString(@"Nearby", nil), NSLocalizedString(@"Leave", nil)]] autorelease];
            seg.tag = TAG_DIRECTION_SEGMENT;
            if(self.reminder.direction != LKReminderDirectionNone)
                [seg setSelectedSegmentIndex:self.reminder.direction];
            else
                [seg setSelectedSegmentIndex:1];
            [seg addTarget:self action:@selector(handleUIControlEvent:) forControlEvents:UIControlEventValueChanged];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
            CGRect newFrame = seg.frame;
            newFrame.size.width = cell.contentView.frame.size.width;
            seg.frame = newFrame;
            seg.center = cell.center;
            [seg setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin)];
            [cell.contentView addSubview:seg];
        }
    } else if(SECTION_MAPIMAGE == section) {
        if(LOCATION_MAPIMAGE == row) {
            cell = self.cellMapImage;
            cell.backgroundColor = [UIColor colorWithPatternImage:self.croppedImage];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(SECTION_MAPIMAGE == indexPath.section) {
        if(LOCATION_MAPIMAGE == indexPath.row) {
            if(self.croppedImage)
                return self.croppedImage.size.height;
            else
                return 0;
        }
    }
    return 44; // TODO: return height do this programatically
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MAX_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (SECTION_SUBJECT == section) {
        return SECTION_SUBJECT_MAX_ROWS;
    } else if (SECTION_DATE == section) {
        return (self.switchEnableDate.isOn)?(SECTION_DATE_MAX_ROWS):(1);
    } else if (SECTION_LOCATION == section) {
        return (self.switchEnableLocation.isOn)?(SECTION_LOCATION_MAX_ROWS):(1);
    } else if (SECTION_DIRECTION_CHOICE == section) {
        return (self.switchEnableLocation.isOn)?(SECTION_DIRECTION_CHOICE_MAX_ROWS):(0);
    } else if (SECTION_MAPIMAGE == section) {
        return (self.switchEnableLocation.isOn)?(1):(0);
    } else {
        return 0;
    }
}

#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(!textField.text.length)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - LKMapSelectionDelegate

#define TEST_SAVE_MAP_IMG
- (void)mapView:(MKMapView*)mapView coordinateSelected:(CLLocationCoordinate2D)coordinate {
    // Capture image from map
    UIImage* img = [mapView renderToImage];
    
    // Capture rect
    // Create a dummy region with selected coordinate
    CGPoint point = [mapView convertCoordinate:coordinate toPointToView:mapView];
    
    NSInteger kMapImageHeight = 100;
    NSInteger kMapImageWidth = 640;
    
    CGRect cropRect;
    cropRect.origin.x = 0;
    cropRect.origin.y = point.y - (kMapImageHeight/2);
    cropRect.size.width = kMapImageWidth;
    cropRect.size.height = kMapImageHeight;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], cropRect);
    UIImage* croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    self.croppedImage = croppedImage;
#ifdef TEST_SAVE_MAP_IMG
    NSData* imgData = UIImagePNGRepresentation(croppedImage);
    //NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* imgPath = [docPath stringByAppendingPathComponent:@"test.png"];
    [imgData writeToFile:imgPath atomically:YES];
#endif

//        CLGeocodeCompletionHandler handler;
//        handler = ^(NSArray* placemarks, NSError* error) {
//            if(!error) {
//                CLPlacemark* p = [placemarks objectAtIndex:0];
//                // TODO: Create LKMapLocation, update model and send a notification or call delegate.
//                LKMapLocationData d;
//                d.mapImage = img;
//                d.coordinate = coordinate;
//                d.placemark = p;
//                LKMapLocation* mapLocation = [LKMapLocation mapLocationWithLocationData:d];
//                self.reminder = [[[LKReminder alloc] init] autorelease];
//                self.reminder.mapLocation = mapLocation;
//                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//                self.navigationItem.rightBarButtonItem.enabled = YES;
//                [self updateUIForReminder:self.reminder];
//            } else {
//                NSLog(@"%s error %@",__PRETTY_FUNCTION__,[error localizedDescription]);
//            }
//        };
//        CLLocation* loc = [[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] autorelease];
//        [[LKMediator sharedInstance].manager geoCodeLocation:loc withCompletionBlock:handler];
    
    CLLocation* committedLoc = [[[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                          longitude:coordinate.longitude] autorelease];
    [self handleCommittedLocation:committedLoc];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    NSLog(@"%s %@ %@",__PRETTY_FUNCTION__,keyPath,[change objectForKey:NSKeyValueChangeNewKey]);
}
@end
