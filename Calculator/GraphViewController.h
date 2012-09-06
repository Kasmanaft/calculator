//
//  GraphViewController.h
//  Calculator
//
//  Created by Leonid Sobolievskyi on 8/28/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (nonatomic, strong) CalculatorBrain *brain;

@end
