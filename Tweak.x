#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import <YouTubeHeader/YTColor.h>
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
#import <YouTubeHeader/MLFormat.h>
#import <YouTubeHeader/YTIFormatStream.h>
#import <YouTubeHeader/YTIShareVideoEndpoint.h>

#define TweakKey "YouTimeStamp"

@interface YTMainAppControlsOverlayView (YouTimeStamp)
@property (retain, nonatomic) YTQTMButton *timestampButton;
- (void)didPressYouTimeStamp:(id)arg;
@end

@interface YTInlinePlayerBarContainerView (YouTimeStamp)
@property (retain, nonatomic) YTQTMButton *timestampButton;
- (void)didPressYouTimeStamp:(id)arg;
@end

NSBundle *YouTimeStampBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:TweakKey ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:[NSString stringWithFormat:ROOT_PATH_NS(@"/Library/Application Support/%@.bundle"), TweakKey]];
    });
    return bundle;
}

%group Top

%hook YTMainAppControlsOverlayView

%property (retain, nonatomic) YTQTMButton *timestampButton;

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    self.timestampButton = [self createButton:TweakKey accessibilityLabel:@"Copy Timestamp" selector:@selector(didPressYouTimeStamp:)];
    return self;
}

- (id)initWithDelegate:(id)delegate autoplaySwitchEnabled:(BOOL)autoplaySwitchEnabled {
    self = %orig;
    self.timestampButton = [self createButton:TweakKey accessibilityLabel:@"Copy Timestamp" selector:@selector(didPressYouTimeStamp:)];
    return self;
}

- (YTQTMButton *)button:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? self.timestampButton : %orig;
}

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? <Your Tweak Button Image> : %orig;
}

%new(v@:@)
- (void)didPressYouTimeStamp:(id)arg {
    YTLabel *currentTimeLabel = playerBarView.currentTimeLabel;
    NSString *timestamp = currentTimeLabel.text;

    NSString *videoShareURL = playerBarView.videoShareURL;
    videoShareURL = [videoShareURL stringByAppendingFormat:@"?t=%@", timestamp];

    [self.timestampButton setImage:<Another Tweak Button Image> forState:0];
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

%property (retain, nonatomic) YTQTMButton *tweakButton;

- (id)init {
    self = %orig;
    self.timestampButton = [self createButton:TweakKey accessibilityLabel:@"Copy Timestamp" selector:@selector(didPressYouTimeStamp:)];
    return self;
}

- (YTQTMButton *)button:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? self.timestampButton : %orig;
}

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:TweakKey] ? <Your Tweak Button Image> : %orig;
}

%new(v@:@)
- (void)didPressTweak:(id)arg {
    NSString *currentTime = self.currentTimeLabel.text;
    NSArray *timeComponents = [currentTime componentsSeparatedByString:@":"];
    
    if (timeComponents.count == 2) {
        NSInteger minutes = [timeComponents[0] integerValue];
        NSInteger seconds = [timeComponents[1] integerValue];
        
        NSInteger totalSeconds = (minutes * 60) + seconds;
        
        self.delegate.videoShareURL = [NSString stringWithFormat:@"%@?t=%ds", self.delegate.videoShareURL, totalSeconds];
    }
    [self.timestampButton setImage:<Another Tweak Button Image> forState:0];
}

%end

%end

%ctor {
    initYTVideoOverlay(TweakKey);
    %init(Top);
    %init(Bottom);
}
