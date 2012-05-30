//
//  drawer.m
//  graphicsExample
//
//  Created by wchient on 11/12/12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "drawer.h"
#include "ofxiPhoneExtras.h"

@implementation drawer


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    myApp = (testApp*)ofGetAppPtr();
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:
                      0.015
                      target: self
                      selector: @selector(updateRunner)
                      userInfo:nil
                      repeats:YES];
    
    scaleGaussian[0]=1.2;
    scaleGaussian[1]=0.5;
    scaleGaussian[2]=0.5;
    scaleGaussian[3]=0.5;
    scaleGaussian[4]=0.5;
    scaleGaussian[5]=0.5;
    scaleGaussian[6]=0.5;
    colors[0]=red;
    colors[1]=green;
    colors[2]=blue;
    colors[3]=cryn;
    colors[4]=yellow;
    colors[5]=purple;
    colors[6]=black;
    for (int i=0; i<7; i++) {
        [colors[i] setFrame:CGRectMake(colors[i].frame.origin.x, colors[i].frame.origin.y, 40, 40)];
        ori_point[i]=CGPointMake(colors[i].frame.origin.x+20, colors[i].frame.origin.y+20);
        [colors[i] setFrame:CGRectMake(ori_point[i].x-10, ori_point[i].y-10, 20, 20)];
    }
    isSelectColor=false;
}
- (void) showColor{
    self.view.hidden=false;
    isSelectColor=true;
    [self resetColorIcon];
}
- (void) resetColorIcon{
    for(int i=0;i<7;i++){
        [colors[i] setFrame:CGRectMake(ori_point[i].x-10, ori_point[i].y-10, 20, 20)];
    }
}
- (void*) updateRunner
{
    if(myApp->newFieldP.y>=470){
        int color=[self checkSelect:myApp->newFieldP.x];
        if(color!=-1){
            if(isSelectColor){
                myApp->selectColor=color;
                [self scaleColorImage:(int)color];
            }
        }
    }else{
        [self resetColorIcon];
        self.view.hidden=true;
        isSelectColor=false;
    }

}
- (int)checkSelect:(float)point{
    if (point>red.frame.origin.x && point<red.frame.origin.x+red.frame.size.width) return 0;
    if (point>green.frame.origin.x && point<green.frame.origin.x+green.frame.size.width) return 1;
    if (point>blue.frame.origin.x && point<blue.frame.origin.x+blue.frame.size.width) return 2;
    if (point>cryn.frame.origin.x && point<cryn.frame.origin.x+cryn.frame.size.width) return 3;
    if (point>yellow.frame.origin.x && point<yellow.frame.origin.x+yellow.frame.size.width) return 4;
    if (point>purple.frame.origin.x && point<purple.frame.origin.x+purple.frame.size.width) return 5;
    if (point>black.frame.origin.x && point<black.frame.origin.x+black.frame.size.width) return 6;
    return -1;
}
- (void)scaleColorImage:(int)CurrentNum{
    for(int i=0;i<7;i++){
        CGSize size = colors[i].frame.size;
        int det=abs(i-CurrentNum);
        size.width=40.0*scaleGaussian[det];
        size.height=40.0*scaleGaussian[det];
        [colors[i] setFrame:CGRectMake(ori_point[i].x-size.width/2, ori_point[i].y-size.height/2, size.width, size.height)];
    }
}

@end
