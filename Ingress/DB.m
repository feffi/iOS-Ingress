//
//  DB.m
//  Ingress
//
//  Created by Alex Studnicka on 24.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "DB.h"

@implementation DB

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Static methods

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Singleton

+ (DB *)sharedInstance {
    static dispatch_once_t onceToken;
    static DB * __sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [self new];
    });
    return __sharedInstance;
}

- (id)init {
    self = [super init];
	if (self) {

    }
    return self;
}

//#pragma mark - Adding
//
//- (void)addEnergyGlobWithGuid:(NSString *)guid {
//	NSArray *fetched = [self fetchObjectsForEntityName:@"EnergyGlob" withPredicate:@"guid = %@", guid];
//	if (fetched.count == 0) {
//		EnergyGlob *energyGlob = [NSEntityDescription insertNewObjectForEntityForName:@"EnergyGlob" inManagedObjectContext:self.managedObjectContext];
//		energyGlob.guid = guid;
//		[self saveContext];
//	}
//}
//
//- (void)addResonatorWithGUID:(NSString *)guid level:(NSInteger)level dropped:(BOOL)dropped {
//	NSArray *fetched = [self fetchObjectsForEntityName:@"Resonator" withPredicate:@"guid = %@", guid];
//	if (fetched.count == 0) {
//		Resonator *resonator = [NSEntityDescription insertNewObjectForEntityForName:@"Resonator" inManagedObjectContext:self.managedObjectContext];
//		resonator.guid = guid;
//		resonator.level = level;
//		[self saveContext];
//	}
//}
//
//- (void)addXMPWithGUID:(NSString *)guid level:(NSInteger)level dropped:(BOOL)dropped {
//	NSArray *fetched = [self fetchObjectsForEntityName:@"XMP" withPredicate:@"guid = %@", guid];
//	if (fetched.count == 0) {
//		XMP *xmp = [NSEntityDescription insertNewObjectForEntityForName:@"XMP" inManagedObjectContext:self.managedObjectContext];
//		xmp.guid = guid;
//		xmp.level = level;
//		[self saveContext];
//	}
//}
//
//- (void)addPortalShieldWithGUID:(NSString *)guid rarity:(PortalShieldRarity)rarity dropped:(BOOL)dropped {
//	int count = [self numberOfObjectsForEntityName:@"Shield" withPredicate:@"guid = %@", guid];
//	if (count == 0) {
//		Shield *shield = [NSEntityDescription insertNewObjectForEntityForName:@"Shield" inManagedObjectContext:self.managedObjectContext];
//		shield.guid = guid;
//		shield.rarity = rarity;
//		[self saveContext];
//	}
//}
//
//- (void)addPortalKeyWithGUID:(NSString *)guid forPortal:(Portal *)portal dropped:(BOOL)dropped {
//	int count = [self numberOfObjectsForEntityName:@"PortalKey" withPredicate:@"guid = %@", guid];
//	if (count == 0) {
//		PortalKey *portalKey = [NSEntityDescription insertNewObjectForEntityForName:@"PortalKey" inManagedObjectContext:self.managedObjectContext];
//		portalKey.guid = guid;
//		portalKey.portal = portal;
//		[self saveContext];
//	}
//}

#pragma mark - Count

- (NSInteger)numberOfEnergyGlobs {
	return [self numberOfObjectsForEntityName:@"EnergyGlob" withPredicate:nil];
}

- (NSInteger)numberOfResonatorsOfLevel:(NSInteger)level {
	return [self numberOfObjectsForEntityName:@"Resonator" withPredicate:@"dropped = NO && level = %d", level];
}

- (NSInteger)numberOfXMPsOfLevel:(NSInteger)level {
	return [self numberOfObjectsForEntityName:@"XMP" withPredicate:@"dropped = NO && level = %d", level];
}

