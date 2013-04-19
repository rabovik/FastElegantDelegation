//
//  FEDProxy.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDProxy.h"
#import "RTMethod.h"
#import "RTProtocol.h"
#import "MAObjCRuntime+FEDAdditions.h"
#import <unordered_map>
#import <unordered_set>

#if !__has_feature(objc_arc)
#error This code needs ARC. Use compiler option -fobjc-arc
#endif

#define FED_PROXY_IVARS                                                                  \
    __weak id _delegate;                                                                 \
    id _strongDelegate;                                                                  \
    Protocol *_protocol;                                                                 \
    std::unordered_map<SEL,id> _signatures;                                              \
    std::unordered_set<SEL> _delegateSelectors;                                          \
    dispatch_block_t _onDeallocBlock;

#pragma mark - IOS 5 HACK -
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
@interface FEDProxy_IOS5 : NSObject
@end
@implementation FEDProxy_IOS5{
    FED_PROXY_IVARS
}
+(void)initialize{
    [FEDRuntime replicateMethodsFromClass:[FEDProxy class] toClass:self];
}
@end
#endif

#pragma mark - PROXY -
@implementation FEDProxy{
    FED_PROXY_IVARS
}

#pragma mark - Init
+(Class)proxyClass{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (![FEDRuntime proxyIsWeakCompatible]) {
        return [FEDProxy_IOS5 class];
    }
#endif
    return self;
}

+(id)proxyWithDelegate:(id)delegate protocol:(Protocol *)protocol{
    return [self proxyWithDelegate:delegate
                          protocol:protocol
                    retainDelegate:NO
                retainedByDelegate:NO
                         onDealloc:nil];
}

+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
    retainedByDelegate:(BOOL)retainedByDelegate
{
    return [self proxyWithDelegate:delegate
                          protocol:protocol
                    retainDelegate:NO
                retainedByDelegate:retainedByDelegate
                         onDealloc:nil];
}

+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
    retainedByDelegate:(BOOL)retainedByDelegate
             onDealloc:(dispatch_block_t)block
{
    return [self proxyWithDelegate:delegate
                          protocol:protocol
                    retainDelegate:NO
                retainedByDelegate:retainedByDelegate
                         onDealloc:block];
}

+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
        retainDelegate:(BOOL)retainDelegate
{
    return [self proxyWithDelegate:delegate
                          protocol:protocol
                    retainDelegate:retainDelegate
                retainedByDelegate:NO
                         onDealloc:nil];
}

+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
        retainDelegate:(BOOL)retainDelegate
    retainedByDelegate:(BOOL)retainedByDelegate
             onDealloc:(dispatch_block_t)block
{
    FEDProxy *proxy = [[self proxyClass] alloc];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if ([self proxyClass] == [FEDProxy_IOS5 class]) {
        proxy = [(id)proxy init];
    }
#endif
    [proxy fed_initWithDelegate:delegate
                       protocol:protocol
                 retainDelegate:retainDelegate
             retainedByDelegate:retainedByDelegate
                      onDealloc:block];
    return proxy;
}

-(void)fed_initWithDelegate:(id)delegate
                   protocol:(Protocol *)objcProtocol
             retainDelegate:(BOOL)retainDelegate
         retainedByDelegate:(BOOL)retainedByDelegate
                  onDealloc:(dispatch_block_t)block
{
    _delegate = delegate;
    _protocol = objcProtocol;
    
    [self fed_prepareSelectorsCache];
    
    if (retainDelegate) {
        _strongDelegate = delegate;
    }
    
    if (retainedByDelegate) {
        objc_setAssociatedObject(delegate, (__bridge void *)self, self, OBJC_ASSOCIATION_RETAIN);
    }
    
    _onDeallocBlock = [block copy];
}

-(void)fed_prepareSelectorsCache{
    RTProtocol *protocol = [RTProtocol protocolWithObjCProtocol:_protocol];
    NSArray *requiredMethods = [protocol methodsRequired:YES
                                                instance:YES
                                            incorporated:YES];
    NSArray *optionalMethods = [protocol methodsRequired:NO
                                                instance:YES
                                            incorporated:YES];
    NSArray *allMethods = [requiredMethods arrayByAddingObjectsFromArray:optionalMethods];
    for (RTMethod *method in requiredMethods){
        _delegateSelectors.insert(method.selector);
    }
    for (RTMethod *method in optionalMethods){
        SEL selector = method.selector;
        if ([_delegate respondsToSelector:selector]) {
            _delegateSelectors.insert(selector);
        }
    }
    for (RTMethod *method in allMethods){
        _signatures[method.selector] =
            [NSMethodSignature signatureWithObjCTypes:method.signature.UTF8String];
    }
}

-(void)dealloc{
    if (_onDeallocBlock) _onDeallocBlock();
}

#pragma mark - Forwarding
-(id)forwardingTargetForSelector:(SEL)selector{
    auto pair = _delegateSelectors.find(selector);
    if (pair != _delegateSelectors.end()) {
        id strongDelegate = _delegate;
        if (strongDelegate) {
            return strongDelegate;
        }
    }
    return nil;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    auto pair = _signatures.find(selector);
    if (pair != _signatures.end()) {
        return pair->second;
    }else{
        @throw [NSException
                exceptionWithName:@"FEDProxyException"
                reason:[NSString stringWithFormat:
                        @"No method signature for selector %@ in protocol %@",
                        NSStringFromSelector(selector),
                        NSStringFromProtocol(_protocol)]
                userInfo:nil];
    }
    return nil;
}

-(void)forwardInvocation:(NSInvocation *)invocation{
    [invocation invokeWithTarget:nil];
}

-(BOOL)respondsToSelector:(SEL)selector{
    id strongDelegate = _delegate;
    if (nil == strongDelegate) return NO;
    auto pair = _delegateSelectors.find(selector);
    if (pair != _delegateSelectors.end()) {
        return YES;
    }
    return NO;
}

#pragma mark - Real delegate getter
-(id)fed_realDelegate{
    return _delegate;
}

@end
