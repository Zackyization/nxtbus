//
//  busStopCellView.h
//  nxtbus
//
//  Created by Zildjian Garcia on 7/2/18.//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface busStopCellView : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopServicesLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceAwayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *distanceAwayImage;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


@property (nonatomic) BOOL favorite;

@end
