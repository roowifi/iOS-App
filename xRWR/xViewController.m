//
//  xViewController.m
//  xRWR
//
//  Created by Xavier-Martí Carné Mohedano on 04/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "xViewController.h"

@interface xViewController ()

@end

@implementation xViewController
@synthesize LabelSpeed;
@synthesize LabelAngle;
@synthesize StatusLabel;
@synthesize BatteryLabel;
@synthesize LabelSpeedLimit;
@synthesize ConfigButton;
@synthesize LoadingCercle;
@synthesize active;
@synthesize LabelObstacle;
@synthesize Vac_But;
@synthesize Switcher;
@synthesize CleanButton;
@synthesize Slider;
@synthesize StopButton;
@synthesize Data;
@synthesize Accelerate_But;
@synthesize Brake_But;
@synthesize RobotCentral;

LXSocket *Socket;
Byte RoombaSpeed;
Byte RoombaBrake;
Byte AngleH;
Byte AngleL;
float AngleAccel;
float SpeedAccel;
float Angle;
Byte SensorState;
Byte ConnectionState;
int BatR;
int BatN;
int MaxSpeed;
NSTimer *TempocheckLoad;
NSTimer *TempoUpdater;
NSTimer *TempoConnectionFSM;
bool VacuumState;
- (void)viewDidLoad
{
    [super viewDidLoad];
    Socket=nil;
     SpeedAccel = 0;
 
    BatR=1;
    BatN=1;
    SensorState = 0;
    ConnectionState=0;
    VacuumState=FALSE;
	if (Socket==nil)
        Socket=[[LXSocket alloc]init];
    TempocheckLoad=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkLoad) userInfo:nil repeats:YES];
    TempoUpdater = [NSTimer scheduledTimerWithTimeInterval:0.07 target:self selector:@selector(Updater) userInfo:nil repeats:YES];
    TempoConnectionFSM= [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(ConnectionFSM) userInfo:nil repeats:YES];
    UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
    accel.delegate = self;
    accel.updateInterval = 1.0f / 15.0f;
    
    
}
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{

    if (acceleration.y < 0) AngleAccel =-sqrtf(sqrtf(sqrtf(-acceleration.y)))*1900;
    else AngleAccel =sqrtf(sqrtf(sqrtf(acceleration.y)))*1900;
    
    if(AngleAccel > 1990) AngleAccel = 1990;
    if(AngleAccel < -1990) AngleAccel = -1990;
    if(AngleAccel > -10 && AngleAccel < 10) AngleAccel =0;   
    Angle=(acceleration.y)/2;
 
}
-(void) rotateRobotCentralToDegree{
    CGAffineTransform rotate = CGAffineTransformMakeRotation( Angle * M_PI );
    [RobotCentral setTransform:rotate];
}
-(void) Updater
{
   
        Byte MyArray[5];
        MyArray[0]=137;
        MyArray[1]=0;
    
        int iAuxValPos = (int)2000-AngleAccel;
        int iAuxValNeg = (int)2000+AngleAccel;
    
        switch(iAuxValNeg-2000)
        {
            case 0: MyArray[3] = 0x80; MyArray[4] = 0x00; break;
            default: 
                if(AngleAccel>0){
                MyArray[3] = (Byte)(((-iAuxValPos)>>8)&0x00FF);
                MyArray[4] = (Byte)((-iAuxValPos)&0x00FF);
                }else {
                    MyArray[3] = (Byte)((iAuxValNeg>>8)&0x00FF);
                    MyArray[4] = (Byte)(iAuxValNeg&0x00FF);
                }
                break;
        }
        if(RoombaBrake)
        {
            
            if(SpeedAccel >0) SpeedAccel -=100;
            else if(SpeedAccel<=-MaxSpeed*10) SpeedAccel = -MaxSpeed*10;
            else SpeedAccel -=MaxSpeed;
        }
        if(RoombaSpeed)
        {
            if(SpeedAccel < 0) SpeedAccel +=100;
            else if(SpeedAccel>=MaxSpeed*10) SpeedAccel = MaxSpeed*10;
            else SpeedAccel +=MaxSpeed;
        }
        if(RoombaBrake==0 && RoombaSpeed==0)
        {
            if(SpeedAccel>0) SpeedAccel-=40;
            else if(SpeedAccel<0) SpeedAccel+=40;
            if(SpeedAccel>=-40 && SpeedAccel<=40 ) SpeedAccel=0;            
        }
        switch((int)SpeedAccel)
        {
            case 0: MyArray[1] = 0x00; MyArray[2] = 0x00; break;
            default: MyArray[1] = (Byte)((((int)(SpeedAccel))>>8)&0x00FF);
                MyArray[2] = (Byte)(((int)(SpeedAccel))&0x00FF);
                break;
        }
    if([Socket IsConnected])
    {    
        
        [Socket sendBytes:(const void*)MyArray length:5];
    }
}
-(void) UpdateUI
{ 
    BatteryLabel.text = [NSString stringWithFormat:@"%d",100*BatN/BatR];
}

