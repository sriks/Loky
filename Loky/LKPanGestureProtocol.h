//
//  LKPanGestureProtocol.h
//  Loky
//
//  Created by Srikanth Sombhatla on 12/02/13.
//  Copyright (c) 2013 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LKReminderTableViewCell;
@protocol LKPanGestureProtocol <NSObject>
- (void)cell:(UITableViewCell*)cell didCrossLevel:(CGFloat)level;
- (BOOL)cell:(UITableViewCell*)cell shouldRestoreToOriginWithCrossLevel:(CGFloat)level;
- (void)cell:(UITableViewCell*)cell gestureEndedAtCrossLevel:(CGFloat)level;
@end
