//
//  FEDMultiProxy.h
//  FEDelegation
//
//  Created by Yan Rabovik on 19.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>

#define fed_synthesize_multiproxy(PROTOCOL,ADD,REMOVE,PROXY_GETTER)                      \
-(void)ADD:(id<PROTOCOL>)delegate{                                                       \
    [self.PROXY_GETTER addDelegate:delegate];                                            \
}                                                                                        \
-(void)REMOVE:(id<PROTOCOL>)delegate{                                                    \
    [self.PROXY_GETTER removeDelegate:delegate];                                         \
}                                                                                        \
-(id)PROXY_GETTER{                                                                       \
    static char key;                                                                     \
    id proxy;                                                                            \
    @synchronized(self){                                                                 \
        proxy = [FEDRuntime associatedObjectFromTarget:self withKey:&key];               \
        if (nil == proxy) {                                                              \
            proxy = [FEDMultiProxy proxyWithProtocol:@protocol(PROTOCOL)];               \
            [FEDRuntime associateRetainedObject:proxy toObject:self withKey:&key];       \
        }                                                                                \
    }                                                                                    \
    return proxy;                                                                        \
}

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
-(void)removeDelegate:(id)delegate;

@end
