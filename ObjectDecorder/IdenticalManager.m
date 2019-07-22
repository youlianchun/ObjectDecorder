//
//  IdenticalManager.m
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/20.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "IdenticalManager.h"
#import "InfoClass.h"

@implementation IdenticalManager
@synthesize infoClass = _infoClass;

+ (instancetype)share {
    return [[self alloc] init];
}

- (Identical<InfoClass *> *)infoClass {
    if (!_infoClass) {
        _infoClass = [Identical identicalWithClass:InfoClass.class property:@selector(uid)];
    }
    return _infoClass;
}

@end
