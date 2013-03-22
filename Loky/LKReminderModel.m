//
//  LKReminderModel.m
//  Loky
//
//  Created by Srikanth Sombhatla on 06/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import "LKReminderModel.h"
#import "LKReminder.h"

@interface LKReminderModel () {
    NSMutableArray* _reminders;
}
@end

@implementation LKReminderModel
@synthesize count = _count;
@synthesize delegate = _delegate;

#pragma mark - pimpl

#pragma mark - lifecycle

- (id)init {
    self  = [super init];
    if(self) {
        _reminders = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_reminders release];
    [super dealloc];
}

#pragma mark - public interface

- (NSInteger)count {
    return [_reminders count];
}

- (NSArray*)reminders {
    return _reminders;
}

- (LKReminder*)reminderAtIndex:(NSInteger)index {
    return [_reminders objectAtIndex:index];
}

- (void)addReminder:(LKReminder*)reminder {
    if([_reminders containsObject:reminder]) {
        NSInteger index = [_reminders indexOfObject:reminder];
        [reminder retain];
        [_reminders replaceObjectAtIndex:index withObject:reminder];
        [reminder release];
        [self.delegate reminderModel:self didUpdateReminder:reminder atIndex:index];
    } else {
        if([_reminders count])
            [_reminders insertObject:reminder atIndex:0]; // latest item is at top
        else
            [_reminders addObject:reminder];
        [self.delegate reminderModel:self didInsertReminder:reminder atIndex:0];
    }
}

- (void)removeReminderAtIndex:(NSInteger)index {
    LKReminder* reminder = [_reminders objectAtIndex:index];
    NSAssert(reminder, @"%p cannot rmove reminder which is not added yet",reminder);
    [_reminders removeObjectAtIndex:index];
    [self.delegate reminderModel:self willRemoveRemainder:reminder atIndex:index];
}

- (void)removeReminder:(LKReminder*)reminder {
    NSUInteger index = [_reminders indexOfObject:reminder];
    NSAssert(index != NSNotFound, @"%p cannot remove reminder which is not added yet.",reminder);
    [self removeReminderAtIndex:index];
}


@end
