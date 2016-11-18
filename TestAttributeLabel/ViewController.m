//
//  ViewController.m
//  TestAttributeLabel
//
//  Created by Dokay on 16/11/3.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "ViewController.h"
#import "HDPAttributeLabel.h"
#import "TTTAttributedLabel.h"
#import "YYText.h"
#import "ASTextNode.h"

#define KExcuteCount 1
#define kFrame CGRectMake(10, 110, 320, 150)

@interface ViewController ()

@property (nonatomic, strong) NSString *testSring;
@property (nonatomic, strong) NSMutableAttributedString *testAttributedString;

@property (nonatomic, strong) UIView *labelHoldView;

@property (nonatomic, assign) BOOL calculateEnable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.labelHoldView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.labelHoldView];
    
    self.testSring = @"人生若只如初见，何事悲风秋画扇。\n等闲变却故人心，却道故人心易变。\n骊山语罢清宵半，泪雨霖铃终不怨。\n何如薄幸锦衣郎，比翼连枝当日愿。";
    
    
    self.testAttributedString = [[NSMutableAttributedString alloc]initWithString:self.testSring];
    //设置字体和设置字体的范围
    [self.testAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30.0f] range:NSMakeRange(0, 3)];
    //添加文字颜色
    [self.testAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(17, 7)];
    //添加文字背景颜色
    [self.testAttributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(17, 7)];
    //添加下划线
    [self.testAttributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(8, 7)];
    
    self.calculateEnable = YES;
    
//    NSArray *testArray = @[@"testArrtibuteLabel",@"testNormalLabel",@"testCoreTextLabel",@"testAsyncDisplaySingleThread",@"testAsyncDisplayMultipleThread",@"testYYTextSingleThread",@"testYYTextMultipleThread"];
//    
//    for (NSString *selectorString in testArray) {
//        [self performSelector:NSSelectorFromString(selectorString) withObject:nil afterDelay:1];
//    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testArrtibuteLabel];
        
        [self testNormalLabel];
        
        [self testCoreTextLabel];
        
        [self testAsyncDisplaySingleThread];
        [self testAsyncDisplayMultipleThread];
        
        [self testYYTextSingleThread];
        [self testYYTextMultipleThread];
    });
}

