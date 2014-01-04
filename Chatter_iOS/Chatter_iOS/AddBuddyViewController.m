//
//  AddBuddyViewController.m
//  Chatter_iOS
//
//  Created by Joe Martin on 1/4/14.
//  Copyright (c) 2014 Indigo Technology. All rights reserved.
//

#import "AddBuddyViewController.h"
#import "AppDelegate.h"

@interface AddBuddyViewController ()

@end

@implementation AddBuddyViewController

@synthesize username;

//Provides a reference to the app delegate so that methods in the app delegate can be called
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//Quick reference to the AppDelegate's xmppStream. This makes localization of signin, signout, and register actions simpler
- (XMPPRoster *)xmppRoster
{
	return [self.appDelegate xmppRoster];
}

// Add a buddy

- (IBAction)submit:(id)sender
{
	XMPPJID *jid = [XMPPJID jidWithString:[username text]];
	
	[[self xmppRoster] addUser:jid withNickname:nil];
	
	// Clear buddy text field
	[username setText:@""];
    [self.view endEditing:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
