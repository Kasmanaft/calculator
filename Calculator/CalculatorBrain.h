//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Leonid Sobolievskyi on 6/14/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorBrain : NSObject
-(void)pushOperand:(double)operand;
-(double)performOperation:(NSString *)operation;
-(void)clearStack;

@property (readonly) id program;

+(double)runProgram:(id)program;
//+(NSString *)descriptionOfProgram:(id) program;

@end