- (void) checkLoad 
{

    Byte* kk;
    Byte MyArray[2]; 
    Byte Leds[4];
    void * Aux;
      NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
            
    MaxSpeed   =(int)Slider.value;
    LabelSpeedLimit.text=[NSString stringWithFormat:@"%d",MaxSpeed*10];
    kk=nil;
   
    if([Socket IsConnected])
    {
        if([prefs integerForKey:@"sensoringRoomba"]==1)
        {
            if((SensorState!=0) && (SensorState!=27) && (SensorState!=28))
            { 
                Aux = [Socket readBytesWithLength:1];
                if(Aux!=nil)
                {
                    kk=(Byte *)Aux;
                }
                else {
                    kk=alloca(1);
                    kk[0]=0;
                }
            }
        }
        else {
            kk=alloca(1);
            kk[0]=0;
            if(SensorState==0) SensorState=1;
        }
        switch(SensorState)
        {
            case 0:
                MyArray[0]=142;
                MyArray[1]=0;
                [Socket sendBytes:(const void*)MyArray length:2];
                SensorState++;
                break;
            case 1:
                //Impacte
                if ((kk[0]&0x0F)!=0)
                {
                    LabelObstacle.textColor =[UIColor redColor];
                }else{ 
                    LabelObstacle.textColor =[UIColor blackColor];
                }
                    SensorState++;
                break;
                //BATERIA
            case 23:
                BatN = (BatN&0x00FF)|((int)(kk[0]<<8)); 
                SensorState++;
                break;
            case 24:
                BatN = (BatN&0xFF00)|((int)(kk[0]));
                SensorState++;
                break;
            case 25:
                BatR = (BatR&0x00FF)|((int)(kk[0]<<8));
                SensorState++;
                break;
            case 26:
                BatR = (BatR&0xFF00)|((int)(kk[0]));
                [self UpdateUI];
                SensorState++;
                break;
            case 27:
                Leds[0]=139;
                Leds[1]=0x01;
                Leds[2]=0x00;
                Leds[3]=0x0F;
                [Socket sendBytes:(const void*)Leds length:4];
               SensorState++;
                break;
            case 28:
                Leds[0]=139;
                Leds[1]=0x00;
                Leds[2]=0x00;
                Leds[3]=0x00;
                [Socket sendBytes:(const void*)Leds length:4];
                SensorState=0;
                break;
            default:
                SensorState++;
                break;
        }
           
        [self rotateRobotCentralToDegree];
        LabelSpeed.text= [NSString stringWithFormat:@"%g", SpeedAccel];
        LabelAngle.text= [NSString stringWithFormat:@"%d", (int)AngleAccel];
        StatusLabel.textColor =[UIColor greenColor];
        LabelSpeed.textColor =[UIColor greenColor];
        LabelAngle.textColor =[UIColor blueColor];
        StatusLabel.text =[NSString stringWithFormat:@"0N"];
        [active startAnimating];
        if(RobotCentral.alpha<1) RobotCentral.alpha+=0.1;
        if(RobotCentral.alpha>=1) RobotCentral.alpha=1;
        
    }else {
        LabelSpeed.textColor =[UIColor blackColor];
        LabelAngle.textColor =[UIColor blackColor];
        StatusLabel.textColor =[UIColor redColor];
        StatusLabel.text =[NSString stringWithFormat:@"0FF"];
        [active stopAnimating];
        if(RobotCentral.alpha>0.1) RobotCentral.alpha-=0.1;
        if(RobotCentral.alpha<=0.1) RobotCentral.alpha=0.1;
    }
}
- (IBAction)Vacuum:(id)sender {
    Byte MyArray[2];
    
    MyArray[0]=138;
    if (VacuumState==FALSE){
     MyArray[1]=0x07;
        VacuumState=TRUE;
    }else {
        MyArray[1]=0;
        VacuumState=FALSE;
    }
    
    [Socket sendBytes:(const void*)MyArray length:2];
}

