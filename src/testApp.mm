#include "testApp.h"
#include <iostream>
#include <math.h>
#include "drawer.h"

drawer *drawercontroller;

void testApp::setup(){
    ofxiPhoneDisableIdleTimer();//turn off auto-timeout
    ofSetBackgroundAuto(false); //turn off auto-repaint
    ofSetCircleResolution(80);  
    ofSetFrameRate(60);
	ofxRegisterMultitouch(this);
    drawercontroller= [[drawer alloc] initWithNibName:@"drawer" bundle:nil];
	[ofxiPhoneGetUIWindow() addSubview:drawercontroller.view];
    drawercontroller.view.hidden=true;
    // initialize the accelerometer
    //	ofxAccelerometer.setup();
    
    //Initialize touches
    for(int i=0; i<5; i++){
        touches[i].x = -1;
        touches[i].y = -1;
    }
    //Initialize pen
    for(int i=0; i<5; i++){
        penVal[i] = -1;
    }
    
	// listen OSC packets on the given port
	cout << "listening for osc messages on port " << PORT << "\n";
	receiver.setup( PORT );

    strkIntensity = 0;
    clearScreen = true;
    ofBackground(255);
    
    rgbColor[0][0]=254;rgbColor[0][1]=0;rgbColor[0][2]=0;
    rgbColor[1][0]=0;rgbColor[1][1]=254;rgbColor[1][2]=0;
    rgbColor[2][0]=0;rgbColor[2][1]=0;rgbColor[2][2]=254;
    rgbColor[3][0]=0;rgbColor[3][1]=200;rgbColor[3][2]=254;
    rgbColor[4][0]=254;rgbColor[4][1]=254;rgbColor[4][2]=0;
    rgbColor[5][0]=254;rgbColor[5][1]=0;rgbColor[5][2]=254;
    rgbColor[6][0]=0;rgbColor[6][1]=0;rgbColor[6][2]=0;
    
    //no action mode
    drawMode=3;
    
    //initial window wirh white background
    initwindow.allocate(ofGetWidth(), ofGetHeight(), OF_IMAGE_COLOR_ALPHA);
    initwindow.grabScreen(0,0, ofGetWidth(), ofGetHeight() );
    
    isTouch=false;
    num_touch=0;
    t_id=-1;
    
    newTouchP.x=-1;
    newTouchP.y=-1;
    oldTouchP.x=-1;
    oldTouchP.y=-1;
    newFieldP.x=-1;
    newFieldP.y=-1;
    oldFieldP.x=-1;
    oldFieldP.y=-1;
    oldstrkIntensity=-1;
    
    oldHandT.x=-1;
    oldHandT.y=-1;
    newHandT.x=-1;
    newHandT.y=-1;
    HandT.x=-1;
    HandT.y=-1;
    
    //initial color as black
    selectColor=6;
}

//--------------------------------------------------------------
void testApp::update(){
    string msg_string;
	while( receiver.hasWaitingMessages() ){
		// get the next message
		ofxOscMessage m;
		receiver.getNextMessage( &m );
        // unrecognized message: display on the bottom of the screen
        msg_string = m.getAddress();
        for( int i=0; i<m.getNumArgs(); i++ ){
            // display the argument - make sure we get the right type
            if( m.getArgType( i ) == OFXOSC_TYPE_INT32 ){
                penVal[i] = m.getArgAsInt32( i );
            }else if( m.getArgType( i ) == OFXOSC_TYPE_FLOAT ){
            }else if( m.getArgType( i ) == OFXOSC_TYPE_STRING ){
            }else{
            }
        }
	}
    cout<<msg_string<<endl;
    //Fill the data from the parsed OSC packet
    strkIntensity = penVal[0];
    newFieldP.x = penVal[1]+2;
    newFieldP.y = penVal[2];
    if(msg_string.compare("/Touch")==0){
        if(isTouch==true){
            drawMode=0;
            isTouch=true;
        }else{
            oldFieldP.x = -1;
            oldFieldP.y = -1;
            newFieldP.x = -1;
            newFieldP.y = -1;
            drawMode=3;
        }
    }else if(msg_string.compare("/Hover")==0 && !drawercontroller->isSelectColor){
        //cout<<msg_string << " "<<strkIntensity<<" "<<newFieldP.x << " "<<newFieldP.y <<endl;
        if(isTouch==true){
            newFieldP.x = -1;
            newFieldP.y = -1;
            oldFieldP.x=-1;
            oldFieldP.y=-1;
            oldstrkIntensity=-1;
            drawMode=3;
        }
        //selectColor
        if(newFieldP.y>=470 && strkIntensity<=40){
            [drawercontroller showColor];
            
        }//eraser
        else if(strkIntensity>40 && strkIntensity<=70){
            drawMode=2; 
        }else if(strkIntensity<=40){
            drawMode=3;
        }//Hover
        else{
            drawMode=1;        
        }
    }else{
    }
    //
    /*
     Need to justify: should judge which touch id (out of 5) is the most possible touch instead of 
     directly assign 0 as the pen id
     */
    if(t_id>=0){
        newTouchP.x = touches[t_id].x;
        newTouchP.y = touches[t_id].y;
    }
    newHandT.x=HandT.x;
    newHandT.y=HandT.y;
    //
}
    
