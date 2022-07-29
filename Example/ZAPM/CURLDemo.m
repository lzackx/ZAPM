//
//  CURLDemo.m
//  ZAPM_Example
//
//  Created by lZackx on 2022/7/29.
//  Copyright © 2022 lZackx. All rights reserved.
//

#import "CURLDemo.h"
#import <Zcurl/curl.h>

@implementation CURLDemo

- (instancetype)init {
    self = [super init];
    if (self) {
        curl_global_init(CURL_GLOBAL_SSL);
    }
    return self;
}

- (void)dealloc {
    curl_global_cleanup();
}

- (void)curl:(NSString *)url {
    
    CURL *curl = curl_easy_init();
    CURLcode code;
    
    code = curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
    code = curl_easy_setopt(curl, CURLOPT_URL, [url UTF8String]);
    code = curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);
    code = curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 2L);
    NSString *caPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"cacert" ofType:@"pem"];
    code = curl_easy_setopt(curl, CURLOPT_CAINFO, [caPath UTF8String]);
    
    code = curl_easy_perform(curl);
    
    double time_namelookup;
    code = curl_easy_getinfo(curl, CURLINFO_NAMELOOKUP_TIME, &time_namelookup);
        
    double time_connect;
    code = curl_easy_getinfo(curl, CURLINFO_CONNECT_TIME, &time_connect);
    
    double time_appconnect;
    code = curl_easy_getinfo(curl, CURLINFO_APPCONNECT_TIME, &time_appconnect);
    
    long http_code;
    code = curl_easy_getinfo(curl, CURLINFO_HTTP_CODE, &http_code);

    long ssl_verify_result;
    code = curl_easy_getinfo(curl, CURLINFO_SSL_VERIFYRESULT, &ssl_verify_result);
    
    double time_pretransfer;
    code = curl_easy_getinfo(curl, CURLINFO_PRETRANSFER_TIME, &time_pretransfer);
    
    double time_starttransfer;
    code = curl_easy_getinfo(curl, CURLINFO_STARTTRANSFER_TIME, &time_starttransfer);
    
    double speed_download;
    code = curl_easy_getinfo(curl, CURLINFO_SPEED_DOWNLOAD, &speed_download);
    
    double time_total;
    code = curl_easy_getinfo(curl, CURLINFO_TOTAL_TIME, &time_total);
    
        
    curl_easy_cleanup(curl);
    
    
    // DNS duration
    NSNumber *dnsDuration = [NSNumber numberWithDouble:time_namelookup];
    // TCP duration
    NSNumber *tcpDuration = [NSNumber numberWithDouble:(time_connect - time_namelookup)];
    // SSL duration
    NSNumber *sslDuration = [NSNumber numberWithDouble:(time_appconnect - time_connect)];
    // server duration
    NSNumber *serverDuration = [NSNumber numberWithDouble:(time_starttransfer - time_pretransfer)];
    
    NSLog(@"");
}

@end
