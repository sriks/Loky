//
//  AllRemindersViewController.h
//  Loky
//
//  Created by Srikanth Sombhatla on 05/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKReminderModel.h"
#import "DCPanGesture.h"

@interface AllRemindersViewController : UITableViewController<LKReminderModelDelegate,DCPanGestureProtocol>
@end
