//
//  ChatBoxViewController.h
//  Chatter_iOS
//
//  Created by Joe Martin on 1/3/14.
//  Copyright (c) 2014 Indigo Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ChatboxViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *messageField;
- (IBAction)done:(id)sender;

@property (nonatomic, strong) NSString *messageReceiver;
@property (nonatomic,strong) CLLocationManager *locationManager;


@end