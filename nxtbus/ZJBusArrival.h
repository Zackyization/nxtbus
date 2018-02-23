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

@property (nonatomic) NSString *busNumber;
@property (nonatomic) CLLocation *busLocation;
@property (nonatomic) int direction;

@property (nonatomic) NSString *busStopID;
@property CLLocation *busStopLocation;
@property (nonatomic) NSString *busStopName;
@property (nonatomic) int busStopDistanceFromUser;

@property NSString *busType; //SD for single deck, DD for double deck
@property (nonatomic) float nextTimeRemaining;
@property (nonatomic) NSString *load; //SEA - non crowded, SDA - moderate, LSD - crowded

//methods returning arrays should only have ZJBusArrival objects in them
-(NSMutableArray *)getNearbyBusStops:(CLLocation *)userLocation;
-(CLLocationCoordinate2D)getBusStopLocationOfBusStopID:(NSString *)busStopID;
-(int)getDistanceFromUserToBusStop:(NSString *)busStopID userLocation:(CLLocation *)location;

-(void)addBusStopAnnotationsToMap:(MKMapView *)map fromUserLocation:(CLLocation *)userLocation;
-(NSDictionary *)getBusStopServicesFromBusStopID:(NSString *)busStopID;

-(NSArray *)getBusStopServiceNumbersFromBusStopID:(NSString *)busStopID;
-(NSArray *)getLiveBusStopServiceNumbersFromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option;


/* Bus Stop Route Info Methods */
-(NSArray *)getBusRouteStopsOf:(NSString *)busNumber direction:(int)directionVal;

//Bus stop name
-(NSString *)getBusStopName:(NSString *)busStopID;

//Nearby train stations
-(NSArray *)getTrainStationsNearbyBusStop:(NSString *)busStopID;


/* Bus info methods */
//useAPI should be set to YES to get a direct feedback from the arrivelah API
//core method
-(NSDictionary *)getBusNumberDictionary:(NSString *)busNumber fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam  useAPI:(BOOL)param direction:(int)directionVal;

//time remaining
-(float)getBusTimeRemainingFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal;

//location of bus
-(CLLocation *)getBusLocation:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal;

//bus load
-(NSString *)getBusLoadFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal;

//wheelchair accessibility
-(BOOL)getBusAccessibilityFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal;

//busType
-(NSString *)getBusType:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal;

//routeName
-(NSString *)getRoute:(NSString *)busNumber fromBusStopID:(NSString *)busStopID direction:(int)directionVal;

//favorite
-(BOOL)checkIfFavorite:(NSString *)busStopID;

@end
