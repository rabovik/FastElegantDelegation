//
//  FEDProxy.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDProxy.h"
#import "FEDUtils.h"
#import "RTMethod.h"
#import "RTProtocol.h"
#import "RTProtocol+FEDAdditions.h"
#import <unordered_map>
#import <unordered_set>

@implementation FEDProxy{
    __weak id _delegate;
    Protocol *_protocol;
    std::unordered_map<SEL,id> _signatures;
    std::unordered_set<SEL> _delegateSelectors;
}

#pragma mark - Init
+(Class)proxyClass{
    return self;
}

+(id)proxyWithDelegate:(id)delegate protocol:(Protocol *)protocol{
    FEDProxy *proxy = [[[self proxyClass] alloc] fed_initWithDelegate:delegate
                                                             protocol:protocol];
    return proxy;
}

-(id)fed_initWithDelegate:(id)delegate protocol:(Protocol *)objcProtocol{
    _delegate = delegate;
    _protocol = objcProtocol;
    
    RTProtocol *protocol = [RTProtocol protocolWithObjCProtocol:objcProtocol];
    NSMutableArray *protocols = [NSMutableArray arrayWithObject:protocol];
    [protocols addObjectsFromArray:[protocol recursivelyIncorporatedProtocols]];
    NSMutableArray *requiredMethods = [NSMutableArray array];
    NSMutableArray *optionalMethods = [NSMutableArray array];
    for (RTProtocol *protocol in protocols) {
        [optionalMethods addObjectsFromArray:[protocol methodsRequired:NO instance:YES]];
        [requiredMethods addObjectsFromArray:[protocol methodsRequired:YES instance:YES]];
    }
    NSMutableArray *allMethods = [NSMutableArray arrayWithArray:requiredMethods];
    [allMethods addObjectsFromArray:optionalMethods];
    for (RTMethod *method in requiredMethods){
        _delegateSelectors.insert(method.selector);
    }
    for (RTMethod *method in optionalMethods){
        SEL selector = method.selector;
        if ([_delegate respondsToSelector:selector]) {
            _delegateSelectors.insert(selector);
        }
    }
    for (RTMethod *method in allMethods){
        const char *types = [method.signature
                             cStringUsingEncoding:NSUTF8StringEncoding];
        _signatures[method.selector] = [NSMethodSignature signatureWithObjCTypes:types];
    }
    return self;
}

#pragma mark - Forwarding
-(id)forwardingTargetForSelector:(SEL)selector{
    std::unordered_set<SEL>::const_iterator pair = _delegateSelectors.find(selector);
    if (pair != _delegateSelectors.end()) {
        id strongDelegate = _delegate;
        if (strongDelegate) {
            return strongDelegate;
        }
    }
    return nil;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    std::unordered_map<SEL,id>::const_iterator pair = _signatures.find(selector);
    if (pair != _signatures.end()) {
        return pair->second;
    }else{
        @throw [NSException
                exceptionWithName:@"FEDProxyException"
                reason:[NSString stringWithFormat:
                        @"No method signature for selector %@ in protocol %@",
                        NSStringFromSelector(selector),
                        NSStringFromProtocol(_protocol)]
                userInfo:nil];
    }
    return nil;
}

-(void)forwardInvocation:(NSInvocation *)invocation{
    [invocation invokeWithTarget:nil];
}

@end
