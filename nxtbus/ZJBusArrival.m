//
//  ZJBusArrival.m
//  arriveLahTest
//
//  Created by Zildjian Garcia on 16/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "ZJBusArrival.h"
#import <UIKit/UIKit.h>

@implementation ZJBusArrival


-(NSMutableDictionary *)getBusStopServicesFromBusStopID:(NSString *)busStopID {
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"https://arrivelah.herokuapp.com/?id=%@", busStopID];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSMutableDictionary *services = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSArray *busNumbers = [[services objectForKey:@"services"] valueForKey:@"no"];
    if (!busNumbers || !busNumbers.count) {
        return NULL;
    }
    
    return services;
}

-(NSMutableArray *)getNearbyBusStops:(CLLocation *)userLocation {
    NSMutableArray *busStops = [[NSMutableArray alloc] init];
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"BusDB.db"];
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    
    [database open];
    NSString *sqlQuery = @"SELECT * FROM bus_stops";
    //Query Result
    FMResultSet *results = [database executeQuery:sqlQuery];
    while ([results next]) {
        NSString *busStopLat = [NSString stringWithFormat:@"%@", [results stringForColumn:@"lat"]];
        NSString *busStopLong = [NSString stringWithFormat:@"%@", [results stringForColumn:@"lng"]];
        NSString *busStopID = [NSString stringWithFormat:@"%@", [results stringForColumn:@"no"]];
        NSString *busStopName = [NSString stringWithFormat:@"%@", [results stringForColumn:@"name"]];
        
        CLLocation *busStopLocation = [[CLLocation alloc] initWithLatitude:[busStopLat doubleValue] longitude:[busStopLong doubleValue]];
        
        if ([userLocation distanceFromLocation:busStopLocation] <= 400) {
            ZJBusArrival *b = [[ZJBusArrival alloc] init];
            [b setBusStopID:busStopID];
            [b setBusStopLocation:busStopLocation];
            [b setBusStopName:busStopName];
            [b setBusStopDistanceFromUser:[userLocation distanceFromLocation:busStopLocation]];
            
            [busStops addObject:b];
        }
    }
    [database close];
    
    return busStops;
}

-(void)addBusStopAnnotationsToMap:(MKMapView *)map fromUserLocation:(CLLocation *)location {
    NSMutableArray *nearbyStopsArray = [[NSMutableArray alloc] init];
    nearbyStopsArray = [self getNearbyBusStops:location];

    for (ZJBusArrival *bus in nearbyStopsArray) {
        MKPointAnnotation *busPoint = [[MKPointAnnotation alloc] init];
        busPoint.coordinate = bus.busStopLocation.coordinate;
        busPoint.title = bus.busStopName;
        busPoint.subtitle = bus.busStopID;
        
        [map addAnnotation:busPoint];
    }
}

-(CLLocationCoordinate2D)getBusStopLocationOfBusStopID:(NSString *)busStopID {
    NSString *busLat;
    NSString *busLong;
    
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"BusDB.db"];

    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    
    [database open];
    NSString *sqlQuery = @"SELECT lat,lng FROM bus_stops WHERE no IN (?)";
    NSArray *values = [[NSArray alloc] initWithObjects:busStopID, nil];
    NSError *error;
    //Query Result
    FMResultSet *results = [database executeQuery:sqlQuery values:values error:&error];
    
    if ([results next]) {
        busLat = [NSString stringWithFormat:@"%@", [results stringForColumn:@"lat"]];
        busLong = [NSString stringWithFormat:@"%@", [results stringForColumn:@"lng"]];
    }
    [database close];
    
    CLLocationCoordinate2D busStopLocation = CLLocationCoordinate2DMake([busLat doubleValue], [busLong doubleValue]);
    
    return busStopLocation;
}

-(int)getDistanceFromUserToBusStop:(NSString *)busStopID userLocation:(CLLocation *)location {
    CLLocationCoordinate2D stopCoordinate = [self getBusStopLocationOfBusStopID:busStopID];
    CLLocation *busStopLocation = [[CLLocation alloc] initWithLatitude:stopCoordinate.latitude longitude:stopCoordinate.longitude];
    
    int distance = [busStopLocation distanceFromLocation:location];
    
    return distance;
}


-(NSArray *)getBusStopServiceNumbersFromBusStopID:(NSString *)busStopID {
    
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bus_stop_services" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];

    NSDictionary *busStopIDsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSArray *services = [busStopIDsDictionary objectForKey:busStopID];
    
    return services;
}

-(int)getNextTimeRemainingFor:(NSString *)busNumber atBusStop:(NSString *)busStopID {
    NSDictionary *busServiceDictionary = [self getBusNumberDictionary:busNumber fromBusStopID:busStopID];

    if (!busServiceDictionary || !busServiceDictionary.count) {
        return -1;
    }
    NSString *nextTimeRemaining = [[busServiceDictionary objectForKey:@"next"] objectForKey:@"duration_ms"];
    CGFloat nextTimeRemainingFloat = [nextTimeRemaining floatValue];
    nextTimeRemainingFloat /= 60000;
    return (int)roundf(nextTimeRemainingFloat);
}

-(NSDictionary *)getBusNumberDictionary:(NSString *)busNumber fromBusStopID:(NSString *)busStopID {
    
    /*TODO: UNCOMMENT LINE BELOW WHEN DONE WTIH TESTING */
    //    NSMutableDictionary *busServicesDictionary = [self getBusStopServicesFromBusStopID:busStopID];
    
    /* PLACEHOLDER CODE START */
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"arriveLahJSON" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *busServiecsDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    /* PLACEHOLDER CODE END */
    
    NSDictionary *desiredDictionary;
    //loop through the array of dictionaries
    //access each dictionary check if the bus number returned is the desired number from the parameter in the method declaration above.
    for (int i = 0; i < [[busServiecsDictionary objectForKey:@"services"] count]; i++) {
        if ([[[[busServiecsDictionary objectForKey:@"services"] objectAtIndex:i] objectForKey:@"no"] isEqualToString:busNumber]) {
            desiredDictionary = [[busServiecsDictionary objectForKey:@"services"] objectAtIndex:i];
            break;
        }
    }
    
    if (!desiredDictionary || !desiredDictionary.count) {
        return NULL;
    }
    
    return desiredDictionary;
}



-(NSString *)getBusNumber:(NSString *)bus fromArray:(NSArray *)array {
    for (int i = 0; i < [array count]; i++) {
        if ([bus isEqualToString:[array objectAtIndex:i]]) {
            return [array objectAtIndex:i];
        }
    }
    return NULL;
}

@end
