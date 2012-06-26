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

- (double)performOperation:(NSString *)operation
{
    double result = 0;
    
    [self pushOperand:result];
    
    return result;
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];

    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtractor = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtractor;
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([operation isEqualToString:@"Sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"Cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"√"]) {
            double operand = [self popOperandOffProgramStack:stack];
            if (operand > 0) result = sqrt(operand);
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
    }

    return result;
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];
    return [self popOperandOffProgramStack:stack];
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
    return NO;
}

+ (NSSet *)operations;
{
    NSSet *allOperations = [NSSet setWithObjects:@"π", nil];
    allOperations = [allOperations setByAddingObjectsFromSet:[self twoOperandOperations]];
    return [allOperations setByAddingObjectsFromSet:[self oneOperandOperations]];
}

+ (NSSet *)twoOperandOperations
{
    return [NSSet setWithObjects:@"+", @"-", @"*", @"/", nil];
}

+ (NSSet *)oneOperandOperations
{
    return [NSSet setWithObjects:@"√", @"Sin", @"Cos", nil];
}
@end
