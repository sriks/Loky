//
//  DCPanGesture.m
//  Loky
//
//  Created by Srikanth Sombhatla on 17/03/13.
//  Copyright (c) 2013 Kony. All rights reserved.
//

#import "DCPanGesture.h"

@interface DCPanGesture ()
- (void)panned:(id)sender;
@end

@implementation DCPanGesture

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    // Handle only horizontal pan
    if(fabsf(p.x) > fabsf(p.y))
        return YES;
    else
        return NO;
}

- (void)panned:(id)sender {
    UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*)sender;
    UITableViewCell* cell = (UITableViewCell*)pan.view;
    UIView* targetView = cell.contentView;
    CGPoint point = [pan translationInView:cell];
    
    if(UIGestureRecognizerStateBegan == pan.state) {
        NSLog(@"began at %@",NSStringFromCGPoint(point));
    } else if (UIGestureRecognizerStateChanged == pan.state) {
        NSLog(@"state changed %@",NSStringFromCGPoint(point));
        
        [UIView animateWithDuration:0.25 animations:^(void){
            CGRect newFrame = targetView.frame;
            newFrame.origin.x = point.x;
            targetView.frame = newFrame;
        } completion:^(BOOL finished) {
            if(UIGestureRecognizerStateChanged == pan.state)
                [self.delegate cell:cell didCrossLevel:point.x];
        }];
        
    } else if(UIGestureRecognizerStateEnded == pan.state) {
        NSLog(@"state ended %@",NSStringFromCGPoint(point));
        if([self.delegate cell:cell shouldRestoreToOriginWithCrossLevel:point.x]) {
            [UIView animateWithDuration:0.25 animations:^(void){
                CGRect newFrame = targetView.frame;
                newFrame.origin.x = 0;
                targetView.frame = newFrame;
            } completion:^(BOOL finished) {
                [self.delegate cell:cell gestureEndedAtCrossLevel:point.x];
                //[self.delegate cellRestoredToOrigin:cell];
            }];
        } else {
            [self.delegate cell:cell gestureEndedAtCrossLevel:point.x];
        }
    }
}

- (void)installGestureOnCell:(UITableViewCell*)cell {
    UIPanGestureRecognizer* pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)] autorelease];
    pan.delegate = self;
    
    [cell addGestureRecognizer:pan];
}

@end
