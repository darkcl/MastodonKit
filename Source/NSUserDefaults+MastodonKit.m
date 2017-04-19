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

+ (NSUserDefaults *)appGroupUserDefault:(NSString *)identifier{
    return identifier ? [[NSUserDefaults alloc] initWithSuiteName:identifier] : [NSUserDefaults standardUserDefaults];
}

+ (NSArray *)clientsArrayWithApplicationName:(NSString *)applicationName
                      withAppGroupIdentifier:(NSString *)identifier{
    NSUserDefaults *userDefault = identifier ? [[NSUserDefaults alloc] initWithSuiteName:identifier] : [NSUserDefaults standardUserDefaults];
    
    NSDictionary *clientsDict = [userDefault valueForKey:MastodonKitClientsKey];
    
    if (clientsDict == nil) {
        clientsDict = @{};
        [userDefault setObject:clientsDict forKey:MastodonKitClientsKey];
        [userDefault synchronize];
    }
    
    id clientsData = [clientsDict objectForKey:applicationName];
    if (clientsData == nil) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:clientsDict];
        [dict setObject:[NSKeyedArchiver archivedDataWithRootObject:@[]] forKey:applicationName];
        [userDefault setObject:dict forKey:MastodonKitClientsKey];
        [userDefault synchronize];
        
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
        applicationName:(NSString *)applicationName
 withAppGroupIdentifier:(NSString *)identifier{
    NSUserDefaults *userDefault = identifier ? [[NSUserDefaults alloc] initWithSuiteName:identifier] : [NSUserDefaults standardUserDefaults];
    
    NSDictionary *clientsDict = [userDefault valueForKey:MastodonKitClientsKey];
    
    if (clientsDict == nil) {
        clientsDict = @{};
        [userDefault setObject:clientsDict forKey:MastodonKitClientsKey];
        [userDefault synchronize];
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:clientsDict];
    
    [dict setObject:[NSKeyedArchiver archivedDataWithRootObject:clients] forKey:applicationName];
    
    [userDefault setObject:dict forKey:MastodonKitClientsKey];
    [userDefault synchronize];
}

@end
