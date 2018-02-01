//
//  ZJBusArrival.h
//  arriveLahTest
//
//  Created by Zildjian Garcia on 16/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ZJBusArrival : NSObject

@property NSString *busNumber;
@property NSString *busStopID;
@property CLLocation *busLocation;

@property NSMutableDictionary *busStopServices;
@property NSArray *busStopServiceNumbers;

@property NSString *busType; //SD for single deck, DD for double deck
@property BOOL busHandicap;
@property float timeRemaining; //RECONSIDER
@property int busDensity;


-(NSMutableDictionary *)getBusStopServicesFromBusStopID:(NSString *)busStopID;
-(BOOL)isBusHandicap;

-(int)getNextTimeRemainingFor:(NSString *)busNumber atBusStop:(NSString *)busStopID;

-(NSArray *)getBusStopServiceNumbersFromBusStopID:(NSString *)busStopID;
-(NSDictionary *)getBusNumberDictionary:(NSString *)busNumber fromBusStopID:(NSString *)busStopID;

@end
