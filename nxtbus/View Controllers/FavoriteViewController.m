//
//  FavoriteViewController.m
//  nxtbus
//
//  Created by Zildjian Garcia on 23/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "FavoriteViewController.h"
#import "busStopCellView.h"
#import "ZJBusArrival.h"

#import "BusStopViewController.h"

@interface FavoriteViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *tableResults;
@property (nonatomic) ZJBusArrival *busArrive;

@property (nonatomic) NSString *busStopIDVal;
@property (nonatomic) NSString *busStopTitleVal;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableResults = [[NSMutableArray alloc] init];
    self.busArrive = [[ZJBusArrival alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    //Get bus stop IDs from DB
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"BusDB.db"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    
    [database open];
    NSString *sqlQuery = @"SELECT * FROM favorite_bus_info";
    NSError *error;
    //Query Result
    FMResultSet *results = [database executeQuery:sqlQuery values:nil error:&error];
    
    NSString *busStop;
    while ([results next]) {
        busStop = [NSString stringWithFormat:@"%@", [results stringForColumn:@"busStopID"]];
        [self.tableResults addObject:busStop];
    }
    
    [database close];

    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.tableResults removeAllObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *busStopCellIdentifer = @"BusStopCell";
    busStopCellView *cell = (busStopCellView *)[tableView dequeueReusableCellWithIdentifier:busStopCellIdentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"busStopCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.stopIDLabel.text = [self.tableResults objectAtIndex:indexPath.row];
    cell.stopNameLabel.text = [self.busArrive getBusStopName:cell.stopIDLabel.text];
    
    NSMutableString *busServices = [[NSMutableString alloc] init];
    NSArray *b = [[NSArray alloc] init];
    
    //get bus services
    b = [self.busArrive getBusStopServiceNumbersFromBusStopID:cell.stopIDLabel.text];
    for (int i = 0; i < [b count]; i++) {
        if (i == ([b count] - 1)) {
            [busServices appendString:[NSString stringWithFormat:@"%@", [b objectAtIndex:i]]];
        } else {
            [busServices appendString:[NSString stringWithFormat:@"%@, ", [b objectAtIndex:i]]];
        }
    }
    cell.stopServicesLabel.text = busServices;
    
    cell.distanceAwayLabel.hidden = YES;
    cell.distanceAwayImage.hidden = YES;
    
    //favorite
    cell.favorite = [self.busArrive checkIfFavorite:cell.stopIDLabel.text];
    if (cell.favorite) {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favoriteOn"] forState:UIControlStateNormal];
    } else {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favoriteOff"] forState:UIControlStateNormal];
    }
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableResults count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    busStopCellView *cell = (busStopCellView *)[tableView cellForRowAtIndexPath:indexPath];

    self.busStopIDVal = cell.stopIDLabel.text;
    self.busStopTitleVal = cell.stopNameLabel.text;
    [self performSegueWithIdentifier:@"busStopModal" sender:self];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"busStopModal"]) {
        BusStopViewController *vc = [segue destinationViewController];
        vc.busStopTitle = self.busStopTitleVal;
        vc.busStopID = self.busStopIDVal;
        [vc.busStopIDLabel setText:self.busStopIDVal];
    }
}


@end
