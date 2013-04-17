//
//  FEDUtils.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDUtils.h"
#import "RTMethod.h"
#import "RTProtocol.h"

@implementation FEDUtils

+(id)methodSignatureForSelector:(SEL)selector fromProtocol:(Protocol *)objcProtocol{
    RTProtocol *protocol = [RTProtocol protocolWithObjCProtocol:objcProtocol];
    NSMutableArray *protocolAndAdopted = [NSMutableArray arrayWithObject:protocol];
    [protocolAndAdopted addObjectsFromArray:[protocol incorporatedProtocols]];
    NSMutableArray *methods = [NSMutableArray array];
    for (RTProtocol *protocol in protocolAndAdopted) {
        [methods addObjectsFromArray:[protocol methodsRequired:NO instance:YES]];
        [methods addObjectsFromArray:[protocol methodsRequired:YES instance:YES]];
    }
    for (RTMethod *method in methods) {
        if (method.selector == selector){
            return [NSMethodSignature
                    signatureWithObjCTypes:[method.signature
                                            cStringUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return nil;
}

@end
