//
//  Fund+Create.m
//  SouthwestTravelFundsManager
//
//  Created by Colin Regan on 8/19/12.
//  Copyright (c) 2012 Red Cup. All rights reserved.
//

#import "Fund+Create.h"
#import "Flight+Create.h"

@interface Fund (Private)

+ (Fund *)fund:(NSDictionary *)fundInfo inDatabase:(NSManagedObjectContext *)context;
+ (Fund *)createNewFund:(NSDictionary *)fundInfo inDatabase:(NSManagedObjectContext *)context;

@end

@implementation Fund (Create)

+ (Fund *)fundWithDictionary:(NSDictionary *)fundInfo inManagedObjectContext:(NSManagedObjectContext *)context {
    Fund *fund = [self fund:fundInfo inDatabase:context];
    if (!fund) fund = [self createNewFund:fundInfo inDatabase:context];
    return fund;
}

+ (Fund *)fund:(NSDictionary *)fundInfo inDatabase:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Fund"];
    request.predicate = [NSPredicate predicateWithFormat:@"originalFlight.ticketNumber = %@", [fundInfo valueForKeyPath:@"originalFlight.ticketNumber"]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:TRUE]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || matches.count > 1) {
        // handle error
        return nil;
    }
    return [matches lastObject];
}

+ (Fund *)createNewFund:(NSDictionary *)fundInfo inDatabase:(NSManagedObjectContext *)context {
    Fund *newFund = [NSEntityDescription insertNewObjectForEntityForName:@"Fund" inManagedObjectContext:context];
    
    // populate fund attributes
    
    newFund.originalFlight = [Flight flightWithDictionary:[fundInfo objectForKey:@"originalFlight"] inManagedObjectContext:context];
    
    return newFund;
}
@end