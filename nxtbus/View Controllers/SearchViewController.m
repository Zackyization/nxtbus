//
//  SearchViewController.m
//  nxtbus
//
//  Created by Zildjian Garcia on 18/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "SearchViewController.h"
#import "busStopCellView.h"
#import "busStopServiceSearch.h"

#import "FMDatabase.h"
#import "ZJBusArrival.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *tableResults;
@property (nonatomic) BOOL clearTable;
@property (nonatomic) ZJBusArrival *busArrive;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableResults = [[NSMutableArray alloc] init];
    self.busArrive = [[ZJBusArrival alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)segmentControlAction:(id)sender {
    [self.tableResults removeAllObjects];
    
    self.clearTable = YES;
    [self.tableView reloadData];
    self.clearTable = NO;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        [self segmentControlAction:nil];
    } else {
        [self.tableResults removeAllObjects];
        
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"BusDB.db"];
        
        FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            //Search for bus stops
            [database open];
            NSString *sqlQuery = @"SELECT no FROM bus_stops WHERE no LIKE ? OR name LIKE ?";
            NSString *searchQuery = [NSString stringWithFormat:@"%%%@%%", searchText];
            NSArray *values = [[NSArray alloc] initWithObjects:searchQuery, searchQuery, nil];
            NSError *error;
            //Query Result
            FMResultSet *results = [database executeQuery:sqlQuery values:values error:&error];
            
            NSString *stopResult;
            while ([results next]) {
                stopResult = [NSString stringWithFormat:@"%@", [results stringForColumn:@"no"]];
                [self.tableResults addObject:stopResult];
            }
            
            [database close];
            
            [self.tableView reloadData];
        } else {
            //Search for bus services
            
        }
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *cellValue = [[NSMutableArray alloc] init];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        //Searching for bus stops
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
        [cellValue addObject:cell];
    } else {
        static NSString *busStopCellIdentifer = @"BusStopServiceSearchCell";
        busStopCellView *cell = (busStopCellView *)[tableView dequeueReusableCellWithIdentifier:busStopCellIdentifer];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"busStopServiceSearch" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
    }
    
    
    return [cellValue objectAtIndex:0];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.clearTable) {
        return 0;
    } else {
        return [self.tableResults count];
    }
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
