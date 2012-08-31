//
//  GraphView.m
//  Calculator
//
//  Created by Leonid Sobolievskyi on 8/28/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"
#import "CalculatorBrain.h"

@implementation GraphView

@synthesize dataSource = _dataSource;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



// handler for a pinch gesture
// modifies self.scale by the amount the pinch changes each update

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.dataSource.scale *= gesture.scale;
        gesture.scale = 1;
    }
}

- (void)panning:(UIPanGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        CGPoint newOrigin = self.dataSource.origin;
        newOrigin.y += translation.y;
        newOrigin.x += translation.x;
        self.dataSource.origin = newOrigin;
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tapping:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateChanged ||
        gesture.state == UIGestureRecognizerStateEnded) {
        self.dataSource.origin = [gesture locationInView:self];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
	CGContextBeginPath(context);

    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorWithColor(context, CGColorCreate(rgb, (CGFloat[]){ 0, 0, 1, 1 }));
    
    CGContextMoveToPoint (context, rect.origin.x, [self.dataSource yForX:rect.origin.x rect:rect]);
    for (double offset = rect.origin.x+1; offset<rect.size.width; offset++ ){
        CGContextAddLineToPoint (context, offset, [self.dataSource yForX:offset rect:rect]);
    }
    CGContextStrokePath(context);
    UIGraphicsPopContext();
    
    CGContextSetFillColorWithColor(context, CGColorCreate(rgb, (CGFloat[]){ 1, 0, 0, 1 }));
    UIFont *font = [UIFont systemFontOfSize:12];
    
    NSString *text = [[self.dataSource.brain class] descriptionOfProgram:[self.dataSource.brain program]];
    
    CGRect textRect;
    textRect.size = [text sizeWithFont:font];
    textRect.origin.x = rect.origin.x + 6;
    textRect.origin.y = rect.size.height - 18;
    [text drawInRect:textRect withFont:font];
    
    CGContextSetFillColorWithColor(context, CGColorCreate(rgb, (CGFloat[]){ .3, .3, .3, 1 }));
    CGContextSetStrokeColorWithColor(context, CGColorCreate(rgb, (CGFloat[]){ 0, 0, 0, 1 }));
    CGColorSpaceRelease(rgb);
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.dataSource.origin scale:self.dataSource.scale];
}

@end
