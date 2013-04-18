//
//  RTProtocol+FEDAdditions.h
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "RTProtocol.h"
#import "RTProperty.h"

@interface RTProtocol (FEDAdditions)

- (NSSet *)recursivelyIncorporatedProtocols;
- (NSArray *)methodsRequired: (BOOL)isRequiredMethod
                    instance: (BOOL)isInstanceMethod
                incorporated: (BOOL)recursivelyIncludeIncorporated;

@end

@interface RTProperty (FEDAdditions)

// Class specified in typeEncoding or nil
- (Class)typeClass;
// Array of RTProtocol instances or an empty array if no protocol specified in typeEncoding
- (NSArray *)typeProtocols;

@end
