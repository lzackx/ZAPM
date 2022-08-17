//
//  ZAPMManager+Network.m
//  ZAPM
//
//  Created by lZackx on 2022/8/15.
//

#import "ZAPMManager+Network.h"
#import "ZAPM.h"

#import <objc/runtime.h>
#import <ZNetDiagnosis/ZNDTracerouteICMPReceiveModel.h>

#import <ZNetDiagnosis/ZNetDiagnosis+dns.h>
#import <ZNetDiagnosis/ZNetDiagnosis+ping.h>
#import <ZNetDiagnosis/ZNetDiagnosis+traceroute.h>

#import <YYModel/YYModel.h>

@implementation ZAPMManager (Network)

// MARK: - Joint trace
- (void)traceWithTarget:(NSArray<NSString *> *)targets
             completion:(void(^)(NSDictionary *info))completion {
    ZAPMLog(@"%s", __FUNCTION__);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (NSString *target in targets) {
            // DNS
            NSString *ip = [[[ZNetDiagnosis shared] ipsForDomainName:target] firstObject];
            if (ip == nil) {
                return;
            }
            ZAPMLog(@"trace target: %@", target);
            __block NSMutableDictionary *traceInfo = [NSMutableDictionary dictionary];
            [traceInfo setValue:target forKey:@"domain"];
            [traceInfo setValue:ip forKey:@"ip"];
            
            // Ping
            ZNDPingConfiguration *pingConfiguration = [[ZNDPingConfiguration alloc] init];
            pingConfiguration.target = ip;
            pingConfiguration.attempt = 4;
            pingConfiguration.timeout = 1;
            __block NSMutableArray *durations = [NSMutableArray array];
            [[ZNetDiagnosis shared] pingWithConfiguration:pingConfiguration success:^(NSDictionary * _Nonnull info) {
                ZAPMLog(@"ping s ==== %@: %@", traceInfo[@"domain"], info);
                if ([info objectForKey:@"duration"]) {
                    NSNumber *d = [info objectForKey:@"duration"];
                    [durations addObject:@((NSInteger)([d doubleValue] * 1000))];
                }
            } failure:^(NSDictionary * _Nonnull info) {
                ZAPMLog(@"ping f ==== %@: %@", traceInfo[@"domain"], info);
                [durations addObject:@(-1)];
            } completion:^(NSDictionary * _Nonnull info) {
                ZAPMLog(@"ping c ==== %@: %@", traceInfo[@"domain"], info);
                [traceInfo setValue:durations forKey:@"ping"];
                NSInteger durationValidSum = 0;
                NSInteger durationValidCount = 0;
                for (NSNumber *d in durations) {
                    if (d.integerValue <= 0) {
                        continue;
                    }
                    durationValidSum += d.integerValue;
                    durationValidCount++;
                }
                NSInteger durationAvg = durationValidSum / durationValidCount;
                [traceInfo setValue:@(durationAvg) forKey:@"pavg"];
                ZAPMLog(@"ping c ==== %@: %@", traceInfo[@"domain"], [traceInfo yy_modelDescription]);
                dispatch_semaphore_signal(semaphore);
            }];
            
            // Traceroute
            ZNDTracerouteConfiguration *tracerouteConfiguration = [[ZNDTracerouteConfiguration alloc] init];
            tracerouteConfiguration.target = ip;
            tracerouteConfiguration.maxTTL = 64;
            tracerouteConfiguration.attempt = 3;
            tracerouteConfiguration.timeout = 1;
            __block NSMutableArray *logs = [NSMutableArray array];
            [[ZNetDiagnosis shared] tracerouteWithConfiguration:tracerouteConfiguration success:^(NSDictionary * _Nonnull info) {
                ZAPMLog(@"tr s ==== %@: %@", traceInfo[@"domain"], info);
                ZNDTracerouteICMPReceiveModel *model = [info objectForKey:@"log"];
                NSMutableString *log = [NSMutableString stringWithFormat:@"%ld\t", model.ttl];
                NSString *replyIP = [NSString string];
                for (NSString *rip in model.replyIPs) {
                    if (rip.length > 0 && [rip containsString:@"*"] == NO) {
                        replyIP = rip;
                    }
                }
                if (replyIP.length == 0) {
                    replyIP = @"\t*\t*\t*";
                }
                [log appendString:replyIP];
                for (int index = 0; index < model.durations.count; index++) {
                    if (model.durations[index].doubleValue != 0) {
                        NSString *d = [NSString stringWithFormat:@"\t%0.0f ms", (model.durations[index].doubleValue * 1000)];
                        [log appendString:d];
                    }
                }
                [logs addObject:log];
            } failure:^(NSDictionary * _Nonnull info) {
                ZAPMLog(@"tr f ==== %@: %@", traceInfo[@"domain"], info);
                NSMutableString *log = [NSMutableString stringWithFormat:@"*"];
                [logs addObject:log];
            } completion:^(NSDictionary * _Nonnull info) {
                ZAPMLog(@"tr c ==== %@: %@", traceInfo[@"domain"], info);
                [traceInfo setValue:logs forKey:@"trace"];
                if (completion) {
                    completion(traceInfo);
                }
                ZAPMLog(@"tr c ==== %@: %@", traceInfo[@"domain"], [traceInfo yy_modelDescription]);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

// MARK: - Ping
- (void)pingWithConfiguration:(ZNDPingConfiguration *)configuration
                  didComplete:(PingDidComplete)didComplete {
    ZAPMLog(@"%s", __FUNCTION__);
    __block NSMutableArray *durations = [NSMutableArray array];
    [[ZNetDiagnosis shared] pingWithConfiguration:configuration success:^(NSDictionary * _Nonnull info) {
        ZAPMLog(@"%s: %@", __FUNCTION__, info);
        if ([info objectForKey:@"duration"]) {
            NSNumber *d = [info objectForKey:@"duration"];
            [durations addObject:@((NSInteger)([d doubleValue] * 1000))];
        }
    } failure:^(NSDictionary * _Nonnull info) {
        ZAPMLog(@"%s: %@", __FUNCTION__, info);
        [durations addObject:@(-1)];
    } completion:^(NSDictionary * _Nonnull info) {
        ZAPMLog(@"%s: %@", __FUNCTION__, info);
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:info];
        [result setValue:durations forKey:@"durations"];
        if (didComplete) {
            didComplete(result);
        }
    }];
}

// MARK: - Traceroute
- (void)tracerouteWithConfiguration:(ZNDTracerouteConfiguration *)configuration
                        didComplete:(TracerouteDidComplete )didComplete {
    ZAPMLog(@"%s", __FUNCTION__);
    __block NSMutableArray *logs = [NSMutableArray array];
    [[ZNetDiagnosis shared] tracerouteWithConfiguration:configuration success:^(NSDictionary * _Nonnull info) {
        ZAPMLog(@"%s: %@", __FUNCTION__, info);
        ZNDTracerouteICMPReceiveModel *model = [info objectForKey:@"log"];
        NSMutableString *log = [NSMutableString stringWithFormat:@"%ld\t", model.ttl];
        NSString *replyIP = [NSString string];
        for (NSString *rip in model.replyIPs) {
            if (rip.length > 0 && [rip containsString:@"*"] == NO) {
                replyIP = rip;
            }
        }
        if (replyIP.length == 0) {
            replyIP = @"\t*\t*\t*";
        }
        [log appendString:replyIP];
        for (int index = 0; index < model.durations.count; index++) {
            if (model.durations[index].doubleValue != 0) {
                NSString *d = [NSString stringWithFormat:@"\t%0.0f ms", (model.durations[index].doubleValue * 1000)];
                [log appendString:d];
            }
        }
        [logs addObject:log];
    } failure:^(NSDictionary * _Nonnull info) {
        ZAPMLog(@"%s: %@", __FUNCTION__, info);
        NSMutableString *log = [NSMutableString stringWithFormat:@"*"];
        [logs addObject:log];
    } completion:^(NSDictionary * _Nonnull info) {
        ZAPMLog(@"%s: %@", __FUNCTION__, info);
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:info];
        [result setValue:logs forKey:@"logs"];
        if (didComplete) {
            didComplete(result);
        }
    }];
}

// MARK: - CURL
- (CURLDidComplete)curlDidComplete {
    CURLDidComplete block = objc_getAssociatedObject(self,
                                                     @selector(curlDidComplete));
    return block;
}

- (void)setCurlDidComplete:(CURLDidComplete)curlDidComplete {
    objc_setAssociatedObject(self,
                             @selector(curlDidComplete),
                             curlDidComplete,
                             OBJC_ASSOCIATION_COPY);
}

- (void)curl:(NSString *)url
 didComplete:(CURLDidComplete)didComplete {
    ZAPMLog(@"%s", __FUNCTION__);
    self.curlDidComplete = didComplete;
    [ZcurlManager shared].delegate = self;
    [[ZcurlManager shared] performWithURLString:url];
}

// MARK: - ZcurlManagerDelegate
- (void)curl:(CURL *)curl willPerformWithURL:(NSURL *)url {
    ZAPMLog(@"%s: %@", __FUNCTION__, url);
}

- (void)curl:(CURL *)curl didPerformWithURL:(NSURL *)url info:(NSDictionary *)info {
    ZAPMLog(@"%s: %@", __FUNCTION__, info);
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [result setValue:url forKey:@"url"];
//    [result addEntriesFromDictionary:info];
    
    // DNS
    NSNumber *time_namelookup = [info objectForKey:@"time_namelookup"];
    if (time_namelookup.doubleValue <= 0) {
        time_namelookup = @(-1);
    }
    [result setValue:@((NSInteger)(time_namelookup.doubleValue * 1000)) forKey:@"DNS"];
    
    // TCP
    NSNumber *time_connect = [info objectForKey:@"time_connect"];
    NSNumber *tcp = @(time_connect.doubleValue - time_namelookup.doubleValue);
    if (tcp.doubleValue <= 0) {
        tcp = @(-1);
    }
    [result setValue:@((NSInteger)(tcp.doubleValue * 1000)) forKey:@"TCP"];
    
    // SSL
    NSNumber *time_appconnect = [info objectForKey:@"time_appconnect"];
    NSNumber *ssl = @(time_appconnect.doubleValue - time_connect.doubleValue);
    if (ssl.doubleValue <= 0) {
        ssl = @(-1);
    }
    [result setValue:@((NSInteger)(ssl.doubleValue * 1000)) forKey:@"SSL"];
    
    // Server
    NSNumber *time_pretransfer = [info objectForKey:@"time_pretransfer"];
    NSNumber *time_starttransfer = [info objectForKey:@"time_starttransfer"];
    NSNumber *server = @(time_starttransfer.doubleValue - time_pretransfer.doubleValue);
    if (server.doubleValue <= 0) {
        server = @(-1);
    }
    [result setValue:@((NSInteger)(server.doubleValue * 1000)) forKey:@"Server"];
    
    // TTFB, time to first byte
    NSNumber *ttfb = @(time_starttransfer.doubleValue - time_appconnect.doubleValue);
    if (ttfb.doubleValue <= 0) {
        ttfb = @(-1);
    }
    [result setValue:@((NSInteger)(ttfb.doubleValue * 1000)) forKey:@"TTFB"];
    
    // Transfer
    NSNumber *time_total = [info objectForKey:@"time_total"];
    NSNumber *transfer = @(time_total.doubleValue - time_starttransfer.doubleValue);
    if (transfer.doubleValue <= 0) {
        transfer = @(-1);
    }
    [result setValue:@((NSInteger)(transfer.doubleValue * 1000)) forKey:@"Transfer"];
    
    // Total
    if (time_total.doubleValue <= 0) {
        time_total = @(-1);
    }
    [result setValue:@((NSInteger)(time_total.doubleValue * 1000)) forKey:@"Total"];
    
    // Speed
    NSNumber *speed_download = [info objectForKey:@"speed_download"];
    if (speed_download.doubleValue <= 0) {
        speed_download = @(-1);
    }
    [result setValue:speed_download forKey:@"speed"];
    
    if (self.curlDidComplete) {
        self.curlDidComplete(result);
    }
}


@end
