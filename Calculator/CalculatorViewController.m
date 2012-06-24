//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Jason Kirchner on 6/23/12.
//  Copyright (c) 2012 Zen Motion Studio. All rights reserved.
//

#import "CalculatorViewController.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@end

@implementation CalculatorViewController
@synthesize display = _display;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;

- (IBAction)digitPressed:(UIButton *)sender 
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:[sender currentTitle]];
    } else {
        self.display.text = sender.currentTitle;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}

- (IBAction)operationPressed:(UIButton *)sender 
{
    // operation pressed code
}

- (IBAction)enterPressed 
{
    // enter is pressed code
}

- (void)viewDidUnload {
    [self setDisplay:nil];
    [super viewDidUnload];
}
@end
