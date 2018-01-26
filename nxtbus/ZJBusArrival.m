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


-(NSString *)getBusNumber {
    return self.busNumber;
}

-(NSString *)getBusStopID {
    return self.busStopID;
}

-(CLLocation *)getBusLocation {
    return self.busLocation;
}


-(NSArray *)getBusStopServiceNumbers {
    return self.busStopServiceNumbers;
}


-(float)getTimeRemaining {
    return self.timeRemaining;
}

-(int)getBusDensity {
    return self.busDensity;
}

-(BOOL)isBusHandicap {
    return self;
}

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

-(NSArray *)getBusStopServiceNumbersFromBusStopID:(NSString *)busStopID {
    NSError *error;
    NSString *url_string = [NSString stringWithFormat: @"https://arrivelah.herokuapp.com/?id=%@", busStopID];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSMutableDictionary *busStopServices = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *services = [[busStopServices objectForKey:@"services"] valueForKey:@"no"];
    
    //check if bus services are active
    if (!services || !services.count) {
        return NULL;
    }
    
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
