//
//  FEDProxy.h
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FEDProxy : NSProxy

+(id)proxyWithDelegate:(id)delegate protocol:(Protocol *)protocol;

@end
