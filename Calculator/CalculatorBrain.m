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
- (void)pushOperand:(NSString *)operand {
    [self willChangeValueForKey:@"programStack"];
    if([CalculatorBrain isVariable:operand])
        [self.programStack addObject:operand];
    else
        [self.programStack addObject:[NSNumber numberWithDouble:[operand doubleValue]]];
    [self didChangeValueForKey:@"programStack"];

}

// just pushes the operation onto our stack internal data structure
- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:[self.variablesDictionary copy]];
}

+(NSString *)descriptionOfProgram:(id)program{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    return [self descriptionOfTopOfStack:stack];
}

+(NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack{
    NSString *operation;
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    
    if([self isDigit:topOfStack]) {
        operation = [topOfStack stringValue];
    } else if ([self isOperation:topOfStack]){
        operation = topOfStack;
        /*
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
        */
    }
    return operation;
}

+(BOOL)isDigit:(id)operand{
    return [operand isKindOfClass:[NSNumber class]];
}

+(BOOL)isOperation:(NSString *)operand{
    return [operand isKindOfClass:[NSString class]] && ![[self possibleVariables] containsObject:operand];
}

+(BOOL)isVariable:(id)operand{
    return [operand isKindOfClass:[NSString class]] && [[self possibleVariables] containsObject:operand];
}

// if the top thing on the passed stack is an operand, return it
// if the top thing on the passed stack is an operation, evaluate it (recursively)
// does not crash (but returns 0) if stack contains objects other than NSNumber or NSString
+(double)popOperandOffStack:(NSMutableArray *)stack{
    double result=0;
    
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    
    if([self isDigit:topOfStack]) {
        return [topOfStack doubleValue];
    } else if ([self isOperation:topOfStack]){
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
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [program objectEnumerator];
    id object;
    // NB! use replaceObjectAtIndex:withObject: instead
    while ((object = [enumerator nextObject])) {
        if ([self isVariable:object]) {
            [result addObject:[NSNumber numberWithDouble:[[variableValues objectForKey:object] doubleValue]]];
        }else
            [result addObject:object]; 
    }
    return [self runProgram:result];
}

+(NSSet *)variablesUsedInProgram:(id) program{
    // Should be nil if no variables used
    NSMutableSet *result = [NSMutableSet setWithArray:program];
    NSSet *possibleVariables = [NSSet setWithObjects:@"a", @"b", @"x", nil];
    if([result intersectsSet:possibleVariables]){
        [result intersectSet:possibleVariables];
        return result;
    }else
        return nil;
}

-(void)clearStack {
    [self willChangeValueForKey:@"programStack"];
    [self.programStack removeAllObjects];
    [self didChangeValueForKey:@"programStack"];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"stack = %@", self.programStack];
}

@end
