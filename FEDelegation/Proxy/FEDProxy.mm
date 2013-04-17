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

-(id)fed_initWithDelegate:(id)delegate protocol:(Protocol *)protocol{
    _delegate = delegate;
    _protocol = protocol;
    NSArray *methods = [FEDUtils instanceMethodsInProtocol:protocol withAdopted:YES];
    for (RTMethod *method in methods){
        SEL selector = method.selector;
        
        if ([_delegate respondsToSelector:selector]) {
            _delegateSelectors.insert(selector);
        }
        const char *types = [method.signature
                             cStringUsingEncoding:NSUTF8StringEncoding];
        _signatures[selector] = [NSMethodSignature signatureWithObjCTypes:types];
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
