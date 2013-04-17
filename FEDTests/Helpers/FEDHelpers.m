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

@end

@implementation FEDExampleDelegator{
    id _proxy;
}

-(void)setDelegate:(id<FEDExampleProtocol>)delegate{
    _proxy = [FEDProxy proxyWithDelegate:delegate protocol:@protocol(FEDExampleProtocol)];
    _delegate = _proxy;
}

-(void)requiredMethod{
    
}

-(void)methodWithArgument:(id)arg{
    
}

@end
