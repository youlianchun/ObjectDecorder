//
//  IdenticalManager.h
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/20.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "SingleObject.h"
#import "Identical.h"

@class InfoClass;

NS_ASSUME_NONNULL_BEGIN

@interface IdenticalManager : SingleObject
+ (instancetype)share;
@property (nonatomic, strong, readonly) Identical<InfoClass *> *infoClass;
@end

NS_ASSUME_NONNULL_END
