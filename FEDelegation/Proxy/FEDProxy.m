//
//  FEDProxy.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDProxy.h"
#import "FEDUtils.h"

@implementation FEDProxy{
    Protocol *_protocol;
}

+(Class)proxyClass{
    return self;
}

+(id)proxyWithDelegate:(id)delegate protocol:(Protocol *)protocol{
    FEDProxy *proxy = [[self proxyClass] alloc];
    proxy->_protocol = protocol;
    return proxy;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    return [FEDUtils methodSignatureForSelector:sel fromProtocol:_protocol];
}

@end
