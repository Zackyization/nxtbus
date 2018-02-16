//
//  BusesViewController.m
//  nxtbus
//
//  Created by Zildjian Garcia on 27/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "NearbyViewController.h"
#import "ZJBusArrival.h"

#import "busStopCellView.h"
#import "BusStopViewController.h"

@interface NearbyViewController ()

@property ZJBusArrival *busArrive;
@property (weak, nonatomic) IBOutlet UILabel *nearbyBusStopsLabel;
@property NSMutableArray *sortedStopsByDistance;

@property NSString *busStopTitleValue;
@property NSString *busStopIDValue;

@end

@implementation NearbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    _busArrive = [[ZJBusArrival alloc] init];

    [_busArrive addBusStopAnnotationsToMap:self.mapView fromUserLocation:self.locationManager.location];
    _nearbyBusStops = [[NSMutableArray alloc] init];
    _nearbyBusStops = [_busArrive getNearbyBusStops:self.locationManager.location];
 
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor whiteColor];
    [refresh addTarget:self action:@selector(refreshButton:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = refresh;
}
-(void)viewDidAppear:(BOOL)animated {
    [self centerUserLocation:nil];
    _nearbyBusStops = [_busArrive getNearbyBusStops:self.locationManager.location];
    self.nearbyBusStopsLabel.text = [NSString stringWithFormat:@"%lu nearby", (unsigned long)[_nearbyBusStops count]];
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}

- (void)removeAllPinsButUserLocation {
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if ( userLocation != nil ) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }

    [self.mapView removeAnnotations:pins];
    pins = nil;
}

- (IBAction)centerUserLocation:(id)sender {
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.locationManager.location.coordinate;
    mapRegion.span.latitudeDelta = 0.008;
    mapRegion.span.longitudeDelta = 0.008;
    
    [self.mapView setRegion:mapRegion animated:YES];
}

- (IBAction)refreshButton:(id)sender {
    //Refresh nearby bus stops
    [self removeAllPinsButUserLocation];
    [_busArrive addBusStopAnnotationsToMap:self.mapView fromUserLocation:self.mapView.userLocation.location];
    _nearbyBusStops = [_busArrive getNearbyBusStops:self.locationManager.location];
    self.nearbyBusStopsLabel.text = [NSString stringWithFormat:@"%lu nearby", (unsigned long)[_nearbyBusStops count]];
    [self centerUserLocation:nil];
    
//    [self.tableView reloadData];
    
    [self.tableView reloadData];
    [self.tableView.refreshControl endRefreshing];
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *busStopCellIdentifer = @"BusStopCell";
    busStopCellView *cell = (busStopCellView *)[tableView dequeueReusableCellWithIdentifier:busStopCellIdentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"busStopCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    _busArrive = [_nearbyBusStops objectAtIndex:indexPath.row];
    cell.stopNameLabel.text = _busArrive.busStopName;
    cell.stopIDLabel.text = _busArrive.busStopID;
    
    NSMutableString *busServices = [[NSMutableString alloc] init];
    NSArray *b = [[NSArray alloc] init];
    
    //get bus services
    b = [_busArrive getBusStopServiceNumbersFromBusStopID:_busArrive.busStopID];
    for (int i = 0; i < [b count]; i++) {
        if (i == ([b count] - 1)) {
            [busServices appendString:[NSString stringWithFormat:@"%@", [b objectAtIndex:i]]];
        } else {
            [busServices appendString:[NSString stringWithFormat:@"%@, ", [b objectAtIndex:i]]];
        }
    }

    cell.stopServicesLabel.text = busServices;
    
    //get distance
    NSString *distance = [NSString stringWithFormat:@"%im", [_busArrive getDistanceFromUserToBusStop:_busArrive.busStopID userLocation:self.locationManager.location]];
    cell.distanceAwayLabel.text = distance;

    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_nearbyBusStops count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    busStopCellView *cell = (busStopCellView *)[tableView cellForRowAtIndexPath:indexPath];
    self.busStopTitleValue = cell.stopNameLabel.text;
    self.busStopIDValue = cell.stopIDLabel.text;
    
    [self performSegueWithIdentifier:@"busStopSegue" sender:self];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([[segue identifier] isEqualToString:@"busStopSegue"]) {
         BusStopViewController *vc = [segue destinationViewController];
         vc.navigationItem.title = self.busStopTitleValue;
         vc.busStopID = self.busStopIDValue;
         [vc.busStopIDLabel setText:self.busStopIDValue];
     }
 }
@end
