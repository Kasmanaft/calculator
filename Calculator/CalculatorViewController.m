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
@property (nonatomic, strong) NSMutableDictionary *variablesDictionary;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize variablesUsedInProgram = _variablesUsedInProgram;
@synthesize history = _history;
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

-(NSDictionary *)variablesDictionary {
    // lazily instantiate
    if(!_variablesDictionary) _variablesDictionary=[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:M_PI], @"π", [NSNumber numberWithDouble:M_E], @"e", nil];
    return _variablesDictionary;
}

// programStack changes observer

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    self.history.text=[CalculatorBrain descriptionOfProgram:self.brain.program];
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
        //if([self.history.text hasSuffix:@" ="])
        //    self.history.text=[self.history.text substringToIndex:(self.history.text.length-2)];
        if([digit isEqualToString:@"."]) digit=@"0.";
        self.display.text=digit;
        self.userIsInTheMiddleOfEnteringANumber=YES;
    }

}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text=@"0";
    //self.history.text=@"";
    [self.brain clearStack];
    [self clearVariablesDictionary]; // Not sure
    [self updateVariablesUsedInProgram];
}

- (IBAction)backspacePressed {
    NSUInteger displayLength=self.display.text.length;
    if(displayLength>2 || (![self.display.text hasPrefix:@"-"] && displayLength==2))
        self.display.text=[self.display.text substringToIndex:(displayLength-1)];
    else
        self.display.text=@"0";
    //Will be used for 'Undo' buttons
    [self updateVariablesUsedInProgram];
}

- (IBAction)enterPressed {
    //if([self.history.text hasSuffix:@" ="])
    //    self.history.text=[self.history.text substringToIndex:(self.history.text.length-2)];
    //self.history.text=[self.history.text stringByAppendingFormat:@" %@", self.display.text ];
    [self.brain pushOperand:self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)testSetPressed:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Test 2"]) {
        [self.variablesDictionary setDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithDouble:3], @"a", [NSNumber numberWithDouble:4], @"b", [NSNumber numberWithDouble:-4], @"x", nil]];
    } else if ([sender.currentTitle isEqualToString:@"Test 3"]) {
        [self.variablesDictionary setDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithDouble:1], @"a", [NSNumber numberWithDouble:2], @"b", [NSNumber numberWithDouble:3], @"x", nil]];
    } else {
        [self clearVariablesDictionary];
    }
    [self updateVariablesUsedInProgram];
    
    // Don't re-calculate if variables on display
    if(![CalculatorBrain isVariable:self.display.text]){
        double result=[CalculatorBrain runProgram:self.brain.program usingVariableValues:[self.variablesDictionary copy]];
        self.display.text = [NSString stringWithFormat:@"%g", result];
    }
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
        //else if ([self.history.text hasSuffix:@" ="])
        //    self.history.text=[self.history.text substringToIndex:(self.history.text.length-2)];
        //self.history.text=[self.history.text stringByAppendingFormat:@" %@ =", sender.currentTitle ];
        double result = [self.brain performOperation:sender.currentTitle];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        [self updateVariablesUsedInProgram];
    }
}

// Private

-(void)clearVariablesDictionary{
    [self.variablesDictionary removeObjectsForKeys:[NSArray arrayWithObjects:@"a", @"b", @"x", nil]];
}

-(void)updateVariablesUsedInProgram {
    NSSet *usedVariables = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    NSString *result = [[NSString alloc] init];
    NSEnumerator *enumerator = [usedVariables objectEnumerator];
    id object;
    
    while ((object = [enumerator nextObject])) {
        result = [result stringByAppendingFormat:@" %@=%g", object, [[self.variablesDictionary objectForKey:object] doubleValue] ];
    }
    self.variablesUsedInProgram.text = result;
}

@end
