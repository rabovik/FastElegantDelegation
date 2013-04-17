//
//  RTProtocol+FEDAdditions.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "RTProtocol+FEDAdditions.h"

@interface RTProtocol()
- (Protocol *)objCProtocol;
@end

@implementation RTProtocol (FEDAdditions)

static NSArray* recursivelyIncorporatedProtocolNamesForObjCProtocol(Protocol *objCProtocol)
{
    unsigned int count;
    Protocol **protocols = protocol_copyProtocolList(objCProtocol, &count);
    NSMutableArray *array = [NSMutableArray array];
    for(unsigned i = 0; i < count; i++){
        [array addObject:NSStringFromProtocol(protocols[i])];
        [array addObjectsFromArray:recursivelyIncorporatedProtocolNamesForObjCProtocol(protocols[i])];
    }
    free(protocols);
    return array;
}

- (NSArray *)recursivelyIncorporatedProtocols
{
    NSSet *names = [NSSet setWithArray:recursivelyIncorporatedProtocolNamesForObjCProtocol([self objCProtocol])];
    NSMutableArray *protocols = [NSMutableArray arrayWithCapacity:names.count];
    for (NSString *name in names) {
        [protocols addObject:[RTProtocol protocolWithName:name]];
    }
    return protocols;
}

@end
