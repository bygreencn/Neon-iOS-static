//
//  neonViewController.m
//  neon-for-iOS
//
//  Created by cheng on 14-9-22.
//  Copyright (c) 2014年 ___VRDATA___. All rights reserved.
//

#import "neonViewController.h"
int Demo_neon ( char * path );

@interface neonViewController ()

@end

@implementation neonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)UploadRoutine:(id)sender
{
    NSString * path = [[NSBundle mainBundle] bundlePath];
	Demo_neon([path cStringUsingEncoding:1]);
}

@end
