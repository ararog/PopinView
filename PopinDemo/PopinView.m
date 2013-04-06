//
//  PopinView.m
//  PopinDemo
//
//  Created by Rogerio Araujo on 05/04/13.
//  Copyright (c) 2013 BMobile. All rights reserved.
//

#import "PopinView.h"
#import <QuartzCore/QuartzCore.h>

@interface PopinView () {
    
    BOOL imageOnCenter;
}

- (CAAnimationGroup *) createAnimation:(UIView *)viewToAnimate
                        withStartPoint:(CGPoint)startPoint
                              endPoint:(CGPoint)endPoint
                               endSize:(CGSize)endSize;

@end

@implementation PopinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = YES;

        UISwipeGestureRecognizer* gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(swipe:)];
        gestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:gestureRecognizer];
        
        imageOnCenter = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.clipsToBounds = YES;
        
        UISwipeGestureRecognizer* gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(swipe:)];
        gestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:gestureRecognizer];
        
        imageOnCenter = NO;
    }
    return self;
}

- (void) swipe:(UISwipeGestureRecognizer *)recognizer {
    
    CGPoint startPoint, endPoint;
    
    UIImageView* oldView = (UIImageView *)[self viewWithTag:1000];
    if(oldView != nil)
        [oldView removeFromSuperview];
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {

        UIImage *image = (UIImage *)[_images objectAtIndex:0];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        imageView.tag = 1000;
        imageView.image = image;
        imageView.clipsToBounds = YES;
        
        [self addSubview:imageView];
        //[self.layer addSublayer:imageView.layer];
        
        if(! imageOnCenter) {
            endPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
            startPoint = endPoint;
            startPoint.y = startPoint.y - 20;
            
            imageView.center = startPoint;

            imageView.bounds = CGRectMake(0, 0, 0, 0);

            [UIView animateWithDuration:0.5 animations:^{
                CAAnimationGroup* group = [self createAnimation:imageView
                                                 withStartPoint:startPoint
                                                       endPoint:endPoint
                                                        endSize:CGSizeMake(64, 64)];
                
                [imageView.layer addAnimation:group forKey:@"curveAnimation"];
            } completion:^(BOOL finished) {
                imageOnCenter = YES;
            }];
        }
        else {
            
            endPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height + (64 * 2));
            startPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
            
            imageView.center = startPoint;
            
            imageView.bounds = CGRectMake(0, 0, 64, 64);
            
            imageView.contentMode = UIViewContentModeScaleToFill;
            
            [UIView animateWithDuration:0.5 animations:^{
                CAAnimationGroup* group = [self createAnimation:imageView
                                                 withStartPoint:startPoint
                                                       endPoint:endPoint
                                                        endSize:CGSizeMake(64 * 3, 64 * 3)];
                
                [imageView.layer addAnimation:group forKey:@"curveAnimation"];
            } completion:^(BOOL finished) {
                imageOnCenter = NO;
            }];
        }
    }
}

-(CAAnimationGroup *)createAnimation:(UIView *)viewToAnimate
                      withStartPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint
                             endSize:(CGSize)endSize {
    
    CABasicAnimation *resizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [resizeAnimation setToValue:[NSValue valueWithCGSize:endSize]];
    resizeAnimation.fillMode = kCAFillModeForwards;
    resizeAnimation.removedOnCompletion = NO;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, startPoint.y, endPoint.x, startPoint.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setAnimations:[NSArray arrayWithObjects:pathAnimation, resizeAnimation, nil]];
    group.duration = 0.5f;
    group.delegate = self;
    [group setValue:viewToAnimate forKey:@"imageViewBeingAnimated"];

    return group;
}

@end
