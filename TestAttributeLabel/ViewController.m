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
#define kFrame CGRectMake(10, 110, 400, 150)

@interface ViewController ()

@property (nonatomic, strong) NSString *testSring;
@property (nonatomic, strong) NSMutableAttributedString *testAttributedString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
//    [self testArrtibuteLabel];
////
//    [self testNormalLabel];
////
//    [self testCoreTextLabel];
    
    [self testYYText];
    
    [self testAsyncDisplay];
}

- (void)testAsyncDisplay
{
    ASTextNode *textNode = [[ASTextNode alloc] init];
    textNode.attributedText = self.testAttributedString;
    textNode.backgroundColor = [UIColor greenColor];
    textNode.maximumNumberOfLines = 0;
    CGSize size = [textNode measure:CGSizeMake(kFrame.size.width,FLT_MAX)];
    
    NSTimeInterval begin, end;
    
    begin = CACurrentMediaTime();
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        
        
//        textNode.frame = kFrame;
        
        
        textNode.frame = CGRectMake(kFrame.origin.x, kFrame.origin.y, size.width, size.height);
        
        [self.view addSubview:textNode.view];
    }
    end = CACurrentMediaTime();
    
    printf("AsyncDisplay:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)testYYText
{
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
    // get text bounding
    //    layout.textBoundingRect; // get bounding rect
    //    layout.textBoundingSize; // get bounding size
    
    // query text layout
    [layout lineIndexForPoint:CGPointMake(10,10)];
    [layout closestLineIndexForPoint:CGPointMake(10,10)];
    [layout closestPositionToPoint:CGPointMake(10,10)];
    [layout textRangeAtPoint:CGPointMake(10,10)];
    [layout rectForRange:[YYTextRange rangeWithRange:NSMakeRange(10,2)]];
    [layout selectionRectsForRange:[YYTextRange rangeWithRange:NSMakeRange(10,2)]];
    
    begin = CACurrentMediaTime();
    
    for (NSInteger i = 0; i < KExcuteCount; i++) {
        // 3. Set to YYLabel or YYTextView.
        YYLabel *label = [YYLabel new];
        label.displaysAsynchronously = YES;
        label.backgroundColor = [UIColor greenColor];
        label.numberOfLines = 0;
//        label.frame = kFrame;
        label.lineBreakMode = NSLineBreakByWordWrapping;
//        label.attributedText = text;
        
        label.frame = layout.textBoundingRect;
        label.textLayout = layout;
        
        [self.view addSubview:label];
    }
    end = CACurrentMediaTime();
    
    printf("YYText:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)testCoreTextLabel
{
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
       

        CGSize size = [label textBoundingSize];
        label.frame = CGRectMake(10, 110, size.width, size.height);
        
        [self.view addSubview:label];
        
    }
    end = CACurrentMediaTime();
    
    printf("Core Text:   %8.2f ms\n", (end - begin) * 1000);
}


- (void)testNormalLabel
{
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
        [label sizeToFit];
        [self.view addSubview:label];
    }
    end = CACurrentMediaTime();
    
    printf("Normal Label:   %8.2f ms\n", (end - begin) * 1000);
}


- (void)testArrtibuteLabel
{
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
        [label sizeToFit];
        [self.view addSubview:label];
    }
    end = CACurrentMediaTime();
    
    printf("Normal attribute:   %8.2f ms\n", (end - begin) * 1000);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
