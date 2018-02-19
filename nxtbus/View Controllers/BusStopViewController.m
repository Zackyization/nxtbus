//
//  BusStopViewController.m
//  nxtbus
//
//  Created by Zildjian Garcia on 10/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "BusStopViewController.h"
#import "ZJBusArrival.h"

#import "busStopServiceCellView.h"

@interface BusStopViewController ()

@property (nonatomic) ZJBusArrival *busArrival;
@property (nonatomic) NSArray *busServices;
@property NSDictionary *busData;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BusStopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.busArrival = [[ZJBusArrival alloc] init];
    self.busServices = [[NSArray alloc] init];
    self.busStopIDLabel.text = self.busStopID;
    
    self.busData = [self.busArrival getBusStopServicesFromBusStopID:self.busStopID];
    self.busServices = [self.busArrival getLiveBusStopServiceNumbersFromBusStopID:self.busStopID fromData:self.busData useAPI:NO];
    
    //when no data is received from api
    if (!_busServices || _busServices.count == 0) {
        self.busServices = [self.busArrival getBusStopServiceNumbersFromBusStopID:self.busStopID];
    }
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(refreshButton:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.refreshControl = refresh;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)refreshButton:(id)sender {
    self.busData = [self.busArrival getBusStopServicesFromBusStopID:self.busStopID];
    self.busServices = [self.busArrival getLiveBusStopServiceNumbersFromBusStopID:self.busStopID fromData:self.busData useAPI:NO];

    //when no data is received from api
    if (!_busServices || _busServices.count == 0) {
        self.busServices = [self.busArrival getBusStopServiceNumbersFromBusStopID:self.busStopID];
    }
    
    [self.tableView reloadData];
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
        [self.tableView.refreshControl endRefreshing];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *busCellIdentifer = @"BusStopServiceCell";
    busStopServiceCellView *cell = (busStopServiceCellView *)[tableView dequeueReusableCellWithIdentifier:busCellIdentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"busStopServiceCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.busServiceLabel.text = [self.busServices objectAtIndex:indexPath.row];
    cell.busArrive = [[ZJBusArrival alloc] init];
    cell.busArrive.busNumber = cell.busServiceLabel.text;
    cell.busArrive.busStopID = self.busStopID;
    
    for (int i = (int)indexPath.row; i < [self.busServices count]; i++) {
        //loops up the array to look for duplicate
        //if no duplicate is found the direction value is 1 for the current cell
        //route is determined this way
        if ([cell.busServiceLabel.text isEqualToString:(NSString *)[self.busServices objectAtIndex:i]]) {
            for (int j = (int)[self.busServices count] - 1; j > (int)indexPath.row - 1; j--) {
                if ([(NSString *)[self.busServices objectAtIndex:i]
                     isEqualToString:(NSString *)[self.busServices objectAtIndex:j]]) {
                    if (i == j) {
                        cell.busArrive.direction = 1;
                    } else {
                        cell.busArrive.direction = 2;
                    }
                }
            }
        }
        
    }
    
    //Bus arrival methods have to use this class' NSDictionary busData to reduce lag
    //Get timing for next
    NSString *nextTimeRemaining;
    float timeRemaining = [self.busArrival getBusTimeRemainingFor:cell.busArrive.busNumber
                                                      busPosition:@"next"
                                                    fromBusStopID:cell.busArrive.busStopID
                                                         fromData:self.busData
                                                           useAPI:NO
                                                        direction:cell.busArrive.direction];

    if (floorf(timeRemaining) <= -2) {
        nextTimeRemaining = @"-";
        cell.nextTimeRemainingLabel.textColor = [UIColor lightGrayColor];
        cell.nextTimeRemainingLabel.font = [UIFont systemFontOfSize:30];
        cell.nextMinsLabel.hidden = YES;
    } else if (floorf(timeRemaining) == 1) {
        cell.nextMinsLabel.text = @"min";
        cell.nextMinsLabel.hidden = NO;
        nextTimeRemaining = [NSString stringWithFormat:@"%.0f", floorf(timeRemaining)];
    } else if (floorf(timeRemaining) <= 0) {
        nextTimeRemaining = @"Arr";
        cell.nextMinsLabel.hidden = YES;
    } else {
        nextTimeRemaining = [NSString stringWithFormat:@"%.0f", floorf(timeRemaining)];
        [cell.nextTimeRemainingLabel setFont:[UIFont fontWithName:@"RobotoCondensed-Bold" size:37]];
        [cell.nextTimeRemainingLabel setTextColor:[UIColor blackColor]];
        cell.nextMinsLabel.hidden = NO;
    }

    cell.nextTimeRemainingLabel.text = nextTimeRemaining;
    
        //Get timing for subsequent
        NSString *subsequentTimeRemaining;
        timeRemaining = [self.busArrival getBusTimeRemainingFor:cell.busArrive.busNumber
                                                busPosition:@"subsequent"
                                              fromBusStopID:cell.busArrive.busStopID
                                                   fromData:self.busData
                                                     useAPI:NO
                                                  direction:cell.busArrive.direction];
    
        if (floorf(timeRemaining) <= -2) {
            cell.subsequentMinsLabel.hidden = YES;
            cell.subsequentTimeRemainingLabel.hidden = YES;
        } else if (floorf(timeRemaining) == 1) {
            cell.subsequentMinsLabel.text = @"min";
            subsequentTimeRemaining = [NSString stringWithFormat:@"%.0f", floorf(timeRemaining)];
        } else if (floorf(timeRemaining) <= 0) {
            subsequentTimeRemaining = @"Arr";
            cell.subsequentMinsLabel.hidden = YES;
        } else {
            subsequentTimeRemaining = [NSString stringWithFormat:@"%.0f", floorf(timeRemaining)];
        }
    

//    Get timing for next3
    NSString *next3TimeRemaining;
    timeRemaining = [self.busArrival getBusTimeRemainingFor:cell.busArrive.busNumber
                                                busPosition:@"next3"
                                              fromBusStopID:cell.busArrive.busStopID
                                                   fromData:self.busData
                                                     useAPI:NO
                                                  direction:cell.busArrive.direction];

    if (floorf(timeRemaining) <= -2) {
        cell.next3MinsLabel.hidden = YES;
        cell.next3TimeRemainingLabel.hidden = YES;
    } else if (floorf(timeRemaining) == 1) {
        cell.next3MinsLabel.text = @"min";
        next3TimeRemaining = [NSString stringWithFormat:@"%.0f", floorf(timeRemaining)];
    } else if (floorf(timeRemaining) <= 0) {
        next3TimeRemaining = @"Arr";
        cell.next3MinsLabel.hidden = YES;
    } else {
        next3TimeRemaining = [NSString stringWithFormat:@"%.0f", floorf(timeRemaining)];
    }

    cell.next3TimeRemainingLabel.text = next3TimeRemaining;

    //Get bus load
    NSString *busLoad = [self.busArrival getBusLoadFor:cell.busArrive.busNumber
                                           busPosition:@"next"
                                         fromBusStopID:cell.busArrive.busStopID
                                              fromData:self.busData
                                                useAPI:NO
                                             direction:cell.busArrive.direction];
    if (busLoad) {
        cell.busLoadIndicatorImage.hidden = NO;
        
        if ([busLoad isEqualToString:@"SEA"]) {
            cell.busLoadIndicatorImage.image = [UIImage imageNamed:@"seatsAvailable"];
        } else if ([busLoad isEqualToString:@"SDA"]) {
            cell.busLoadIndicatorImage.image = [UIImage imageNamed:@"standingAvailable"];
        } else if ([busLoad isEqualToString:@"LSD"]) {
            cell.busLoadIndicatorImage.image = [UIImage imageNamed:@"limitedStanding"];
        }
    }
    
    //Get bus accessibility
    BOOL wheelchairAccessible = [self.busArrival getBusAccessibilityFor:cell.busArrive.busNumber
                                                            busPosition:@"next" fromBusStopID:cell.busArrive.busStopID
                                                               fromData:self.busData
                                                                 useAPI:NO
                                                              direction:cell.busArrive.direction];
    if (wheelchairAccessible == YES) {
        cell.busAccessibilityIndicatorImage.hidden = NO;
    }
    
    
    //Get bus type
    NSString *busType = [self.busArrival getBusType:cell.busArrive.busNumber
                                        busPosition:@"next"
                                      fromBusStopID:cell.busArrive.busStopID
                                           fromData:self.busData
                                             useAPI:NO
                                          direction:cell.busArrive.direction];
    if (busType) {
        cell.busTypeIndicatorImage.hidden = NO;
        
        if ([busType isEqualToString:@"SD"]) {
            cell.busTypeIndicatorImage.image = [UIImage imageNamed:@"singleDeckBus"];
        } else if ([busType isEqualToString:@"DD"]) {
            cell.busTypeIndicatorImage.image = [UIImage imageNamed:@"doubleDeckerBus"];
        }
    }
    
    //Get route name
    NSString *routeName;
    @try {
        routeName = [self.busArrival getRoute:cell.busArrive.busNumber fromBusStopID:cell.busArrive.busStopID direction:cell.busArrive.direction];
    } @catch (NSException *exception) {
        routeName = nil;
        cell.busRouteNameLabel.text = @"-";
    } @finally {
        cell.busRouteNameLabel.text = routeName;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.busServices count];
}

@end
