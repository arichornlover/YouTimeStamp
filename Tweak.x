#import <Foundation/Foundation.h>

#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import "../YouTubeHeader/YTColor.h"
#import "../YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h"
#import "../YouTubeHeader/YTMainAppControlsOverlayView.h"
#import "../YouTubeHeader/MLFormat.h"
#import "../YouTubeHeader/YTIFormatStream.h"
#import "../YouTubeHeader/YTIShareVideoEndpoint.h"

#define TweakKey @"YouTimeStamp"

@interface YTMainAppControlsOverlayView (YouTimeStamp)
@property (retain, nonatomic) YTQTMButton *timestampButton;
- (void)didPressYouTimeStamp:(id)arg;
- (void)copyModifiedURLToClipboard:(NSString *)originalURL withTime:(NSString *)timeString;
- (NSInteger)timeToSeconds:(NSString *)timeString;
@property (nonatomic, strong) YTLabel *currentTimeLabel; // YTInlinePlayerBarContainerView
@property (nonatomic, copy) NSString *videoShareURL; // YTIShareVideoEndpoint
@end

@interface YTInlinePlayerBarContainerView (YouTimeStamp)
@property (retain, nonatomic) YTQTMButton *timestampButton;
- (void)didPressYouTimeStamp:(id)arg;
- (void)copyModifiedURLToClipboard:(NSString *)originalURL withTime:(NSString *)timeString;
- (NSInteger)timeToSeconds:(NSString *)timeString;
@property (nonatomic, strong) YTLabel *currentTimeLabel; // YTInlinePlayerBarContainerView
@property (nonatomic, copy) NSString *videoShareURL; // YTIShareVideoEndpoint
@end

// For displaying snackbars - @theRealfoxster
@interface YTHUDMessage : NSObject
+ (id)messageWithText:(id)text;
- (void)setAction:(id)action;
@end

@interface GOOHUDMessageAction : NSObject
- (void)setTitle:(NSString *)title;
- (void)setHandler:(void (^)(id))handler;
@end

@interface GOOHUDManagerInternal : NSObject
- (void)showMessageMainThread:(id)message;
+ (id)sharedInstance;
@end
//

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
    NSString *currentTime = self.currentTimeLabel.text;
    if (currentTime && [self respondsToSelector:@selector(videoShareURL)]) {
        NSString *videoShareURL = self.videoShareURL;
        [self copyModifiedURLToClipboard:videoShareURL withTime:currentTime];
    }
    [self.timestampButton setImage:timestampImage(@"2") forState:0];
}
- (NSString *)currentTimeString {
    if (self.currentTimeLabel) {
        return self.currentTimeLabel.text;
    }
    return nil;
}

- (void)copyModifiedURLToClipboard:(NSString *)originalURL withTime:(NSString *)timeString {
    NSInteger seconds = [self timeToSeconds:timeString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?t=%lds", originalURL, (long)seconds]];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:url.absoluteString];
    [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:@"Successfully copied URL with Timestamp"]];
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

%property (retain, nonatomic) YTQTMButton *timestampButton;

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
- (void)didPressYouTimeStamp:(id)arg {
    NSString *currentTime = self.currentTimeLabel.text;
    if (currentTime && [self respondsToSelector:@selector(videoShareURL)]) {
        NSString *videoShareURL = self.videoShareURL;
        [self copyModifiedURLToClipboard:videoShareURL withTime:currentTime];
    }
    [self.timestampButton setImage:timestampImage(@"2") forState:0];
}
- (NSString *)currentTimeString {
    if (self.currentTimeLabel) {
        return self.currentTimeLabel.text;
    }
    return nil;
}
- (void)copyModifiedURLToClipboard:(NSString *)originalURL withTime:(NSString *)timeString {
    NSInteger seconds = [self timeToSeconds:timeString];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?t=%lds", originalURL, (long)seconds]];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:url.absoluteString];
    [[%c(GOOHUDManagerInternal) sharedInstance] showMessageMainThread:[%c(YTHUDMessage) messageWithText:@"Successfully copied URL with Timestamp"]];
}

%end

%end

%ctor {
    initYTVideoOverlay(TweakKey);
    %init(Top);
    %init(Bottom);
}
