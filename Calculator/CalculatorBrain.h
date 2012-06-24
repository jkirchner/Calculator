//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Jason Kirchner on 6/23/12.
//  Copyright (c) 2012 Zen Motion Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;

@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariables:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

+ (NSSet *)operations;
+ (NSSet *)twoOperandOperations;
+ (NSSet *)oneOperandOperations;
@end
