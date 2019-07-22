//
//  Identical.m
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/20.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "Identical.h"
#import "ObjectDecorder.h"
#import <objc/runtime.h>

typedef enum  {
    kProperty_Number,
    kProperty_String,
    kProperty_Struct,
    kProperty_Pointer,
    kProperty_Object,
    kProperty_Unknown,
}kPropertyType;

@implementation Identical
{
    ObjectDecorder *_decorder;
    Class _cls;
    SEL _property;
    kPropertyType _type;
    NSString *_keyPath;
    dispatch_queue_t _queue;
}

+ (instancetype)identicalWithClass:(Class)cls property:(SEL)property  {
    kPropertyType type = getPropertyType(cls, property);
    if (type == kProperty_Unknown) {
        //log
        return nil;
    }
    if (type != kProperty_Number && type != kProperty_String) {
        //log
        return nil;
    }
    return [[self alloc] initWithClass:cls property:property type:type];
}

- (instancetype)initWithClass:(Class)cls property:(SEL)property type:(kPropertyType)type {
    self = [super init];
    if (self) {
        _cls = cls;
        _property = property;
        _type = type;
        _keyPath = NSStringFromSelector(property);
        _decorder = [ObjectDecorder new];
        _queue = dispatch_queue_create("com.queue.identical", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

static kPropertyType getPropertyType(Class cls, SEL property) {
    kPropertyType type = kProperty_Unknown;
    objc_property_t property_t = class_getProperty(cls, sel_getName(property));
    if (property_t == NULL) return type;
    const char *attr = property_getAttributes(property_t);
    if (attr == NULL) return type;
    if (attr[0] == 'T') {
        switch (attr[1]) {
            case 'c':
                type = kProperty_String;
                break;
            case 'd':
            case 'i':
            case 'f':
            case 'l':
            case 's':
            case 'I':
                type = kProperty_Number;
                break;
            case '@':
            {
                type = kProperty_Object;
                
                int loc = 2;
                int len = 0;
                int i = loc;
                while (attr[i] != '\n' && attr[i] != ',') {
                    i ++;
                    len ++;
                }
                if (attr[loc] == '"') {
                    loc = loc + 1;
                    len = len - 2;
                }
                char *clsName = malloc(sizeof(char) * len);
                strncpy(clsName, attr + loc, len);
                Class cls = objc_getClass(clsName);
                free(clsName);
                
                for (Class tcls = cls; tcls; tcls = class_getSuperclass(tcls)) {
                    if (tcls == [NSString class]) {
                        type = kProperty_String;
                        break;
                    }
                    else if (tcls == [NSNumber class]) {
                        type = kProperty_Number;
                        break;
                    }
                }
            }
                break;
            case '^':
                type = kProperty_Pointer;
                break;
            case '{':
                type = kProperty_Struct;
                break;
            default:
                break;
        }
    }
    return type;
}

- (NSString *)keyWithObject:(id)object {
    if (![object isKindOfClass:_cls]) return nil;
    id val = [object valueForKeyPath:_keyPath];
    if (!val) return nil;
    return [NSString stringWithFormat:@"%@", val];
}

- (void)addObject:(id)object {
    NSString *key = [self keyWithObject:object];
    if (key.length == 0) return;
    dispatch_async(_queue, ^{
        [self->_decorder addObject:object key:key];
    });
}

- (void)identicalWithObject:(id)object usingBlock:(void(^)(id from, id to))block completion:(void(^)(void))completion {
    if (!block) return;
    NSString *key = [self keyWithObject:object];
    if (key.length == 0) return;
    dispatch_async(_queue, ^{
        __block BOOL flag = NO;
        [self->_decorder ergodicObjectWithKey:key callback:^(id  _Nonnull obj) {
            if ([obj isEqual:object]) return;
            flag = YES;
            block(object, obj);
        }];
        if (!flag || !completion) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

@end


@implementation AutoIdentical
{
    void(^_autoIdentical)(id from, id to);
    void(^_completion)(id from);
}

+ (instancetype)identicalWithClass:(Class)cls property:(SEL)property auto:(void(^)(id from, id to))block completion:(void(^)(id from))completion {
    AutoIdentical *ai = [super identicalWithClass:cls property:property];
    [ai setAutoIdentical:block];
    [ai setCompletion:completion];
    return ai;
}

- (void)setAutoIdentical:(void(^)(id from, id to))block {
    _autoIdentical = block;
}

- (void)setCompletion:(void(^)(id from))block {
    _completion = block;
}

- (void)addObject:(id)object {
    [self identicalWithObject:object completion:_completion];
    [super addObject:object];
}

- (void)identicalWithObject:(id)object completion:(void(^)(id from))completion {
    [super identicalWithObject:object usingBlock:_autoIdentical completion:^{
        completion(object);
    }];
}

@end
