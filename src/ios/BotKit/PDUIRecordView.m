//
//  PDUIRecordView.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/5.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIRecordView.h"
#import "PDUITools.h"

@interface PDUIRecordView ()

@property (strong, nonatomic) UIImageView* volumeImage;
@property (strong, nonatomic) UILabel* stateLabel;
@property (assign, nonatomic) BOOL cancel;
@property (assign, nonatomic) float volume;

@end

@implementation PDUIRecordView

- (id)initWithFrame:(CGRect)frame
{
    frame.origin.x = frame.size.width / 2 - 80;
    frame.origin.y = frame.size.height / 2 - 80;
    frame.size.width = 160;
    frame.size.height = 160;
    
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createSubViews];
    }
    return self;
}

- (void)createSubViews
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    self.volumeImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 36, 60, 60)];
    [self addSubview:self.volumeImage];
    
    self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 128, 144, 24)];
    self.stateLabel.font = [UIFont boldSystemFontOfSize:14];
    self.stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel.textColor = [UIColor whiteColor];
    self.stateLabel.layer.cornerRadius = 2;
    self.stateLabel.layer.masksToBounds = YES;
    [self addSubview:self.stateLabel];
    
    [self setCancel:false];
    [self setVolume:0.0f];
}

- (void)setCancel:(BOOL)cancel
{
    _cancel = cancel;
    if (cancel)
    {
        self.stateLabel.text = PDLocalString(@"ReleaseAndCancel");
        self.stateLabel.backgroundColor = [UIColor colorWithRed:0x93/255.0f green:0x31/255.0f blue:0x2F/255.0f alpha:1.0f];
        self.volumeImage.image = [PDUITools imageBundleNamed:@"record_cancel"];
    }
    else
    {
        self.stateLabel.text = PDLocalString(@"SlideUpAndCancel");
        self.stateLabel.backgroundColor = [UIColor clearColor];
        [self setVolumeImage];
    }
}

- (void)setVolume:(float)volume
{
    _volume = volume;
    if (!_cancel) [self setVolumeImage];
}

- (void)setVolumeImage
{
    int level = (int)ceilf(self.volume * 8.0f);
    if (level==0) level = 1;
    NSString* name = [NSString stringWithFormat:@"record_volume_%d", level];
    self.volumeImage.image = [PDUITools imageBundleNamed:name];
}

@end