- (void)testAsyncDisplayMultipleThread
{
    [self.labelHoldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    ASTextNode *textNode = [[ASTextNode alloc] init];
    textNode.attributedText = self.testAttributedString;
    textNode.backgroundColor = [UIColor greenColor];
    textNode.maximumNumberOfLines = 0;
    
    if (self.calculateEnable) {
        CGSize size = [textNode measure:CGSizeMake(kFrame.size.width,FLT_MAX)];
        textNode.frame = CGRectMake(kFrame.origin.x, kFrame.origin.y, size.width, size.height);
    }else{
        textNode.frame = kFrame;
    }
    
    NSTimeInterval begin, end;
    
    begin = CACurrentMediaTime();
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        
        textNode.frame = CGRectMake(kFrame.origin.x, kFrame.origin.y, kFrame.size.width, kFrame.size.height);
        
        [self.labelHoldView addSubview:textNode.view];
    }
    end = CACurrentMediaTime();
    
    printf("AsyncDisplay multiple thread:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)testAsyncDisplaySingleThread
{
    [self.labelHoldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSTimeInterval begin, end;
    begin = CACurrentMediaTime();
    
    ASTextNode *textNode = [[ASTextNode alloc] init];
    textNode.attributedText = self.testAttributedString;
    textNode.backgroundColor = [UIColor greenColor];
    textNode.maximumNumberOfLines = 0;
    //    CGSize size = [textNode measure:CGSizeMake(kFrame.size.width,FLT_MAX)];
    
    if (self.calculateEnable) {
        CGSize size = [textNode measure:CGSizeMake(kFrame.size.width,FLT_MAX)];
        textNode.frame = CGRectMake(kFrame.origin.x, kFrame.origin.y, size.width, size.height);
    }else{
        textNode.frame = kFrame;
    }
    
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        
        [self.labelHoldView addSubview:textNode.view];
    }
    end = CACurrentMediaTime();
    
    printf("AsyncDisplay single thread:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)testYYTextSingleThread
{
    [self.labelHoldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 1. Create an attributed string.
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.testSring];
    
    // 2. Set attributes to text, you can use almost all CoreText attributes.
    text.yy_font = [UIFont systemFontOfSize:14];
    text.yy_color = [UIColor blackColor];
    
    [text yy_setColor:[UIColor redColor] range:NSMakeRange(17,7)];
    [text yy_setFont:[UIFont systemFontOfSize:30] range:NSMakeRange(0, 3)];
    [text yy_setBackgroundColor:[UIColor orangeColor] range:NSMakeRange(17,7)];
    [text yy_setUnderlineStyle:NSUnderlineStyleSingle range:NSMakeRange(8, 7)];
    
    text.yy_lineSpacing = 3;
    
    NSTimeInterval begin, end;
    begin = CACurrentMediaTime();
    
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        
        YYLabel *label = [YYLabel new];
        label.backgroundColor = [UIColor greenColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.attributedText = text;
        
        if (self.calculateEnable) {
            [label sizeToFit];
        }else{
            label.frame = kFrame;
        }
        
        [self.labelHoldView addSubview:label];
        
    }
    end = CACurrentMediaTime();
    
    printf("YYText single thread:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)testYYTextMultipleThread
{
    [self.labelHoldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 1. Create an attributed string.
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.testSring];
    
    // 2. Set attributes to text, you can use almost all CoreText attributes.
    text.yy_font = [UIFont systemFontOfSize:14];
    text.yy_color = [UIColor blackColor];
    
    [text yy_setColor:[UIColor redColor] range:NSMakeRange(17,7)];
    [text yy_setFont:[UIFont systemFontOfSize:30] range:NSMakeRange(0, 3)];
    [text yy_setBackgroundColor:[UIColor orangeColor] range:NSMakeRange(17,7)];
    [text yy_setUnderlineStyle:NSUnderlineStyleSingle range:NSMakeRange(8, 7)];
    
    text.yy_lineSpacing = 3;
    
    NSTimeInterval begin, end;
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:(kFrame.size) text:text];
    
    begin = CACurrentMediaTime();
    
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        YYLabel *label = [YYLabel new];
        label.displaysAsynchronously = YES;
        label.backgroundColor = [UIColor greenColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        if (self.calculateEnable) {
            label.frame = CGRectMake(kFrame.origin.x, kFrame.origin.y, layout.textBoundingSize.width, layout.textBoundingSize.height);
        }else{
            label.frame = kFrame;
        }
        label.textLayout = layout;
        
        [self.labelHoldView addSubview:label];
    }
    end = CACurrentMediaTime();
    
    printf("YYText multiple thread:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)testCoreTextLabel
{
    [self.labelHoldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSTimeInterval begin, end;
    
    begin = CACurrentMediaTime();
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        HDPAttributeLabel *label = [[HDPAttributeLabel alloc] initWithFrame:kFrame];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor greenColor];
        
        label.text = self.testSring;
        //        [label setBackGroundColor:[UIColor orangeColor] fromIndex:17 length:7];
        [label setFont:[UIFont systemFontOfSize:30.0f] fromIndex:0 length:3];
        [label setColor:[UIColor redColor] fromIndex:17 length:7];
        [label setStyle:kCTUnderlineStyleSingle fromIndex:8 length:7];
        
        if (self.calculateEnable) {
            CGSize size = [label textBoundingSize];
            label.frame = CGRectMake(kFrame.origin.x, kFrame.origin.y, size.width, size.height);
            //        label.frame = kFrame;
        }
        
        [self.labelHoldView addSubview:label];
        
    }
    end = CACurrentMediaTime();
    
    printf("Core Text:   %8.2f ms\n", (end - begin) * 1000);
}


- (void)testNormalLabel
{
    [self.labelHoldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSTimeInterval begin, end;
    
    begin = CACurrentMediaTime();
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:kFrame];
        label.backgroundColor = [UIColor greenColor];
        //自动换行
        label.numberOfLines = 0;
        //设置label的文本
        label.text = self.testSring;
        //label高度自适应
        if (self.calculateEnable) {
            [label sizeToFit];
        }
        [self.labelHoldView addSubview:label];
    }
    end = CACurrentMediaTime();
    
    printf("Normal Label:   %8.2f ms\n", (end - begin) * 1000);
}


- (void)testArrtibuteLabel
{
    [self.labelHoldView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSTimeInterval begin, end;
    
    begin = CACurrentMediaTime();
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:kFrame];
        label.backgroundColor = [UIColor greenColor];
        //自动换行
        label.numberOfLines = 0;
        //设置label的富文本
        label.attributedText = self.testAttributedString;
        //label高度自适应
        if (self.calculateEnable) {
            [label sizeToFit];
        }
        
        [self.labelHoldView addSubview:label];
    }
    end = CACurrentMediaTime();
    
    printf("Normal attribute:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
