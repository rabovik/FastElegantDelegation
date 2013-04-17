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

@implementation FEDProxy{
    Protocol *_protocol;
    std::unordered_map<SEL,id> _signatures;
}

+(Class)proxyClass{
    return self;
}

+(id)proxyWithDelegate:(id)delegate protocol:(Protocol *)protocol{
    FEDProxy *proxy = [[[self proxyClass] alloc] fed_initWithDelegate:delegate
                                                             protocol:protocol];
    return proxy;
}

-(id)fed_initWithDelegate:(id)delegate protocol:(Protocol *)protocol{
    _protocol = protocol;
    
    NSArray *methods = [FEDUtils instanceMethodsInProtocol:protocol withAdopted:YES];
    for (RTMethod *method in methods){
        const char *types = [method.signature
                             cStringUsingEncoding:NSUTF8StringEncoding];
        _signatures[method.selector] = [NSMethodSignature signatureWithObjCTypes:types];
    }
    
    return self;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    std::unordered_map<SEL,id>::const_iterator pair = _signatures.find(selector);
    if (pair != _signatures.end()) {
        return pair->second;
    }else{
        return [super methodSignatureForSelector:selector];
    }
    return nil;
}

@end
