//
//  RouteViewController.m
//  nxtbus
//
//  Created by Zildjian Garcia on 20/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "RouteViewController.h"
#import "busRouteCell.h"

@interface RouteViewController ()

@property (nonatomic) NSArray *routeStops;
@property (nonatomic) int passedCount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *centerCurrentLocationButton;

@end

@implementation RouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@ Route", self.busService];
    
    self.routeStops = [self.busArrive getBusRouteStopsOf:self.busService direction:self.busArrive.direction];
    if ([self.routeStops count] == 0) {
        self.busArrive = [[ZJBusArrival alloc] init];
        self.routeStops = [self.busArrive getBusRouteStopsOf:self.busService direction:1];
        self.centerCurrentLocationButton.hidden = YES;
    }
    
    for (int i = 0; i < [self.routeStops count]; i++) {
        if ([self.currentBusStopID isEqualToString:[self.routeStops objectAtIndex:i]]) {
            self.passedCount = i;
            break;
        }
    }
    
    //Add stop annotations to mapview
    for (NSString *stop in self.routeStops) {
        CLLocationCoordinate2D stopCoordinate = [self.busArrive getBusStopLocationOfBusStopID:stop];
        
        MKPointAnnotation *busStopPoint = [[MKPointAnnotation alloc] init];
        busStopPoint.coordinate = stopCoordinate;
        busStopPoint.title = [self.busArrive getBusStopName:stop];
        busStopPoint.subtitle = stop;
        
        [self.mapView addAnnotation:busStopPoint];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)viewDidAppear:(BOOL)animated {
    for (int i = 0; i < [self.routeStops count]; i++) {
        if ([self.currentBusStopID isEqualToString:[self.routeStops objectAtIndex:i]]) {
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        }
    }
    
    if (self.currentBusStopID) {
        [self centerOnCurrentBusStop:nil];
    } else {
        [self centerOnBusStop:[self.routeStops objectAtIndex:0]];
    }
}

-(void)reloadData {
    [self.tableView reloadData];
}

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)centerOnCurrentBusStop:(id)sender {
    MKCoordinateRegion mapRegion;
    mapRegion.center = [self.busArrive getBusStopLocationOfBusStopID:self.currentBusStopID];
    mapRegion.span.latitudeDelta = 0.003;
    mapRegion.span.longitudeDelta = 0.003;
    
    [self.mapView setRegion:mapRegion animated:YES];
}