- (NSInteger)numberOfPortalShieldsOfRarity:(PortalShieldRarity)rarity {
	return [self numberOfObjectsForEntityName:@"Shield" withPredicate:@"dropped = NO && rarity = %d", rarity];
}

- (NSInteger)numberOfMediaItems {
	return [self numberOfObjectsForEntityName:@"Media" withPredicate:@"dropped = NO"];
}

- (NSInteger)numberOfResonatorsOfPortal:(Portal *)portal {
	return [self numberOfObjectsForEntityName:@"DeployedResonator" withPredicate:@"portal = %@", portal];
}

- (NSInteger)numberOfPowerCubesOfLevel:(NSInteger)level {
	return [self numberOfObjectsForEntityName:@"PowerCube" withPredicate:@"dropped = NO && level = %d", level];
}

#pragma mark - Getters

- (Item *)getItemWithGuid:(NSString *)guid {
	NSArray *fetched = [self fetchObjectsForEntityName:@"Item" withPredicate:@"guid = %@", guid];
	if (fetched.count > 0) {
		return fetched[0];
	}
	return nil;
}

- (Item *)getOrCreateItemWithGuid:(NSString *)guid classStr:(NSString *)classStr {
	Item *fetched = [self getItemWithGuid:guid];
	if (fetched) {
		return fetched;
	}
	Item *item = [NSEntityDescription insertNewObjectForEntityForName:classStr inManagedObjectContext:self.managedObjectContext];
	item.guid = guid;
	//[self saveContext];
	return item;
}

- (DeployedResonator *)deployedResonatorForPortal:(Portal *)portal atSlot:(int)slot shouldCreate:(BOOL)shouldCreate {
	NSArray *fetched = [self fetchObjectsForEntityName:@"DeployedResonator" withPredicate:@"portal = %@ && slot = %d", portal, slot];
	if (fetched.count > 0) {
		return fetched[0];
	}
	if (shouldCreate) {
		DeployedResonator *resonator = [NSEntityDescription insertNewObjectForEntityForName:@"DeployedResonator" inManagedObjectContext:self.managedObjectContext];
		resonator.portal = portal;
		resonator.slot = slot;
		[self saveContext];
		return resonator;
	}
	return nil;
}

- (DeployedMod *)deployedModPortal:(Portal *)portal ofClass:(NSString *)classStr atSlot:(int)slot shouldCreate:(BOOL)shouldCreate {
	NSArray *fetched = [self fetchObjectsForEntityName:@"DeployedMod" withPredicate:@"portal = %@ && slot = %d", portal, slot];
	if (fetched.count > 0) {
		return fetched[0];
	}
	if (shouldCreate) {
		DeployedMod *mod = [NSEntityDescription insertNewObjectForEntityForName:(classStr ? classStr : @"DeployedMod") inManagedObjectContext:self.managedObjectContext];
		mod.portal = portal;
		mod.slot = slot;
		[self saveContext];
		return mod;
	}
	return nil;
}

- (NSArray *)deployedResonatorsForPortal:(Portal *)portal {
	NSArray *fetched = [self fetchObjectsForEntityName:@"DeployedResonator" withPredicate:@"portal = %@", portal];
	return fetched;
}

- (NSArray *)getEnergyGlobs:(int)count {
	//return nil;
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"EnergyGlob"];
	request.fetchLimit = count;
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error != nil) {
        [NSException raise:NSGenericException format:@"%@", error.description];
    }
	if (results.count > count) {
		//NSLog(@"subarray");
		results = [results subarrayWithRange:NSMakeRange(0, count)];
	}
	return results;
}

- (User *)userWithGuid:(NSString *)guid shouldCreate:(BOOL)shouldCreate {
	NSArray *fetched = [self fetchObjectsForEntityName:@"User" withPredicate:@"guid = %@", guid];
	if (fetched.count > 0) {
		return fetched[0];
	}
	if (shouldCreate) {
		User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.managedObjectContext];
		user.guid = guid;
		[self saveContext];
		return user;
	}
	return nil;
}

