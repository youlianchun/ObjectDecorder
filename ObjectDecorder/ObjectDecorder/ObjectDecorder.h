//
//  ObjectDecorder.h
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/19.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectDecorder<ObjectType> : NSObject

- (void)addObject:(ObjectType)object key:(NSString *)key;

- (void)ergodicObjectWithKey:(NSString *)key callback:(void(^)(ObjectType obj))callback;

@end

NS_ASSUME_NONNULL_END

