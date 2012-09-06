//
//  GraphViewController.m
//  Calculator
//
//  Created by Leonid Sobolievskyi on 8/28/12.
//  Copyright (c) 2012 Kasmanaft. All rights reserved.
//

#import "GraphViewController.h"
//#import "GraphView.h"
#import "CalculatorBrain.h"

@interface GraphViewController () <GraphViewDataSource, UISplitViewControllerDelegate>
//@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController

@synthesize graphView = _graphView;
@synthesize scale = _scale;
@synthesize origin = _origin;
@synthesize brain = _brain;
@synthesize toolbar = _toolbar;


#define DEFAULT_SIZE 100.0 // Looks good, IMO

// return the DEFAULT_SIZE if _scale is not set (i.e. is zero)

- (CGFloat)scale {
    if (!_scale) {
        if([[NSUserDefaults standardUserDefaults] floatForKey:@"GraphScale"]<=0){
            [[NSUserDefaults standardUserDefaults] setFloat:DEFAULT_SIZE forKey:@"GraphScale"];
        }
        _scale=[[NSUserDefaults standardUserDefaults] floatForKey:@"GraphScale"];
    }
    return _scale;
}

// don't allow negative scales
// we need a redraw when scale changes

- (void)setScale:(CGFloat)scale {
    if (scale >= 0) {
        _scale = scale;
        [[NSUserDefaults standardUserDefaults] setFloat:_scale forKey:@"GraphScale"];
    }
    [self.graphView setNeedsDisplay];
}

- (CGPoint)origin {
    if (_origin.x<=0 && _origin.y<=0) {
        if([[NSUserDefaults standardUserDefaults] floatForKey:@"GraphOriginX"]<=0 && [[NSUserDefaults standardUserDefaults] floatForKey:@"GraphOriginY"]<=0){
            [[NSUserDefaults standardUserDefaults] setFloat:(self.graphView.bounds.origin.x + self.graphView.bounds.size.width/2) forKey:@"GraphOriginX"];
            [[NSUserDefaults standardUserDefaults] setFloat:(self.graphView.bounds.origin.y + self.graphView.bounds.size.height/2) forKey:@"GraphOriginY"];
        }
        _origin.x=[[NSUserDefaults standardUserDefaults] floatForKey:@"GraphOriginX"];
        _origin.y=[[NSUserDefaults standardUserDefaults] floatForKey:@"GraphOriginY"];
    }
    return _origin;
}


- (void)setOrigin:(CGPoint)origin
{
    _origin = origin;
    [[NSUserDefaults standardUserDefaults] setFloat:_origin.x forKey:@"GraphOriginX"];
    [[NSUserDefaults standardUserDefaults] setFloat:_origin.y forKey:@"GraphOriginY"];
    [self.graphView setNeedsDisplay];
}


// called when iOS sets our outlet to the FaceView
// add gesture recognizers to the FaceView
// set ourselves as the dataSource of the FaceView so we can provide "smileyness"

- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(panning:)]];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tapping:)];
    tap.numberOfTapsRequired=3;
    [self.graphView addGestureRecognizer:tap];
    self.graphView.dataSource = self;
}

/*-(GraphView *)graphView{
    return _graphView;
}
*/

- (NSNumber *)xForProgram:(CGFloat)x{
    NSNumber *result=[NSNumber numberWithFloat:((x-self.origin.x)/self.scale)];
    return result;
}

-(CGFloat)yForGraph:(double)y{
    double result=self.origin.y-(y*self.scale);
    return result;
}

-(CGFloat)yForX:(CGFloat)x rect:(CGRect)rect{
    return [self yForGraph:[CalculatorBrain runProgram:[self.brain program] usingVariableValues:[NSMutableDictionary dictionaryWithObjectsAndKeys:[self xForProgram:x], @"x",nil]]];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

// LECTURE 7 ADDITIONS

// viewDidLoad is called after all of our outlets are set up
// and we are installed in whatever controller of controllers we're going to be in
// so this is a good place to set ourselves as the delegate of any split view we are in
// setting the split view's presentsWithGesture to NO means swiping does not hide the master
//  (only clicking the toolbar button does)

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.splitViewController.presentsWithGesture = NO;
    self.splitViewController.delegate = self;
}

// split view delegation methods
// these will only work if we have an outlet called "toolbar"
// which points to a UIToolbar to put the split view hiding/unhiding UIBarButtonItem into

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

// called when the master (left) split view pane gets hidden
// make sure to set the master view controller's title in Xcode

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
}

// called when the master (left) split view pane appears

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:barButtonItem];
    self.toolbar.items = toolbarItems;
}

// automatically generated when we made the toolbar outlet

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [super viewDidUnload];
}

@end
