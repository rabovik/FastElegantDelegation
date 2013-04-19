//
//  RTProtocol+FEDAdditions.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "MAObjCRuntime+FEDAdditions.h"
#import "RTMethod.h"

#if __has_feature(objc_arc)
#error This code needs ARC disabled. Use compiler option -fno-objc-arc
#endif

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

@implementation RTProperty (FEDAdditions)

- (Class)typeClass
{
    NSString *typeEncoding = [self typeEncoding];
    NSLog(@"%@",typeEncoding);
    if (![typeEncoding hasPrefix:@"@"])
        return nil;
    NSRange quoteStart = [typeEncoding rangeOfString:@"\""];
    if (NSNotFound == quoteStart.location)
        return nil;
    NSUInteger classStart = quoteStart.location + 1;
    NSRange protocolsStart = [typeEncoding rangeOfString:@"<"];
    NSUInteger classEnd;
    if (NSNotFound != protocolsStart.location)
    {
        classEnd = protocolsStart.location-1;
    }else{
        classEnd = [typeEncoding rangeOfString:@"\"" options:NSBackwardsSearch].location - 1;
    }
    NSString *className = [typeEncoding substringWithRange:NSMakeRange(classStart, 1+classEnd-classStart)];
    return NSClassFromString(className);
}

- (NSArray *)typeProtocols
{
    NSString *typeEncoding = [self typeEncoding];
    if (![typeEncoding hasPrefix:@"@"])
        return [NSArray array];
    NSRange parenthesisStart = [typeEncoding rangeOfString:@"<"];
    NSRange parenthesisEnd = [typeEncoding rangeOfString:@">" options:NSBackwardsSearch];
    if (NSNotFound == parenthesisStart.location || NSNotFound == parenthesisEnd.location)
        return [NSArray array];
    NSString *protocolsString = [typeEncoding substringWithRange:NSMakeRange(parenthesisStart.location+1, parenthesisEnd.location-parenthesisStart.location-1)];
    NSMutableArray *protocols = [NSMutableArray array];
    for (NSString *name in [protocolsString componentsSeparatedByString:@"><"]) {
        [protocols addObject:[RTProtocol protocolWithName:name]];
    }
    return protocols;
}

@end
