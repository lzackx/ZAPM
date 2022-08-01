//
//  CURLDemo.m
//  ZAPM_Example
//
//  Created by lZackx on 2022/7/29.
//  Copyright © 2022 lZackx. All rights reserved.
//

#import "CURLDemo.h"
#import <ZAPM/CURLTool.h>
#import <ZAPM/CURLToolDelegate.h>


@interface CURLDemo () <CURLToolDelegate>

@end

@implementation CURLDemo

- (instancetype)init {
    self = [super init];
    if (self) {
        [CURLTool shared].delegate = self;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)curl:(NSString *)url {
    
    [[CURLTool shared] performWithURLString:url];
}

// MARK: - CURLToolDelegate
- (void)curl:(CURL *)curl willPerformWithURL:(NSURL *)url {
    
    NSLog(@"url: %@", url);
}

- (void)curl:(CURL *)curl
didPerformWithURL:(NSURL *)url
        info:(NSDictionary *)info {
    
    NSLog(@"url: %@", url);
    NSLog(@"@%@", info);

}

@end
