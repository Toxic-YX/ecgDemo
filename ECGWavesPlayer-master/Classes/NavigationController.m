//
//  NavigationController.m
//  ECGWavePlayer
//
//  Created by Will Yang (yangyu.will@gmail.com) on 10/12/12.
//
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
@end
