//
//  DeallocMonitor.m
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/19.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "DeallocMonitor.h"
#import <objc/runtime.h>

typedef void (*INVOKE)(id, SEL, id);

@interface DMInvocation : NSObject
@property (nonatomic, readonly) NSString *dmiId;
+ (instancetype)invocationWithTarget:(id)target sel:(SEL)sel;
@end

@implementation DMInvocation
{
    __weak id _target;
    SEL _sel;
    NSString *_dmiId;
    INVOKE _invoke;
}

+ (instancetype)invocationWithTarget:(id)target sel:(SEL)sel {
    if (![target respondsToSelector:sel]) return nil;
    return [[self alloc] initWithTarget:target sel:sel];
}

- (instancetype)initWithTarget:(id)target sel:(SEL)sel {
    if (self = [super init]) {
        _target = target;
        _sel = sel;
        _invoke = (INVOKE)[_target methodForSelector:_sel];
    }
    return self;
}

- (NSString *)dmiId {
    if (!_dmiId) {
        _dmiId = [NSString stringWithFormat:@"%ld", self.hash];
    }
    return _dmiId;
}

- (void)invokeWithSender:(id)sender {
    _invoke(_target, _sel, sender);
}

@end


@interface DMDecorder : NSObject
@end

@implementation DMDecorder
{
    NSMutableDictionary <NSString*, DMInvocation *> *_monitorDict;
    __weak id _sender;
}
- (instancetype)initWithSender:(id)sender {
    if (self = [super init]) {
        _monitorDict = [NSMutableDictionary dictionary];
        _sender = sender;
    }
    return self;
}

- (void)dealloc {
    __strong id sender = _sender;
    [_monitorDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, DMInvocation * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invokeWithSender:sender];
    }];
}

- (void)addInvocation:(DMInvocation *)invocation {
    if (!invocation) return;
    _monitorDict[invocation.dmiId] = invocation;
}

- (void)remiveInvocation:(DMInvocation *)invocation {
    if (!invocation) return;
    _monitorDict[invocation.dmiId] = nil;
}

@end


@interface NSObject (DeallocMonitor)
@property (nonatomic, strong) DMDecorder *dmDecorder;
@end

@implementation NSObject (DeallocMonitor)
- (DMDecorder *)dmDecorder {
    return objc_getAssociatedObject(self, @selector(dmDecorder));
}

- (void)setDmDecorder:(DMDecorder *)dmDecorder {
    objc_setAssociatedObject(self, @selector(dmDecorder), dmDecorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addDMInvocation:(DMInvocation *)invocation {
    if (!invocation) return;
    if (!self.dmDecorder) {
        self.dmDecorder = [[DMDecorder alloc] initWithSender:self];
    }
    [self.dmDecorder addInvocation:invocation];
}

- (void)removeDMInvocation:(DMInvocation *)invocation {
    if (!invocation) return;
    [self.dmDecorder  remiveInvocation:invocation];
}

@end


@implementation DeallocMonitor
{
    __weak id _weakObj;
    void(^_monitor)(DeallocMonitor *dm);
    DMInvocation *_invocation;
}
@synthesize dmId = _dmId, objId = _objId;

+ (instancetype)monitorWithObj:(id)obj objDelloc:(void(^)(DeallocMonitor *dm))monitor {
    if (!obj || !monitor) return nil;
    return [[self alloc] initWithObj:obj objDelloc:monitor];
}

- (instancetype)initWithObj:(id)obj objDelloc:(void(^)(DeallocMonitor *dm))monitor {
    if (self = [super init]) {
        _weakObj = obj;
        _objId = [NSString stringWithFormat:@"%ld", [obj hash]];
        _monitor = monitor;
        _invocation = [DMInvocation invocationWithTarget:self sel:@selector(weakObjDeallocMonitor)];
        [obj addDMInvocation:_invocation];
    }
    return self;
}

- (id)obj {
    return _weakObj;
}

- (NSString *)dmId {
    if (!_dmId) {
        _dmId = [NSString stringWithFormat:@"%ld", self.hash];
    }
    return _dmId;
}

- (void)weakObjDeallocMonitor {
    _weakObj = nil;
    _invocation = nil;
    !_monitor?:_monitor(self);
}

- (void)invalidate {
    if (_invocation && _weakObj) {
        [_weakObj removeDMInvocation:_invocation];
        _weakObj = nil;
        _invocation = nil;
    }
}

-(void)dealloc {
    [self invalidate];
}

@end
