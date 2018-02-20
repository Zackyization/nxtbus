//
//  RouteViewController.m
//  nxtbus
//
//  Created by Zildjian Garcia on 20/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "RouteViewController.h"
#import "ZJBusArrival.h"

@interface RouteViewController ()

@property (nonatomic) NSArray *routeStops;

@end

@implementation RouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.topItem.title = [NSString stringWithFormat:@"%@ Route", self.busService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)centerCurrentBusStop:(id)sender {
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    static NSString *busStopCellIdentifer = @"BusStopCell";
    //    busStopCellView *cell = (busStopCellView *)[tableView dequeueReusableCellWithIdentifier:busStopCellIdentifer];
    //    if (cell == nil) {
    //        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"busStopCell" owner:self options:nil];
    //        cell = [nib objectAtIndex:0];
    //    }
    
    
    
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
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
