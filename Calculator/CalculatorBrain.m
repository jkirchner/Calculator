//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Jason Kirchner on 6/23/12.
//  Copyright (c) 2012 Zen Motion Studio. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;
@synthesize program = _program;

- (NSMutableArray *)operandStack
{
    if (!_operandStack)
        _operandStack = [[NSMutableArray alloc] init];
    
    return _operandStack;
}

- (id)program
{
    return [self.operandStack copy];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.operandStack addObject:operandObject];
}

- (double)popOperand
{
    NSNumber *operandObject = [self.operandStack lastObject];
    if (operandObject) [self.operandStack removeLastObject];
    return operandObject.doubleValue;
}

- (double)performOperation:(NSString *)operation
{
    double result = 0;
    
    if ([operation isEqualToString:@"+"]) {
        result = [self popOperand] + [self popOperand];
    } else if ([operation isEqualToString:@"-"]) {
        double subtractor = [self popOperand];
        result = [self popOperand] - subtractor;
    } else if ([operation isEqualToString:@"*"]) {
        result = [self popOperand] * [self popOperand];
    } else if ([operation isEqualToString:@"/"]) {
        double divisor = [self popOperand];
        if (divisor) result = [self popOperand] / divisor;
    } else if ([operation isEqualToString:@"Sin"]) {
        result = sin([self popOperand]);
    } else if ([operation isEqualToString:@"Cos"]) {
        result = cos([self popOperand]);
    } else if ([operation isEqualToString:@"√"]) {
        double operand = [self popOperand];
        if (operand > 0) result = sqrt(operand);
    } else if ([operation isEqualToString:@"π"]) {
        result = M_PI;
    }
    [self pushOperand:result];
    
    return result;
}

+ (double)runProgram:(id)program
{
    double result = 0;
    
    return result;
}

+ (double)runProgram:(id)program usingVariables:(NSDictionary *)variableValues
{
    double result = 0;
    
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *description = @"";
    
    return description;
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    return nil;
}

+ (BOOL)isOperation:(NSString *)operation
{
    
}
@end
