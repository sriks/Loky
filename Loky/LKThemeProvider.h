//
//  ThemeProvider.h
//  Loky
//
//  Created by Srikanth Sombhatla on 03/10/12.
//  Copyright (c) 2012 Kony. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LKThemeProviderProtocol
@required
    - (void)themeNavigationController:(UINavigationController*)navController;
    - (void)themeBarButtonItem:(UIBarButtonItem*)barButtonItem;
    - (void)themeBackgroundImageForView:(UIView*)view;
    - (void)themeTableView:(UITableView*)tableView;
    - (void)themeReminderCell:(UITableViewCell*)cell;
    - (void)themeReminderCellTitle:(UILabel*)label withStateEnabled:(BOOL)enabled;
    - (void)themeReminderCellSubtitle:(UILabel*)label withStateEnabled:(BOOL)enabled;
    - (void)themePanGestureCommandLabel:(UILabel*)label;

    // Fonts
    - (UIFont*)smallFontWithBold:(BOOL)bold andItalic:(BOOL)italic;
    - (UIFont*)mediumFontWithBold:(BOOL)bold andItalic:(BOOL)italic;
    - (UIFont*)largeFontWithBold:(BOOL)bold andItalic:(BOOL)italic;
@end

// Master class to access theme providers
@interface LKThemeProvider : NSObject
    + (id<LKThemeProviderProtocol>)defaultThemeProvider;
@end

// Default implementation of LKThemeProviderProtocol
@interface LKThemeProviderDefault : NSObject <LKThemeProviderProtocol>
    - (void)themeNavigationController:(UINavigationController*)navController;
    - (void)themeBarButtonItem:(UIBarButtonItem*)barButtonItem;
    - (void)themeBackgroundImageForView:(UIView*)view;
    - (void)themeTableView:(UITableView*)tableView;
    - (void)themeReminderCell:(UITableViewCell*)cell;
    - (void)themeReminderCellTitle:(UILabel*)label withStateEnabled:(BOOL)enabled;
    - (void)themeReminderCellSubtitle:(UILabel*)label withStateEnabled:(BOOL)enabled;
    - (void)themePanGestureCommandLabel:(UILabel*)label;

    - (UIFont*)smallFontWithBold:(BOOL)bold andItalic:(BOOL)italic;
    - (UIFont*)mediumFontWithBold:(BOOL)bold andItalic:(BOOL)italic;
    - (UIFont*)largeFontWithBold:(BOOL)bold andItalic:(BOOL)italic;
@end
