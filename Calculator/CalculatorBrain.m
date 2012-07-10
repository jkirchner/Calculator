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

- (void)clearProgramStack
{
    if (self.operandStack) {
        [self.operandStack removeAllObjects];
    }
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.operandStack addObject:operandObject];
}

- (void)removeTopOfProgram
{
    if (self.operandStack) [self.operandStack removeLastObject];
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
    id result = [[self class] runProgram:self.operandStack];
    if ([result isKindOfClass:[NSNumber class]]) {
        return [result doubleValue];
    } else {
        return 0;
    }
}

+ (id)popOperandOffProgramStack:(NSMutableArray *)stack error:(NSError **)error
{
    double result = 0;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];

    if (!topOfStack) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Insufficient operands" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"popOperandOffProgramStack" code:100 userInfo:errorDetail];
    }

    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [[self popOperandOffProgramStack:stack error:error] doubleValue] + [[self popOperandOffProgramStack:stack error:error] doubleValue];
        } else if ([operation isEqualToString:@"-"]) {
            double subtractor = [[self popOperandOffProgramStack:stack error:error] doubleValue];
            result = [[self popOperandOffProgramStack:stack error:error] doubleValue] - subtractor;
        } else if ([operation isEqualToString:@"*"]) {
            result = [[self popOperandOffProgramStack:stack error:error] doubleValue] * [[self popOperandOffProgramStack:stack error:error] doubleValue];
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [[self popOperandOffProgramStack:stack error:error] doubleValue];
            if (divisor) 
                result = [[self popOperandOffProgramStack:stack error:error] doubleValue] / divisor;
            else {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:@"Div/0" forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"popOperandOffProgramStack" code:200 userInfo:errorDetail];
            }
        } else if ([operation isEqualToString:@"Sin"]) {
            result = sin([[self popOperandOffProgramStack:stack error:error] doubleValue]);
        } else if ([operation isEqualToString:@"Cos"]) {
            result = cos([[self popOperandOffProgramStack:stack error:error] doubleValue]);
        } else if ([operation isEqualToString:@"√"]) {
            double operand = [[self popOperandOffProgramStack:stack error:error] doubleValue];
            if (operand > 0) 
                result = sqrt(operand);
            else {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                [errorDetail setValue:[NSString stringWithFormat:@"√(%g)", operand] forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"popOperandOffProgramStack" code:300 userInfo:errorDetail];
            }
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
    }

    return [NSNumber numberWithDouble:result];
}

+ (id)runProgram:(id)program
{
    NSError *error = nil;
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) 
        stack = [program mutableCopy];
    
    id result = [self popOperandOffProgramStack:stack error:&error];
    if (error) {
//        NSLog(@"%@", error.userInfo);
        return [NSString stringWithFormat:@"Err: %@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]];
    }
        
    return result;
}

+ (id)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
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
    
    return [self runProgram:stack];
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    NSString *description = @"0";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]])
        description = [topOfStack stringValue];
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([self isOperation:topOfStack]) {
            BOOL nextOperatationIsAddOrSubtract = [self nextOperationIsAddOrSubtract:stack];
            // check if the operation is a 2-input, 1-input, or no input operation and display correctly
            if ([[self twoOperandOperations] containsObject:topOfStack]) {
                NSString *secondOperand = [self descriptionOfTopOfStack:stack];
                NSString *firstOperand = [self descriptionOfTopOfStack:stack];
                
                description = [NSString stringWithFormat:@"(%@ %@ %@)", firstOperand, topOfStack, secondOperand];
                
                // if current operation is * or / and next operation is + or -, parentheses should be removed around the current description
                if (([topOfStack isEqualToString:@"*"] || [topOfStack isEqualToString:@"/"]) && nextOperatationIsAddOrSubtract)
                    description = [self cleanUpParentheses:description];
            } else if ([[self oneOperandOperations] containsObject:topOfStack]) {
                description = [NSString stringWithFormat:@"%@(%@)", topOfStack, [self cleanUpParentheses:[self descriptionOfTopOfStack:stack]]];
            } else {
                description = topOfStack;
            }
        } else {
            description = topOfStack;
        }
    }
    
    return description;
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSMutableArray *stack;
    NSString *description = @"";
    
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    while (stack.count) {
        description = [description stringByAppendingString:[self descriptionOfTopOfStack:stack]];
        description = [self cleanUpParentheses:description];
        
        if (stack.count)
            description = [description stringByAppendingString:@", "];

    }

    return description;
}

+ (BOOL)nextOperationIsAddOrSubtract:(id)stack
{
    NSMutableArray *programStack;
    if ([stack isKindOfClass:[NSMutableArray class]]) 
        programStack = [stack mutableCopy];
    
    while (programStack.count) {
        id topOfStack = [programStack lastObject];
        if (topOfStack) [programStack removeLastObject];
        
        if ([topOfStack isKindOfClass:[NSString class]]) {
            if ([topOfStack isEqualToString:@"+"] || [topOfStack isEqualToString:@"-"]) {
                return YES;
            } else if ([self isOperation:topOfStack])
                return NO;
        }
    }
    return NO;
}

+ (NSString *)cleanUpParentheses:(NSString *)description
{
    // remove outer parentheses
    if ([description hasPrefix:@"("] && [description hasSuffix:@")"])
        description = [description substringWithRange:NSMakeRange(1, description.length-2)];
    
    return description;
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    NSMutableSet *variables = [[NSMutableSet alloc] init];
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    while (topOfStack) {
        if ([topOfStack isKindOfClass:[NSString class]]) {
            if (![self isOperation:topOfStack]) {
                [variables addObject:topOfStack];
            }
        }
        
        topOfStack = [stack lastObject];
        if (topOfStack) [stack removeLastObject];
    }
    
    if ([variables count] == 0)
        return nil;
    else 
        return [variables copy];
}

+ (BOOL)isOperation:(NSString *)operation
{
    return [[[self class] operations] containsObject:operation];
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation
{
    return [[[self class] twoOperandOperations] containsObject:operation];
}

+ (BOOL)isOneOperandOperation:(NSString *)operation
{
    return [[[self class] oneOperandOperations] containsObject:operation];
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
