//
//  busRouteCell.h
//  nxtbus
//
//  Created by Zildjian Garcia on 20/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface busRouteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *busStopImageState;
@property (weak, nonatomic) IBOutlet UIView *topRouteLine;
@property (weak, nonatomic) IBOutlet UIView *bottomRouteLine;

@property (weak, nonatomic) IBOutlet UILabel *busStopIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *busStopServiceNameLabel;

//Train IDs
@property (weak, nonatomic) IBOutlet UILabel *firstTrainIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondTrainLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdTrainLabel;


@end
