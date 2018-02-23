//
//  busStopServiceCellView.h
//  nxtbus
//
//  Created by Zildjian Garcia on 11/2/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJBusArrival.h"

@interface busStopServiceCellView : UITableViewCell

@property (nonatomic) NSString *busServiceNumber;
@property (nonatomic) NSString *busStopID;
//@property (nonatomic) BOOL *favourite;

@property (nonatomic) ZJBusArrival *busArrive;

@property (weak, nonatomic) IBOutlet UILabel *busServiceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *busLoadIndicatorImage;
@property (weak, nonatomic) IBOutlet UIImageView *busTypeIndicatorImage;
@property (weak, nonatomic) IBOutlet UIImageView *busAccessibilityIndicatorImage;
@property (weak, nonatomic) IBOutlet UILabel *busRouteNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *favouriteBusButton;


//Next
@property (weak, nonatomic) IBOutlet UILabel *nextTimeRemainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextMinsLabel;

//subsequent
@property (weak, nonatomic) IBOutlet UILabel *subsequentTimeRemainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *subsequentMinsLabel;

//next3
@property (weak, nonatomic) IBOutlet UILabel *next3TimeRemainingLabel;
@property (weak, nonatomic) IBOutlet UILabel *next3MinsLabel;

@end
