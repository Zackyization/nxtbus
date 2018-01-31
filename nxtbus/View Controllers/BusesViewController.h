//
//  BusesViewController.h
//  nxtbus
//
//  Created by Zildjian Garcia on 27/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface BusesViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
