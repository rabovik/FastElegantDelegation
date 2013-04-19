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
fed_use_proxy_for_property(strongDelegate,setStrongDelegate)

-(int)parentOptionalMethodReturns42{
    return [self.delegate parentOptionalMethodReturns42];
}

@end

@implementation FEDExamplePerson{
    NSString *_name;
    NSUInteger _age;
}

+(id)personWithName:(NSString *)name age:(NSUInteger)age{
    FEDExamplePerson *person = [[self alloc] init];
    person->_name = [name copy];
    person->_age = age;
    return person;
}

-(NSString *)name{
    return _name;
}

-(NSUInteger)age{
    return _age;
}

@end

@implementation FEDExampleMultiDelegator

-(void)addDelegate:(id<FEDExampleProtocol>)delegate{
    
}

-(void)removeDelegate:(id<FEDExampleProtocol>)delegate{
    
}

-(NSArray *)names{
    return nil;
}

-(NSUInteger)maxAge{
    return 0;
}

@end
