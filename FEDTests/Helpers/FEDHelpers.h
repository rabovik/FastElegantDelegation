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
-(int)parentOptionalMethodReturns42;
@end

@protocol FEDExampleProtocol <FEDParentProtocol>
-(void)requiredMethod;
-(int)requiredMethodReturns13;
@optional
-(void)methodWithArgument:(id)arg;
-(void)methodWithFloat:(float)floatArg;
-(NSString *)optionalNotImplementedMethodReturnsString;
-(int)optionalNotImplementedMethodReturnsInt;
-(BOOL)optionalNotImplementedMethodReturnsBOOL;
@end

@protocol FEDExampleProtocolWithNotExistentMethods <NSObject>
-(void)requiredNotImplementedMethod;
@optional
-(void)optionalNotImplementedMethod;
@end

@interface FEDExampleDelegate : NSObject<FEDExampleProtocol>
@end

@interface FEDExampleDelegator : NSObject
-(int)parentOptionalMethodReturns42;
@property (nonatomic,weak) id<FEDExampleProtocol> delegate;
@property (nonatomic,strong) id<FEDExampleProtocol> strongDelegate;
@end

@protocol FEDExamplePersonProtocol<NSObject>
-(NSString *)name;
-(NSUInteger)age;
@end

@interface FEDExamplePerson : NSObject<FEDExamplePersonProtocol>
+(id)personWithName:(NSString *)name age:(NSUInteger)age;
@end

@interface FEDExampleMultiDelegator : NSObject
-(void)addDelegate:(id<FEDExamplePersonProtocol>)person;
-(void)removeDelegate:(id<FEDExamplePersonProtocol>)person;
-(NSArray *)names;
-(NSUInteger)maxAge;
@end

@protocol FEDExampleFlattenProtocol <NSObject>
@optional
-(NSSet *)sampleSet;
-(NSArray *)sampleArray;
@end

@interface FEDExampleFlattenSetDelegate : NSObject<FEDExampleFlattenProtocol>
@end
@interface FEDExampleFlattenArrayDelegate : NSObject<FEDExampleFlattenProtocol>
@end