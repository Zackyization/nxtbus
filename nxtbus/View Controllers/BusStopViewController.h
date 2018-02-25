//
//  BusStopViewController.h
//  nxtbus
//
//  Created by Zildjian Garcia on 10/2/18.ith
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusStopViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSString *busStopID;
@property (nonatomic) NSString *busStopTitle;
@property (weak, nonatomic) IBOutlet UILabel *busStopIDLabel;
@property (weak, nonatomic) IBOutlet UINavigationBar *modalNavigationBar;

@end
