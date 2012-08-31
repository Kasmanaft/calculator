//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Leonid Sobolievskyi on 6/13/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSMutableDictionary *variablesDictionary;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize variablesUsedInProgram = _variablesUsedInProgram;
@synthesize descriptionOfProgram = _descriptionOfProgram;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize variablesDictionary = _variablesDictionary;

// Getters & Setters

- (CalculatorBrain *)brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
        _brain.variablesDictionary=self.variablesDictionary;
        [_brain addObserver:self forKeyPath:@"programStack" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _brain;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController respondsToSelector:@selector(setBrain:)]) {
        if ([segue.identifier isEqualToString:@"graphSegue"]) {
            [segue.destinationViewController setBrain:self.brain];
        }
    }
}

-(NSDictionary *)variablesDictionary {
    // lazily instantiate
    if(!_variablesDictionary) _variablesDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:M_PI], @"π", [NSNumber numberWithDouble:M_E], @"e", nil];
    return _variablesDictionary;
}

// programStack changes observer

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    self.descriptionOfProgram.text=[CalculatorBrain descriptionOfProgram:self.brain.program];
}

// Buttons

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
        if([digit isEqualToString:@"."]) digit=@"0.";
        self.display.text=digit;
        self.userIsInTheMiddleOfEnteringANumber=YES;
    }

}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text=@"0";
    [self.brain clearStack];
}

- (IBAction)backspacePressed {
    if (self.userIsInTheMiddleOfEnteringANumber){
        NSUInteger displayLength=self.display.text.length;
        if(displayLength>2 || (![self.display.text hasPrefix:@"-"] && displayLength==2))
            self.display.text=[self.display.text substringToIndex:(displayLength-1)];
        else
            self.display.text=@"0";
    }else{
        self.display.text=[self.brain popOperandOffProgramStack];
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}


- (IBAction)operationPressed:(UIButton *)sender {
    if([CalculatorBrain isVariable:sender.currentTitle]){
        if (self.userIsInTheMiddleOfEnteringANumber)
            [self enterPressed];
        self.display.text=sender.currentTitle;
        [self enterPressed];
    } else if ([sender.currentTitle isEqualToString:@"+/-"]) {
        if(![self.display.text isEqualToString:@"0"]){
            self.display.text = [NSString stringWithFormat:@"%g", -[self.display.text doubleValue]];

            if (!self.userIsInTheMiddleOfEnteringANumber)
                [self enterPressed];
        }
    } else {
        if (self.userIsInTheMiddleOfEnteringANumber)
            [self enterPressed];
        double result = [self.brain performOperation:sender.currentTitle];
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
}


@end
