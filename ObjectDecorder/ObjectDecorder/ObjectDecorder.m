//
//  ObjectDecorder.m
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/19.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "ObjectDecorder.h"
#import "DeallocMonitor.h"

@interface ObjectDecorder()
@property (nonatomic, copy) NSMutableDictionary <NSString *, NSMutableDictionary<NSString *, DeallocMonitor *> *> *dict;
@end

@implementation ObjectDecorder

- (void)addObject:(id)object key:(NSString *)key {
    if (!object || !key) return;
    NSMutableDictionary *dict = [self subDict:key];
    __weak typeof(self) wself = self;
    DeallocMonitor *dm = [DeallocMonitor monitorWithObj:object objDelloc:^(DeallocMonitor *dm){
        dict[dm.objId] = nil;
        if (dict.count == 0) {
            wself.dict[key] = nil;
        }
    }];
    if (dict[dm.objId]) {
        [dm invalidate];
        return;
    }
    dict[dm.objId] = dm;
}

- (void)ergodicObjectWithKey:(NSString *)key callback:(void(^)(id obj))callback {
    if (!callback || !key) return;
    [self.dict[key] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DeallocMonitor * _Nonnull obj, BOOL * _Nonnull stop) {
        callback(obj.obj);
    }];
}

- (NSMutableDictionary <NSString *, DeallocMonitor*> *)subDict:(NSString *)key {
    NSMutableDictionary *dict = self.dict[key];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        self.dict[key] = dict;
    }
    return dict;
}

- (NSMutableDictionary *)dict {
    if (!_dict) {
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}

@end
