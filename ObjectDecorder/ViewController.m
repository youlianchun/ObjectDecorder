//
//  ViewController.m
//  ObjectDecorder
//
//  Created by YLCHUN on 2019/7/20.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "ViewController.h"
#import "IdenticalManager.h"
#import "InfoClass.h"

@interface ViewController ()
@property (nonatomic, strong) InfoClass *infoClass;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    InfoClass *infoClass = [InfoClass new];
    [[IdenticalManager share].infoClass addObject:infoClass];
    [[IdenticalManager share].infoClass addObject:infoClass];
//    self.infoClass = [InfoClass new];
//    self.infoClass.uid = self.navigationController.viewControllers.count % 3;
//    self.infoClass.str = [NSString stringWithFormat:@"str_ %d", self.infoClass.uid];
//    [[IdenticalManager share].infoClass addObject:self.infoClass];
//    [[IdenticalManager share].infoClass addObject:self.infoClass];

    // Do any additional setup after loading the view.
}

- (IBAction)IdenticalAction:(UIButton *)sender {
    InfoClass *infoClass = [InfoClass new];
    infoClass.uid = self.infoClass.uid;
    infoClass.str = @"123456";
    [[IdenticalManager share].infoClass identicalWithObject:infoClass usingBlock:^(InfoClass * _Nonnull from, InfoClass * _Nonnull to) {
        to.str = from.str;
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = self.infoClass.str;
}

@end
