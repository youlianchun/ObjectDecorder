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
    NSMutableDictionary <NSString *, NSMutableDictionary<NSString *, DeallocMonitor *> *> *_dict;
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
    __weak typeof(self) wself = self;
    DeallocMonitor *dm = [DeallocMonitor monitorWithObj:object objDelloc:^(DeallocMonitor *dm){
        [wself removeDM:dm key:key];
    }];
    [self addDM:dm key:key];
}

- (void)ergodicObjectWithKey:(NSString *)key callback:(void(^)(id obj))callback {
    if (!callback || !key) return;
    [[self dmsWithKey:key] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DeallocMonitor * _Nonnull obj, BOOL * _Nonnull stop) {
        callback(obj.obj);
    }];
}

#pragma mark -

- (void)addDM:(DeallocMonitor *)dm key:(NSString *)key {
    [_lock lock];
    NSMutableDictionary *dict = _dict[key];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        _dict[key] = dict;
    }
    
    if (dict[dm.objId]) {
        [dm invalidate];
    } else {
        dict[dm.objId] = dm;
    }
    [_lock unlock];
}

- (void)removeDM:(DeallocMonitor *)dm key:(NSString *)key {
    [_lock lock];
    NSMutableDictionary *dict = _dict[key];
    if (dict) {
        dict[dm.objId] = nil;
        if (dict.count == 0) {
            _dict[key] = nil;
        }
    }
    [_lock unlock];
}

- (NSDictionary<NSString *, DeallocMonitor *> *)dmsWithKey:(NSString *)key {
    NSDictionary<NSString *, DeallocMonitor *> *dict;
    [_lock lock];
    dict = [_dict[key] copy];
    [_lock unlock];
    return dict;
}

@end
