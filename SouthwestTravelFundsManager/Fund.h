//
//  Fund.h
//  SouthwestTravelFundsManager
//
//  Created by Colin Regan on 8/19/12.
//  Copyright (c) 2012 Red Cup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Flight;

@interface Fund : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * balance;
@property (nonatomic, retain) NSNumber * unusedTicket;
@property (nonatomic, retain) NSDate * expirationDate;
@property (nonatomic, retain) NSSet *flightsAppliedTo;
@property (nonatomic, retain) Flight *originalFlight;
@end

@interface Fund (CoreDataGeneratedAccessors)

- (void)addFlightsAppliedToObject:(Flight *)value;
- (void)removeFlightsAppliedToObject:(Flight *)value;
- (void)addFlightsAppliedTo:(NSSet *)values;
- (void)removeFlightsAppliedTo:(NSSet *)values;

@end