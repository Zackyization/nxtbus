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

@end

@implementation RouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@ Route", self.busService];
    
    self.routeStops = [self.busArrive getBusRouteStopsOf:self.busService direction:self.busArrive.direction];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)centerCurrentBusStop:(id)sender {
    //TODO
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
    //LEFT OFF HERE, continue working on the bus route cells
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.routeStops count];
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
