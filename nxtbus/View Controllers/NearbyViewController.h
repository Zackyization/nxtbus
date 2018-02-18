//
//  BusesViewController.h
//  nxtbus
//
//  Created by Zildjian Garcia on 27/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserv ed.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "FMDatabase.h"

@interface NearbyViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property CLLocationManager *locationManager;
@property NSMutableArray *nearbyBusStops;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


- (IBAction)centerUserLocation:(id)sender;
- (IBAction)refreshButton:(id)sender;

@end