//--------------------------------------------------------------
void testApp::draw(){
    if(clearScreen==true){
        ofBackground(255);
        clearScreen = false;
        ofClear(255, 255, 255);
        initwindow.grabScreen(0,0, ofGetWidth(), ofGetHeight() );
    }
    //draw triangle mesh
    if (drawMode==0) {
        //if Touch is near the Field Point then draw and set check as true
        bool check=false;
        if(newTouchP.x>-1 && oldTouchP.x>-1 && newTouchP.y>-1 && oldTouchP.y>-1){
            if(newFieldP.x>-1 && oldFieldP.x>-1 && newFieldP.y>-1 && oldFieldP.y>-1){
                //--------
                //Please refer the the paper to modify this part using gouraud shading and triangle strip.
                
                ofEnableSmoothing(); //turn on anti-aliasing
                ofSetLineWidth(1);
                ofNoFill();
                int tmpIntensity=strkIntensity;
                if (oldstrkIntensity>0){
                    if(abs(strkIntensity-oldstrkIntensity) >= 10) {
                        tmpIntensity=(strkIntensity+oldstrkIntensity)/2;
                    }
                }
                
                float intensity=(1.0*tmpIntensity-MagLowest);
                intensity=intensity/(1.0*MagInterval);
                float tmp_rgb[3]={1.0*rgbColor[selectColor][0],1.0*rgbColor[selectColor][1],1.0*rgbColor[selectColor][2]};
                float* rgb=scaleRGB(intensity,tmp_rgb[0],tmp_rgb[1],tmp_rgb[2]);
                float rr=rgb[0],gg=rgb[1],bb=rgb[2];
                if(selectColor==6){
                    ofSetColor(255-1.0*255*intensity, 255-1.0*255*intensity, 255-1.0*255*intensity);
                }else{
                    ofSetColor(rr,gg,bb);
                }
                ofTriangle(newTouchP.x, newTouchP.y, oldFieldP.x, oldFieldP.y, newFieldP.x, newFieldP.y);
                ofTriangle(oldTouchP.x, oldTouchP.y, oldFieldP.x, oldFieldP.y, newTouchP.x, newTouchP.y);
                ofFill();
                ofTriangle(newTouchP.x, newTouchP.y, oldFieldP.x, oldFieldP.y, newFieldP.x, newFieldP.y);
                ofTriangle(oldTouchP.x, oldTouchP.y, oldFieldP.x, oldFieldP.y, newTouchP.x, newTouchP.y);
                ofDisableSmoothing(); //turn off anti-aliasing
                //--------
            }
            check=true;
        }else{
            if(newTouchP.x>-1){
                
            }else{
            }
        }
        //if check is true means we are drawing the mesh, so we need to change Field and strIntensity value
        if(check){
            oldFieldP = newFieldP;
            oldstrkIntensity=strkIntensity;
        }
        oldTouchP = newTouchP;
        ofNoFill();
    }
    //if draw mode is 1 means it is Hover state. Because drawmod only depends on strIntensity
    //use isTouch to avoid the situation that the pen is touched but magnetic value is bellow
    //threshold
    else if(drawMode==1 && !isTouch){
        ofBackground(255,255,255);
        ofSetColor(255,255,255);
        initwindow.draw(0,0);
        ofNoFill();
        ofSetColor(rgbColor[selectColor][0], rgbColor[selectColor][1],rgbColor[selectColor][2]);
        ofCircle(newFieldP.x, newFieldP.y, 10);
    }
    //Eraser part
    //the logic in check is the same as drawmode=0
    else if(drawMode==2){
        bool check=false;
        ofSetColor(255, 255, 255);
        initwindow.draw(0,0);
        if(num_touch>0){
            if(newTouchP.x>-1 && oldTouchP.x>-1 && newTouchP.y>-1 && oldTouchP.y>-1){
                ofSetLineWidth(60);
                ofLine(newTouchP.x, newTouchP.y, oldTouchP.x, oldTouchP.y);
                ofSetLineWidth(1);
                check=true;
            }
            if(check){
                oldFieldP = newFieldP;
            }
            oldTouchP = newTouchP;
        }
        initwindow.grabScreen(0, 0, ofGetWidth(), ofGetHeight());
    }else{
    }
    //this part allows us to draw lines by hands
    if(newHandT.x!=-1&&newHandT.y!=-1 && drawMode>2){
        if(oldHandT.x!=-1&&oldHandT.y!=-1){
            ofSetLineWidth(1);
            ofEnableSmoothing();
            ofSetColor(rgbColor[selectColor][0],rgbColor[selectColor][1],rgbColor[selectColor][2]);
            ofLine(newHandT.x, newHandT.y, oldHandT.x, oldHandT.y);
            ofDisableSmoothing();
        }
        oldHandT.x=newHandT.x;
        oldHandT.y=newHandT.y;
    }
}
//----------------
void testApp::touchDown(int x, int y, int id){
    num_touch++;
    //This function check whether we are drawing by pen
    if(sqrt(pow(newFieldP.x-x,2)+pow(newFieldP.y-y,2))<80){
        t_id=id;
        isTouch=true;
        ofSetColor(255,255,255);
        initwindow.draw(0,0, ofGetWidth(), ofGetHeight() );
    }
    //It is touched but not by pen, so it must touch by hand
    if(t_id!=id && drawMode==3){
        HandT.x=x;
        HandT.y=y;
    }
    touches[id].x = x;
    touches[id].y = y;
}

