//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Jason Kirchner on 6/23/12.
//  Copyright (c) 2012 Zen Motion Studio. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)clear 
{
    self.brain = nil;
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)digitPressed:(UIButton *)sender 
{
    if ([sender.currentTitle isEqualToString:@"."]) {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            NSString *display = self.display.text;
            NSRange range = [display rangeOfString:@"."];
            if (!(range.location == NSNotFound)) {
                return;
            }
        } else {
            self.display.text = @"0.";
            self.userIsInTheMiddleOfEnteringANumber = YES;
            return;
        }
        
    }
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:[sender currentTitle]];
    } else {
        self.display.text = sender.currentTitle;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber)
        [self enterPressed];
    
    double result = [self.brain performOperation:[sender currentTitle]];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

@end
