//
//  NSUserDefaults+MastodonKit.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "NSUserDefaults+MastodonKit.h"

#import "MastodonConstants.h"

@implementation NSUserDefaults (MastodonKit)

+ (NSArray *)clientsArrayWithApplicationName:(NSString *)applicationName{
    NSDictionary *clientsDict = [[NSUserDefaults standardUserDefaults] valueForKey:MastodonKitClientsKey];
    
    if (clientsDict == nil) {
        clientsDict = @{};
        [[NSUserDefaults standardUserDefaults] setObject:clientsDict forKey:MastodonKitClientsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    id clientsData = [clientsDict objectForKey:applicationName];
    if (clientsData == nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:clientsDict];
        [dict setObject:[NSKeyedArchiver archivedDataWithRootObject:@[]] forKey:applicationName];
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:MastodonKitClientsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return @[];
    }else{
        if ([clientsData isKindOfClass:[NSArray class]]) {
            return clientsData;
        }else{
            NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:clientsData];
            
            return arr;
        }
    }
}

+ (void)setClientsArray:(NSArray *)clients
        applicationName:(NSString *)applicationName{
    NSDictionary *clientsDict = [[NSUserDefaults standardUserDefaults] valueForKey:MastodonKitClientsKey];
    
    if (clientsDict == nil) {
        clientsDict = @{};
        [[NSUserDefaults standardUserDefaults] setObject:clientsDict forKey:MastodonKitClientsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:clientsDict];
    
    [dict setObject:[NSKeyedArchiver archivedDataWithRootObject:clients] forKey:applicationName];
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:MastodonKitClientsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
