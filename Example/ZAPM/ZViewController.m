//
//  ZViewController.m
//  ZAPM
//
//  Created by lZackx on 07/29/2022.
//  Copyright (c) 2022 lZackx. All rights reserved.
//

#import "ZViewController.h"

#import <ZAPM/ZAPMManager+Network.h>
#import <YYModel/YYModel.h>


@interface ZViewController ()

@end

@implementation ZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self ping];
    [self traceroute];
    [self curl];
    
}

- (void)ping {
    ZNDPingConfiguration *configuration = [[ZNDPingConfiguration alloc] init];
    configuration.target = @"google.com";
    [[ZAPMManager shared] pingWithConfiguration:configuration didComplete:^(NSDictionary * _Nonnull info) {
        NSLog(@"%s %@", __FUNCTION__, [info yy_modelToJSONString]);
    }];
}

- (void)traceroute {
    ZNDTracerouteConfiguration *configuration = [[ZNDTracerouteConfiguration alloc] init];
    configuration.target = @"google.com";
    configuration.attempt = 3;
    configuration.port = 80;
    [[ZAPMManager shared] tracerouteWithConfiguration:configuration didComplete:^(NSDictionary * _Nonnull info) {
        NSLog(@"%s %@", __FUNCTION__, [info yy_modelToJSONString]);
    }];
}

- (void)curl {
    [[ZAPMManager shared] curl:@"https://www.lzackx.com" didComplete:^(NSDictionary * _Nonnull info) {
        NSLog(@"%s %@", __FUNCTION__, [info yy_modelToJSONString]);
        
        
        
    }];
}

@end
