//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Leonid Sobolievskyi on 6/14/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import "CalculatorBrain.h"
//#import <math.h>

@interface CalculatorBrain()

// contains all operations and operands ever sent to this instance
// operands are NSNumbers, operations are NSStrings
@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize variablesDictionary = _variablesDictionary;

- (NSMutableArray *)programStack {
    // lazily instantiate
    if (!_programStack) _programStack=[[NSMutableArray alloc] init];
    return _programStack;
}

// we must return some object (of any class) that represents
//  all the operands and operations performed on this instance
//  so that it can be played back via runProgram:
// we'll simply return an immutable copy of our internal data structure
-(id)program{
    return [self.programStack copy];
}

+(NSSet *)possibleVariables{
    return [NSSet setWithObjects:@"a", @"b", @"x", @"π", @"e", nil];
}

// just pushes the operand onto our stack internal data structure
- (void)pushOperand:(double)operand {
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

// just pushes the operation onto our stack internal data structure
- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    //return [CalculatorBrain runProgram:self.program];
    return [CalculatorBrain runProgram:self.program usingVariableValues:[self.variablesDictionary copy]];
}

+(NSString *)descriptionOfProgram:(id)program{
    return @"Implement this in assigment #2";
}

// if the top thing on the passed stack is an operand, return it
// if the top thing on the passed stack is an operation, evaluate it (recursively)
// does not crash (but returns 0) if stack contains objects other than NSNumber or NSString
+(double)popOperandOffStack:(NSMutableArray *)stack{
    double result=0;
    
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]]) {
        return [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if ([@"-" isEqualToString:operation]) {
            result = - [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"/" isEqualToString:operation]) {
            double divisor=[self popOperandOffStack:stack];
            if (divisor)
                result = [self popOperandOffStack:stack] / divisor;
            else
                result=0;
        } else if ([@"sin" isEqualToString:operation]) {
            result=sin([self popOperandOffStack:stack]);
        } else if ([@"cos" isEqualToString:operation]) {
            result=cos([self popOperandOffStack:stack]);
        } else if ([@"sqrt" isEqualToString:operation]) {
            result=sqrt([self popOperandOffStack:stack]);
        } else if ([@"log" isEqualToString:operation]) {
            result=log([self popOperandOffStack:stack]);
        }
    }
    return result;
}

// checks to be sure passed program is actually an array
//  then evaluates it by calling popOperandOffProgramStack:
// assumes popOperandOffProgramStack: protects against junk array contents
+(double)runProgram:(id)program{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+(double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    if([variableValues isKindOfClass:[NSMutableDictionary class]]){
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSEnumerator *enumerator = [program objectEnumerator];
        id object;
        
        while ((object = [enumerator nextObject])) {
            if ([object isKindOfClass:[NSString class]] && [[self possibleVariables] member:object]) {
                [result addObject:[NSNumber numberWithDouble:[[variableValues objectForKey:object] doubleValue]]];
            }else
                [result addObject:object]; 
        }
        return [self runProgram:result];
    }else{
        return [self runProgram:program];
    }
}

+(NSSet *)variablesUsedInProgram:(id) program{
    NSMutableSet *result = [[NSMutableSet alloc] init];
    NSEnumerator *enumerator = [program objectEnumerator];
    NSSet *possibleVariables = [NSSet setWithObjects:@"a", @"b", @"x", nil];
    id object;
    
    while ((object = [enumerator nextObject])) {
        if ([object isKindOfClass:[NSString class]] && [possibleVariables member:object]) {
            [result addObject:object];
        }
    }
    return result;
}

-(void)clearStack {
    [self.programStack removeAllObjects];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"stack = %@", self.programStack];
}

@end
