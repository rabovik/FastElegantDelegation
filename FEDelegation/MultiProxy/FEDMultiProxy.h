//
//  FEDMultiProxy.h
//  FEDelegation
//
//  Created by Yan Rabovik on 19.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FEDMultiProxy : NSProxy

+(id)proxyWithProtocol:(Protocol *)protocol;
+(id)proxyWithDelegates:(NSArray *)delegates
               protocol:(Protocol *)protocol
    retainedByDelegates:(BOOL)retainedByDelegates
              onDealloc:(dispatch_block_t)block;
+(id)proxyWithDelegates:(NSArray *)delegates
               protocol:(Protocol *)protocol
        retainDelegates:(BOOL)retainDelegates;
-(NSArray *)fed_realDelegates;
-(id)mapToArray:(NSMutableArray *)array;
-(id)mapToBlock:(void(^)(NSInvocation *invocation))block;
-(void)addDelegate:(id)delegate;
-(void)removeDelegate;

@end
