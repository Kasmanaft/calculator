//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Leonid Sobolievskyi on 6/13/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize history = _history;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    
    NSString *digit = [sender currentTitle];
    NSRange dotInDigit=[self.display.text rangeOfString:@"."];
    
    if(self.userIsInTheMiddleOfEnteringANumber){
        if(![digit isEqualToString:@"."] || dotInDigit.location==NSNotFound){
            if([self.display.text isEqualToString:@"0"] && ![digit isEqualToString:@"."]){
                self.display.text=digit; 
            }else{
                self.display.text=[self.display.text stringByAppendingString:digit];
            }
        }
    } else {
        if([self.history.text hasSuffix:@" ="])
            self.history.text=[self.history.text substringToIndex:(self.history.text.length-2)];
        if([digit isEqualToString:@"."]) digit=@"0.";
        self.display.text=digit;
        self.userIsInTheMiddleOfEnteringANumber=YES;
    }

}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text=@"0";
    self.history.text=@"";
    [self.brain clearStack];
}

- (IBAction)backspacePressed {
    NSUInteger displayLength=self.display.text.length;
    if(displayLength>2 || (![self.display.text hasPrefix:@"-"] && displayLength==2))
        self.display.text=[self.display.text substringToIndex:(displayLength-1)];
    else
        self.display.text=@"0";
}

- (IBAction)enterPressed {
    if([self.history.text hasSuffix:@" ="])
        self.history.text=[self.history.text substringToIndex:(self.history.text.length-2)];
    self.history.text=[self.history.text stringByAppendingFormat:@" %@", self.display.text ];
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"+/-"]) {
        if(![self.display.text isEqualToString:@"0"]){
            self.display.text = [NSString stringWithFormat:@"%g", -[self.display.text doubleValue]];

            if (!self.userIsInTheMiddleOfEnteringANumber)
                [self enterPressed];
        }
        
    } else {
        if (self.userIsInTheMiddleOfEnteringANumber)
            [self enterPressed];
        else if ([self.history.text hasSuffix:@" ="])
            self.history.text=[self.history.text substringToIndex:(self.history.text.length-2)];
        self.history.text=[self.history.text stringByAppendingFormat:@" %@ =", sender.currentTitle ];
        double result = [self.brain performOperation:sender.currentTitle];
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
}

@end
