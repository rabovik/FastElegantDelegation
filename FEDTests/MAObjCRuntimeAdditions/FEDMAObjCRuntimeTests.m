//
//  FEDMAObjCRuntimeTests.m
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import "FEDMAObjCRuntimeTests.h"
#import "RTProtocol+FEDAdditions.h"

@protocol FEDMARTTestsParentProtocol1 <NSObject>
@end

@protocol FEDMARTTestsParentProtocol2
@end

@protocol FEDMARTTestsProtocol <FEDMARTTestsParentProtocol1,
                                FEDMARTTestsParentProtocol2,
                                NSObject>
@end


@implementation FEDMAObjCRuntimeTests

-(void)testRecursivelyIncorporatedProtocols{
    RTProtocol *protocol = [RTProtocol
                            protocolWithObjCProtocol:@protocol(FEDMARTTestsProtocol)];
    NSArray *adoptedProtocols = [protocol recursivelyIncorporatedProtocols];
    STAssertTrue(3 == adoptedProtocols.count,
                 @"count is %u",
                 adoptedProtocols.count);
    NSMutableSet *adoptedNames = [NSMutableSet set];
    for (RTProtocol *protocol in adoptedProtocols) {
        [adoptedNames addObject:protocol.name];
    }
    NSLog(@"Adopted protocol names\n%@",adoptedNames);
    NSSet *etalonSet = [NSSet setWithObjects:@"FEDMARTTestsParentProtocol1",
                                             @"FEDMARTTestsParentProtocol2",
                                             @"NSObject", nil];
    STAssertTrue([etalonSet isEqualToSet:adoptedNames], @"%@",adoptedNames);
}

@end
