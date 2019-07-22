//
//  DeallocMonitor.h
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/19.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeallocMonitor : NSObject
@property (nonatomic, readonly) NSString *dmId;
@property (nonatomic, weak, readonly) id obj;
@property (nonatomic, readonly) NSString *objId;
+ (instancetype)monitorWithObj:(id)obj objDelloc:(void(^)(DeallocMonitor *dm))monitor;
- (void)invalidate;
@end
