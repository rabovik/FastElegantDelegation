//
//  FEDHelpers.h
//  FEDelegation
//
//  Created by Yan Rabovik on 17.04.13.
//  Copyright (c) 2013 Yan Rabovik. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FEDParentProtocol <NSObject>
@optional
-(void)parentOptionalMethod;
@end

@protocol FEDExampleProtocol <FEDParentProtocol>
-(void)requiredMethod;
@optional
-(void)methodWithArgument:(id)arg;
-(void)methodWithFloat:(float)floatArg;
@end

@interface FEDExampleDelegate : NSObject<FEDExampleProtocol>
@end

@interface FEDExampleDelegator : NSObject
-(void)requiredMethod;
-(void)methodWithArgument:(id)arg;
@property (nonatomic,weak) id<FEDExampleProtocol> delegate;
@end