-(void)centerOnBusStop:(NSString *)busStopID {
    MKCoordinateRegion mapRegion;
    mapRegion.center = [self.busArrive getBusStopLocationOfBusStopID:busStopID];
    mapRegion.span.latitudeDelta = 0.003;
    mapRegion.span.longitudeDelta = 0.003;
    
    [self.mapView setRegion:mapRegion animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        static NSString *busRouteCellIdentifer = @"BusRouteCell";
        busRouteCell *cell = (busRouteCell *)[tableView dequeueReusableCellWithIdentifier:busRouteCellIdentifer];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"busRouteCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    
    cell.busStopIDLabel.text = [self.routeStops objectAtIndex:indexPath.row];
    cell.busStopServiceNameLabel.text = [self.busArrive getBusStopName:cell.busStopIDLabel.text];

    //Determinining route line appearence for first and alst stop
    if (indexPath.row == 0) {
        cell.topRouteLine.hidden = YES;
    } else if (indexPath.row == [self.routeStops count] - 1) {
        cell.bottomRouteLine.hidden = YES;
    } else {
        cell.topRouteLine.hidden = NO;
        cell.bottomRouteLine.hidden = NO;
    }
    
    //Determine current stop
    if ([self.currentBusStopID isEqualToString:[self.routeStops objectAtIndex:indexPath.row]]) {
        [cell.busStopImageState setImage:[UIImage imageNamed:@"busStop_current"]];
    } else {
        [cell.busStopImageState setImage:[UIImage imageNamed:@"busStop_normal"]];
    }
    
    //Determine passed stops
    if (indexPath.row < self.passedCount) {
        [cell.busStopImageState setImage:[UIImage imageNamed:@"busStop_passed"]];
        [cell.topRouteLine setAlpha:0.3];
        [cell.bottomRouteLine setAlpha:0.3];
    } else if (indexPath.row == self.passedCount) {
        [cell.topRouteLine setAlpha:0.3];
        [cell.bottomRouteLine setAlpha:1.0];
    }
    else {
        [cell.topRouteLine setAlpha:1.0];
        [cell.bottomRouteLine setAlpha:1.0];
    }
    
    
    //Determine nearby trains stations
    NSArray *trainStations = [self.busArrive getTrainStationsNearbyBusStop:cell.busStopIDLabel.text];
    if ([trainStations count] > 0) {
        for (int i = 0; i < [trainStations count]; i++) {
            switch (i) {
                case 0:
                    cell.firstTrainIDLabel.hidden = NO;
                    cell.firstTrainIDLabel.text = [trainStations objectAtIndex:0];
                    cell.firstTrainIDLabel.backgroundColor = [self determineStationColour:cell.firstTrainIDLabel.text];
                    break;
                    
                case 1:
                    cell.secondTrainLabel.hidden = NO;
                    cell.secondTrainLabel.text = [trainStations objectAtIndex:1];
                    cell.secondTrainLabel.backgroundColor = [self determineStationColour:cell.secondTrainLabel.text];
                    break;
                    
                case 2:
                    cell.thirdTrainLabel.hidden = NO;
                    cell.thirdTrainLabel.text = [trainStations objectAtIndex:2];
                    cell.thirdTrainLabel.backgroundColor = [self determineStationColour:cell.thirdTrainLabel.text];
                    break;
            }
            
        }
    } else {
        cell.firstTrainIDLabel.hidden = YES;
        cell.secondTrainLabel.hidden = YES;
        cell.thirdTrainLabel.hidden = YES;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.routeStops count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    busRouteCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self centerOnBusStop:cell.busStopIDLabel.text];
}

-(UIColor *)determineStationColour:(NSString *)stationCode {
    UIColor *green = [UIColor colorWithRed:17.0f/255.0f green:134.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
    UIColor *red = [UIColor colorWithRed:209.0f/255.0f green:12.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
    UIColor *purple = [UIColor colorWithRed:123.0f/255.0f green:0.0f/255.0f blue:163.0f/255.0f alpha:1.0f];
    UIColor *yellow = [UIColor colorWithRed:253.0f/255.0f green:136.0f/255.0f blue:8.0f/255.0f alpha:1.0f];
    UIColor *blue = [UIColor colorWithRed:10.0f/255.0f green:63.0f/255.0f blue:149.0f/255.0f alpha:1.0f];
    UIColor *lrt = [UIColor colorWithRed:97.0f/255.0f green:114.0f/255.0f blue:100.0f/255.0f alpha:1.0f];

    NSString *station = stationCode;
    station = [station substringToIndex:2];
    if ([station isEqualToString:@"NS"]) {
        return red;
    } else if ([station isEqualToString:@"EW"] || [station isEqualToString:@"CG"]) {
        return green;
    } else if ([station isEqualToString:@"NE"]) {
        return purple;
    } else if ([station isEqualToString:@"CC"] || [station isEqualToString:@"CE"]) {
        return yellow;
    } else if ([station isEqualToString:@"DT"]) {
        return blue;
    } else if ([station isEqualToString:@"BP"] || [station isEqualToString:@"STC"] ||
               [station isEqualToString:@"SE"] || [station isEqualToString:@"SW"] ||
               [station isEqualToString:@"PTC"] || [station isEqualToString:@"PE"] || [station isEqualToString:@"PW"]) {
        return lrt;
    }
    
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
