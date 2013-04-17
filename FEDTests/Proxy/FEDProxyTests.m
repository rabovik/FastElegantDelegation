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

-(void)testMethodSignature{
    SEL selector = @selector(method);
    NSMethodSignature *delegateSignature =
        [self.delegate methodSignatureForSelector:selector];
    NSMethodSignature *proxySignature = [self.proxy methodSignatureForSelector:selector];
    STAssertEqualObjects(delegateSignature, proxySignature, @"");
}

-(void)testMethodSignatureForOptionalMethod{
    SEL selector = @selector(methodWithArgument:);
    NSMethodSignature *delegateSignature =
    [self.delegate methodSignatureForSelector:selector];
    NSMethodSignature *proxySignature = [self.proxy methodSignatureForSelector:selector];
    STAssertEqualObjects(delegateSignature, proxySignature, @"");    
}

@end
