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

- (NSSet *)recursivelyIncorporatedProtocols
{
    NSArray *incorporatedProtocols = [self incorporatedProtocols];
    NSMutableSet *protocols = [NSMutableSet setWithArray:incorporatedProtocols];
    for (RTProtocol *protocol in incorporatedProtocols) {
        [protocols unionSet:[protocol recursivelyIncorporatedProtocols]];
    }
    return protocols;
}

@end
