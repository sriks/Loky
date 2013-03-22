//
//  DCPanGesture.h
//  Loky
//
//  Created by Srikanth Sombhatla on 17/03/13.
//  Copyright (c) 2013 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DCPanGestureProtocol <NSObject>
- (void)cell:(UITableViewCell*)cell didCrossLevel:(CGFloat)level;
- (void)cell:(UITableViewCell*)cell gestureEndedAtCrossLevel:(CGFloat)level;
- (BOOL)cell:(UITableViewCell*)cell shouldRestoreToOriginWithCrossLevel:(CGFloat)level;
- (void)cellRestoredToOrigin:(UITableViewCell*)cell;
@end

@interface DCPanGesture : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, assign, readwrite) id<DCPanGestureProtocol> delegate;

- (void)installGestureOnCell:(UITableViewCell*)cell;
@end
