//
//  FEDProxyTests.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDProxyTests.h"

@interface FEDProxyTests ()
@property (nonatomic,strong) FEDExampleDelegate *strongDelegate;
@property (nonatomic,strong) id strongProxy;
@end

@implementation FEDProxyTests{
    
}

#pragma mark - Setup
-(void)setUp{
    [super setUp];
    _strongDelegate = [FEDExampleDelegate new];
    _strongProxy = [FEDProxy proxyWithDelegate:_strongDelegate
                                      protocol:@protocol(FEDExampleProtocol)];
}

-(void)tearDown{
    [super tearDown];
}

#pragma mark - Signatures
-(void)runMethodSignatureTestForSelector:(SEL)selector{
    NSMethodSignature *delegateSignature =
        [self.strongDelegate methodSignatureForSelector:selector];
    NSMethodSignature *proxySignature = [self.strongProxy methodSignatureForSelector:selector];
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

-(void)testSignatureForNonExistentSelector{
    SEL selector = @selector(selector_doesNot_exists);
    STAssertThrows([self.strongProxy methodSignatureForSelector:selector],@"");
}

-(void)testMethodsInProtocol{
    RTProtocol *protocol = [RTProtocol
                            protocolWithObjCProtocol:@protocol(FEDExampleProtocol)];
    NSArray *methods = [[protocol methodsRequired:YES instance:YES incorporated:YES]
                        arrayByAddingObjectsFromArray:
                        [protocol methodsRequired:NO instance:YES incorporated:YES]];
    for (RTMethod *method in methods) {
        NSLog(@"%@",method.selectorName);
    }
}

#pragma mark - Delegation
-(void)testRequiredImplementedMethod{
    STAssertTrue(13 == [self.strongProxy requiredMethodReturns13], @"");
}

-(void)testOptionalImplementedMethod{
    STAssertTrue(42 == [self.strongProxy parentOptionalMethodReturns42], @"");
}

-(void)testNotImplementedMethods{
    id proxy = [FEDProxy
                proxyWithDelegate:[NSObject new]
                protocol:@protocol(FEDExampleProtocolWithNotExistentMethods)];
    STAssertThrows([proxy requiredNotImplementedMethod], @"");
    STAssertNoThrow([proxy optionalNotImplementedMethod], @"");
    // test method not present in protocol
    STAssertThrows([proxy testNotImplementedMethods], @"");
}

-(void)testRespondsToSelector{
    STAssertTrue([self.strongProxy respondsToSelector:@selector(requiredMethodReturns13)], @"");
    STAssertTrue([self.strongProxy
                  respondsToSelector:@selector(parentOptionalMethodReturns42)], @"");
    STAssertFalse([self.strongProxy
                   respondsToSelector:@selector(optionalNotImplementedMethod)], @"");
}

#pragma mark - Weak references compatibility
// see http://stackoverflow.com/questions/13800136/nsproxy-weak-reference-bug-under-arc-on-ios-5
-(void)testWeakReferencesCompatibilityOnIOS5{
    __weak id weakProxy = self.strongProxy;
    STAssertNotNil(weakProxy, @"");
}

#pragma mark - Retained by delegate
-(void)testRetainedByDelegate{
    __weak id weakProxy;
    @autoreleasepool {
        id proxy = [FEDProxy proxyWithDelegate:self.strongDelegate
                                      protocol:@protocol(FEDExampleProtocol)
                            retainedByDelegate:YES];
        weakProxy = proxy;
    }
    id strongProxy = weakProxy;
    STAssertNotNil(strongProxy, @"");
}

#pragma mark - OnDealloc
-(void)testOnDeallocBlock{
    __block BOOL dispatched = NO;
    @autoreleasepool {
        id proxy = [FEDProxy proxyWithDelegate:[NSObject new]
                                      protocol:@protocol(FEDExampleProtocol)
                            retainedByDelegate:YES
                                     onDealloc:^{
                                         dispatched = YES;
                                     }];
        proxy = nil;
    }
    STAssertTrue(dispatched, @"");
}

@end
