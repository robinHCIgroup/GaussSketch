#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"

// listen on port 12345
#define PORT 1234
#define MagLowest 150
#define MagHighest 280
#define MagInterval 130

class testApp : public ofxiPhoneApp {

	public:
		void setup();
		void update();
		void draw();
		
		void touchDown(int x, int y, int id);
		void touchMoved(int x, int y, int id);
		void touchUp(int x, int y, int id);
		void touchDoubleTap(int x, int y, int id);
        
        void exit();
        void touchCancelled(ofTouchEventArgs &touch);
        void lostFocus();
		void gotFocus();
		void gotMemoryWarning();
		void deviceOrientationChanged(int newOrientation);
   
        //+++++++++++++++Variables+++++++++++++++
    
		ofxOscReceiver	receiver;
        //incoming osc socket
        int penVal[5]; 
    
        //touch events' registration
        ofPoint touches[5];
        
        //Data for rendering the stroke
        int strkIntensity;//Magnetic Value
        int oldstrkIntensity;
        //Field Point represent the point approximate by magnetic value
        ofPoint oldFieldP;
        ofPoint newFieldP;
        //The real point that pen touched
        ofPoint oldTouchP;
        ofPoint newTouchP;
        //Colors in color panel
        int rgbColor[7][3];
        int selectColor;//Color which is choosen
        int drawMode;//(0 triangle) (1 hover) (2 eraser) (3 do nothing)
        int num_touch;//Total touch number
        int t_id;//IF there exist multiple touch, using it to recognize different touch point
    
        bool isTouch;
    
        //this window is used to save the origin window before we change it(because we use
        //ofSetBackgroundAuto(false))
        ofImage initwindow;
        ofImage colorwindow;
    
        //This part is the parameter which we used to draw by hands
        //The reason adding this value is to avoid ambiguity with other touch value
        ofPoint HandT;
        ofPoint oldHandT;
        ofPoint newHandT;
        
        //Flag for manually flushthe display
        bool clearScreen;
    
        float* scaleRGB(double scale,float r,float g,float b);

    
};

