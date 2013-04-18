//
//  FEDProxy.h
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEDRuntime.h"

@interface FEDProxy : NSProxy

+(id)proxyWithDelegate:(id)delegate protocol:(Protocol *)protocol;
+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
    retainedByDelegate:(BOOL)retainedByDelegate;
+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
    retainedByDelegate:(BOOL)retainedByDelegate
             onDealloc:(dispatch_block_t)block;
+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
        retainDelegate:(BOOL)retainDelegate;

@end
