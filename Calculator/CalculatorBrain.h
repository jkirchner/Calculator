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
- (void)pushVariable:(NSString *)variable;
- (double)performOperation:(NSString *)operation;
- (void)clearProgramStack;
- (void)removeTopOfProgram;

@property (readonly) id program;

+ (id)runProgram:(id)program;
+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSString *)descriptionOfProgram:(id)program;
+ (NSSet *)variablesUsedInProgram:(id)program;

+ (NSSet *)operations;
+ (NSSet *)twoOperandOperations;
+ (NSSet *)oneOperandOperations;
@end
