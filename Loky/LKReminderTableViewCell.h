//
//  LKReminderTableViewCell.h
//  Loky
//
//  Created by Srikanth Sombhatla on 17/01/13.
//  Copyright (c) 2013 Kony. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKPanGestureProtocol.h"

extern NSString* const kLKReminderTableViewCellIdentifier;

@interface LKReminderTableViewCell : UITableViewCell

@property(nonatomic,readwrite,retain) IBOutlet UILabel* title;
@property(nonatomic,readwrite,retain) IBOutlet UILabel* subtitle1;
@property(nonatomic,readwrite,retain) IBOutlet UILabel* subtitle2;

@property(nonatomic,assign) UITableView* containedTableView;
@property(nonatomic,assign) id<LKPanGestureProtocol> delegate;
@end
