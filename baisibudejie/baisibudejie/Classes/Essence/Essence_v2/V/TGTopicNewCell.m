//
//  TGTopicNewCell.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTopicNewCell.h"
#import "TGTopicNewM.h"
#import "TGCommentNewM.h"
#import "TGUserNewM.h"
#import "TGPicNewV.h"
#import "TGVideoNewV.h"
#import "TGVoiceNewV.h"
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TGTopicNewCell()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageV;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *passtimeLbl;
@property (weak, nonatomic) IBOutlet UILabel *textLbl;
@property (weak, nonatomic) IBOutlet UIButton *dingBtn;
@property (weak, nonatomic) IBOutlet UIButton *caiBtn;
@property (weak, nonatomic) IBOutlet UIButton *repostBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIView *topCmtV;
@property (weak, nonatomic) IBOutlet UILabel *topCmtLbl;
@property (weak, nonatomic) IBOutlet UIImageView *sinaV;
@property (weak, nonatomic) IBOutlet UIImageView *vip;
@property (nonatomic, weak) TGPicNewV *picV;
@property (nonatomic, weak) TGVideoNewV *videoV;
@property (nonatomic, weak) TGVoiceNewV *voiceV;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end

@implementation TGTopicNewCell

- (TGVoiceNewV *)voiceV{
    if (!_voiceV) {
        TGVoiceNewV *voiceV = [TGVoiceNewV viewFromXIB];
        [self.contentView addSubview:voiceV];
        _voiceV = voiceV;
    }
    return _voiceV;
}

- (TGPicNewV *)picV{
    if (!_picV) {
        TGPicNewV *picV = [TGPicNewV viewFromXIB];
        [self.contentView addSubview:picV];
        _picV = picV;
    }
    return _picV;
}

- (TGVideoNewV *)videoV{
    if (!_videoV) {
        TGVideoNewV *videoV = [TGVideoNewV viewFromXIB];
        [self.contentView addSubview:videoV];
        _videoV = videoV;
    }
    return _videoV;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainCellBackground"]];
    self.textLbl.font = [UIFont systemFontOfSize:14];
    self.topCmtLbl.font = [UIFont systemFontOfSize:12];
}

- (void)setTopic:(TGTopicNewM *)topic{
    _topic = topic;

    self.sinaV.hidden = !topic.u.is_v;
    self.vip.hidden = !topic.u.is_vip;
    
    [self.nameLbl setTextColor:topic.u.is_vip ? TGColor(240, 77, 71) : TGColor(0, 128, 128) ];
    
    [self.profileImageV tg_setHeader:topic.u.header];
    
    self.nameLbl.text = topic.u.name;
    self.passtimeLbl.text = topic.passtime;
    self.textLbl.text = topic.text;
    [self setupButtonTitle:self.dingBtn number:topic.up placeholder:@"顶"];
    [self setupButtonTitle:self.caiBtn number:topic.down placeholder:@"踩"];
    [self setupButtonTitle:self.repostBtn number:topic.forward placeholder:@"分享"];
    [self setupButtonTitle:self.commentBtn number:topic.comment placeholder:@"评论"];
    
    self.topCmtV.hidden = topic.top_comments.count <= 0 ;
    if (topic.top_comments.count){
        self.topCmtLbl.attributedText = topic.attrStrM;
    }
    
    self.picV.hidden = !([topic.type.lowercaseString isEqualToString:@"image"] || [topic.type.lowercaseString isEqualToString:@"gif"]);
    self.videoV.hidden = !([topic.type.lowercaseString isEqualToString:@"video"]);
    self.voiceV.hidden = !([topic.type.lowercaseString isEqualToString:@"audio"]);
    if ([topic.type.lowercaseString isEqualToString:@"image"] || [topic.type.lowercaseString isEqualToString:@"gif"]) { // 图片
        self.picV.topic = topic;
    } else if ([topic.type.lowercaseString isEqualToString:@"audio"]) { // 声音
        self.voiceV.topic = topic;
    }else if ([topic.type.lowercaseString isEqualToString:@"video"]) { // 视频
        self.videoV.topic = topic;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if ([self.topic.type.lowercaseString isEqualToString:@"image"] || [self.topic.type.lowercaseString isEqualToString:@"gif"]) { // 图片
        self.picV.frame = self.topic.middleFrame;
    } else if ([self.topic.type.lowercaseString isEqualToString:@"audio"]) { // 声音
        self.voiceV.frame = self.topic.middleFrame;
    }else if ([self.topic.type.lowercaseString isEqualToString:@"video"]) { // 视频
        self.videoV.frame = self.topic.middleFrame;
    }
}

- (void)setupButtonTitle:(UIButton *)button number:(NSInteger)number placeholder:(NSString *)placeholder{
    if (number >= 10000) {
        [button setTitle:[NSString stringWithFormat:@"%.1f万", number / 10000.0] forState:UIControlStateNormal];
    } else if (number > 0) {
        [button setTitle:[NSString stringWithFormat:@"%zd", number] forState:UIControlStateNormal];
    } else {
        [button setTitle:placeholder forState:UIControlStateNormal];
    }
}

- (void)setFrame:(CGRect)frame{
    //frame.size.height += 1;//不采用背景图做为分隔,直接在cell里加一个0.5高度的view作为分隔线
    [super setFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)more:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TGLog(@"点击了[收藏]按钮")
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        TGLog(@"点击了[举报]按钮")
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        TGLog(@"点击了[取消]按钮")
    }]];
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

@end
