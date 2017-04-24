//
//  hvECGAppDelegate.h
//  hvECG
//
//  Created by Will Yang (yangyu.will@gmail.com) on 7/9/11.
//  Copyright 2013 WMS Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECGWavePlayerViewController;

@interface ECGWavePlayerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;

@end

