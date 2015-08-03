//
//  ViewController.m
//  TextViewDemo
//
//  Created by Fanta Xu on 15/7/31.
//  Copyright (c) 2015年 Fanta Xu. All rights reserved.
//

#import "ViewController.h"

#define RGBCOLOR(R,G,B) [UIColor colorWithRed:(R/255) green:(G/255) blue:(B/255) alpha:1.0]

@interface ViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (assign, nonatomic) NSRange topicRange;
@property (assign, nonatomic) NSUInteger maxTextLength;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setTopicText:@"#测试话题测试话题测试话题#"];
    _maxTextLength = _topicRange.length + 20;
    
    UIFont *font = [UIFont  systemFontOfSize:16];
    self.textView.contentMode = UIViewContentModeTopLeft;
    self.textView.delegate = self;
    self.textView.font = font;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setText:(NSString *)text
{
    self.textView.text = text;
}

- (void)formatTopicText
{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self.textView.text];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:_topicRange];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(_topicRange.length, self.textView.text.length-_topicRange.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, self.textView.text.length)];
    [self.textView setAttributedText:attStr];
    
    self.textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:16]};
}

- (void)setTopicText:(NSString *)topicStr
{
    if (topicStr && topicStr.length) {
        _topicRange = NSMakeRange(0, topicStr.length);
        [self setText:topicStr];
        [self formatTopicText];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 回车键
    if ([text isEqualToString:@"\n"]) {
        [self.textView resignFirstResponder];
        return NO;
    }
    
    //防止编辑或删除话题
    if (_topicRange.length && range.location < _topicRange.length) {
        return NO;
    }
    
    //点选中文联想时居然不调shouldChangeTextInRange就进textViewDidChange，所以假如一开始就是联想输入那么这里不会调到，所以在初始化时就设一下
    textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:16]};
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //检查字符数必须是在textViewDidChange中，因为点选中文联想时居然不调shouldChangeTextInRange就进textViewDidChange
    if (_maxTextLength > 0 && textView.markedTextRange == nil && textView.text.length > _maxTextLength) {
        NSRange lastRange = [textView.text rangeOfComposedCharacterSequenceAtIndex:_maxTextLength - 1];
        if (lastRange.location + lastRange.length > _maxTextLength) {
            textView.text = [textView.text substringToIndex:lastRange.location];
        } else {
            textView.text = [textView.text substringToIndex:_maxTextLength];
        }
        //重新设了text后必须再apply一下话题样式
        [self formatTopicText];
        
        [textView.undoManager removeAllActions];
    }
    //点选中文联想时居然不调shouldChangeTextInRange就进textViewDidChange
    self.textView.typingAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:16]};

    if (textView.text.length > 0) {
        //滚动下
        NSRange range = NSMakeRange(self.textView.text.length - 1, 1);
        [textView scrollRangeToVisible:range];
        
    }
}

@end
