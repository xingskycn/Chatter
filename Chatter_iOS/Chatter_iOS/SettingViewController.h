//
//  SettingViewController.h
//  Chatter_iOS
//
//  Created by Joe Martin on 1/2/14.
//  Copyright (c) 2014 Indigo Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController
{
    BOOL isRegistering;
    BOOL isAuthenticating;
    BOOL firstLogin;
    
}

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)registerUser:(id)sender;
- (IBAction)submit:(id)sender;

@end
