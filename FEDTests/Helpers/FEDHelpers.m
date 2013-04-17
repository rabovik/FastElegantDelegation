//
//  FEDHelpers.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDHelpers.h"
#import "FEDProxy.h"

@implementation FEDExampleDelegate

-(void)requiredMethod{};

-(int)requiredMethodReturns13{
    return 13;
}

-(int)parentOptionalMethodReturns42{
    return 42;
}

@end

@implementation FEDExampleDelegator{
    id _proxy;
}

-(void)setDelegate:(id<FEDExampleProtocol>)delegate{
    _proxy = [FEDProxy proxyWithDelegate:delegate protocol:@protocol(FEDExampleProtocol)];
    _delegate = _proxy;
}

-(void)requiredMethod{
    [self.delegate requiredMethod];
}

-(void)methodWithArgument:(id)arg{
    [self.delegate methodWithArgument:arg];
}

@end
