//
//  InfoClass.m
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/20.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "InfoClass.h"

@implementation InfoClass

- (void)dealloc {
    NSLog(@"dealloc: %@", self.str);
}

@end
