//
//  ZJBusArrival.m
//  arriveLahTest
//
//  Created by Zildjian Garcia on 16/1/18.
//  Copyright © 2018 Zildjian Garcia. All rights reserved.
//

#import "ZJBusArrival.h"

@implementation ZJBusArrival

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
    
    //sort by nearest distance
    NSArray *sortedBuses = [busStops sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [NSString stringWithFormat:@"%i", [(ZJBusArrival *)a busStopDistanceFromUser]];
        NSString *second = [NSString stringWithFormat:@"%i", [(ZJBusArrival *)b busStopDistanceFromUser]];
        return [first compare:second options:NSNumericSearch];
    }];
    
    NSMutableArray *finalArray = [NSMutableArray arrayWithArray:sortedBuses];
    
    return finalArray;
}

-(NSDictionary *)getBusStopServicesFromBusStopID:(NSString *)busStopID {
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"https://arrivelah.herokuapp.com/?id=%@", busStopID];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSDictionary *services = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSArray *busNumbers = [[services objectForKey:@"services"] valueForKey:@"no"];
    if (!busNumbers || !busNumbers.count) {
        return nil;
    }
    
    return services;
}

-(NSArray *)getLiveBusStopServiceNumbersFromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option {
    NSDictionary *busServicesDictionary;
    if (option == YES) {
        busServicesDictionary = [self getBusStopServicesFromBusStopID:busStopID];
    } else {
        busServicesDictionary = dictionaryParam;
    }
    
    if (!busServicesDictionary || [busServicesDictionary count] == 0) {
        return nil;
    }
    
    NSMutableArray *busNumbers = [[NSMutableArray alloc] init];
    for (int i = 0; i < [[busServicesDictionary objectForKey:@"services"] count]; i++) {
        NSString *number = [[[busServicesDictionary objectForKey:@"services"] objectAtIndex:i] objectForKey:@"no"];
        [busNumbers addObject:number];
    }
    
    //Live results may not always include all services that belong to that particular bus stop
    //Missing services will get added with the code below
    NSArray *actualServiceNumbers = [self getBusStopServiceNumbersFromBusStopID:busStopID];
    for (NSString *busNo in actualServiceNumbers) {
        if (![busNumbers containsObject:busNo]) {
            [busNumbers addObject:busNo];
        }
    }
    
    NSArray *result = [NSArray arrayWithArray:busNumbers];
    return result;
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


-(NSDictionary *)getBusNumberDictionary:(NSString *)busNumber fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal {
    
    NSDictionary *busServicesDictionary;
    if (option == YES) {
        busServicesDictionary = [self getBusStopServicesFromBusStopID:busStopID];
    } else {
        busServicesDictionary = dictionaryParam;
    }
    
    //access each dictionary check if the bus number returned is the desired number from the parameter in the method declaration above
    //directionVal helps to differentiate
    NSDictionary *desiredDictionary;
    if (directionVal == 2) {
        for (int i = 0; i < [[busServicesDictionary objectForKey:@"services"] count]; i++) {
            if ([[[[busServicesDictionary objectForKey:@"services"] objectAtIndex:i] objectForKey:@"no"] isEqualToString:busNumber]) {
                desiredDictionary = [[busServicesDictionary objectForKey:@"services"] objectAtIndex:i];
                break;
            }
        }
    } else {
        for (int i = (int)[[busServicesDictionary objectForKey:@"services"] count] - 1; i > -1; i--) {
            if ([[[[busServicesDictionary objectForKey:@"services"] objectAtIndex:i] objectForKey:@"no"] isEqualToString:busNumber]) {
                desiredDictionary = [[busServicesDictionary objectForKey:@"services"] objectAtIndex:i];
                break;
            }
        }
    }
    
    if (!desiredDictionary || !desiredDictionary.count) {
        return nil;
    }
    
    return desiredDictionary;
}

/* Next bus info */
//time remaining
-(float)getBusTimeRemainingFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)value {
    NSDictionary *busService = [self getBusNumberDictionary:busNumber fromBusStopID:busStopID fromData:dictionaryParam useAPI:option direction:value];
    if (!busService || busService.count == 0) {
        return -5;
    }
    
    
    NSNumber *val = [busService valueForKeyPath:[NSString stringWithFormat:@"%@.duration_ms", position]];
    if (val < 0 || [val isKindOfClass:[NSNull class]]) {
        return -5;
    }
    
    float timeRemaining = [val floatValue];
    timeRemaining /= 60000;
    
    return timeRemaining;
}


