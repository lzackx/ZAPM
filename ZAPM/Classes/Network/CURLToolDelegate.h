//
//  CURLToolDelegate.h
//  Pods
//
//  Created by lZackx on 2022/8/1.
//

#ifndef CURLToolDelegate_h
#define CURLToolDelegate_h

#import <Foundation/Foundation.h>
#import <Zcurl/curl.h>


@protocol CURLToolDelegate <NSObject>

- (void)curl:(CURL *)curl willPerformWithURL:(NSURL *)url;

- (void)curl:(CURL *)curl didPerformWithURL:(NSURL *)url info:(NSDictionary *)info;

@end


#endif /* CURLToolDelegate_h */