- (User *)userWhoCapturedPortal:(Portal *)portal {
	NSArray *fetched = [self fetchObjectsForEntityName:@"User" withPredicate:@"ANY capturedPortals = %@", portal];
	if (fetched.count > 0) {
		return fetched[0];
	}
	return nil;
}

- (NSArray *)portalsForControlField:(ControlField *)controlField {
	NSArray *fetched = [self fetchObjectsForEntityName:@"Portal" withPredicate:@"ANY vertexForControlFields = %@", controlField];
	return fetched;
}

#pragma mark - Random

- (Resonator *)getRandomResonatorOfLevel:(NSInteger)level {
	NSArray *fetched = [self fetchObjectsForEntityName:@"Resonator" withPredicate:@"dropped = NO && level = %d", level];
	if (fetched.count > 0) {
		return fetched[0];
	}
	return nil;
}

- (XMP *)getRandomXMPOfLevel:(NSInteger)level {
	NSArray *fetched = [self fetchObjectsForEntityName:@"XMP" withPredicate:@"dropped = NO && level = %d", level];
	if (fetched.count > 0) {
		return fetched[0];
	}
	return nil;
}

- (Shield *)getRandomShieldOfRarity:(PortalShieldRarity)rarity {
	NSArray *fetched = [self fetchObjectsForEntityName:@"Shield" withPredicate:@"dropped = NO && rarity = %d", rarity];
	if (fetched.count > 0) {
		return fetched[0];
	}
	return nil;
}

- (PowerCube *)getRandomPowerCubeOfLevel:(NSInteger)level {
	NSArray *fetched = [self fetchObjectsForEntityName:@"PowerCube" withPredicate:@"dropped = NO && level = %d", level];
	if (fetched.count > 0) {
		return fetched[0];
	}
	return nil;
}

#pragma mark - Deleting

- (void)removeItemWithGuid:(NSString *)guid {
	NSManagedObject *object = [self getItemWithGuid:guid];
	if (object) {
//		NSLog(@"deleting: %@", object);
		[self.managedObjectContext deleteObject:object];
	}
//	else {
//		NSLog(@"error while deleting");
//	}
}

- (void)removeAllMapData {
	NSArray *fetchedPortals = [self fetchObjectsForEntityName:@"Portal" withPredicate:nil];
	for (Portal *portal in fetchedPortals) {
		[self.managedObjectContext deleteObject:portal];
	}
	NSArray *fetchedLinks = [self fetchObjectsForEntityName:@"PortalLink" withPredicate:nil];
	for (PortalLink *portalLink in fetchedLinks) {
		[self.managedObjectContext deleteObject:portalLink];
	}
	NSArray *fetchedFields = [self fetchObjectsForEntityName:@"ControlField" withPredicate:nil];
	for (ControlField *controlField in fetchedFields) {
		[self.managedObjectContext deleteObject:controlField];
	}
	NSArray *fetchedDeployedResonators = [self fetchObjectsForEntityName:@"DeployedResonator" withPredicate:nil];
	for (DeployedResonator *deployedResonator in fetchedDeployedResonators) {
		[self.managedObjectContext deleteObject:deployedResonator];
	}
	NSArray *fetchedDroppedItems = [self fetchObjectsForEntityName:@"Item" withPredicate:@"dropped = YES"];
	for (DeployedResonator *item in fetchedDroppedItems) {
		[self.managedObjectContext deleteObject:item];
	}
}

- (void)removeAllEnergyGlobs {
	NSArray *fetchedGlobs = [self fetchObjectsForEntityName:@"EnergyGlob" withPredicate:nil];
	for (EnergyGlob *glob in fetchedGlobs) {
		[self.managedObjectContext deleteObject:glob];
	}
}

#pragma mark - Map View

