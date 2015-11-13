//
//  x2ViewController.m
//  xRWR
//
//  Created by Xavier-Martí Carné Mohedano on 10/03/12.
//  Copyright (c) 2012 __RooWifi__. All rights reserved.
//

#import "x2ViewController.h"

@interface x2ViewController ()

@end

@implementation x2ViewController
@synthesize SaveBut;
@synthesize IPTextBox;
@synthesize InternalWebSiteBut;
@synthesize SensorSwitcher;
@synthesize CarnlanWebSiteBut;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)SaveDataConfig:(id)sender {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    // saving an NSString
    [prefs setObject:IPTextBox.text forKey:@"RoombaIP"];
    
    // saving an NSInteger
    if(self.SensorSwitcher.on)
    [prefs setInteger:1 forKey:@"sensoringRoomba"];
    else
    [prefs setInteger:0 forKey:@"sensoringRoomba"];    
    
    // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
    [prefs synchronize];
}
-(IBAction)dismissKeyboard: (id)sender {
    [sender resignFirstResponder];
}
- (IBAction)ShowInternalWebSite:(id)sender {
    NSString *s= [[NSString alloc]initWithFormat:@"http://%@/wcfg.html",IPTextBox.text];
    NSURL *url = [ [ NSURL alloc ] initWithString: s ];
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)ShowCarnlanWebSite:(id)sender {
     NSURL *url = [ [ NSURL alloc ] initWithString: @"http://www.roowifi.com" ];
    [[UIApplication sharedApplication] openURL:url];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    IPTextBox.text= [prefs stringForKey:@"RoombaIP"];
    
    if([prefs integerForKey:@"sensoringRoomba"]==1) self.SensorSwitcher.on=TRUE;
    else self.SensorSwitcher.on=FALSE;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSaveBut:nil];
    [self setIPTextBox:nil];
    [self setCarnlanWebSiteBut:nil];
    [self setInternalWebSiteBut:nil];
    [self setSensorSwitcher:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

@end
