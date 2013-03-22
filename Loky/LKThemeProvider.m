//
//  ThemeProvider.m
//  Loky
//
//  Created by Srikanth Sombhatla on 03/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <QuartzCore/CALayer.h>
#import "LKThemeProvider.h"

static id<LKThemeProviderProtocol> themeProvider = nil; // TODO: Who deletes this?

@implementation LKThemeProvider
+ (id<LKThemeProviderProtocol>)defaultThemeProvider {
    if(!themeProvider) {
        themeProvider = [[LKThemeProviderDefault alloc] init];
    }
    return themeProvider;
}
@end

@implementation LKThemeProviderDefault

#define kDefaultFontMediumPointSize             18.5
#define kDefaultFontSmallPointSize              12.5
#define kDefaultFontLargePointSize              19.5

// This is the default font used across this theme.
NSString* const kDefaultFontName                =    @"HelveticaNeue-Light";
NSString* const kDefaultFontNameWithBold        =    @"HelveticaNeue-Bold";
NSString* const kDefaultFontNameWithItalic      =    @"HelveticaNeue-Italic";
NSString* const kDefaultFontNameWithBoldItalic  =    @"HelveticaNeue-BoldItalic";

// Convenience method to get font name with specified font attributes
- (NSString*)fontNameWithBold:(BOOL)bold andItalic:(BOOL)italic {
    NSString* fontName;
    if(bold && italic)
        fontName = kDefaultFontNameWithBoldItalic;
    else if(bold)
        fontName = kDefaultFontNameWithBold;
    else if(italic)
        fontName = kDefaultFontNameWithItalic;
    else
        fontName = kDefaultFontName;
    return fontName;
}

- (void)themeNavigationController:(UINavigationController*)navController {
    [navController.navigationBar setTranslucent:NO];
    navController.navigationBar.tintColor = [UIColor colorWithWhite:0.880 alpha:1.000];
}

- (void)themeBarButtonItem:(UIBarButtonItem*)barButtonItem {
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithWhite:0.674 alpha:1.000] ];
    
}

- (void)themeBackgroundImageForView:(UIView*)view {
    view.backgroundColor = [UIColor whiteColor];
}

- (void)themeTableView:(UITableView*)tableView {
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithWhite:0.794 alpha:1.000];
}

- (void)themeReminderCell:(UITableViewCell*)cell {
#ifdef LK_USE_SHADOW_BKG
    static int count = 0;
    NSLog(@"%s %d",__PRETTY_FUNCTION__,count++);
    NSLog(@"cell contentview frame %@",NSStringFromCGRect(cell.contentView.frame));
    cell.contentView.layer.masksToBounds = NO;
    CALayer* bkgLayer = [[[CALayer alloc] init] autorelease];
    //bkgLayer.frame = CGRectMake(0, 5, cell.contentView.frame.size.width, cell.contentView.frame.size.height - 20);
    bkgLayer.frame = cell.contentView.frame;
    bkgLayer.backgroundColor = [[UIColor colorWithWhite:0.882 alpha:1.000] CGColor];
    bkgLayer.zPosition = -1;
    
    CALayer* layer = bkgLayer;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:bkgLayer.bounds] CGPath];
    layer.shadowColor = [[UIColor colorWithWhite:0.729 alpha:1.000] CGColor];
    layer.shadowOpacity = 1;
    layer.shadowRadius = 0.8;
    layer.shadowOffset = CGSizeMake(3, 5);
    
    [cell.contentView.layer addSublayer:bkgLayer];
#else
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    CALayer* shadow = cell.contentView.layer;
    shadow.shadowPath = [[UIBezierPath bezierPathWithRect:cell.contentView.frame] CGPath];
    shadow.shadowColor = [[UIColor colorWithWhite:0.667 alpha:1.000] CGColor];
    shadow.shadowRadius = 0.25;
    shadow.shadowOpacity = 0.6;
    shadow.shadowOffset = CGSizeMake(-2.5, 0);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
#endif
}

- (void)themeReminderCellTitle:(UILabel*)label withStateEnabled:(BOOL)enabled {
    UIColor* textColor = nil;
    if(enabled) {
        textColor = [UIColor blackColor];
    } else {
        textColor = [UIColor blackColor];
    }
    
    label.textColor = textColor;
    label.font = [self mediumFontWithBold:NO andItalic:NO];
}

- (void)themeReminderCellSubtitle:(UILabel*)label withStateEnabled:(BOOL)enabled {
    UIColor* textColor = nil;
    if(enabled) {
        textColor = [UIColor blackColor];
    } else {
        textColor = [UIColor blackColor];
    }
    
    label.textColor = textColor;
    label.font = [self smallFontWithBold:NO andItalic:NO];
}

- (void)themePanGestureCommandLabel:(UILabel*)label {
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [self mediumFontWithBold:YES andItalic:NO];
}

- (UIFont*)smallFontWithBold:(BOOL)bold andItalic:(BOOL)italic {
    return [UIFont fontWithName:[self fontNameWithBold:bold andItalic:italic] size:kDefaultFontSmallPointSize];
}

- (UIFont*)mediumFontWithBold:(BOOL)bold andItalic:(BOOL)italic {
    return [UIFont fontWithName:[self fontNameWithBold:bold andItalic:italic] size:kDefaultFontMediumPointSize];
}

- (UIFont*)largeFontWithBold:(BOOL)bold andItalic:(BOOL)italic {
    return [UIFont fontWithName:[self fontNameWithBold:bold andItalic:italic] size:kDefaultFontLargePointSize];
}

@end
