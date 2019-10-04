//
//  ObjectDecorder.m
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/19.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "ObjectDecorder.h"
#import "DeallocMonitor.h"

@implementation ObjectDecorder
{
    NSMutableDictionary <NSString *, NSHashTable *> *_dict;
    NSLock *_lock;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        _lock = [NSLock new];
    }
    return self;
}

#pragma mark -

- (void)addObject:(id)object key:(NSString *)key {
    if (!object || !key) return;
    [_lock lock];
    NSHashTable *table = _dict[key];
    if (!table) {
        table = [NSHashTable weakObjectsHashTable];
        _dict[key] = table;
    }
    [table addObject:object];
    [_lock unlock];
}

- (void)ergodicObjectWithKey:(NSString *)key callback:(void(^)(id obj))callback {
    if (!callback || !key) return;
    [_lock lock];
    NSArray *arr = _dict[key].allObjects;
    [_lock unlock];
    for (NSObject *obj in arr) {
        callback(obj);
    }
}

@end