//location of bus
-(CLLocation *)getBusLocation:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal {
    NSDictionary *busService = [self getBusNumberDictionary:busNumber fromBusStopID:busStopID fromData:dictionaryParam useAPI:option direction:directionVal];
    if (!busService || busService.count == 0) {
        return nil;
    }
    
    NSNumber *latitude = [busService valueForKeyPath:[NSString stringWithFormat:@"%@.lat", position]];
    NSNumber *longtitude = [busService valueForKeyPath:[NSString stringWithFormat:@"%@.lng", position]];
    if (latitude < 0 || longtitude < 0) {
        return nil;
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longtitude floatValue]];
    
    return location;
}

//bus load
-(NSString *)getBusLoadFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal {
    NSDictionary *busService = [self getBusNumberDictionary:busNumber fromBusStopID:busStopID fromData:dictionaryParam useAPI:option direction:directionVal];
    if (!busService || busService.count == 0) {
        return nil;
        
    }
    
    NSString *load = [busService valueForKeyPath:[NSString stringWithFormat:@"%@.load", position]];
    
    if (!load || [load isEqualToString:@""]) {
        return nil;
    }
    
    return load;
}

//wheelchair accessibility
-(BOOL)getBusAccessibilityFor:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal {
    NSDictionary *busService = [self getBusNumberDictionary:busNumber fromBusStopID:busStopID fromData:dictionaryParam useAPI:option direction:directionVal];
    if (!busService || busService.count == 0) {
        return NO;
    }
    
    NSString *result = [busService valueForKeyPath:[NSString stringWithFormat:@"%@.feature", position]];
    
    if ([result isEqualToString:@"WAB"]) {
        return YES;
    }
    
    return NO;
}

-(NSString *)getBusType:(NSString *)busNumber busPosition:(NSString *)position fromBusStopID:(NSString *)busStopID fromData:(NSDictionary *)dictionaryParam useAPI:(BOOL)option direction:(int)directionVal {
    NSDictionary *busService = [self getBusNumberDictionary:busNumber fromBusStopID:busStopID fromData:dictionaryParam useAPI:option direction:directionVal];
    if (!busService || busService.count == 0) {
        return nil;
    }
    
    NSString *busType = [busService valueForKeyPath:[NSString stringWithFormat:@"%@.type", position]];
    if (!busType || [busType isEqualToString:@""]) {
        return nil;
    }
    
    return busType;
}

-(NSString *)getRoute:(NSString *)busNumber fromBusStopID:(NSString *)busStopID  direction:(int)directionVal {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@", busNumber] ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *busRouteDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    
    NSArray *arrayOfStops;
    arrayOfStops = [busRouteDictionary valueForKeyPath:[NSString stringWithFormat:@"%i.stops", directionVal]];
    NSString *lastBusStop = [arrayOfStops lastObject];
    
    //Query for last bus stop name
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsPath = [paths objectAtIndex:0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"BusDB.db"];
    
    
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
    
    NSString *busStopName;
    [database open];
    NSString *sqlQuery = @"SELECT name FROM bus_stops WHERE no IN (?)";
    NSArray *values = [[NSArray alloc] initWithObjects:lastBusStop, nil];
    
    //Query Result
    FMResultSet *results = [database executeQuery:sqlQuery values:values error:&error];
    if ([results next]) {
        busStopName = [NSString stringWithFormat:@"%@", [results stringForColumn:@"name"]];
    }
    
    [database close];
    
    return busStopName;
}

@end
