//
//  CURLTool.m
//  ZAPM
//
//  Created by lZackx on 2022/8/1.
//

#import "CURLTool.h"
#import "CURLToolDelegate.h"
#import <Zcurl/Zcurl.h>
#import <Zcurl/curl.h>


@implementation CURLTool

// MARK: - Life Cycle
static CURLTool *_shared;

+ (instancetype)shared {
    if (_shared == nil) {
        _shared = [[CURLTool alloc] init];
    }
    return _shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        curl_global_init(CURL_GLOBAL_SSL);
    }
    return self;
}

- (instancetype)copy {
    return self;
}

- (instancetype)mutableCopy {
    return self;
}

- (void)dealloc {
    curl_global_cleanup();
}

// MARK: - API
- (void)performWithURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        NSLog(@"curl perform failed: %@", urlString);
        return;
    }
    [self performWithURL:url];
}

- (void)performWithURL:(NSURL *)url {
    
    CURLcode code;
    CURL *curl = curl_easy_init();
    
    // URL
    code = curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
    if (code != CURLE_OK) {
        NSLog(@"CURLOPT_VERBOSE failure: %u", code);
    }
    // URL
    code = curl_easy_setopt(curl, CURLOPT_URL, [[url absoluteString] UTF8String]);
    if (code != CURLE_OK) {
        NSLog(@"CURLOPT_URL failure: %u", code);
    }
    // SSL
    NSBundle *zcurlBundle = [NSBundle bundleForClass:[Zcurl class]];
    NSString *caPath = [zcurlBundle pathForResource:@"cacert" ofType:@"pem"];
    code = curl_easy_setopt(curl, CURLOPT_CAINFO, [caPath UTF8String]);
    if (code != CURLE_OK) {
        NSLog(@"CURLOPT_CAINFO failure: %u", code);
    }
    code = curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);
    if (code != CURLE_OK) {
        NSLog(@"CURLOPT_SSL_VERIFYPEER failure: %u", code);
    }
    code = curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2L);
    if (code != CURLE_OK) {
        NSLog(@"CURLOPT_SSL_VERIFYHOST failure: %u", code);
    }
    
    // delegate: - (void)curl:(CURL *)curl willPerformWithURL:(NSURL *)url;
    if ([self.delegate respondsToSelector:@selector(curl:willPerformWithURL:)]) {
        [self.delegate curl:curl willPerformWithURL:url];
    }
    
    // perform
    code = curl_easy_perform(curl);
    if (code != CURLE_OK) {
        NSLog(@"perform failure: %u", code);
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];

//    char *url_effective;
//    code = curl_easy_getinfo(curl, CURLINFO_EFFECTIVE_URL, url_effective);
    
//    double time_namelookup;
//    code = curl_easy_getinfo(curl, CURLINFO_NAMELOOKUP_TIME, &time_namelookup);
//
//    double time_connect;
//    code = curl_easy_getinfo(curl, CURLINFO_CONNECT_TIME, &time_connect);
//
//    double time_appconnect;
//    code = curl_easy_getinfo(curl, CURLINFO_APPCONNECT_TIME, &time_appconnect);
//
//    long http_code;
//    code = curl_easy_getinfo(curl, CURLINFO_HTTP_CODE, &http_code);
//
//    long ssl_verify_result;
//    code = curl_easy_getinfo(curl, CURLINFO_SSL_VERIFYRESULT, &ssl_verify_result);
//
//    double time_pretransfer;
//    code = curl_easy_getinfo(curl, CURLINFO_PRETRANSFER_TIME, &time_pretransfer);
//
//    double time_starttransfer;
//    code = curl_easy_getinfo(curl, CURLINFO_STARTTRANSFER_TIME, &time_starttransfer);
//
//    double speed_download;
//    code = curl_easy_getinfo(curl, CURLINFO_SPEED_DOWNLOAD, &speed_download);
//
//    double time_total;
//    code = curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &time_total);
    
    // delegate: - (void)curl:(CURL *)curl didPerformWithURL:(NSURL *)url info:(NSDictionary *)info;
    if ([self.delegate respondsToSelector:@selector(curl:didPerformWithURL:info:)]) {
        [self.delegate curl:curl didPerformWithURL:url info:info];
    }
    
    curl_easy_cleanup(curl);
}

@end
