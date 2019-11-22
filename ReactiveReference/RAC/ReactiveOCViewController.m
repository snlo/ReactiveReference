//
//  ReactiveOCViewController.m
//  ReactiveReference
//
//  Created by snlo on 2019/9/24.
//  Copyright © 2019 snlo. All rights reserved.
//

#import "ReactiveOCViewController.h"

#import <ReactiveObjC/ReactiveObjC.h>

static NSString * kIdentifier = @"RACViewController_cell";

@interface ReactiveOCViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelTest;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTest;
@property (weak, nonatomic) IBOutlet UIButton *buttonTest;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) id tableviewDelegate;
@property (nonatomic, strong) id tableviewDataSource;

@end

@implementation ReactiveOCViewController

- (void)dealloc {
    NSLog(@"销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"RAC";
    self.view.backgroundColor = [UIColor yellowColor];
    
    @weakify(self);
    
    NSArray * array = @[@(1), @(2), @(3), @(4), @(5)];
    
#pragma mark -- 映射
    NSLog(@" -map- %@",[[[array rac_sequence] map:^id _Nullable(id  _Nullable value) {
        return @([value integerValue] + 3);
    }] array]);
#pragma mark -- 过滤
    NSLog(@" -filter- %@", [[[array rac_sequence] filter:^BOOL(id  _Nullable value) {
        return [value integerValue] > 3;
    }] array]);
#pragma mark -- 折叠
    NSLog(@" -fold- %@",[[[array rac_sequence] map:^id _Nullable(id  _Nullable value) {
        return [value stringValue];
    }] foldLeftWithStart:@"" reduce:^id _Nullable(id  _Nullable accumulator, id  _Nullable value) {
        return [accumulator stringByAppendingString:value];
    }]);
    
#pragma mark -- 信号绑定(单向)
    
    RACSignal * signalMail = [self.textFieldTest.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @(
        [value rangeOfString:@"@"].location != NSNotFound &&
        [value rangeOfString:@".com"].location != NSNotFound
        );
    }];
    
    RAC(self.buttonTest, enabled) = signalMail;
    
    [RACObserve(self.buttonTest, enabled) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        NSLog(@"button - enabled : x %@",NSStringFromClass([x class]));
        if ([x boolValue]) {
            self.buttonTest.backgroundColor = [UIColor blueColor];
        } else {
            self.buttonTest.backgroundColor = [UIColor grayColor];
        }
    }];
    RAC(self.textFieldTest, textColor) = [signalMail map:^id _Nullable(id  _Nullable value) {
        if ([value boolValue]) {
            return [UIColor greenColor];
        } else {
            return [UIColor redColor];
        }
    }];
    

    RAC(self.labelTest, textColor) = [RACSignal combineLatest:@[RACObserve(self.buttonTest, enabled), self.textFieldTest.rac_textSignal] reduce:^(NSNumber * x1, NSString * x2){
        if ([x1 boolValue] && x2.length > 5) {
            return [UIColor greenColor];
        } else {
            return [UIColor redColor];
        }
    }];
    

#pragma mark -- 订阅信号
    [[self.buttonTest rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.labelTest.text = @"uuuu";
    }];
    
#pragma mark -- 信号绑定(双向)
    RACChannelTo(self.labelTest, text) = self.textFieldTest.rac_newTextChannel;
    
#pragma mark -- 替换代理(只能替换无返回值的代理)
    self.tableView.dataSource = self;
    
    self.tableviewDelegate = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UITableViewDelegate)];
    [[self.tableviewDelegate rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"点击了CELL");
    }];
    self.tableView.delegate = self.tableviewDelegate;
    
    [[self rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:) fromProtocol:@protocol(UITableViewDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"点击了-CELL");
        [x.first deselectRowAtIndexPath:x.second animated:YES];
    }];
    self.tableView.delegate = self;
    
    
    

    
    [self click];
    [self click_double];
    [self notification];
    
}

#pragma mark -- UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
        [tableView registerClass:cell.class forCellReuseIdentifier:kIdentifier];
    }

    cell.backgroundColor = [UIColor blueColor];

    return cell;
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

// MARK: - 单击按钮事件流
- (void)click {
    [[self.buttonTest rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"点击事件：%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"错误：%@",error);
    } completed:^{
        NSLog(@"完成");
    }];
}

// MARK: - 双击按钮事件流
- (void)click_double {
    RACScheduler * scheduler = [RACScheduler scheduler];

    [[[[[self.buttonTest rac_signalForControlEvents:UIControlEventTouchUpInside]
       bufferWithTime:0.250 onScheduler:scheduler]
       map:^id _Nullable(RACTuple * _Nullable value) {
        NSLog(@"映射：%@",value);
        return @(value.count);
    }] filter:^BOOL(id  _Nullable value) {
        NSLog(@"过滤：%@",value);
        return [value integerValue] == 2;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"双击结果：%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"错误：%@",error);
    } completed:^{
        NSLog(@"完成");
    }];
}

// MARK: - 通知
- (void)notification {
    //订阅通知观察者
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"notification_name" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@":%@",x.userInfo);
    }];
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notification_name" object:nil userInfo:@{@"user_name":@"noti"}];
    
}

@end
