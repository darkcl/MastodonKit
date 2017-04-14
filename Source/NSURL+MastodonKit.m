//
//  NSURL+MastodonKit.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 14/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "NSURL+MastodonKit.h"

@implementation NSURL (MastodonKit)

- (NSURL *)urlWithParameters:(NSDictionary *)parameters{
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    NSMutableArray *queries = [[NSMutableArray alloc] init];
    
    for (NSString *key in parameters.allKeys) {
        id val = parameters[key];
        
        if ([val isKindOfClass:[NSArray class]]) {
            NSArray *subArr = (NSArray *)val;
            for (id subObj in subArr) {
                [queries addObject:[[NSURLQueryItem alloc] initWithName:[NSString stringWithFormat:@"%@[]",key] value:subObj]];
            }
        }else{
            [queries addObject:[[NSURLQueryItem alloc] initWithName:@"key" value:val]];
        }
    }
    components.queryItems = queries;
    return components.URL;
}

@end
