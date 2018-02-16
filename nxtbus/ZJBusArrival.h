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

//TODO: Make additional methods in ZJBusArrive to get the necessary info for the bus cell

@interface ZJBusArrival : NSObject

@property (nonatomic) NSString *busNumber;
@property (nonatomic) CLLocation *busLocation;

@property (nonatomic) NSString *busStopID;
@property CLLocation *busStopLocation;
@property (nonatomic) NSString *busStopName;
@property (nonatomic) int busStopDistanceFromUser;

@property NSString *busType; //SD for single deck, DD for double deck
@property (nonatomic) BOOL busHandicap; //RECONSIDER
@property (nonatomic) float nextTimeRemaining;
@property (nonatomic) NSString *load; //SEA - non crowded, SDA - moderate, LSD - crowded

//methods returning arrays should only have ZJBusArrival objects in them
-(NSMutableArray *)getNearbyBusStops:(CLLocation *)userLocation;
-(CLLocationCoordinate2D)getBusStopLocationOfBusStopID:(NSString *)busStopID;
-(int)getDistanceFromUserToBusStop:(NSString *)busStopID userLocation:(CLLocation *)location;

-(void)addBusStopAnnotationsToMap:(MKMapView *)map fromUserLocation:(CLLocation *)userLocation;
-(NSDictionary *)getBusStopServicesFromBusStopID:(NSString *)busStopID;
-(BOOL)isBusHandicap;

-(NSArray *)getBusStopServiceNumbersFromBusStopID:(NSString *)busStopID;
-(NSArray *)getLiveBusStopServiceNumbersFromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option;
/* Methods that may require online connection */
//useAPI should be set to YES to get a direct feedback from the arrivelah API

//core method
-(NSDictionary *)getBusNumberDictionary:(NSString *)busNumber fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)param;

/* Bus info methods */
//time remaining
//TODO: Restructure below method from float to NSMutableArray
-(float)getBusTimeRemainingFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option;

//location of bus
-(CLLocation *)getBusLocation:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option;

//bus load
-(NSString *)getBusLoadFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option;

//wheelchair accessibility
-(BOOL)getBusAccessibilityFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option;

//busType
-(NSString *)getBusType:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option;

//routeName
-(NSString *)getRoute:(NSString *)busNumber fromBusStopID:(NSString *)busStopID;

/* Subsequent bus info */


/* next2 bus info */

@end
