//
//  HDPAttributeLabel.m
//  HengDaPoints
//
//  Created by Dokay on 16/1/22.
//  Copyright © 2016年 dj226. All rights reserved.
//

#import "HDPAttributeLabel.h"

@interface HDPAttributeLabel()

@property (nonatomic, strong) NSMutableAttributedString *attString;

@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, assign) CGFloat suggestHeight;

@end

@implementation HDPAttributeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI
{
    self.userInteractionEnabled = YES;
}

- (void)dealloc
{
    if (_frameRef) {
        CFRelease(_frameRef);
    }
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"thread:%d",[NSThread isMainThread]);
    if (self.text) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, 0.0);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge  CFAttributedStringRef)_attString);
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathAddRect(pathRef,NULL , CGRectMake(0, 0, rect.size.width, rect.size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), pathRef,NULL );
        
        CFRelease(framesetter);
        
        CGContextTranslateCTM(context, 0, -rect.size.height);
        CTFrameDraw(frame, context);
        CGContextRestoreGState(context);
        
        if (_frameRef) {
            CFRelease(_frameRef);
        }
        _frameRef = frame;
        
        CGPathRelease(pathRef);
        UIGraphicsPushContext(context);
    }
}

- (CGSize)textBoundingSize
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge  CFAttributedStringRef)_attString);
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef,NULL , CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    CGFloat widthConstraint = self.frame.size.width; // Your width constraint, using 500 as an example
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(
                                                                        framesetter, /* Framesetter */
                                                                        CFRangeMake(0, _text.length), /* String range (entire string) */
                                                                        NULL, /* Frame attributes */
                                                                        CGSizeMake(widthConstraint, CGFLOAT_MAX), /* Constraints (CGFLOAT_MAX indicates unconstrained) */
                                                                        NULL /* Gives the range of string that fits into the constraints, doesn't matter in your situation */
                                                                        );
    CFRelease(framesetter);
    
    return suggestedSize;
}

- (void)setText:(NSString *)text
{
    _text = text;
    if (!text) {
        self.attString = nil;
    }else{
        self.attString = [[NSMutableAttributedString alloc] initWithString:text];
        [self setFont:self.font];
        [self setTextColor:self.textColor];
        [self setTextAlignment:self.textAlignment];
    }
}

- (void)setFrameForLabelWithFont:(UIFont*)font
{
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    CGSize size = self.frame.size;
    if (self.text){
        size =[self.text boundingRectWithSize:CGSizeMake(size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }
    CGRect frame = self.frame;
    frame.size.height = size.height;
    [self setFrame:frame];
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [_attString addAttribute:(__bridge NSString *)kCTFontAttributeName
                       value:(__bridge id)fontRef
                       range:NSMakeRange(0, _attString.length)];
//    [self setFrameForLabelWithFont:font];
    CFRelease(fontRef);
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [_attString addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName value:(id)textColor.CGColor range:NSMakeRange(0, _attString.length)];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    
    CTTextAlignment alignment = NSTextAlignmentToCTTextAlignment(textAlignment);
    
    CTParagraphStyleSetting paraStyles[1] = {
        {.spec = kCTParagraphStyleSpecifierAlignment,
            .valueSize = sizeof(CTTextAlignment),
            .value = (const void*)&alignment},
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(paraStyles,2);
    
    [_attString addAttribute:(__bridge NSString*)(kCTParagraphStyleAttributeName) value:(__bridge id)style range:NSMakeRange(0,[self.text length])];
    
    CFRelease(style);
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    _lineBreakMode = lineBreakMode;
    CTLineBreakMode coreTextLineMode = (CTLineBreakMode)lineBreakMode;
    
    CTParagraphStyleSetting paraStyles[1] = {
        {.spec = kCTParagraphStyleSpecifierLineBreakMode,
            .valueSize = sizeof(CTLineBreakMode),
            .value = (const void*)&coreTextLineMode},
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(paraStyles,2);
    [_attString addAttribute:(__bridge NSString*)(kCTParagraphStyleAttributeName) value:(__bridge id)style range:NSMakeRange(0,[self.text length])];
    
    CFRelease(style);
}

/**
 *  设置某段字的颜色
 *
 *  @param color color to set
 *  @param location from index
 *  @param length length of text to change
 */
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length
{
    if (location < 0||location>self.text.length-1||length+location>self.text.length){
        return;
    }
    [_attString addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName
                       value:(id)color.CGColor
                       range:NSMakeRange(location, length)];
}

/**
 *  设置某段字的背景颜色
 *
 *  @param color color to set
 *  @param location from index
 *  @param length length of text to change
 */
- (void)setBackGroundColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length
{
    if (location < 0||location>self.text.length-1||length+location>self.text.length){
        return;
    }
//    kCTBackgroundColorAttributeName iOS 10 +
    [_attString addAttribute:(__bridge NSString *)kCTBackgroundColorAttributeName
                       value:(id)color.CGColor
                       range:NSMakeRange(location, length)];
}

/**
 *  设置某段字的字体
 *
 *  @param font     font to be set
 *  @param location from index
 *  @param length length of text to change
 */
- (void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length
{
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName,
                                             font.pointSize,
                                             NULL);
    [_attString addAttribute:(__bridge NSString *)kCTFontAttributeName
                       value:(__bridge id)fontRef
                       range:NSMakeRange(location, length)];
    CFRelease(fontRef);
}

/**
 *  设置某段字的下划线风格
 *
 *  @param style    style to be set
 *  @param location from index
 *  @param length   length of text to change
 */
- (void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length
{
    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
        return;
    }
    [_attString addAttribute:(__bridge NSString *)kCTUnderlineStyleAttributeName
                       value:(id)[NSNumber numberWithInt:style]
                       range:NSMakeRange(location, length)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //获取UITouch对象
    UITouch *touch = [touches anyObject];
    //获取触摸点击当前view的坐标位置
    CGPoint location = [touch locationInView:self];
    //获取每一行
    CFArrayRef lines = CTFrameGetLines(self.frameRef);
    CGPoint origins[CFArrayGetCount(lines)];
    //获取每行的原点坐标
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), origins);
    CTLineRef line = NULL;
    CGPoint lineOrigin = CGPointZero;
    for (int i= 0; i < CFArrayGetCount(lines); i++)
    {
        CGPoint origin = origins[i];
        CGPathRef path = CTFrameGetPath(self.frameRef);
        //获取整个CTFrame的大小
        CGRect rect = CGPathGetBoundingBox(path);
        //坐标转换，把每行的原点坐标转换为uiview的坐标体系
        CGFloat y = rect.origin.y + rect.size.height - origin.y;
        //判断点击的位置处于那一行范围内
        if ((location.y <= y) && (location.x >= origin.x))
        {
            line = CFArrayGetValueAtIndex(lines, i);
            lineOrigin = origin;
            break;
        }
    }
    
    location.x -= lineOrigin.x;
    //获取点击位置所处的字符位置，就是相当于点击了第几个字符
    CFIndex index = CTLineGetStringIndexForPosition(line, location);
    //判断点击的字符是否在需要处理点击事件的字符串范围内，这里是hard code了需要触发事件的字符串范围
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(clickTextWithIndex:)]) {
        [self.delegate clickTextWithIndex:index];
    }
    
}

@end
