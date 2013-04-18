//
//  FEDProxy.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDProxy.h"
#import "FEDUtils.h"
#import "MARTNSObject.h"
#import "RTMethod.h"
#import "RTProtocol.h"
#import "RTProtocol+FEDAdditions.h"
#import <unordered_map>
#import <unordered_set>

#define FEDPROXY_IVARS \
    __weak id _delegate; \
    Protocol *_protocol; \
    std::unordered_map<SEL,id> _signatures; \
    std::unordered_set<SEL> _delegateSelectors; \
    dispatch_block_t _onDeallocBlock;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
#define FED_USE_IOS5_CLASS_REPLACEMENT_HACK 1
@interface FEDProxy_IOS5 : NSObject
@end
@implementation FEDProxy_IOS5{
    FEDPROXY_IVARS
}
+(void)initialize{
    unsigned int count;
    Method *objCMethods = class_copyMethodList([FEDProxy class], &count);
    NSMutableArray *methods = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++){
        [methods addObject: [RTMethod methodWithObjCMethod: objCMethods[i]]];
    }
    free(objCMethods);
    for (RTMethod *method in methods) {
        [self rt_addMethod:method];
    }
}
@end
#endif

@implementation FEDProxy{
    FEDPROXY_IVARS
}

#pragma mark - Init
+(Class)proxyClass{
#ifdef FED_USE_IOS5_CLASS_REPLACEMENT_HACK
    static Class proxyClass;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // On iOS5 we need to check if proxy is compatible with weak references.
        // If no then our proxy will be inherited from NSObject instead of NSProxy.
        // See bug in iOS 5: http://stackoverflow.com/questions/13800136/nsproxy-weak-reference-bug-under-arc-on-ios-5
        id proxy = [NSProxy alloc];
        __weak id weakProxy = proxy;
        id strongProxy = weakProxy;
        if (strongProxy) {
            proxyClass = self;
        }else{
            proxyClass = [FEDProxy_IOS5 class];
        }
    });
    return proxyClass;
#else
    return self;
#endif
}

+(id)proxyWithDelegate:(id)delegate protocol:(Protocol *)protocol{
    return [self proxyWithDelegate:delegate protocol:protocol retainedByDelegate:NO];
}

+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
    retainedByDelegate:(BOOL)retained
{
    return [self proxyWithDelegate:delegate
                          protocol:protocol
                retainedByDelegate:retained
                         onDealloc:nil];
}

+(id)proxyWithDelegate:(id)delegate
              protocol:(Protocol *)protocol
    retainedByDelegate:(BOOL)retained
             onDealloc:(dispatch_block_t)block
{
    FEDProxy *proxy = [[self proxyClass] alloc];
#ifdef FED_USE_IOS5_CLASS_REPLACEMENT_HACK
    if ([self proxyClass] == [FEDProxy_IOS5 class]) {
        proxy = [(id)proxy init];
    }
#endif
    [proxy fed_initWithDelegate:delegate
                       protocol:protocol
             retainedByDelegate:retained
                      onDealloc:block];
    return proxy;
}

-(id)fed_initWithDelegate:(id)delegate
                 protocol:(Protocol *)objcProtocol
       retainedByDelegate:(BOOL)retained
                onDealloc:(dispatch_block_t)block
{
    _delegate = delegate;
    _protocol = objcProtocol;
    
    [self fed_prepareSelectorsCache];
    
    if (retained) {
        static char key;
        objc_setAssociatedObject(delegate, &key, self, OBJC_ASSOCIATION_RETAIN);
    }
    
    _onDeallocBlock = block;
    
    return self;
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
        const char *types = [method.signature
                             cStringUsingEncoding:NSUTF8StringEncoding];
        _signatures[method.selector] = [NSMethodSignature signatureWithObjCTypes:types];
    }    
}

-(void)dealloc{
    if (_onDeallocBlock) _onDeallocBlock();
}

#pragma mark - Forwarding
-(id)forwardingTargetForSelector:(SEL)selector{
    std::unordered_set<SEL>::const_iterator pair = _delegateSelectors.find(selector);
    if (pair != _delegateSelectors.end()) {
        id strongDelegate = _delegate;
        if (strongDelegate) {
            return strongDelegate;
        }
    }
    return nil;
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    std::unordered_map<SEL,id>::const_iterator pair = _signatures.find(selector);
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
    std::unordered_set<SEL>::const_iterator pair = _delegateSelectors.find(selector);
    if (pair != _delegateSelectors.end()) {
        return YES;
    }
    return NO;
}

@end
