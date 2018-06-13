//
//  PDUIAudioTools.m
//  PDBotKit
//
//  Created by wuyifan on 2018/1/8.
//  Copyright © 2018年 4Paradigm. All rights reserved.
//

#import "PDUIAudioTools.h"
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

#define kCafFileName @"Record.caf"
#define kMp3FileName @"Record.mp3"

@interface PDUIAudioTools ()

@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, strong) NSURL* playingUrl;
@property (nonatomic, strong) AVAudioRecorder* audioRecorder;
@property (nonatomic, strong) NSDate* recorderStartTime;

@end

@implementation PDUIAudioTools

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initAudio];
    }
    return self;
}

- (void)initAudio
{
    NSDictionary* setting = @
    {
        AVFormatIDKey: @(kAudioFormatLinearPCM),
        AVSampleRateKey: @16000,
        AVNumberOfChannelsKey: @2,
        AVLinearPCMBitDepthKey: @16,
        AVEncoderAudioQualityKey: @(AVAudioQualityMin)
    };
    
    NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:kCafFileName];
    NSURL* url = [NSURL fileURLWithPath:filePath];
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:nil];
    self.audioRecorder.meteringEnabled = YES;
}

- (BOOL)hasRecordPermission
{
    __block BOOL permission = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            permission = granted;
        }];
    }
    return permission;
}

- (void)startRecord
{
    [self stopPlay];
    [self cancelRecord];

    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    
    [self.audioRecorder record];
    self.recorderStartTime = [NSDate date];
}

- (NSURL*)stopRecord
{
    if ([self.audioRecorder isRecording])
    {
        [self.audioRecorder stop];
    }
    
    NSDate* now = [NSDate date];
    self.recordTime = [now timeIntervalSinceDate:self.recorderStartTime];
    self.recordTime = floor(self.recordTime);
    if (self.recordTime<1.0) return nil;
    
    NSString* mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:kMp3FileName];
    NSString* pcmPath = [NSTemporaryDirectory() stringByAppendingPathComponent:kCafFileName];
    [self convertPCM:pcmPath toMP3:mp3Path];
    [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];

    return [NSURL fileURLWithPath:mp3Path];
}

- (void)cancelRecord
{
    if ([self.audioRecorder isRecording])
    {
        [self.audioRecorder stop];
    }
}

- (float)getRecordVolume
{
    [self.audioRecorder updateMeters];
    float power = ([self.audioRecorder peakPowerForChannel:0] + 32) / 32;
    if (power<0.0f) power = 0.0f;
    if (power>1.0f) power = 1.0f;
    return power;
}

- (void)startPlay:(NSURL*)url
{
    [self stopPlay];

    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.audioPlayer play];
    
    self.playingUrl = url;
}

- (void)stopPlay
{
    if (self.audioPlayer)
    {
        if ([self.audioPlayer isPlaying]) [_audioPlayer stop];
        self.audioPlayer = nil;
    }
}

- (NSURL*)playingFile
{
    return self.audioPlayer && self.audioPlayer.isPlaying ? self.playingUrl : nil;
}

- (void)convertPCM:(NSString*)pcmPath toMP3:(NSString*)mp3Path
{
    @try
    {
        int read, write;
        
        FILE* pcm = fopen(pcmPath.UTF8String, "rb");
        FILE* mp3 = fopen(mp3Path.UTF8String, "wb");
        fseek(pcm, 4*1024, SEEK_CUR);
        
        const size_t PCM_SIZE = 1024*8;
        const size_t MP3_SIZE = 1024*8;
        short pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_num_channels(lame, 2);
        lame_set_in_samplerate(lame, 16000);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do
        {
            read = (int)fread(pcm_buffer, sizeof(short)*2, PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
        }
        while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException* exception)
    {
        NSLog(@"%@", exception);
    }
}

@end
