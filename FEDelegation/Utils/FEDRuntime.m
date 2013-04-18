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


@end
