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
    NSMutableArray *array = [NSMutableArray array];
    [[proxy mapToArray:array] name];
    STAssertTrue(([array isEqualToArray:@[@"Bob",@"John",@"Alice"]]), @"");
}

@end
