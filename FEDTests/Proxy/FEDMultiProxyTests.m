//
//  FEDMultiProxyTests.m
//  FEDelegation
//
//  Created by Yan Rabovik on 19.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDTests.h"
#import "FEDMultiProxy.h"

@interface FEDMultiProxyTests : FEDTests
@end

@implementation FEDMultiProxyTests

-(void)testWeakDelegates{
    FEDMultiProxy *proxy;
    id delegate1 = [NSObject new];
    @autoreleasepool {
        id delegate2 = [NSObject new];
        proxy = [FEDMultiProxy proxyWithDelegates:@[delegate1,delegate2]
                                         protocol:nil
                                  retainDelegates:NO];
        STAssertTrue(2 == proxy.fed_realDelegates.count, @"");
    }
    STAssertTrue(1 == proxy.fed_realDelegates.count, @"");
}

-(void)testMultiProxy{
    FEDExamplePerson *bob = [FEDExamplePerson personWithName:@"Bob" age:30];
    FEDExamplePerson *john = [FEDExamplePerson personWithName:@"John" age:40];
    FEDExamplePerson *alice = [FEDExamplePerson personWithName:@"Alice" age:20];
    id proxy = [FEDMultiProxy
                proxyWithDelegates:@[[NSObject new],bob,john,@"Some string",alice]
                protocol:@protocol(FEDExamplePersonProtocol)
                retainDelegates:NO];
    // test return first value
    STAssertTrue(30 == [proxy age], @"");
    // test mapToArray
    NSArray *array;
    [[proxy mapToArray:&array] name];
    STAssertTrue(([array isEqualToArray:@[@"Bob",@"John",@"Alice"]]), @"");
    // test returns first after previous mapToArray
    STAssertTrue([@"Bob" isEqualToString:[proxy name]], @"");
    // test mapToArray with incorrect method signature
    STAssertThrows([[proxy mapToArray:&array] age], @"");
    // test mapToBlock
    __block int iteration = 0;
    NSArray *ages = @[@30,@40,@20];
    [[proxy mapToBlock:^(NSInvocation *invocation) {
        NSUInteger age;
        [invocation getReturnValue:&age];
        STAssertTrue((age == [ages[iteration++] unsignedIntegerValue]), @"");
    }] age];
    // test returns first after previous mapToBlock
    STAssertTrue([@"Bob" isEqualToString:[proxy name]], @"");
}

-(void)testDelegator{
    FEDExamplePerson *bob = [FEDExamplePerson personWithName:@"Bob" age:30];
    FEDExamplePerson *john = [FEDExamplePerson personWithName:@"John" age:40];
    FEDExamplePerson *alice = [FEDExamplePerson personWithName:@"Alice" age:20];
    FEDExampleMultiDelegator *delegator = [FEDExampleMultiDelegator new];
    [delegator addDelegate:bob];
    [delegator addDelegate:john];
    [delegator addDelegate:alice];
    STAssertTrue(([@[@"Bob",@"John",@"Alice"] isEqualToArray:[delegator names]]),@"");
    STAssertTrue(40 == [delegator maxAge],@"");
    [delegator removeDelegate:john];
    STAssertTrue(([@[@"Bob",@"Alice"] isEqualToArray:[delegator names]]),@"");
    STAssertTrue(30 == [delegator maxAge],@"");
    [delegator removeDelegate:bob];
    [delegator removeDelegate:alice];
    STAssertTrue(([@[] isEqualToArray:[delegator names]]),@"");
    STAssertTrue(0 == [delegator maxAge],@"");
    [delegator addDelegate:alice];
    STAssertTrue(([@[@"Alice"] isEqualToArray:[delegator names]]),@"");
    STAssertTrue(20 == [delegator maxAge],@"");
}

-(void)testMapToArraySyntax{
    __weak NSArray *weakArray;
    @autoreleasepool {
        FEDExamplePerson *bob = [FEDExamplePerson personWithName:@"Bob" age:30];
        id proxy = [FEDMultiProxy
                    proxyWithDelegates:@[bob]
                    protocol:@protocol(FEDExamplePersonProtocol)
                    retainDelegates:NO];
        NSArray *array;
        [[proxy mapToArray:&array] name];
        STAssertTrue(([@[@"Bob"] isEqualToArray:array]), @"");
        weakArray = array;
    }
    id strongArray = weakArray;
    STAssertNil(strongArray, @"");
}

@end
