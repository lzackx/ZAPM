//
//  ZViewController.m
//  ZAPM
//
//  Created by lZackx on 07/29/2022.
//  Copyright (c) 2022 lZackx. All rights reserved.
//

#import "ZViewController.h"
#import "CURLDemo.h"


@interface ZViewController ()

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self testCURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)testCURL {
    CURLDemo *demo = [[CURLDemo alloc] init];
    
    [demo curl:@"https://lzackx.com"];
}

@end
