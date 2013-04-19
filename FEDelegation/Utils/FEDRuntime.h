//
//  FEDUtils.h
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FEDRuntime : NSObject

+(Protocol *)protocolFromProperty:(NSString *)propertyName object:(id)object;
+(BOOL)propertyIsWeak:(NSString *)propertyName object:(id)object;
+(void)associateRetainedObject:(id)object toObject:(id)target withKey:(void *)key;
+(id)associatedObjectFromTarget:(id)target withKey:(void *)key;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
+(BOOL)proxyIsWeakCompatible;
+(void)replicateMethodsFromClass:(Class)fromClass toClass:(Class)toClass;
#endif

@end