- (void)addPortalsToMapView {

	MKMapView *mapView = [AppDelegate instance].mapView;
	
//	return;
	
	////////////////////////
	
	NSMutableArray *annotationsToRemove = [mapView.annotations mutableCopy];
	[annotationsToRemove removeObject:mapView.userLocation];
	[mapView removeAnnotations:annotationsToRemove];
	
	[mapView removeOverlays:mapView.overlays];
	
	////////////////////////
	
	//[mapView addOverlay:[ColorOverlay new]];
	
	NSArray *fetchedFields = [self fetchObjectsForEntityName:@"ControlField" withPredicate:nil];
	for (ControlField *controlField in fetchedFields) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[mapView addOverlay:controlField.polygon];
		});
	}
	
	NSArray *fetchedLinks = [self fetchObjectsForEntityName:@"PortalLink" withPredicate:nil];
	for (PortalLink *portalLink in fetchedLinks) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[mapView addOverlay:portalLink.polyline];
		});
	}
	
	NSArray *fetchedItems = [self fetchObjectsForEntityName:@"Item" withPredicate:@"dropped = YES"];
	for (Item *item in fetchedItems) {
		//NSLog(@"adding item to map: %@ (%f, %f)", item, item.latitude, item.longitude);
		if (item.coordinate.latitude == 0 && item.coordinate.longitude == 0) { continue; }
		dispatch_async(dispatch_get_main_queue(), ^{
			[mapView addAnnotation:item];
		});
	}
	
	NSArray *fetchedPortals = [self fetchObjectsForEntityName:@"Portal" withPredicate:@"completeInfo = YES"];
	for (Portal *portal in fetchedPortals) {
		//NSLog(@"adding portal to map: %@ (%f, %f)", portal.subtitle, portal.latitude, portal.longitude);
		if (portal.coordinate.latitude == 0 && portal.coordinate.longitude == 0) { continue; }
		dispatch_async(dispatch_get_main_queue(), ^{
			[mapView addAnnotation:portal];
			//[mapView addOverlay:portal];
		});
	}
	
	NSArray *fetchedResonators = [self fetchObjectsForEntityName:@"DeployedResonator" withPredicate:nil];
	for (DeployedResonator *resonator in fetchedResonators) {
		//NSLog(@"adding resonator to map: %@ (%f, %f)", resonator, resonator.coordinate.latitude, resonator.coordinate.longitude);
		if (resonator.portal.coordinate.latitude == 0 && resonator.portal.coordinate.longitude == 0) { continue; }
		dispatch_async(dispatch_get_main_queue(), ^{
			[mapView addOverlay:resonator.circle];
		});
	}
	
}

#pragma mark - Fetching

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ... {

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:newEntityName];

    if (stringOrPredicate) {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]]) {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        } else {
            NSAssert([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
	
    if (error != nil) {
        [NSException raise:NSGenericException format:@"%@", error.description];
    }
	
	return results;
    //return [NSSet setWithArray:results];
}

- (NSUInteger)numberOfObjectsForEntityName:(NSString *)newEntityName withPredicate:(id)stringOrPredicate, ... {
	
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:newEntityName];
	
    if (stringOrPredicate) {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]]) {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        } else {
            NSAssert([stringOrPredicate isKindOfClass:[NSPredicate class]],
					 @"Second parameter passed to %s is of unexpected class %@",
					 sel_getName(_cmd), NSStringFromClass([stringOrPredicate class]));
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
	NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    if (error != nil) {
        [NSException raise:NSGenericException format:@"%@", error.description];
    }
	
    return count;
}

#pragma mark - Core Data stack

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Ingress" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[DB applicationDocumentsDirectory] URLByAppendingPathComponent:@"Ingress.sqlite"];
    
	NSDictionary *options = @{
		NSMigratePersistentStoresAutomaticallyOption: @YES,
		NSInferMappingModelAutomaticallyOption: @YES
	};
	
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
