//
//  YYModelExample.m
//  YYKitDemo_First
//
//  Created by chen on 2017/3/7.
//  Copyright © 2017年 lucky. All rights reserved.
//

#import "YYModelExample.h"
#import "YYKit.h"

////////////////////////////////////////////////////////////////////////////////
#pragma mark Simple Object Example

@interface YYBook : NSObject
@property (copy,   nonatomic) NSString* name;
@property (assign, nonatomic) uint64_t pages;
@property (strong, nonatomic) NSDate* publishDate;
@end

@implementation YYBook
@end

static void SimpleObjectExample() {
    
}


@implementation YYModelExample

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UILabel* label = [[UILabel alloc] init];
    label.size = CGSizeMake(kScreenWidth, 30);
    // !!!:视图的中心和屏幕的中心
    label.centerY = self.view.height / 2 - (kiOS7Later ? 0 : 32);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"See code in YYModelExample.m";
    [self.view addSubview:label];
    
    
    [self runExample];
}

- (void)runExample {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
