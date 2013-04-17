//
//  FEDUtils.h
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FEDUtils : NSObject

+(id)methodSignatureForSelector:(SEL)selector fromProtocol:(Protocol *)protocol;
+(NSArray*)instanceMethodsInProtocol:(Protocol*)protocol withAdopted:(BOOL)adopted;

@end
