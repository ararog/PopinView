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
    
    NSInteger stopAt, current, previous;
    BOOL first, last;
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
        
        first = YES;
        last = NO;
        current = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.clipsToBounds = YES;
        
        UISwipeGestureRecognizer* gestureRecognizer;
        
        gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(swipe:)];
        gestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;

        [self addGestureRecognizer:gestureRecognizer];

        gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(swipe:)];
        gestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        
        [self addGestureRecognizer:gestureRecognizer];
        
        first = YES;
        last = NO;
        current = 0;
    }
    return self;
}

- (void) swipe:(UISwipeGestureRecognizer *)recognizer {
    
    UIImageView *currentImageView, *existingImageView, *previousImageView;
    CGPoint startPoint, endPoint;
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionDown) {

        UIImage *image = [_images objectAtIndex:current];
        
        existingImageView = (UIImageView *) [self viewWithTag:(current + 1000)];
        if(existingImageView)
            currentImageView = existingImageView;
        
        currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        currentImageView.tag = current + 1000;
        currentImageView.image = image;

        if (first) {
            [self addSubview:currentImageView];
        }
        else
            [self insertSubview:currentImageView
                   belowSubview:[self viewWithTag:(previous + 1000)]];
        
        endPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        startPoint = endPoint;
        startPoint.y = startPoint.y - 20;
        
        currentImageView.center = startPoint;

        currentImageView.bounds = CGRectMake(0, 0, 0, 0);

        [UIView animateWithDuration:0.5 animations:^{
            
            CAAnimationGroup* group = [self createAnimation:currentImageView
                                             withStartPoint:startPoint
                                                   endPoint:endPoint
                                                    endSize:CGSizeMake(64, 64)];
            
            [currentImageView.layer addAnimation:group forKey:@"curveAnimation"];
            
        } completion:^(BOOL finished) {
            if(first) {
                previous = current;
                current++;
                first = NO;
            }
        }];

        if(! first) {
            
            previousImageView = (UIImageView *) [self viewWithTag:(previous + 1000)];
            
            endPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height + (64 * 2));
            startPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
            
            previousImageView.center = startPoint;
            
            previousImageView.bounds = CGRectMake(0, 0, 64, 64);
            
            previousImageView.contentMode = UIViewContentModeScaleToFill;
            
            [UIView animateWithDuration:0.5 animations:^{
                
                CAAnimationGroup* group = [self createAnimation:previousImageView
                                                 withStartPoint:startPoint
                                                       endPoint:endPoint
                                                        endSize:CGSizeMake(64 * 3, 64 * 3)];
                
                [previousImageView.layer addAnimation:group forKey:@"curveAnimation"];
                
            } completion:^(BOOL finished) {

                previous = current;
                current++;
                if (current >= [_images count]) {
                    previous = current - 1;
                    current = 0;
                }
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
