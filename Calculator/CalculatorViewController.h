//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Leonid Sobolievskyi on 6/13/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *history;
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *variablesUsedInProgram;

//@property (nonatomic, strong) NSDictionary *variablesDictionary;

@end
