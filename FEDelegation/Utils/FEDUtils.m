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
    NSArray *methods = [self instanceMethodsInProtocol:objcProtocol withAdopted:YES];
    for (RTMethod *method in methods) {
        if (method.selector == selector){
            return [NSMethodSignature
                    signatureWithObjCTypes:[method.signature
                                            cStringUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    return nil;
}

+(NSArray*)instanceMethodsInProtocol:(Protocol*)objcProtocol withAdopted:(BOOL)adopted{
    RTProtocol *protocol = [RTProtocol protocolWithObjCProtocol:objcProtocol];
    NSMutableArray *protocols = [NSMutableArray arrayWithObject:protocol];
    if (adopted) {
        [protocols addObjectsFromArray:[protocol incorporatedProtocols]];
    }
    NSMutableArray *methods = [NSMutableArray array];
    for (RTProtocol *protocol in protocols) {
        [methods addObjectsFromArray:[protocol methodsRequired:NO instance:YES]];
        [methods addObjectsFromArray:[protocol methodsRequired:YES instance:YES]];
    }
    return methods;
}


@end
