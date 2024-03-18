#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import "../YouTubeHeader/YTColor.h"
#import "../YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "../YouTubeHeader/MLFormat.h"
#import "../YouTubeHeader/YTIFormatStream.h"
#import "../YouTubeHeader/YTIShareVideoEndpoint.h"

#define TweakKey @"YouTimeStamp"

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

static UIImage *timestampImage(NSString *qualityLabel) {
    return [%c(QTMIcon) tintImage:[UIImage imageNamed:[NSString stringWithFormat:@"Timestamp@%@", qualityLabel] inBundle: YouTimeStampBundle() compatibleWithTraitCollection:nil] color:[%c(YTColor) white1]];
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
    return [tweakId isEqualToString:TweakKey] ? timestampImage(@"3") : %orig;
}

%new(v@:@)
- (void)didPressYouTimeStamp:(id)arg {
    YTLabel *currentTimeLabel = playerBarView.currentTimeLabel;
    NSString *timestamp = currentTimeLabel.text;

    NSString *videoShareURL = playerBarView.videoShareURL;
    videoShareURL = [videoShareURL stringByAppendingFormat:@"?t=%@", timestamp];

    [self.timestampButton setImage:timestampImage(@"2") forState:0];
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
    return [tweakId isEqualToString:TweakKey] ? timestampImage(@"3") : %orig;
}

%new(v@:@)
- (void)didPressTweak:(id)arg {
    NSString *currentTime = self.currentTimeLabel.text;
    if (currentTime && self.videoShareURL) {
        [self copyModifiedURLToClipboard:self.videoShareURL withTime:currentTime];
    }
    [self.timestampButton setImage:timestampImage(@"2") forState:0];
}
- (NSInteger)timeToSeconds:(NSString *)timeString {
    NSArray *components = [timeString componentsSeparatedByString:@":"];
    if (components.count == 2) {
        NSInteger minutes = [components[0] integerValue];
        NSInteger seconds = [components[1] integerValue];
        return (minutes * 60) + seconds;
    }
    return 0;
}
- (void)copyModifiedURLToClipboard:(NSString *)originalURL withTime:(NSString *)timeString {
    NSInteger seconds = [self timeToSeconds:timeString];
    NSURL *url = [NSURL URLWithString:[originalURL stringByAppendingFormat:@"?t=%ds", seconds]];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:url.absoluteString];
    
    // you can display a success message or alert about the timestamp here
}

%end

%end

%ctor {
    initYTVideoOverlay(TweakKey);
    %init(Top);
    %init(Bottom);
}
