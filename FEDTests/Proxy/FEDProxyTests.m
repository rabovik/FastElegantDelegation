//
//  FEDProxyTests.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDProxyTests.h"

@interface FEDProxyTests ()
@property (nonatomic,strong) FEDExampleDelegate *delegate;
@property (nonatomic,strong) FEDProxy *proxy;
@end

@implementation FEDProxyTests

-(void)setUp{
    [super setUp];
    _delegate = [FEDExampleDelegate new];
    _proxy = [FEDProxy proxyWithDelegate:_delegate
                                protocol:@protocol(FEDExampleProtocol)];
}

-(void)runMethodSignatureTestForSelector:(SEL)selector{
    NSMethodSignature *delegateSignature =
        [self.delegate methodSignatureForSelector:selector];
    NSMethodSignature *proxySignature = [self.proxy methodSignatureForSelector:selector];
    STAssertNotNil(delegateSignature,
                   @"Selector: %@",
                   NSStringFromSelector(selector));
    STAssertNotNil(proxySignature,
                   @"Selector: %@",
                   NSStringFromSelector(selector));
    STAssertEqualObjects(delegateSignature,
                         proxySignature,
                         @"Selector: %@",
                         NSStringFromSelector(selector));
}

-(void)testMethodSignatures{
    // required
    [self runMethodSignatureTestForSelector:@selector(requiredMethod)];
    // optional
    [self runMethodSignatureTestForSelector:@selector(methodWithArgument:)];
    // method in adopted protocol
    [self runMethodSignatureTestForSelector:@selector(self)];
}

@end
