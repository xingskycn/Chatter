//
//  SettingViewController.m
//  Chatter_iOS
//
//  Created by Joe Martin on 1/2/14.
//  Copyright (c) 2014 Indigo Technology. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "XMPPFramework.h"

//Not even sure...somehow this makes the login visible to another controller
//Maybe this is sort of weird global hash
NSString *const kXMPPmyJID = @"kXMPPmyJID";
NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

@implementation SettingViewController

@synthesize username;
@synthesize password;


//Provides a reference to the app delegate so that methods in the app delegate can be called
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Disconnect old stream
    [[self appDelegate] disconnect];
    [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];

    username.text = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    password.text = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setField:(UITextField *)field forKey:(NSString *)key
{
    if (field.text != nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:field.text forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
}

- (IBAction)submit:(id)sender {
    
    [self setField:username forKey:kXMPPmyJID];
    [self setField:password forKey:kXMPPmyPassword];
    [self.view endEditing:YES];
    
    //Create a new connection stream
    [[self appDelegate] connect];
}
@end
