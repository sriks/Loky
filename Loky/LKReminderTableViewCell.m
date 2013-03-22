//
//  LKReminderTableViewCell.m
//  Loky
//
//  Created by Srikanth Sombhatla on 17/01/13.
//  Copyright (c) 2013 Kony. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LKReminderTableViewCell.h"

NSString* const kLKReminderTableViewCellIdentifier = @"com.loky.lkremindertableviewcell";

@interface LKReminderTableViewCell ()
    @property (nonatomic,assign) BOOL handledTouchMove;
    @property (nonatomic,assign) CGFloat cumulativeXMovement;
    @property (nonatomic,assign) CATextLayer* textLayer;
@end

@implementation LKReminderTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
    
}
- (id)init {
    self = [super init];
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UIView* bkgView = [[[UIView alloc] initWithFrame:self.frame] autorelease];
        self.backgroundView = bkgView;
    }
    return self;
}

- (void)dealloc {
    [_title release];
    [_subtitle1 release];
    [_subtitle2 release];
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString*)restorationIdentifier {
    return kLKReminderTableViewCellIdentifier;
    //return @"none";
}

#pragma mark UIView

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    return;
//    //NSLog(@"%s",__PRETTY_FUNCTION__);
//    self.cumulativeXMovement = 0;
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    return;
//    //NSLog(@"%s",__PRETTY_FUNCTION__);
//    UIView* theView = self.contentView;
//    UITouch* t = [touches anyObject];
//    CGFloat x = [t locationInView:theView].x;
//    CGFloat prevX = [t previousLocationInView:self.contentView].x;
//    
//    CGFloat xOffset = x - prevX;
//    self.cumulativeXMovement += xOffset;
//    [self.delegate cell:self didCrossLevel:self.cumulativeXMovement];
//    
//    //NSLog(@"x:%f prevX:%f xOffset:%f cumX:%f",x,prevX,xOffset,self.cumulativeXMovement);
//    CGRect newFrame = [theView frame];
//    newFrame.origin.x += xOffset;
//    
//    [UIView beginAnimations:@"settngframe" context:nil];
//    theView.frame = newFrame;
//    [UIView commitAnimations];
//    
//    self.handledTouchMove = YES;
//    [self.containedTableView setScrollEnabled:NO];
//    [super touchesMoved:touches withEvent:event];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    return;
//    //NSLog(@"%s",__PRETTY_FUNCTION__);
//    if(self.handledTouchMove) {
//        if([self.delegate cell:self shouldRestoreToOriginWithCrossLevel:self.cumulativeXMovement]) {
//            NSLog(@"mine");
//            self.handledTouchMove = NO;
//            UIView* theView = self.contentView;
//            CGRect newFrame = [theView frame];
//            newFrame.origin.x = 0;
//            [UIView beginAnimations:@"settngframe" context:nil];
//            theView.frame = newFrame;
//            [UIView commitAnimations];
//            [self.containedTableView setScrollEnabled:YES];
//            [super touchesCancelled:touches withEvent:event];
//        }
//        [self.delegate cell:self gestureEndedAtCrossLevel:self.cumulativeXMovement];
//    } else {
//        //NSLog(@"super");
//        [super touchesBegan:touches withEvent:event];
//        [super touchesEnded:touches withEvent:event];
//    }
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    return;
//    //NSLog(@"%s",__PRETTY_FUNCTION__);
//    // TODO: move to common impl
//    if(self.handledTouchMove) {
//        NSLog(@"mine");
//        self.handledTouchMove = NO;
//        UIView* theView = self.contentView;
//        CGRect newFrame = [theView frame];
//        newFrame.origin.x = 0;
//        [UIView beginAnimations:@"settngframe" context:nil];
//        theView.frame = newFrame;
//        [UIView commitAnimations];
//        
//    } else {
//        [super touchesCancelled:touches withEvent:event];
//    }
//}

@end
