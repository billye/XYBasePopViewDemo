//
//  ViewController.m
//  PopViewDemo
//
//  Created by billyye on 16/2/22.
//  Copyright © 2016年 billyye. All rights reserved.
//

#import "ViewController.h"
#import "XYTestPopView.h"
#import "XYBaseConentView+YCPopView.h"
@interface ViewController ()
@property (nonatomic, strong) UIButton *popButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self layoutSubviews];
}

#pragma mark - UI Methods
- (void)setupSubViews
{
    [self.view addSubview:self.popButton];
}

- (void)layoutSubviews
{
    _popButton.center = CGPointMake(CGRectGetMidX(self.view.frame),CGRectGetMaxY(self.view.frame)- _popButton.frame.size.height);
    
}

- (UIButton *)popButton
{
    if (_popButton == nil) {
        _popButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _popButton.frame = CGRectMake(0,0,200,30);
        _popButton.backgroundColor = [UIColor grayColor];
        [_popButton setTitle:@"show popView" forState:UIControlStateNormal];
        [_popButton addTarget:self action:@selector(onPopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _popButton;
}

#pragma mark - IBAction Methods
- (void)onPopButtonClicked:(UIButton *)button
{
    XYTestPopView *popView = [[XYTestPopView alloc] initWithFrame:CGRectMake(0,0,300,400)];
    popView.backgroundColor = [UIColor redColor];
    [popView showViewInSuperView:self.view
                    animatedType:YCPopAnimatedTypeFromBottom
                           model:nil
                popCompleteBlock:^(id model) {
        
    }];
}


@end
