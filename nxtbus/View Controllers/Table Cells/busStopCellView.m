//
//  busStopCellView.m
//  nxtbus
//
//  Created by Zildjian Garcia on 7/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "busStopCellView.h"
#import "FMDB.h"

@implementation busStopCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)toggleFavorites:(id)sender {
    if (self.favorite == NO) {
        //favorite
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"BusDB.db"];
        
        FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
        
        [database open];
        NSString *sqlQuery = @"INSERT INTO favorite_bus_info (busStopID) VALUES (?)";
        NSArray *values = [[NSArray alloc] initWithObjects:self.stopIDLabel.text, nil];
        NSError *error;
        
        if (![database executeUpdate:sqlQuery values:values error:&error]) {
            NSLog(@"Insert into favorites failed!");
        }
        
        [database close];
        
        
        [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteOn"] forState:UIControlStateNormal];
        self.favorite = YES;
    } else {
        //unfavorite
        
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:@"BusDB.db"];
        
        FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
        
        [database open];
        NSString *sqlQuery = @"DELETE FROM favorite_bus_info WHERE busStopID = ?";
        NSArray *values = [[NSArray alloc] initWithObjects:self.stopIDLabel.text, nil];
        NSError *error;
        
        if (![database executeUpdate:sqlQuery values:values error:&error]) {
            NSLog(@"Delete from favorites failed!");
        }
        
        [database close];
        
        [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteOff"] forState:UIControlStateNormal];
        self.favorite = NO;
    }
}

@end
