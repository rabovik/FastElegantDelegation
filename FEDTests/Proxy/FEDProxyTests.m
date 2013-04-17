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

-(void)testMethodSignatures{
    NSMethodSignature *sig = [self.proxy methodSignatureForSelector:@selector(method)];
    NSLog(@"%@",sig);
}

@end
