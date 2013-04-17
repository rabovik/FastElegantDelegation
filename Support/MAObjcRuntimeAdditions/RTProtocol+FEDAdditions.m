//
//  RTProtocol+FEDAdditions.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "RTProtocol+FEDAdditions.h"
#import "RTMethod.h"

@interface RTProtocol()
- (Protocol *)objCProtocol;
@end

@implementation RTProtocol (FEDAdditions)

- (NSSet *)recursivelyIncorporatedProtocols
{
    NSArray *incorporatedProtocols = [self incorporatedProtocols];
    NSMutableSet *protocols = [NSMutableSet setWithArray:incorporatedProtocols];
    for (RTProtocol *protocol in incorporatedProtocols)
    {
        [protocols unionSet:[protocol recursivelyIncorporatedProtocols]];
    }
    return protocols;
}

- (NSArray *)methodsRequired: (BOOL)isRequiredMethod
                    instance: (BOOL)isInstanceMethod
                incorporated: (BOOL)recursivelyIncludeIncorporated
{
    NSMutableSet *protocols = [NSMutableSet setWithObject:self];
    if (recursivelyIncludeIncorporated) {
        [protocols unionSet:[self recursivelyIncorporatedProtocols]];
    }
    NSMutableSet *set = [NSMutableSet set];
    for (RTProtocol *protocol in protocols)
    {
        unsigned int count;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList([protocol objCProtocol], isRequiredMethod, isInstanceMethod, &count);
        
        for(unsigned i = 0; i < count; i++)
        {
            NSString *signature = [NSString stringWithCString: methods[i].types encoding: [NSString defaultCStringEncoding]];
            [set addObject: [RTMethod methodWithSelector: methods[i].name implementation: NULL signature: signature]];
        }
        
        free(methods);
    }
    return [set allObjects];
}

@end
