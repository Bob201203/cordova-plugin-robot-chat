//
//  YFGIFImageView.m
//  UIImageView-PlayGIF
//
//  Created by Yang Fei on 14-3-26.
//  Copyright (c) 2014年 yangfei.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "YFGIFImageView.h"

@interface YFGIFManager : NSObject

@property (nonatomic, strong) CADisplayLink  *displayLink;
@property (nonatomic, strong) NSHashTable    *gifViewHashTable;

+ (YFGIFManager *)shared;
- (void)stopGIFView:(YFGIFImageView *)view;

@end

@implementation YFGIFManager

+ (YFGIFManager *)shared
{
    static YFGIFManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[YFGIFManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    }
    return self;
}

- (void)play
{
    for (YFGIFImageView *imageView in _gifViewHashTable)
    {
        [imageView performSelector:@selector(play)];
    }
}

- (void)stopDisplayLink
{
    if (self.displayLink)
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)stopGIFView:(YFGIFImageView *)view
{
    [_gifViewHashTable removeObject:view];
    if (_gifViewHashTable.count<1 && !_displayLink)
    {
        [self stopDisplayLink];
    }
}
@end

@interface YFGIFImageView()
{
    size_t              _index;
    size_t              _frameCount;
    float               _timestamp;
    float               _currentProgress;
    CGImageSourceRef    _gifSourceRef;
}

@property (strong, nonatomic) NSOperationQueue    *renderQueue;

@end

@implementation YFGIFImageView

#pragma mark - property settings

- (NSOperationQueue *)renderQueue
{
    if (!_renderQueue)
    {
        _renderQueue = [NSOperationQueue new];
        _renderQueue.maxConcurrentOperationCount = 1;
    }
    return _renderQueue;
}

#pragma mark - super methods

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self stopGIF];
}

#pragma mark - Gif methods

- (void)startGIF
{
    _gifPixelSize = CGSizeZero;
    [self.renderQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startGIFWithRunLoopMode:NSDefaultRunLoopMode andImageDidLoad:nil];
        });
    }];
}

- (void)startGIFWithRunLoopMode:(NSString * const)runLoopMode andImageDidLoad:(void(^)(CGSize imageSize))didLoad
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[YFGIFManager shared].gifViewHashTable containsObject:self])
        {
            if ((self.gifData || self.gifPath))
            {
                CGImageSourceRef gifSourceRef;
                if (self.gifData)
                {
                    gifSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self.gifData), NULL);
                }
                else
                {
                    gifSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:self.gifPath], NULL);
                }
                CGSize pixcelSize = [self GIFDimensionalSize:gifSourceRef];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _gifPixelSize = pixcelSize;
                    CGFloat scale = [UIScreen mainScreen].scale;
                    CGSize imgSize = CGSizeMake(pixcelSize.width/scale, pixcelSize.height/scale);
                    if (didLoad) didLoad(imgSize);
                    if (!gifSourceRef) return;
                    
                    [[YFGIFManager shared].gifViewHashTable addObject:self];
                    _gifSourceRef = gifSourceRef;
                    _frameCount = CGImageSourceGetCount(gifSourceRef);
                    if (![YFGIFManager shared].displayLink) {
                        [YFGIFManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[YFGIFManager shared] selector:@selector(play)];
                        [[YFGIFManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:runLoopMode];
                    }
                });
            }
        }
    });
}

- (void)stopGIF
{
    [self.renderQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_gifSourceRef)
            {
                CFRelease(_gifSourceRef);
                _gifSourceRef = nil;
            }
            [[YFGIFManager shared] stopGIFView:self];
        });
    }];
}

- (void)play
{
    if (_timestamp >= _currentProgress)
    {
        if(self.renderQueue.operationCount<=0)
        {
            [self.renderQueue addOperationWithBlock:^{
                CGImageRef ref = CGImageSourceCreateImageAtIndex(_gifSourceRef, _index%_frameCount, NULL);
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = [UIImage imageWithCGImage:ref];
                    CGImageRelease(ref);
                });
            }];
        }
        
        _index ++;
        float nextFrameDuration = [self frameDurationAtIndex:_index%_frameCount];
        _currentProgress += nextFrameDuration;
        
        if (_index%_frameCount == 0)
        {
            if (self.unRepeat)
            {
                [self stopGIF];
                return;
            }
        }
    }
    _timestamp += [YFGIFManager shared].displayLink.duration;
}

- (BOOL)isGIFPlaying
{
    return _gifSourceRef?YES:NO;
}

- (float)frameDurationAtIndex:(size_t)index
{
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(_gifSourceRef, index, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    NSDictionary *gifDict = (dict[(NSString *)kCGImagePropertyGIFDictionary]);
    NSNumber *unclampedDelayTime = gifDict[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    NSNumber *delayTime = gifDict[(NSString *)kCGImagePropertyGIFDelayTime];
    CFRelease(dictRef);
    if (unclampedDelayTime.floatValue)
    {
        return unclampedDelayTime.floatValue;
    }
    else if (delayTime.floatValue)
    {
        return delayTime.floatValue;
    }
    else
    {
        return 1/24.0f;
    }
}

- (CGSize)GIFDimensionalSize:(CGImageSourceRef)imgSourceRef
{
    if(!imgSourceRef)
    {
        return CGSizeZero;
    }
    
    CFDictionaryRef dictRef = CGImageSourceCopyPropertiesAtIndex(imgSourceRef, 0, NULL);
    NSDictionary *dict = (__bridge NSDictionary *)dictRef;
    
    NSNumber* pixelWidth = (dict[(NSString*)kCGImagePropertyPixelWidth]);
    NSNumber* pixelHeight = (dict[(NSString*)kCGImagePropertyPixelHeight]);
    
    CGSize sizeAsInProperties = CGSizeMake([pixelWidth floatValue], [pixelHeight floatValue]);
    
    CFRelease(dictRef);
    
    return sizeAsInProperties;
}

+ (BOOL)isGIFData:(NSData*)data
{
    uint8_t c;
    [data getBytes:&c length:1];
    return c == 0x47;
}

@end
