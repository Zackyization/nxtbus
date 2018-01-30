# nxtbus
Simulator device: iPhone 7.
Test device: Sean's iPhone 6S




I will update the content below soon. -ZJ
Below is the content from the document file we created:
# Properties

- busNumber (NSString)			bus number (eg. 123, 123M, 195, etc.)
- busStopID (NSString)				bus stop id (eg. 62139)
- busStopLocation (CLLocation)		bus stop on map
- timeRemaining (int)				time remaining for bus to arrive
- busLocation (CLLocation)			where the bus currently is
- doubleDeck (BOOL)				to check if the bus is double decker
- highCapacity (BOOL)				to check if the bus is a high capacity busHandicap (BOOL) 			show wheelchair image
- busAlarm 					to get off
- busDensity (int)				0 - not crowded, 1 - moderate, 2 - crowded
- busStopServices (NSMutableArray *)	holds the services 


# Methods
- (NSString *)getBusNumber			returns a string value of busNumber
- (NSString *)getBusStopID			returns a string value of busStopID
- (CLLocation *)getbusStopLocation		returns a CLLocation value of busStopLocation
- (int)getTimeRemaining			returns int value of timeRemaining
- (BOOL)isHandicap				returns bool value of handicap



- initWithBusStopNumber:(NSString *)stopID     Initializes and sets the busStopID variable to stopID.
- initWithBusStopNumber:(NSString *)stopNumber and busNumber:(NSString *)


# Links

- https://dev.twitter.com/twitterkit/ios/show-tweets				errthing twitter related
- https://arrivelah.herokuapp.com/?id=10371					test bed for api
- https://github.com/cheeaun/busrouter-sg/blob/master/README.md	data found in the repo
- https://www.youtube.com/watch?v=K57dKTagKzg 				50 min video 
- https://www.ioscreator.com/tutorials/draw-route-mapkit-tutorial .   MapKit Routing

