//
//  GPEvent.m
//  GrowthPush
//
//  Created by uchidas on 2015/06/22.
//  Copyright (c) 2015年 SIROK, Inc. All rights reserved.
//

#import "GPEvent.h"
#import "GrowthPush.h"
#import "GBHttpClient.h"

@implementation GPEvent

@synthesize goalId;
@synthesize timestamp;
@synthesize clientId;
@synthesize value;

static NSString *const kGPPreferenceEventKeyFormat = @"events:%@";

+ (GPEvent *) createWithGrowthbeatClient:(NSString *)clientId credentialId:(NSString *)credentialId name:(NSString *)name value:(NSString *)value {
    
    NSString *path = @"/3/events";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    if (clientId) {
        [body setObject:clientId forKey:@"clientId"];
    }
    if (credentialId) {
        [body setObject:credentialId forKey:@"credentialId"];
    }
    if (name) {
        [body setObject:name forKey:@"name"];
    }
    if (value) {
        [body setObject:value forKey:@"value"];
    }
    
    GBHttpRequest *httpRequest = [GBHttpRequest instanceWithMethod:GBRequestMethodPost path:path query:nil body:body];
    GBHttpResponse *httpResponse = [[[GrowthPush sharedInstance] httpClient] httpRequest:httpRequest];
    if (!httpResponse.success) {
        [[[GrowthPush sharedInstance] logger] error:@"Failed to create event. %@", httpResponse.error];
    }
    
    return [GPEvent domainWithDictionary:httpResponse.body];
    
}

+ (void) save:(GPEvent *)event name:(NSString *)name {
    if (event && name) {
        [[[GrowthPush sharedInstance] preference] setObject:event forKey:[NSString stringWithFormat:kGPPreferenceEventKeyFormat, name]];
    }
}

+ (GPEvent *) load:(NSString *)name {
    
    if (name)
        return nil;
    
    return [[[GrowthPush sharedInstance] preference] objectForKey:[NSString stringWithFormat:kGPPreferenceEventKeyFormat, name]];
    
}


- (id) initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        if ([dictionary objectForKey:@"goalId"] && [dictionary objectForKey:@"goalId"] != [NSNull null]) {
            self.goalId = [[dictionary objectForKey:@"goalId"] integerValue];
        }
        if ([dictionary objectForKey:@"timestamp"] && [dictionary objectForKey:@"timestamp"] != [NSNull null]) {
            self.timestamp = [[dictionary objectForKey:@"timestamp"] longLongValue];
        }
        if ([dictionary objectForKey:@"clientId"] && [dictionary objectForKey:@"clientId"] != [NSNull null]) {
            self.clientId = [[dictionary objectForKey:@"clientId"] longLongValue];
        }
        if ([dictionary objectForKey:@"value"] && [dictionary objectForKey:@"value"] != [NSNull null]) {
            self.value = [dictionary objectForKey:@"value"];
        }
    }
    
    return self;
    
}

# pragma mark --
# pragma mark NSCoding

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self) {
        if ([aDecoder containsValueForKey:@"goalId"]) {
            self.goalId = [aDecoder decodeIntegerForKey:@"goalId"];
        }
        if ([aDecoder containsValueForKey:@"timestamp"]) {
            self.timestamp = [[aDecoder decodeObjectForKey:@"timestamp"] longLongValue];
        }
        if ([aDecoder containsValueForKey:@"clientId"]) {
            self.clientId = [[aDecoder decodeObjectForKey:@"clientId"] longLongValue];
        }
        if ([aDecoder containsValueForKey:@"value"]) {
            self.value = [aDecoder decodeObjectForKey:@"value"];
        }
    }
    
    return self;
    
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeInteger:goalId forKey:@"goalId"];
    [aCoder encodeObject:@(timestamp) forKey:@"timestamp"];
    [aCoder encodeObject:@(clientId) forKey:@"clientId"];
    [aCoder encodeObject:value forKey:@"value"];
    
}

@end