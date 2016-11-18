//
//  HDPAttributeLabel.h
//  HengDaPoints
//
//  Created by Dokay on 16/1/22.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreText;

@protocol HDPAttributeLabelDelegate <NSObject>

- (void)clickTextWithIndex:(CFIndex)index;

@end

@interface HDPAttributeLabel : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor  *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;

- (CGSize)textBoundingSize;

@property (nonatomic, weak) id<HDPAttributeLabelDelegate> delegate;

/**
 *  设置某段字的颜色
 *
 *  @param color color to set
 *  @param location from index
 *  @param length length of text to change
 */
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length;

/**
 *  设置某段字的背景颜色,iOS 10 +
 *
 *  @param color color to set
 *  @param location from index
 *  @param length length of text to change
 */
- (void)setBackGroundColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length;

/**
 *  设置某段字的字体
 *
 *  @param font     font to be set
 *  @param location from index
 *  @param length length of text to change
 */
- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length;

/**
 *  设置某段字的下划线风格
 *
 *  @param style    style to be set
 *  @param location from index
 *  @param length   length of text to change
 */
- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length;

@end
