//
//  FEDProxyTests.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDTests.h"

#pragma mark - PROXY TESTS -

@interface FEDProxyTests : FEDTests
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
    _strongDelegate = nil;
    _strongProxy = nil;
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

#pragma mark - Defaults
-(void)testDefaultString{
    NSString *returnedString = [[self.strongProxy fed_default:@"ABC"]
                                optionalNotImplementedMethodReturnsString];
    STAssertTrue([@"ABC" isEqualToString:returnedString], @"%@",returnedString);
}

-(void)testDefaultInt{
    int returnedInt = [[self.strongProxy fed_default:[NSNumber numberWithInt:13]]
                                optionalNotImplementedMethodReturnsInt];
    STAssertTrue(13 == returnedInt, @"%d",returnedInt);
}

#pragma mark - Weak references compatibility
// see http://stackoverflow.com/questions/13800136/nsproxy-weak-reference-bug-under-arc-on-ios-5
-(void)testWeakReferencesCompatibilityOnIOS5{
    __weak id weakProxy = self.strongProxy;
    STAssertNotNil(weakProxy, @"");
}

#pragma mark - Retaining
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

-(void)testTwoProxiesRetainedByOneDelegate{
    __weak id weakProxy1;
    __weak id weakProxy2;
    @autoreleasepool {
        id proxy1 = [FEDProxy proxyWithDelegate:self.strongDelegate
                                       protocol:@protocol(FEDExampleProtocol)
                             retainedByDelegate:YES];
        id proxy2 = [FEDProxy proxyWithDelegate:self.strongDelegate
                                       protocol:@protocol(FEDExampleProtocol)
                             retainedByDelegate:YES];
        weakProxy1 = proxy1;
        weakProxy2 = proxy2;
    }
    id strongProxy1 = weakProxy1;
    id strongProxy2 = weakProxy2;
    STAssertNotNil(strongProxy1, @"");
    STAssertNotNil(strongProxy2, @"");
}

-(void)testRetainDelegate{
    id proxy;
    @autoreleasepool {
        FEDExampleDelegate *delegate = [FEDExampleDelegate new];
        proxy = [FEDProxy proxyWithDelegate:delegate
                                   protocol:@protocol(FEDExampleProtocol)
                             retainDelegate:YES];
        delegate = nil;
    }
    STAssertTrue(42 == [proxy parentOptionalMethodReturns42], @"");
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

#pragma mark - DELAGATOR TESTS -

@interface FEDProxyDelegatorTests : FEDTests
@property (nonatomic,strong) FEDExampleDelegator *delegator;
@property (nonatomic,strong) FEDExampleDelegate *strongDelegate;
@end

@implementation FEDProxyDelegatorTests{
    NSLock *lock;
    BOOL _testDone;
    NSUInteger _testStep;
}

#pragma mark - Setup
- (void)waitForCompletion:(NSTimeInterval)timeoutSecs{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    do{
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0){
            STFail(@"TimeOut");
            break;
        }
    }
    while (!_testDone);
}

-(void)setUp{
    [super setUp];
    _delegator = [FEDExampleDelegator new];
    _strongDelegate = [FEDExampleDelegate new];
    _testDone = NO;
    _testStep = 0;
}

-(void)tearDown{
    _strongDelegate = nil;
    _delegator = nil;
    [super tearDown];
}

#pragma mark - Tests
-(void)testDelegatorWorks{
    @autoreleasepool {
        self.delegator.delegate = self.strongDelegate;
        self.delegator.strongDelegate = [FEDExampleDelegate new];
    }
    STAssertTrue(42 == [self.delegator parentOptionalMethodReturns42], @"");
    STAssertTrue(42 == [self.delegator.strongDelegate parentOptionalMethodReturns42],@"");
    STAssertNoThrow([self.delegator.delegate parentOptionalMethod], @"");
    STAssertNoThrow([self.delegator.strongDelegate parentOptionalMethod], @"");
}

-(void)testDelegateIsAliveIfProxyIsAlive{
    lock = [NSLock new];
    [lock lock];
    STAssertTrue(1 == ++_testStep, @"");
    // Step 1. Create real delegate;
    __block id delegate = [FEDExampleDelegate new];
    @autoreleasepool {
        self.delegator.delegate = delegate;
    }
    [self
     performSelectorInBackground:@selector(delegateIsAliveIfProxyIsAliveBackgroundTest)
     withObject:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        STAssertTrue(3 == ++_testStep, @"");
        // Step 3. Destroy real delegate
        delegate = nil;
        [lock unlock];
    });
    [self waitForCompletion:5];
    STAssertTrue(5 == ++_testStep, @"");
    // Step 5. Finish test.
    lock = nil;
}

-(void)delegateIsAliveIfProxyIsAliveBackgroundTest{
    STAssertTrue(2 == ++_testStep, @"");
    // Step 2. Save strong reference to proxy;
    id delegate = self.delegator.delegate;
    [lock lock];
    STAssertTrue(4 == ++_testStep, @"");
    // Step 4. Normally real delegate should be nil here.
    // But we extended it's lifetime in delegator's 'delegate' getter
    // so it is still alive
    STAssertTrue(42 == [delegate parentOptionalMethodReturns42], @"");
    [lock unlock];
    dispatch_async(dispatch_get_main_queue(), ^{
        _testDone = YES;
    });
}


@end
