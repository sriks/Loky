//
//  AddReminderViewController.h
//  Loky
//
//  Created by Srikanth Sombhatla on 10/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKMapSelectionDelegate.h"
#import "LKReminder.h"

@interface AddReminderViewController : UIViewController <UITableViewDelegate,
                                                         UITableViewDataSource,
                                                         LKMapSelectionDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil reminder:(LKReminder*)reminder;

@property (nonatomic,copy,readwrite) NSString* locationAddress;
@property (nonatomic,retain,readwrite) LKReminder* reminder;
@end
