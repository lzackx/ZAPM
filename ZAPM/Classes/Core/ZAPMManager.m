//
//  ZAPMManager.m
//  ZAPM
//
//  Created by lZackx on 2022/8/15.
//

#import "ZAPMManager.h"

@implementation ZAPMManager

// MARK: - Life Cycle
static ZAPMManager *_shared;

+ (instancetype)shared {
    static dispatch_once_t zndOneToken;
    dispatch_once(&zndOneToken, ^{
        _shared = [[super allocWithZone:NULL] init];
    });
    return _shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [ZAPMManager shared];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

@end
