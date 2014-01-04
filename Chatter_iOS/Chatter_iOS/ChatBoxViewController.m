//
//  ChatBoxViewController.m
//  Chatter_iOS
//
//  Created by Joe Martin on 1/3/14.
//  Copyright (c) 2014 Indigo Technology. All rights reserved.
//

#import "ChatboxViewController.h"
#import "NSXMLElement+XMPP.h"
#import "NSString+DDXML.h"
#import "AppDelegate.h"

@interface ChatboxViewController ()

@end

@implementation ChatboxViewController

@synthesize messageField;
@synthesize messageReceiver;

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
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


- (IBAction)done:(id)sender
{
    
    [self sendMessage];
    [self.messageField setText:@""];
    [self.view endEditing:YES];
    
}


-(void)sendMessage
{
    NSString *messageStr = messageField.text;
    if([messageStr length] > 0)
    {
        //NSLog(@"%@",[self messageReceiver]);
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:[self messageReceiver]];
        [message addChild:body];
        // NSLog(@"message1%@",message);
        
        [[self appDelegate].xmppStream sendElement:message];
    }
}

@end
