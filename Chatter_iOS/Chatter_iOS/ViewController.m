//
//  ViewController.m
//  Chatter_iOS
//
//  Created by Joe Martin on 10/24/13.
//  Copyright (c) 2013 Indigo Technology. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)loginView:(id)sender {
    //transition to the view containing the login screen
    [self performSegueWithIdentifier:@"settings" sender:self];
}

- (IBAction)buddyListView:(id)sender {
    //transition to the view containing the buddy list
    [self performSegueWithIdentifier:@"buddy" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
