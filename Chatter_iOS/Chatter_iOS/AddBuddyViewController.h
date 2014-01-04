//
//  AddBuddyViewController.h
//  Chatter_iOS
//
//  Created by Joe Martin on 1/4/14.
//  Copyright (c) 2014 Indigo Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddBuddyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *username;
- (IBAction)submit:(id)sender;

@end
