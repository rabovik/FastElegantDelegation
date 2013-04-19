//
//  FEDMultiProxy.m
//  FEDelegation
//
//  Created by Yan Rabovik on 19.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDMultiProxy.h"
#import "FEDRuntime.h"
#import "RTProtocol.h"
#import "MAObjCRuntime+FEDAdditions.h"
#import "RTMethod.h"
#import <vector>
#import <unordered_map>

#if !__has_feature(objc_arc)
#error This code needs ARC. Use compiler option -fobjc-arc
#endif

#define FED_MULTIPROXY_IVARS                                                             \
    Protocol *_protocol;                                                                 \
    dispatch_block_t _onDeallocBlock;                                                    \
    std::vector<__weak id> _delegates;                                                   \
    NSMutableArray *_strongDelegates;                                                    \
    std::unordered_map<SEL,id> _signatures;                                              \
    NSArray *__strong * _mappedArrayRef;                                                 \
    BOOL _flattenMappedArray;                                                            \
    void(^_mappedBlock)(NSInvocation *);

#pragma mark - IOS 5 HACK -
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
@interface FEDMultiProxy_IOS5 : NSObject
@end
@implementation FEDMultiProxy_IOS5{
    FED_MULTIPROXY_IVARS
}
+(void)initialize{
    [FEDRuntime replicateMethodsFromClass:[FEDMultiProxy class] toClass:self];
}
@end
#endif

#pragma mark - MULTIPROXY -
@implementation FEDMultiProxy{
    FED_MULTIPROXY_IVARS
}

#pragma mark - Init
+(Class)proxyClass{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if (![FEDRuntime proxyIsWeakCompatible]) {
        return [FEDMultiProxy_IOS5 class];
    }
#endif
    return self;
}

+(id)proxyWithProtocol:(Protocol *)protocol{
    return [self proxyWithDelegates:nil
                           protocol:protocol
                    retainDelegates:NO
                retainedByDelegates:NO
                          onDealloc:nil];
}


+(id)proxyWithDelegates:(NSArray *)delegates
               protocol:(Protocol *)protocol
    retainedByDelegates:(BOOL)retainedByDelegates
              onDealloc:(dispatch_block_t)block
{
    return [self proxyWithDelegates:delegates
                           protocol:protocol
                    retainDelegates:NO
                retainedByDelegates:retainedByDelegates
                          onDealloc:block];
}

+(id)proxyWithDelegates:(NSArray *)delegates
               protocol:(Protocol *)protocol
        retainDelegates:(BOOL)retainDelegates
{
    return [self proxyWithDelegates:delegates
                           protocol:protocol
                    retainDelegates:retainDelegates
                retainedByDelegates:NO
                          onDealloc:nil];
}

+(id)proxyWithDelegates:(NSArray *)delegates
               protocol:(Protocol *)protocol
        retainDelegates:(BOOL)retainDelegates
    retainedByDelegates:(BOOL)retainedByDelegates
              onDealloc:(dispatch_block_t)block
{
    FEDMultiProxy *proxy = [[self proxyClass] alloc];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    if ([self proxyClass] == [FEDMultiProxy_IOS5 class]) {
        proxy = [(id)proxy init];
    }
#endif
    [proxy fed_initWithDelegates:delegates
                        protocol:protocol
                 retainDelegates:retainDelegates
             retainedByDelegates:retainedByDelegates
                       onDealloc:block];
    return proxy;
}

