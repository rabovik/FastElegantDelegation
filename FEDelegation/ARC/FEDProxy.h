//
//  FEDProxy.h
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FEDRuntime.h"

#if !__has_feature(objc_arc)
#error This code needs ARC. Use compiler option -fobjc-arc
#endif

#define fed_use_proxy_for_delegate fed_use_proxy_for_property(delegate,setDelegate)

#define fed_use_proxy_for_property(GETTER,SETTER)                                        \
@synthesize GETTER=_fed_##GETTER;                                                        \
-(void)SETTER:(id)GETTER{                                                                \
    if (nil == GETTER) {                                                                 \
        _fed_##GETTER = nil;                                                             \
        return;                                                                          \
    }                                                                                    \
    Protocol *protocol = [FEDRuntime protocolFromProperty:(@"" #GETTER) object:self];    \
    if ([FEDRuntime propertyIsWeak:(@"" #GETTER) object:self]) {                         \
        _fed_##GETTER = [FEDProxy proxyWithDelegate:GETTER                               \
                                           protocol:protocol                             \
                                 retainedByDelegate:YES];                                \
    }else{                                                                               \
        _fed_##GETTER = [FEDProxy proxyWithDelegate:GETTER                               \
                                           protocol:protocol                             \
                                     retainDelegate:YES];                                \
    }                                                                                    \
}                                                                                        \
-(id)GETTER{                                                                             \
    id strongRealDelegate = [(FEDProxy *)_fed_##GETTER fed_realDelegate];                \
    if (!strongRealDelegate) return nil;                                                 \
    return _fed_##GETTER;                                                                \
}

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
-(id)fed_realDelegate;

@end
