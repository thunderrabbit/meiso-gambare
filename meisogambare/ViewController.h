//
//  ViewController.h
//  meisogambare
//
//  Created by Rob Nugen on 3/8/13.
//  Copyright (c) 2013 Rob Nugen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Sound.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *countdownPicker;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UISwitch *twitterBoolean;
@property (weak, nonatomic) IBOutlet UISwitch *facebookBoolean;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainLabel;

@end