-(void)fed_initWithDelegates:(NSArray *)delegates
                    protocol:(Protocol *)protocol
             retainDelegates:(BOOL)retainDelegates
         retainedByDelegates:(BOOL)retainedByDelegates
                   onDealloc:(dispatch_block_t)block
{
    _protocol = protocol;
    
    for (id delegate in delegates) {
        _delegates.push_back(delegate);
    }
    
    [self fed_prepareSelectorsCache];
    
    if (retainDelegates) {
        _strongDelegates = [NSMutableArray arrayWithArray:delegates];
    }
    
    if (retainedByDelegates) {
        for (id delegate in delegates) {
            objc_setAssociatedObject(delegate, (__bridge void *)self, self, OBJC_ASSOCIATION_RETAIN);
        }
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
    for (RTMethod *method in allMethods){
        _signatures[method.selector] =
            [NSMethodSignature signatureWithObjCTypes:method.signature.UTF8String];
    }
}


-(void)dealloc{
    if (_onDeallocBlock) _onDeallocBlock();
}

#pragma mark - Delegates management
-(NSArray *)fed_realDelegates{
    NSMutableArray *array = [NSMutableArray array];
    // construct array and clean dead delagates from vector
    _delegates.erase(std::remove_if(_delegates.begin(),
                                    _delegates.end(),
                                    [&array](id delegate) -> bool {
                                        if (nil != delegate) {
                                            [array addObject:delegate];
                                            return false;
                                        }else{
                                            return true;
                                        }
                                    }),
                     _delegates.end());
    return array;
}

-(void)addDelegate:(id)delegate{
    _delegates.push_back(delegate);
    [_strongDelegates addObject:delegate];
}

-(void)removeDelegate:(id)delegate{
    _delegates.erase(std::remove(_delegates.begin(), _delegates.end(), delegate),
                     _delegates.end());
    [_strongDelegates removeObject:delegate];
}

#pragma mark - Forwarding
-(NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    auto pair = _signatures.find(selector);
    if (pair != _signatures.end()) {
        return pair->second;
    }else{
        @throw [NSException
                exceptionWithName:@"FEDMultiProxyException"
                reason:[NSString stringWithFormat:
                        @"No method signature for selector %@ in protocol %@",
                        NSStringFromSelector(selector),
                        NSStringFromProtocol(_protocol)]
                userInfo:nil];
    }
    return nil;
}

-(void)forwardInvocation:(NSInvocation *)invocation{
    const char *returnType = invocation.methodSignature.methodReturnType;
    BOOL voidReturnType = (0 == strncmp("v", returnType, 1));
    BOOL objectReturnType = (0 == strncmp("@", returnType, 1));
    NSMutableArray *mappedArray;
    if (NULL != _mappedArrayRef) {
        if (!objectReturnType) {
            _mappedArrayRef = NULL;
            @throw [NSException
                    exceptionWithName:@"FEDMultiProxyException"
                    reason:[NSString stringWithFormat:
                            @"Can not map to array with return type %s",
                            returnType]
                    userInfo:nil];
        }
        mappedArray = [NSMutableArray array];
    }
    BOOL invoked;
    for (id delegate in self.fed_realDelegates) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
            invoked = YES;
            if (nil != _mappedBlock){
                _mappedBlock(invocation);
                continue;
            }
            if (nil != mappedArray) {
                __unsafe_unretained id result;
                [invocation getReturnValue:&result];
                if (_flattenMappedArray) {
                    if ([result isKindOfClass:[NSArray class]]
                        || [result isKindOfClass:[NSMutableArray class]])
                    {
                        [mappedArray addObjectsFromArray:result];
                        continue;
                    }
                    if ([result isKindOfClass:[NSSet class]]
                        || [result isKindOfClass:[NSMutableSet class]])
                    {
                        [mappedArray addObjectsFromArray:[result allObjects]];
                        continue;
                    }
                }
                [mappedArray addObject:result];
                continue;
            }
            if (!voidReturnType) {
                break;
            }
        }
    }
    if (!invoked) {
        [invocation invokeWithTarget:nil];
    }
    if (NULL != _mappedArrayRef) {
        *_mappedArrayRef = mappedArray;
        _mappedArrayRef = NULL;
    }
    _mappedBlock = nil;
}

-(BOOL)respondsToSelector:(SEL)selector{
    for (id delegate in self.fed_realDelegates) {
        if ([delegate respondsToSelector:selector]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Mapping
-(id)mapToArray:(NSArray *__strong *)arrayRef{
    return [self mapToArray:arrayRef flatten:NO];
}

-(id)mapToArray:(NSArray *__strong *)arrayRef flatten:(BOOL)flatten{
    _mappedArrayRef = arrayRef;
    _flattenMappedArray = flatten;
    return self;
}

-(id)mapToBlock:(void(^)(NSInvocation *invocation))block{
    _mappedBlock = [block copy];
    return self;
}

@end
