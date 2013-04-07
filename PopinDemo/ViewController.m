//
//  ViewController.m
//  PopinDemo
//
//  Created by Rogerio Araujo on 05/04/13.
//  Copyright (c) 2013 BMobile. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    popinView.images = @[[UIImage imageNamed:@"apple.png"],
                         [UIImage imageNamed:@"android.png"],
                         [UIImage imageNamed:@"google.png"],
                         [UIImage imageNamed:@"skype.png"]];
}

@end
