//
//  FEDRuntimeTests.m
//  FEDelegation
//
//  Created by Yan Rabovik on 18.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDTests.h"

@interface FEDRuntimeTests : FEDTests
@end

@implementation FEDRuntimeTests

-(void)testProtocolFromProperty{
    FEDExampleDelegator *object = [FEDExampleDelegator new];
    Protocol *protocol = [FEDRuntime protocolFromProperty:@"delegate" object:object];
    RTProtocol *etalonProtocol =
        [RTProtocol protocolWithObjCProtocol:@protocol(FEDExampleProtocol)];
    STAssertTrue(protocol_isEqual(protocol,[etalonProtocol objCProtocol]),@"");
}

@end
