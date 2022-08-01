//
//  CURLTool.h
//  ZAPM
//
//  Created by lZackx on 2022/8/1.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CURLTool : NSObject

@property (nonatomic, readwrite, weak) id delegate;

+ (instancetype)shared;

- (void)performWithURLString:(NSString *)urlString;

- (void)performWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
