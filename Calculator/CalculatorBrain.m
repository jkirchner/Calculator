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

- (void)pushVariable:(NSString *)variable
{
    if ([variable isKindOfClass:[NSString class]]) {
        if (![[self class] isOperation:variable]) 
            [self.operandStack addObject:variable];
    }
}

- (double)performOperation:(NSString *)operation
{
    [self.operandStack addObject:operation];
    return [[self class] runProgram:self.operandStack];
    //return 0;
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
    NSMutableArray *stack;
    NSUInteger index = 0;
    NSNumber *currentVariableValue = [[NSNumber alloc] initWithDouble:0];
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
        NSSet *variablesInProgram = [self variablesUsedInProgram:stack];
        
        for (NSString *variable in variablesInProgram) {
            index = 0;
            currentVariableValue = [variableValues objectForKey:variable];
            if (!currentVariableValue)
                currentVariableValue = [NSNumber numberWithDouble:0];
            for (id operand in [stack copy]) {
                if ([operand isKindOfClass:[NSString class]]) {
                    if (![self isOperation:operand]) {
                        if ([operand isEqualToString:variable]) {
                            [stack replaceObjectAtIndex:index withObject:currentVariableValue];
                        }
                    }
                }
                index ++;
            }
        }
    }
    
    return [[self class] runProgram:stack];
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
    return [[[self class] operations] containsObject:operation];
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
