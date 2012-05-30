//
//  drawer.h
//  graphicsExample
//
//  Created by wchient on 11/12/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "testApp.h"

@interface drawer : UIViewController{
    
@public
    bool isSelectColor;
    testApp *myApp;
    UIImageView *colors[7];
    IBOutlet UIImageView *red;
    IBOutlet UIImageView *green;
    IBOutlet UIImageView *blue;
    IBOutlet UIImageView *cryn;
    IBOutlet UIImageView *yellow;
    IBOutlet UIImageView *purple;
    IBOutlet UIImageView *black;
    double scaleGaussian[7];
    CGPoint ori_point[7];
}

- (void) showColor;
- (float*) scaleRGB:(double)scale:(float)r:(float)g:(float)b;
- (void )resetColorIcon;
- (int) checkSelect:(float)point;
- (void) scaleColorImage:(int)CurrentNum;

@end


