//
//  GraphView.h
//  Calculator
//
//  Created by Leonid Sobolievskyi on 8/28/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalculatorBrain.h"

@class GraphView;

@protocol GraphViewDataSource

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@property (nonatomic, strong) CalculatorBrain *brain;

-(CGFloat) yForX:(CGFloat)x rect:(CGRect)rect;

@end

@interface GraphView : UIView

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)panning:(UIPanGestureRecognizer *)gesture;
- (void)tapping:(UITapGestureRecognizer *)gesture;

@property (nonatomic, weak) id <GraphViewDataSource> dataSource;

@end
