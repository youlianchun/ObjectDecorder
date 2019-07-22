//
//  DeallocMonitor.h
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/19.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeallocMonitor<ObjectType> : NSObject
@property (nonatomic, readonly) NSString *dmId;
@property (nonatomic, weak, readonly) ObjectType obj;
@property (nonatomic, readonly) NSString *objId;

+ (instancetype)monitorWithObj:(ObjectType)obj objDelloc:(void(^)(DeallocMonitor *dm))monitor;
- (void)invalidate;
@end
