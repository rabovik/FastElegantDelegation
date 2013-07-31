//
//  FEDUtils.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDRuntime.h"
#import "RTMethod.h"
#import "RTProtocol.h"
#import "RTProperty.h"
#import "MARTNSObject.h"
#import "MAObjCRuntime+FEDAdditions.h"

#if !__has_feature(objc_arc)
#error This code needs ARC. Use compiler option -fobjc-arc
#endif

@implementation FEDRuntime

+(Protocol *)protocolFromProperty:(NSString *)propertyName object:(id)object{
    RTProperty *property = [[object class] rt_propertyForName:propertyName];
    NSArray *protocols = property.typeProtocols;
    switch (protocols.count) {
        case 0:
            @throw [NSException
                    exceptionWithName:@"FEDRuntimeException"
                    reason:[NSString stringWithFormat:
                            @"Can not fetch protocol from property %@ of class %@",
                            propertyName,
                            NSStringFromClass([object class])]
                    userInfo:nil];
            break;
        case 1:
            break;
        default:
            @throw [NSException
                    exceptionWithName:@"FEDRuntimeException"
                    reason:[NSString stringWithFormat:
                            @"There are more than one protocol specified in property %@ of class %@",
                            propertyName,
                            NSStringFromClass([object class])]
                    userInfo:nil];
            break;
    }
    return [[protocols lastObject] objCProtocol];
}

+(BOOL)propertyIsWeak:(NSString *)propertyName object:(id)object{
    RTProperty *property = [[object class] rt_propertyForName:propertyName];
    return (RTPropertySetterSemanticsAssign == property.setterSemantics);
}

+(void)associateRetainedObject:(id)object toObject:(id)target withKey:(void *)key{
    objc_setAssociatedObject(target, key, object, OBJC_ASSOCIATION_RETAIN);
}

+(id)associatedObjectFromTarget:(id)target withKey:(void *)key{
    return objc_getAssociatedObject(target, key);
}



#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
+(BOOL)proxyIsWeakCompatible{
    static BOOL compatible;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // On iOS5 we need to check if proxy is compatible with weak references.
        // If no then our proxy will be inherited from NSObject instead of NSProxy.
        // See bug in iOS 5: http://stackoverflow.com/questions/13800136/nsproxy-weak-reference-bug-under-arc-on-ios-5
        id proxy = [NSProxy alloc];
        __weak id weakProxy = proxy;
        id strongProxy = weakProxy;
        compatible = (nil != weakProxy && nil != strongProxy);
    });
    return compatible;
}

+(void)replicateMethodsFromClass:(Class)fromClass toClass:(Class)toClass{
    unsigned int count;
    Method *objCMethods = class_copyMethodList(fromClass, &count);
    NSMutableArray *methods = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++){
        [methods addObject: [RTMethod methodWithObjCMethod: objCMethods[i]]];
    }
    free(objCMethods);
    for (RTMethod *method in methods) {
        [toClass rt_addMethod:method];
    }
}
#endif

@end
