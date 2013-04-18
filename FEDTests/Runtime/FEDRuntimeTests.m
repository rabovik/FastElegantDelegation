//
//  FEDRuntimeTests.m
//  FEDelegation
//
//  Created by Yan Rabovik on 18.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDTests.h"

@interface FEDRuntimeExampleClass : NSObject
@property (nonatomic,assign) id assignProperty;
@property (nonatomic,weak) id weakProperty;
@property (nonatomic,copy) id copiedProperty;
@property (nonatomic,strong) id strongProperty;
@end

@implementation FEDRuntimeExampleClass
@end

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

-(void)testIsWeak{
    id object = [FEDRuntimeExampleClass new];
    STAssertTrue([FEDRuntime propertyIsWeak:@"assignProperty" object:object], @"");
    STAssertTrue([FEDRuntime propertyIsWeak:@"weakProperty" object:object], @"");
    STAssertFalse([FEDRuntime propertyIsWeak:@"copiedProperty" object:object], @"");
    STAssertFalse([FEDRuntime propertyIsWeak:@"strongProperty" object:object], @"");
}

@end
