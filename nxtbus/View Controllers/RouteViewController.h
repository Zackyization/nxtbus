//
//  RouteViewController.h
//  nxtbus
//
//  Created by Zildjian Garcia on 20/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface RouteViewController : UIViewController  <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic) NSString *busService;
@property (nonatomic) NSString *currentBusStopID;

@end
