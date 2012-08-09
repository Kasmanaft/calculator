//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Leonid Sobolievskyi on 6/14/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

// push operands ...
-(void)pushOperand:(double)operand;
// ... then perform operations on those operands
-(double)performOperation:(NSString *)operation;
-(void)clearStack;

// returns an object of unspecified class which
// represents the sequence of operands and operations
// since last clear
@property (readonly) id program;
@property (nonatomic, weak) NSMutableDictionary *variablesDictionary;

// runs the program (obtained from the program @property of a CalculatorBrain instance)
// if the last thing done in the program was pushOperand:, this returns that operand
// if the last thing done in the program was performOperation:, this evaluates it (recursively)
+(double)runProgram:(id)program;
// And now with variables
+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

// a string representing (to an end user) the passed program
// (programs are obtained from the program @property of a CalculatorBrain instance)
+(NSString *)descriptionOfProgram:(id) program;

+(NSSet *)variablesUsedInProgram:(id) program;

@end
