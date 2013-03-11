//
//  ViewController.m
//  meisogambare
//
//  Created by Rob Nugen on 3/8/13.
//  Copyright (c) 2013 Rob Nugen. All rights reserved.
//

#import "ViewController.h"

typedef enum {
    StateWaiting,
    StateCounting,
    StateStoppedBeforeGoalTime,
    StateExtraTime,
    StateStoppedAfterGoalTime
}  MeditationState;

const int  TIME_DIALATION = 1;
NSString * prefSendTweets = @"preftweet";
NSString * prefSendFBs = @"prefface";

@interface ViewController ()

@property NSTimeInterval goalTimeRemain;
@property NSDate * goalDateFTW;
@property MeditationState state;
@property (strong) NSTimer * timer;
@property (strong) NSDateFormatter *dateformatter;
@property int secondsCompletedGoal;
@property int secondsCompletedExtra;
@property Sound * click;

@end

@implementation ViewController

- (void) addThisManySecondsToDate:(int)seconds {
    self.goalDateFTW = [self.goalDateFTW dateByAddingTimeInterval:seconds];
    self.timeRemainLabel.text = [NSString stringWithFormat:@"%@",[self.dateformatter stringFromDate:self.goalDateFTW]];
}

- (void) revealCountdownTimer {
    self.timeRemainLabel.alpha = 1;
    self.countdownPicker.alpha = 0;
}

- (void) revealTimePicker {
    self.countdownPicker.alpha = 1;
    self.timeRemainLabel.alpha = 0;
}

- (IBAction)startCountdown:(id)sender {
    if(self.state == StateWaiting) {
        self.secondsCompletedExtra = 0;
        self.secondsCompletedGoal = 0;
        self.state = StateCounting;
        [self.goButton setTitle:@"stop" forState:UIControlStateNormal];
        self.goalTimeRemain = self.countdownPicker.countDownDuration;
        self.goalDateFTW = [self.countdownPicker date];
        [self addThisManySecondsToDate:0];      // just to display the goal time, not change it

        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];

        [self revealCountdownTimer];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    } else if(self.state == StateCounting) {
        if(self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.state = StateWaiting;
        [self revealTimePicker];
        [self.goButton setTitle:@"go" forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    } else if(self.state == StateExtraTime) {
        self.state = StateStoppedAfterGoalTime;
        [self.goButton setTitle:@"go" forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

- (void)updateTimer {
    self.goalTimeRemain -= 1 * TIME_DIALATION;
    [self addThisManySecondsToDate:-1 * TIME_DIALATION];

    if (0 <= self.goalTimeRemain && self.goalTimeRemain < 3) {
        [self.click play];
    }
    if (self.goalTimeRemain <= 0) // Goal time reached, so start counting up.
    {
        self.secondsCompletedGoal = self.countdownPicker.countDownDuration;
        self.state = StateExtraTime;
        if(self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
        }
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateExtraTime) userInfo:nil repeats:YES];
    }

}

- (void)updateExtraTime {
    [self addThisManySecondsToDate:1];
    self.secondsCompletedExtra += 1;

    if (self.state == StateStoppedAfterGoalTime)
    {
        [self shoutOut];
        [self revealTimePicker];
        if(self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

-(void) tweetThis:(NSString *) tweet {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType options:nil
          completion:^(BOOL granted, NSError *error) {
                if (granted)
                {
                    NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];

                    if ([arrayOfAccounts count] > 0)
                    {
                        ACAccount *twitterAccount = [arrayOfAccounts objectAtIndex:0];

                        NSURL *requestURL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];

                        NSDictionary *message = @{@"status": tweet};

                        SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                    requestMethod:SLRequestMethodPOST
                                                                              URL:requestURL
                                                                       parameters:message];

                        postRequest.account = twitterAccount;

                        [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                         {
                             NSLog(@"Twitter HTTP response: %i", [urlResponse statusCode]);
                         }];
                    }
                } else {
                    [self alertTwitterDisabledInSettings];
                }
    }];
}

- (void) face {
    ACAccountStore *account = [[ACAccountStore alloc]init];
    ACAccountType *FBaccountType= [account accountTypeWithAccountTypeIdentifier:
                                   ACAccountTypeIdentifierFacebook];
    NSString *key = FBAppID; //put your own key from FB here
    NSDictionary *dictFB = [NSDictionary dictionaryWithObjectsAndKeys:key,ACFacebookAppIdKey,@[@"email"],ACFacebookPermissionsKey, nil];
    [account requestAccessToAccountsWithType:FBaccountType options:dictFB
                                            completion: ^(BOOL granted, NSError *e) {
                                                if (granted) {
                                                    NSArray *accounts = [account accountsWithAccountType:FBaccountType];
                                                    //it will always be the last object with SSO
                                                    ACAccount * facebookAccount = [accounts lastObject];


                                                    
                                                } else {
                                                    //Fail gracefully...
                                                    NSLog(@"error getting permission %@",e);
                                                } }];

}

- (void) shoutOut {
    if(self.twitterBoolean.isOn) {
        int goalMinutes = self.secondsCompletedGoal / 60;
        int extraMinutes = self.secondsCompletedExtra / 60;
        if(extraMinutes > 1) {
            [self tweetThis:[NSString stringWithFormat:@"just successfully meditated with @meisogambare timer for %d minutes plus %d bonus minutes",goalMinutes,extraMinutes]];
        } else if(extraMinutes == 1) {
            [self tweetThis:[NSString stringWithFormat:@"just successfully meditated with @meisogambare timer for %d minutes plus %d bonus minute",goalMinutes,extraMinutes]];
        } else {
            [self tweetThis:[NSString stringWithFormat:@"just successfully meditated with @meisogambare timer for %d minutes",goalMinutes]];
        }
    }
    if(self.facebookBoolean.isOn) {
        [self face];
    }
    self.state = StateWaiting;
}
- (IBAction)countdownChanged:(id)sender {
}

- (void) alertTwitterDisabledInSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter Disabled in settings" message:@"Please go into your device's settings menu to allow access to your Twitter account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

- (IBAction)twitterToggled:(id)sender {
    if(self.twitterBoolean.isOn) {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                      ACAccountTypeIdentifierTwitter];

        [account requestAccessToAccountsWithType:accountType
                                         options:nil
                                      completion:^(BOOL granted, NSError *error) {
                                          if (granted)
                                          {
                                              [[NSUserDefaults standardUserDefaults] setBool:self.twitterBoolean.isOn forKey:prefSendTweets];
                                          } else {
                                              [self alertTwitterDisabledInSettings];
                                              [self.twitterBoolean setOn:NO animated:YES];
                                          }
                                      }];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:self.twitterBoolean.isOn forKey:prefSendTweets];
    }
}
- (IBAction)facebookToggled:(id)sender {
    NSLog(@"setting FB to %d",self.facebookBoolean.isOn);
    [[NSUserDefaults standardUserDefaults] setBool:self.facebookBoolean.isOn forKey:prefSendFBs];
}

- (void) checkSettings {
    [self.twitterBoolean setOn:[[NSUserDefaults standardUserDefaults] boolForKey:prefSendTweets]];
    [self.facebookBoolean setOn:[[NSUserDefaults standardUserDefaults] boolForKey:prefSendFBs]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkSettings];
    self.state = StateWaiting;
    self.timeRemainLabel.alpha = 0;
    self.dateformatter = [[NSDateFormatter alloc] init];
    [self.dateformatter setDateFormat:@"HH:mm:ss"];
    self.click = [[Sound alloc] initWithPath:@"click.caf"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
