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
@property (nonatomic, strong) NSMutableArray *operandStack;
@end

@implementation CalculatorBrain

@synthesize operandStack = _operandStack;

- (NSMutableArray *)operandStack {
    if (!_operandStack) _operandStack=[[NSMutableArray alloc] init];
    return _operandStack;
}

- (void)pushOperand:(double)operand {
    [self.operandStack addObject:[NSNumber numberWithDouble:operand]];
}

- (double)popOperand {
    NSNumber *operandObject = self.operandStack.lastObject;
    if (operandObject) [self.operandStack removeLastObject];
    return operandObject.doubleValue;
}

- (double)performOperation:(NSString *)operation {
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


-(void)clearStack {
    [self.operandStack removeAllObjects];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"stack = %@", self.operandStack];
}

@end
