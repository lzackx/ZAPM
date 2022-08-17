//
//  ZAPMManager+Network.h
//  ZAPM
//
//  Created by lZackx on 2022/8/15.
//

#import "ZAPMManager.h"

#import <ZNetDiagnosis/ZNetDiagnosis+ping.h>

#import <ZNetDiagnosis/ZNetDiagnosis+traceroute.h>

#import <Zcurl/Zcurl.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PingDidComplete)(NSDictionary *info);

typedef void(^TracerouteDidComplete)(NSDictionary *info);

typedef void(^CURLDidComplete)(NSDictionary *info);

@interface ZAPMManager (Network) <ZcurlManagerDelegate>

- (void)traceWithTarget:(NSArray<NSString *> *)targets
             completion:(void(^)(NSDictionary *info))completion;

- (void)pingWithConfiguration:(ZNDPingConfiguration *)configuration
                  didComplete:(PingDidComplete)didComplete;

- (void)tracerouteWithConfiguration:(ZNDTracerouteConfiguration *)configuration
                        didComplete:(TracerouteDidComplete )didComplete;

- (void)curl:(NSString *)url
 didComplete:(CURLDidComplete __nullable)didComplete;

@end

NS_ASSUME_NONNULL_END
