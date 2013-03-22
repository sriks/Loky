//
//  LKReminderModel.h
//  Loky
//
//  Created by Srikanth Sombhatla on 06/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LKReminder;
@class LKReminderModel;
@protocol LKReminderModelDelegate <NSObject>
@optional
- (void)reminderModel:(LKReminderModel*)model didInsertReminder:(LKReminder*)reminder atIndex:(NSInteger)index;
- (void)reminderModel:(LKReminderModel*)model didUpdateReminder:(LKReminder*)reminder atIndex:(NSInteger)index;
- (void)reminderModel:(LKReminderModel*)model willRemoveRemainder:(LKReminder*)reminder atIndex:(NSInteger)index;
@end

@interface LKReminderModel : NSObject // TODO: confirm to LKReminderModelProtocol

- (LKReminder*)reminderAtIndex:(NSInteger)index;
- (void)addReminder:(LKReminder*)reminder;
- (void)removeReminder:(LKReminder*)reminder;
- (void)removeReminderAtIndex:(NSInteger)index;

@property (nonatomic,readonly) NSInteger count;
@property (nonatomic,readonly) NSArray* reminders;
@property (nonatomic,assign,readwrite) id<LKReminderModelDelegate> delegate;
@end
