//
//  TGTopicNewM.m
//  baisibudejie
//
//  Created by targetcloud on 2017/5/30.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import "TGTopicNewM.h"
#import "TGCommentNewM.h"
#import "TGUserNewM.h"

@implementation TGTopicNewM
{
    CGFloat _cellHeight;
    CGFloat _commentVH;
    CGRect _middleFrame;
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"top_comments" : [TGCommentNewM class]
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"ID" : @"id",
             
             @"video_playfcount" : @"video.playfcount",
             @"video_width" : @"video.width",
             @"video_height" : @"video.height",
             @"video_uri" : @"video.video[0]",
             @"video_duration" : @"video.duration",
             @"video_playcount" : @"video.playcount",
             @"video_thumbnail" : @"video.thumbnail[0]",
             @"video_thumbnail_small" : @"video.thumbnail_small[0]",
             
             @"image_medium" : @"image.medium[0]",
             @"image_big" : @"image.big[0]",
             @"image_height" : @"image.height",
             @"image_width" : @"image.width",
             @"image_small" : @"image.small[0]",
             @"image_thumbnail_small" :@"image.thumbnail_small[0]",
             
             @"images_gif" :@"gif.images[0]",
             @"gif_width" :@"gif.width",
             @"gif_thumbnail" :@"gif.gif_thumbnail[0]",
             @"gif_height" :@"gif.height",
             
             @"audio_playfcount" :@"audio.playfcount",
             @"audio_height" :@"audio.height",
             @"audio_width" :@"audio.width",
             @"audio_duration" :@"audio.duration",
             @"audio_playcount" :@"audio.playcount",
             @"audio_uri" :@"audio.audio[0]",
             @"audio_thumbnail" :@"audio.thumbnail[0]",
             @"audio_thumbnail_small" :@"audio.thumbnail_small[0]",
             
             };
}

-(NSString * )image{
    return [_type isEqualToString:@"video"] ? _video_thumbnail :
           [_type isEqualToString:@"image"] ? _image_big :
           [_type isEqualToString:@"gif"] ? _gif_thumbnail :
           [_type isEqualToString:@"audio"] ? _audio_thumbnail : @"";
}

-(NSInteger) width{
    return [_type isEqualToString:@"video"] ? _video_width :
           [_type isEqualToString:@"image"] ? _image_width :
           [_type isEqualToString:@"gif"] ? _gif_width :
           [_type isEqualToString:@"audio"] ? _audio_width : 0;
}

-(NSInteger) height{
    return [_type isEqualToString:@"video"] ? _video_height :
           [_type isEqualToString:@"image"] ? _image_height :
           [_type isEqualToString:@"gif"] ? _gif_height :
           [_type isEqualToString:@"audio"] ? _audio_height : 0;
}

- (CGFloat)cellHeight{
    if (_cellHeight) return _cellHeight;
    _commentVH = 0;
    _cellHeight += 55;
    
    CGSize textMaxSize = CGSizeMake(ScreenW - 2 * Margin , MAXFLOAT);
    _cellHeight += [self.text boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height + Margin;
    //   [self.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textMaxSize].height;
    
    if (![self.type isEqualToString: @"text"]) { //图片、视频
        CGFloat middleW = textMaxSize.width;
        CGFloat middleH = middleW * self.height / self.width;
        if (middleH >= ScreenH) { // 显示的图片高度超过一个屏幕，就是超长图片
            middleH = 300;
            _bigPicture = YES;
        }
        CGFloat middleY = _cellHeight;
        CGFloat middleX = Margin;
        _middleFrame = CGRectMake(middleX, middleY, middleW, middleH);
        //TGLog(@"%ld,%ld, %@ , %@ ,%@", self.height, self.width,self.type,self.text, NSStringFromCGRect(_middleFrame))
        _cellHeight += middleH + Margin;
    }
    
    if (self.top_comments.count > 0){//评论
        textMaxSize = CGSizeMake(ScreenW - 2 * Margin - 10, MAXFLOAT);
        NSMutableAttributedString *attrStrM = [[NSMutableAttributedString alloc] init];
        for (int i=0 ; i <self.top_comments.count; i++){
            TGCommentNewM * com = self.top_comments[i];
            NSString *content = com.content;
            NSString *username = com.u.name;
            NSString *cmtText = [NSString stringWithFormat:@"%@ : %@", username,content];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString : cmtText];
            [attrStr addAttribute:NSFontAttributeName
                            value:[UIFont systemFontOfSize:12.0f]
                            range:NSMakeRange(0, attrStr.length)];
            [attrStr addAttribute:NSForegroundColorAttributeName
                            value:TGColor(62, 114, 166)
                            range:NSMakeRange(0, username.length)];
            [attrStrM appendAttributedString:attrStr];
            if (i != self.top_comments.count-1){
                [attrStrM appendAttributedString: [[NSAttributedString alloc] initWithString:@"\n"]];
            }
            _commentVH += [cmtText boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size.height;
        }
        _attrStrM = attrStrM;
        _cellHeight += (_commentVH + 10);
    }
    _cellHeight += 35 ;//工具条
    //TGLog(@"_cellHeight,%@,%@,%f",self.type, self.text, _cellHeight)
    return _cellHeight;
}

- (NSString *)passtime{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *create = [fmt dateFromString:_passtime];
    if (create.isThisYear) { // 今年
        if (create.isToday) { // 今天
            NSDateComponents *cmps = [[NSDate date] deltaFrom:create];
            if (cmps.hour >= 1) { // 时间差距 >= 1小时
                return [NSString stringWithFormat:@"%zd小时前", cmps.hour];
            } else if (cmps.minute >= 1) { // 1小时 > 时间差距 >= 1分钟
                return [NSString stringWithFormat:@"%zd分钟前", cmps.minute];
            } else { // 1分钟 > 时间差距
                return @"刚刚";
            }
        } else if (create.isYesterday) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm:ss";
            return [fmt stringFromDate:create];
        } else { // 其他
            fmt.dateFormat = @"MM-dd HH:mm:ss";
            return [fmt stringFromDate:create];
        }
    } else { // 非今年
        return _passtime;
    }
}
@end
