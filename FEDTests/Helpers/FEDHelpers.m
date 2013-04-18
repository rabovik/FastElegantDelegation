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

@implementation FEDExampleDelegator
fed_use_proxy_for_delegate

-(int)parentOptionalMethodReturns42{
    return [self.delegate parentOptionalMethodReturns42];
}

@end
