//
//  BuddyListViewController.h
//  Chatter_iOS
//
//  Created by Joe Martin on 1/2/14.
//  Copyright (c) 2014 Indigo Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface BuddyListViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
    // This needed to be within the interface, as it somehow affects visibility to other controllers
    NSFetchedResultsController *fetchedResultsController;
}

@end