//----------------
void testApp::touchMoved(int x, int y, int id){
    if(drawMode!=3 && sqrt(pow(newFieldP.x-x,2)+pow(newFieldP.y-y,2))<80){
        t_id=id;
    }
    if(t_id!=id && drawMode==3){
        HandT.x=x;
        HandT.y=y;
    }
    touches[id].x = x;
    touches[id].y = y;
}

//----------------
void testApp::touchUp(int x, int y, int id){
    touches[id].x = -1;
    touches[id].y = -1;
    num_touch--;
    if(t_id>=0){
        if(t_id==id){
            isTouch=false;
            newTouchP.x=-1;
            newTouchP.y=-1;
        }        
        initwindow.grabScreen(0,0, ofGetWidth(), ofGetHeight() );
    }
    if(t_id!=id && drawMode!=1){
        HandT.x=-1;
        HandT.y=-1;
        oldHandT.x=-1;
        oldHandT.y=-1;
        newHandT.x=-1;
        newHandT.y=-1;
        initwindow.grabScreen(0,0, ofGetWidth(), ofGetHeight() );
    }
    if(num_touch==0){
        t_id=-1;
        isTouch=false;
    }
}

//---------------
void testApp::touchDoubleTap(int x, int y, int id){
    int tmp_id;
    if(drawMode!=3 && sqrt(pow(newFieldP.x-x,2)+pow(newFieldP.y-y,2))<50){
        tmp_id=id;
    }
    if(tmp_id!=id && drawMode==3){
        if(x<40 && y<40){
            clearScreen = true; //flush the display
           
            //可能可以砍掉
            ofClear(255, 255, 255);
            initwindow.grabScreen(0, 0, ofGetWidth(),ofGetHeight());
        }
    }
}
//This function transfer RGB value to HSV value, and change the S value which means changing intensity
//After change S value, then changing HSV value back to RGB value.
float* testApp::scaleRGB(double scale, float r,float g,float b){
    double maxC = b;
    if (maxC < g) maxC = g;
    if (maxC < r) maxC = r;
    double minC = b;
    if (minC > g) minC = g;
    if (minC > r) minC = r;
    
    double delta = maxC - minC;
    
    double V = maxC;
    double S = 0;
    double H = 0;
    
    if (delta == 0)
    {
        H = 0;
        S = 0;
    }
    else
    {
        S = delta / maxC;
        double dR = 60*(maxC - r)/delta + 180;
        double dG = 60*(maxC - g)/delta + 180;
        double dB = 60*(maxC - b)/delta + 180;
        if (r == maxC)
            H = dB - dG;
        else if (g == maxC)
            H = 120 + dR - dB;
        else
            H = 240 + dG - dR;
    }
    
    if (H<0)
        H+=360;
    if (H>=360)
        H-=360;
    //change S value
    S=(1.0*S)*scale;
    
	double h=H/60;
	int hi=(int)floor(h);
	double f=h-hi;
	double p=V*(1-S);
	double q = V * (1 - S * f);
	double t = V * (1 - S * (1 - f));
	switch(hi){
		case 0:
			r=V;
			g=t;
			b=p;
			break;
		case 1:
			r=q;
			g=V;
			b=p;
			break;
		case 2:
			r=p;
			g=V;
			b=t;
			break;
		case 3:
			r=p;
			g=q;
			b=V;
			break;
		case 4:
			r=t;
			g=p;
			b=V;
			break;
		case 5:
			r=V;
			g=p;
			b=q;
			break;
	}
    float tmp[3]={r,g,b};
    return tmp;
}

//-----------------
void testApp::exit(){}
void testApp::lostFocus(){}
void testApp::gotFocus(){}
void testApp::gotMemoryWarning(){}
void testApp::deviceOrientationChanged(int newOrientation){}
void testApp::touchCancelled(ofTouchEventArgs& args){}