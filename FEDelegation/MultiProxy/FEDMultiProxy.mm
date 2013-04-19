//
//  FEDMultiProxy.m
//  FEDelegation
//
//  Created by Yan Rabovik on 19.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDMultiProxy.h"
#import "FEDRuntime.h"
#import <vector>

#define FED_MULTIPROXY_IVARS                                                             \
    Protocol *_protocol;                                                                 \
    dispatch_block_t _onDeallocBlock;                                                    \
    std::vector<__weak id> _delegates;

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
    
    // ... delegates
    for (id delegate in delegates) {
        _delegates.push_back(delegate);
    }
    
    if (retainDelegates) {
        // ...
    }
    
    if (retainedByDelegates) {
        // ...
    }
    
    _onDeallocBlock = [block copy];
}

-(void)dealloc{
    if (_onDeallocBlock) _onDeallocBlock();
}

#pragma mark - Delegates menagement
-(NSArray *)fed_realDelegates{
    NSMutableArray *array = [NSMutableArray array];
    // construct array and clean dead delagates from vector
    _delegates.erase(std::remove_if(_delegates.begin(),
                                    _delegates.end(),
                                    [array](id delegate) -> bool {
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



@end
