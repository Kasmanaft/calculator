//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Leonid Sobolievskyi on 6/14/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import "CalculatorBrain.h"
#import <math.h>

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack {
    if (!_programStack) _programStack=[[NSMutableArray alloc] init];
    return _programStack;
}

-(id)program{
    return [self.programStack copy];
}

- (void)pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}


- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

+(NSString *)descriptionOfProgram:(id)program{
    return @"Implement this in assigment #2";
}

+(double)popOperandOffStack:(NSMutableArray *)stack{
    double result=0;
    // pop operand off the stack
    // if operation, need to recursive evaluate
    return result;
}

+(double)runProgram:(id)program{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

/*
    double result = 0;
    if ([operation isEqualToString:@"+"]) {
        result = self.popOperand + self.popOperand;
    } else if ([@"*" isEqualToString:operation]) {
        result = self.popOperand * self.popOperand;
    } else if ([@"-" isEqualToString:operation]) {
        result = - self.popOperand + self.popOperand;
    } else if ([@"/" isEqualToString:operation]) {
        double divisor=self.popOperand;
        if (divisor)
            result = self.popOperand / divisor;
        else
            result=0;
    } else if ([@"sin" isEqualToString:operation]) {
        result=sin(self.popOperand);
    } else if ([@"cos" isEqualToString:operation]) {
        result=cos(self.popOperand);
    } else if ([@"sqrt" isEqualToString:operation]) {
        result=sqrt(self.popOperand);
    } else if ([@"log" isEqualToString:operation]) {
        result=log(self.popOperand);
    } else if ([@"π" isEqualToString:operation]) {
        result=M_PI;
    } else if ([@"e" isEqualToString:operation]) {
        result=M_E;
    }
    
    [self pushOperand:result];
    
    return result;
}
*/

-(void)clearStack {
    [self.programStack removeAllObjects];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"stack = %@", self.programStack];
}

@end
