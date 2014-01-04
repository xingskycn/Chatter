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


@implementation SettingViewController

@synthesize username;
@synthesize password;


//Provides a reference to the app delegate so that methods in the app delegate can be called
- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//Quick reference to the AppDelegate's xmppStream. This makes localization of signin, signout, and register actions simpler
- (XMPPStream *)xmppStream
{
	return [self.appDelegate xmppStream];
}

/*
 
 This is responsible for updating the default information for creating the XMPP connection
 This will be called every time before signing in, and before registering
 
 Notes:
    - set the xmppStream.hostName in appDelegate
    - set the xmppSteam.hostPort in appDelegate
    - set useSSL, allowSelfSignedCertificates, and allowSSLHostNameMismatch in appDelegate
    - removed resouce field, shouldn't need it
 */

- (void)updateAccountInfo
{
	//NSString *domain = [serverField stringValue];
	//self.xmppStream.hostName = domain;
	
	//int port = [portField intValue];
	//self.xmppStream.hostPort = port;
	
//	useSSL                      = ([sslButton state] == NSOnState);
//	allowSelfSignedCertificates = ([selfSignedButton state] == NSOnState);
//	allowSSLHostNameMismatch    = ([mismatchButton state] == NSOnState);
	
//	NSString *resource = [resourceField stringValue];
//	if ([resource length] == 0)
//	{
//		resource = (__bridge_transfer NSString *)SCDynamicStoreCopyComputerName(NULL, NULL);
//	}
	
	XMPPJID *jid = [XMPPJID jidWithString:[username text]];
	self.xmppStream.myJID = jid;
	
	// Update persistent info
	
	NSUserDefaults *dflts = [NSUserDefaults standardUserDefaults];
	
//	[dflts setObject:domain forKey:@"Account.Server"];
	
//	[dflts setObject:(port ? [NSNumber numberWithInt:port] : nil)
//			  forKey:@"Account.Port"];
	
	[dflts setObject:[username text]
			  forKey:@"Account.JID"];
	
//	[dflts setObject:[resourceField stringValue]
//			  forKey:@"Account.Resource"];
	
//	[dflts setBool:useSSL                      forKey:@"Account.UseSSL"];
//	[dflts setBool:allowSelfSignedCertificates forKey:@"Account.AllowSelfSignedCert"];
//	[dflts setBool:allowSSLHostNameMismatch    forKey:@"Account.AllowSSLHostNameMismatch"];
	
//	if ([rememberPasswordCheckbox state] == NSOnState)
//	{
//		NSString *jidStr   = [username text];
//		NSString *password = [password text];
		
//		[SSKeychain setPassword:password forService:@"XMPPFramework" account:jidStr];
//
//		[dflts setBool:YES forKey:@"Account.RememberPassword"];
//	}
//	else
//	{
//		[dflts setBool:NO forKey:@"Account.RememberPassword"];
//	}
    
    [dflts setObject:[password text]
			  forKey:@"Account.password"];
    
	
	[dflts synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add this view as delegate (allows for methods like didStreamConnect)
    [[self xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    username.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Account.JID"];
    password.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Account.password"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)registerUser:(id)sender {
    
    //Disconnect old stream
    [[self appDelegate] disconnect];
    [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    [self updateAccountInfo];
    [self.view endEditing:YES];
    
    //Create a new connection
    NSError *error = nil;
    //Establish the stream connection with the current JID
    [[self xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
    isRegistering = YES;
    
    //Attempt to register the JID and password
    NSString *passwordStr = [password text];
    [[self xmppStream] registerWithPassword:passwordStr error:&error];
}

-(void)registerClient
{
    
    /*
    NSMutableArray *elements = [NSMutableArray array];
    [elements addObject:[NSXMLElement elementWithName:@"username" stringValue:@"aroon@localhost"]];
    [elements addObject:[NSXMLElement elementWithName:@"password" stringValue:@"waffles"]];
    [elements addObject:[NSXMLElement elementWithName:@"name" stringValue:@"Aroon Sharma"]];
    [elements addObject:[NSXMLElement elementWithName:@"accountType" stringValue:@"3"]];
    [elements addObject:[NSXMLElement elementWithName:@"deviceToken" stringValue:@"adfg3455bhjdfsdfhhaqjdsjd635n"]];
    
    [elements addObject:[NSXMLElement elementWithName:@"email" stringValue:@"subbareddy.vennapusa@sagarsoft.in"]];
    
    [[[self appDelegate] xmppStream] registerWithElements:elements error:nil];
     
     */
    
}
//The action that responds to signing in
- (IBAction)submit:(id)sender {
    
    //Disconnect old stream
    [[self appDelegate] disconnect];
    [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    [self updateAccountInfo];
    [self.view endEditing:YES];
    
    //Create a new connection
    NSError *error = nil;
    //Establish the stream connection with the current JID
    [[self xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
    isAuthenticating = YES;
    
    /*
    //Attempt to validate a password with that JID
    NSString *passwordStr = [password text];
    [[self xmppStream] authenticateWithPassword:passwordStr error:&error];
     */
    
	
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    
	
	NSError *error = nil;
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:@"Account.password"];
    
    if (isRegistering)
	{
        [[self xmppStream] registerWithPassword:myPassword error:&error];
        isRegistering = NO;
	}
	else
	{
        [[self xmppStream] authenticateWithPassword:myPassword error:&error];
        isAuthenticating = NO;
	}

}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	
	[self goOnline];
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

@end
