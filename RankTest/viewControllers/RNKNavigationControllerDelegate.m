//
//  RNKNavigationControllerDelegate.m
//  RankTest
//
//  Created by Rafael Bartolome on 26/11/14.
//  Copyright (c) 2014 www.rafaelbartolome.es. All rights reserved.
//

#import "RNKNavigationControllerDelegate.h"
#import "RNKConstants.h"
#import "RNKPicturePushAnimationController.h"

@implementation RNKNavigationControllerDelegate


#pragma mark UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {


    //TODO:

    if (operation == UINavigationControllerOperationPush) {
        DLog(@"Push");

        return [[RNKPicturePushAnimationController alloc] init];
    }

    if (operation == UINavigationControllerOperationPop) {
        DLog(@"Pop");

    }


    return nil;
}



@end
