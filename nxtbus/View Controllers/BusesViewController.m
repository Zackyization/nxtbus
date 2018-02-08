//
//  BusesViewController.m
//  nxtbus
//
//  Created by Zildjian Garcia on 27/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "BusesViewController.h"
#import "ZJBusArrival.h"

#import "busStopCellView.h"

@interface BusesViewController ()

@property ZJBusArrival *busArrive;
@property (weak, nonatomic) IBOutlet UILabel *nearbyBusStopsLabel;

@end

@implementation BusesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate]; //TODO: fix status bar colour issue
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

//    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _busArrive = [[ZJBusArrival alloc] init];

    [_busArrive addBusStopAnnotationsToMap:self.mapView fromUserLocation:self.locationManager.location];
    _nearbyBusStops = [[NSMutableArray alloc] init];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [self centerUserLocation:nil];
    _nearbyBusStops = [_busArrive getNearbyBusStops:self.locationManager.location];
    self.nearbyBusStopsLabel.text = [NSString stringWithFormat:@"%lu nearby", (unsigned long)[_nearbyBusStops count]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
}

- (UIStatusBarStyle)preferredStatusBarStyle { //TODO: fix later on
    return UIStatusBarStyleDefault;
}

-(void)refreshTable {
    //  TODO
    //this method should run on viewDidLoad

    //get ahold of tableview in view controller
    //get user current location
    //updates the bus arrival information

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
    [self removeAllPinsButUserLocation];
    [_busArrive addBusStopAnnotationsToMap:self.mapView fromUserLocation:self.mapView.userLocation.location];
    self.nearbyBusStopsLabel.text = [NSString stringWithFormat:@"%lu nearby", (unsigned long)[_nearbyBusStops count]];
    [self centerUserLocation:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *busStopCellIdentifer = @"BusStopCell";
    busStopCellView *cell = (busStopCellView *)[tableView dequeueReusableCellWithIdentifier:busStopCellIdentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BusStopCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    _busArrive = [_nearbyBusStops objectAtIndex:indexPath.row];
    cell.stopNameLabel.text = _busArrive.busStopName;
    cell.stopIDLabel.text = _busArrive.busStopID;
    
    NSString *busServices;
    NSArray *b = [[NSArray alloc] init];
    
    //make bus services appear
    b = [_busArrive getBusStopServiceNumbersFromBusStopID:_busArrive.busStopID];
    for (int i = 0; i < [b count]; i++) {
        if (i == ([b count] - 1)) {
            busServices = [busServices stringByAppendingString:[NSString stringWithFormat:@"%@", [b objectAtIndex:i]]];
        } else {
            busServices = [busServices stringByAppendingString:[NSString stringWithFormat:@"%@, ", [b objectAtIndex:i]]];
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_nearbyBusStops count];
}

//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
//    <#code#>q2
//}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
//- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
//    <#code#>
//}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

@end
