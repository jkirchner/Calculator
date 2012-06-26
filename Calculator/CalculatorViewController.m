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
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize history = _history;
@synthesize variableValues = _variableValues;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)clear 
{
    self.brain = nil;
    self.display.text = @"0";
    self.history.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.testVariableValues = nil;
    [self updateVariableValuesDisplay];
}

- (IBAction)backSpacePressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if (self.display.text.length == 1) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
        else                
            self.display.text = [self.display.text substringToIndex:(self.display.text.length - 1)];
    } else 
        self.display.text = @"0";
}

- (IBAction)chanageSign 
{
    if ([self.display.text doubleValue]) {
        self.display.text = [NSString stringWithFormat:@"%g", ([self.display.text doubleValue]) * -1];
    }
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
        self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    } else {
        self.display.text = sender.currentTitle;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (IBAction)variablePressed:(UIButton *)sender 
{
    [self.brain pushVariable:sender.currentTitle];
    [self runProgram];
}

- (IBAction)changeTestVariableValues:(UIButton *)sender 
{
    if ([sender.currentTitle isEqualToString:@"Test nil"])
        self.testVariableValues = nil;
    else if ([sender.currentTitle isEqualToString:@"Test 1"])
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:10], @"x", [NSNumber numberWithDouble:5], @"a", [NSNumber numberWithDouble:1], @"b", [NSNumber numberWithDouble:20], @"y", nil];
    else if ([sender.currentTitle isEqualToString:@"Test 2"])
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:1], @"x", [NSNumber numberWithDouble:2], @"a", @"*", @"b", nil];
    else if ([sender.currentTitle isEqualToString:@"Test 3"])
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:10], @"x", [NSNumber numberWithDouble:5], @"a", @"*", @"b", nil];

    [self updateVariableValuesDisplay];
}

- (void)updateVariableValuesDisplay
{
    NSString *variableDisplayString = @"";
    NSNumber *variableValue = [NSNumber numberWithDouble:0];

    if (self.testVariableValues) {
        NSSet *variablesUsedInProgram = [CalculatorBrain variablesUsedInProgram:self.brain.program];
        
        for (NSString *variable in variablesUsedInProgram) {
            variableValue = [NSNumber numberWithDouble:0];
            if ([self.testVariableValues objectForKey:variable]) variableValue = [self.testVariableValues objectForKey:variable];
            variableDisplayString = [variableDisplayString stringByAppendingFormat:@"%@ = %@ ", variable, variableValue];
            
        }
    }
    
    self.variableValues.text = variableDisplayString;
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber)
        [self enterPressed];
    
    [self.brain performOperation:sender.currentTitle];
    [self runProgram];
}

- (IBAction)enterPressed 
{
    [self.brain pushOperand:self.display.text.doubleValue];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self runProgram];
}

- (void)runProgram
{
    self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues]];
    self.history.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    [self updateVariableValuesDisplay];
}

- (IBAction)undoPressed 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self backSpacePressed];
        if ([self.display.text isEqualToString:@"0"])
            [self runProgram];
    }
    else {
        [self.brain removeTopOfProgram];
        [self runProgram];
    }
}

- (void)viewDidUnload {
    [self setVariableValues:nil];
    [super viewDidUnload];
}
@end
