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

- (void)pushOperand:(double)operand
{
    
}

- (double)performOperation:(NSString *)operation
{
    double result = 0;
    
    return result;
}

@end