- (void)viewDidUnload
{
    [self setActive:nil];
    [self setSwitcher:nil];
    [self setCleanButton:nil];
    [self setSlider:nil];
    [self setStopButton:nil];
    [self setData:nil];
    [self setAccelerate_But:nil];
    [self setBrake_But:nil];
    [self setRobotCentral:nil];
    if ([Socket IsConnected]) [Socket disconnect];
    Socket=nil;
    [self setLabelSpeed:nil];
    [self setLabelAngle:nil];
    [self setStatusLabel:nil];
    [self setBatteryLabel:nil];
    [self setConfigButton:nil];
    [self setLabelSpeedLimit:nil];
    [self setLabelObstacle:nil];
    [self setLoadingCercle:nil];
    [TempocheckLoad invalidate];
    [TempoUpdater invalidate];
    [TempoConnectionFSM invalidate];
    [self setVac_But:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}
- (void)StopMoving {
    Byte MyArray[5];
    
    MyArray[0]=137;
    MyArray[1]=0x00; MyArray[2]=0x00;
    MyArray[3]= 0x80; MyArray[4]=0x00;
    
    if(Socket.IsConnected)
    {
        [Socket sendBytes:(const void*)MyArray length:5];
    } 
}
- (IBAction)AccelerateMoving:(id)sender {
    RoombaSpeed = 1;
    RoombaBrake = 0;
}
- (IBAction)StopAccelerate:(id)sender {
    RoombaSpeed = 0;
    RoombaBrake = 0;
}
- (IBAction)BrakeMoving:(id)sender {
    RoombaBrake=1;
    RoombaSpeed=0;
}
- (IBAction)StopMoving:(id)sender {
    RoombaSpeed =0;
    RoombaBrake=0;
}

- (IBAction)CleanButtonDown:(id)sender {
    if(Socket.IsConnected)
    {
        [Socket sendShort:135];
        [self Switcher].on=FALSE;
        SensorState=0;
        [Socket disconnect];
    }
}
- (IBAction)SpotButtonDown:(id)sender {
    if(Socket.IsConnected)
    {
        [Socket sendShort:134];
        [self Switcher].on=FALSE;
        SensorState=0;
        [Socket disconnect];
    }
}
- (IBAction)DockButtonDown:(id)sender {
    if(Socket.IsConnected)
    {
        [Socket sendShort:143];
        [self Switcher].on=FALSE;
        SensorState=0;
        [Socket disconnect];
    }
}
-(void) Disconnecter
{
    [Socket disconnect];
}
-(void)ConnectionFSM
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Roomba Wi-Fi Remote" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
    Byte MyArray[2];
    
    switch (ConnectionState)
    {
        case 1:
            if ([Socket IsConnected]){
                message.message=@"You are allready connected";
                [message show];
            }
            else 
            {
                [LoadingCercle startAnimating];
                ConnectionState++;    
            }
            
            break;
        case 2:
            if ([Socket connect: [prefs stringForKey:@"RoombaIP"] port: 9001] == NO) 
            { 
                [self Switcher].on = FALSE;
                [LoadingCercle stopAnimating];
                message.message=@"Failed Connection. Review your Configuration";
                [message show];
            }
            else 
            {
                [LoadingCercle stopAnimating];
                MyArray[0]=130;
                MyArray[1]=132;
                [Socket sendBytes:(const void*)MyArray length:2];
            }
            ConnectionState=0;
            break;
            
        case 0://IDLE
            break;
        default:
            ConnectionState=0;
            break;
    }
}
- (IBAction)SwitcherChange:(id)sender {
    SpeedAccel = 0;
    Byte MyArray[2];
    if([self Switcher].on)
   {
       ConnectionState=1;
   }
   else
   {
       if ([Socket IsConnected] == TRUE) 
       {

           SensorState=0; //CAL FER FFLUSH
           MyArray[0]=143;
           MyArray[1]=143;
           [Socket sendBytes:(const void*)MyArray length:1];
           [NSThread sleepForTimeInterval:0.5];
           [Socket sendBytes:(const void*)MyArray length:1];
           [Socket disconnect];
          
       }
   }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
       if ([Socket IsConnected]) [Socket disconnect];
    Socket=nil;
    
    [TempocheckLoad invalidate];
    [TempoUpdater invalidate];
    [TempoConnectionFSM invalidate];
    TempocheckLoad=nil;
    TempoUpdater=nil;
    TempoConnectionFSM=nil;
}
@end
