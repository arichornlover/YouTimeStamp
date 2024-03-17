#import "../YTVideoOverlay/Header.h"
#import "../YTVideoOverlay/Init.x"
#import <YouTubeHeader/YTMainAppVideoPlayerOverlayViewController.h>
#import <YouTubeHeader/MLFormat.h>
#import <YouTubeHeader/YTIFormatStream.h>

#define TweakKey "YouTimeStamp"

@interface YTMainAppControlsOverlayView (YouTimeStamp)
@property (retain, nonatomic) YTQTMButton *timestampButton;
- (void)didPressYouTimeStamp:(id)arg;
@end

@interface YTInlinePlayerBarContainerView (YouTimeStamp)
@property (retain, nonatomic) YTQTMButton *timestampButton;
- (void)didPressYouTimeStamp:(id)arg;
@end

%group Top

%hook YTMainAppControlsOverlayView

%property (retain, nonatomic) YTQTMButton *timestampButton;

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    self.timestampButton = [self createButton:YouTimeStamp accessibilityLabel:@"Copy Timestamp" selector:@selector(didPressYouTimeStamp:)];
    return self;
}

- (id)initWithDelegate:(id)delegate autoplaySwitchEnabled:(BOOL)autoplaySwitchEnabled {
    self = %orig;
    self.timestampButton = [self createButton:TweakKey accessibilityLabel:@"Copy Timestamp" selector:@selector(didPressYouTimeStamp:)];
    return self;
}

- (YTQTMButton *)button:(NSString *)tweakId {
    return [tweakId isEqualToString:YouTimeStamp] ? self.timestampButton : %orig;
}

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:YouTimeStamp] ? <Your Tweak Button Image> : %orig;
}

%new(v@:@)
- (void)didPressYouTimeStamp:(id)arg {
    // Do stuff
    [self.timestampButton setImage:<Another Tweak Button Image> forState:0];
}

%end

%end

%group Bottom

%hook YTInlinePlayerBarContainerView

%property (retain, nonatomic) YTQTMButton *tweakButton;

- (id)init {
    self = %orig;
    self.timestampButton = [self createButton:YouTimeStamp accessibilityLabel:@"Copy Timestamp" selector:@selector(didPressYouTimeStamp:)];
    return self;
}

- (YTQTMButton *)button:(NSString *)tweakId {
    return [tweakId isEqualToString:YouTimeStamp] ? self.timestampButton : %orig;
}

- (UIImage *)buttonImage:(NSString *)tweakId {
    return [tweakId isEqualToString:YouTimeStamp] ? <Your Tweak Button Image> : %orig;
}

%new(v@:@)
- (void)didPressTweak:(id)arg {
    // Do stuff
    [self.timestampButton setImage:<Another Tweak Button Image> forState:0];
}

%end

%end

%ctor {
    initYTVideoOverlay(TweakKey);
    %init(Top);
    %init(Bottom);
}
