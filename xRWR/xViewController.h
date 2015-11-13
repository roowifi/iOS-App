//
//  xViewController.h
//  xRWR
//
//  Created by Xavier-Martí Carné Mohedano on 04/03/12.
//  Copyright (c) 2012 __RooWifi__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LXSocket.h"

@interface xViewController : UIViewController <UIAccelerometerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LoadingCercle;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *active;
@property (weak, nonatomic) IBOutlet UILabel *LabelObstacle;
@property (weak, nonatomic) IBOutlet UIButton *Vac_But;
@property (weak, nonatomic) IBOutlet UISwitch *Switcher;
@property (weak, nonatomic) IBOutlet UIButton *CleanButton;
@property (weak, nonatomic) IBOutlet UISlider *Slider;
@property (weak, nonatomic) IBOutlet UIButton *StopButton;
@property (weak, nonatomic) IBOutlet UITextField *Data;
@property (weak, nonatomic) IBOutlet UIButton *Accelerate_But;
@property (weak, nonatomic) IBOutlet UIButton *Brake_But;
@property (weak, nonatomic) IBOutlet UIImageView *RobotCentral;
@property (weak, nonatomic) IBOutlet UILabel *LabelSpeed;
@property (weak, nonatomic) IBOutlet UILabel *LabelAngle;
@property (weak, nonatomic) IBOutlet UILabel *StatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *BatteryLabel;
@property (weak, nonatomic) IBOutlet UILabel *LabelSpeedLimit;
@property (weak, nonatomic) IBOutlet UIButton *ConfigButton;
@end
