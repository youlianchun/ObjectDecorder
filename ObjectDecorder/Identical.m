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
#import "YYModel.h"

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
    void(^_autoIdentical)(id from, id to);
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

- (void)setAutoIdentical:(void(^)(id from, id to))block {
    _autoIdentical = block;
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
    if (_autoIdentical) {
        [self identicalWithObject:object usingBlock:_autoIdentical];
    }
    dispatch_async(_queue, ^{
        [self->_decorder addObject:object key:key];
    });
}

- (void)identicalWithObject:(id)object usingBlock:(void(^)(id from, id to))block {
    if (!block) return;
    NSString *key = [self keyWithObject:object];
    if (key.length == 0) return;
    dispatch_async(_queue, ^{
        [self->_decorder ergodicObjectWithKey:key callback:^(id  _Nonnull obj) {
            if ([obj isEqual:object]) return;
            block(object, obj);
        }];
    });
}

- (void)identicalWithObject:(id)object {
    if (_autoIdentical) {
        [self identicalWithObject:object usingBlock:_autoIdentical];
    }
    else {
        [self identicalWithObject:object usingBlock:^(id  _Nonnull from, id  _Nonnull to) {
            [to yy_modelSetWithJSON:[from yy_modelToJSONString]];
        }];
    }
}

@end


@implementation Identical (Auto)

+ (instancetype)identicalWithClass:(Class)cls property:(SEL)property auto:(void(^)(id from, id to))block {
    Identical *identical = [self identicalWithClass:cls property:property];
    [identical setAutoIdentical:block];
    return identical;
}

@end
