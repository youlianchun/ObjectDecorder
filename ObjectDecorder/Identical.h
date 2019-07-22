//
//  Identical.h
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/20.
//  Copyright © 2019 YLCHUN. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Identical<ObjectType> : NSObject
+ (instancetype)identicalWithClass:(Class)cls property:(SEL)property;
- (void)addObject:(ObjectType)object;

- (void)identicalWithObject:(ObjectType)object usingBlock:(void(^)(ObjectType from, ObjectType to))block;
- (void)identicalWithObject:(id)object;
@end

@interface Identical<ObjectType> (Auto)
+ (instancetype)identicalWithClass:(Class)cls property:(SEL)property auto:(void(^)(ObjectType from, ObjectType to))block;
@end
NS_ASSUME_NONNULL_END


