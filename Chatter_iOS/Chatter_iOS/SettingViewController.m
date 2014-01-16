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

-(XMPPvCardTempModule *)xmppvCardTempModule {
    return [self.appDelegate xmppvCardTempModule];
}

/*
 
 This is responsible for updating the default information for creating the XMPP connection
 This will be called every time before signing in, and before registering
 
 Notes:
    - set the xmppStream.hostName in appDelegate
    - set the xmppSteam.hostPort in appDelegate
    - set useSSL, allowSelfSignedCertificates, and allowSSLHostNameMismatch in appDelegate
    - removed resource field, shouldn't need it
 */


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add this view as delegate (allows for methods like didStreamConnect)
    [[self xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[self xmppvCardTempModule] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    username.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Account.JID"];
    password.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"Account.password"];
    
}

// This method is responsible for updating the user defaults
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


// Add some error handling by putting delegate methods visible in this class
- (IBAction)registerUser:(id)sender {
    
    //Disconnect old stream
    [self goOffline];
   // [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    [self updateAccountInfo];
    [self.view endEditing:YES];
    
    //Create a new connection
    NSError *error = nil;
    //Establish the stream connection with the current JID
    isRegistering = YES;
    [[self xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
}


//The action that responds to signing in
- (IBAction)submit:(id)sender {
    
    //Disconnect old stream
    [self goOffline];
//    [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    [self updateAccountInfo];
    [self.view endEditing:YES];
    
    //Create a new connection
    NSError *error = nil;
    //Establish the stream connection with the current JID
    isAuthenticating = YES;
    [[self xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    
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
        firstLogin = YES;
        
	}
	else
	{
        
        [[self xmppStream] authenticateWithPassword:myPassword error:&error];
        isAuthenticating = NO;
	}

}

//-----------------------DELEGATE METHODS--------------------------------------
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
    NSError *error = nil;
    
    //Disconnect old stream
    [self goOffline];
    [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    
    //Create a new connection
    isAuthenticating = YES;
    [[self xmppStream] connectWithTimeout:XMPPStreamTimeoutNone error:&error];
}


- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
    firstLogin = NO;
    
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    
    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    if([errorCode isEqualToString:@"409"]){
        
        [alert setMessage:@"Username Already Exists!"];
    }
    [alert show];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    
    if (firstLogin) {
        
        
        //Create the vcard to store device ID and phone type
        NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
        XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
        [newvCardTemp setMailer:@"3eca19d72fff06a1ac349a4821d1178c3e0a38aea54631efe07f05b6bea10cec"];
       // [newvCardTemp setMailer:@"HERRO"];
        [[self xmppvCardTempModule] updateMyvCardTemp:newvCardTemp];
        
        firstLogin = NO;
    }
    
	[self goOnline];
}

// Sign on and Sign off

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
    [[self xmppStream] disconnect];
}

@end
