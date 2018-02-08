//
//  ZJBusArrival.h
//  arriveLahTest
//
//  Created by Zildjian Garcia on 16/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "FMDatabase.h"

@interface ZJBusArrival : NSObject

@property NSString *busNumber;
@property CLLocation *busLocation;

@property NSString *busStopID;
@property CLLocation *busStopLocation;
@property NSString *busStopName;
@property int busStopDistanceFromUser;
//@property NSMutableDictionary *busStopServices; //RECONSIDER
//@property NSArray *busStopServiceNumbers; //RECONSIDER

@property NSString *busType; //SD for single deck, DD for double deck
//@property BOOL busHandicap; //RECONSIDER
//@property float timeRemaining; //RECONSIDER
@property int busDensity;

//methods returning arrays should only have ZJBusArrival objects in them
-(NSMutableArray *)getNearbyBusStops:(CLLocation *)userLocation;
-(CLLocationCoordinate2D)getBusStopLocationOfBusStopID:(NSString *)busStopID;
-(int)getDistanceFromUserToBusStop:(NSString *)busStopID userLocation:(CLLocation *)location;


-(void)addBusStopAnnotationsToMap:(MKMapView *)map fromUserLocation:(CLLocation *)userLocation;
-(NSMutableDictionary *)getBusStopServicesFromBusStopID:(NSString *)busStopID;
-(BOOL)isBusHandicap;

-(int)getNextTimeRemainingFor:(NSString *)busNumber atBusStop:(NSString *)busStopID;

-(NSArray *)getBusStopServiceNumbersFromBusStopID:(NSString *)busStopID;
-(NSDictionary *)getBusNumberDictionary:(NSString *)busNumber fromBusStopID:(NSString *)busStopID;

@end
