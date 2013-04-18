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

@end
