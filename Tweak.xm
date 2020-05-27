#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

@interface CSTeachableMomentsContainerView : UIView
@property(retain, nonatomic) UIView *controlCenterGrabberView;
@property(retain, nonatomic) UIView *controlCenterGrabberEffectContainerView;
@property (retain, nonatomic) UIImageView * controlCenterGlyphView; 
@end

@interface CSQuickActionsView : UIView
-(UIEdgeInsets)_buttonOutsets;
@property (nonatomic, retain) UIControl *flashlightButton; 
@property (nonatomic, retain) UIControl *cameraButton;
@end

// Gesture
%hook BSPlatform
-(NSInteger)homeButtonType {
   return 2;
}
%end

// No homebar inapp
%hook SBFHomeGrabberSettings
-(bool)isEnabled {
   return NO;
} 
%end

// iPad STB
%hook _UIStatusBarVisualProvider_iOS
+(Class)class {
   return NSClassFromString(@"_UIStatusBarVisualProvider_Pad_ForcedCellular");
}
%end

%hook CCUIHeaderPocketView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, -24));
}
%end

// Flashlight & Camera & CC Grabber in LS
%hook CSQuickActionsView
-(bool)_prototypingAllowsButtons {
return YES;
}
-(void)_layoutQuickActionButtons {
   CGRect screenBounds = [UIScreen mainScreen].bounds;
   int inset = [self _buttonOutsets].top;
   [self flashlightButton].frame = CGRectMake(46, screenBounds.size.height - 90 - inset, 50, 50);
   [self cameraButton].frame = CGRectMake(screenBounds.size.width - 96, screenBounds.size.height - 90 - inset, 50, 50);
}
%end

%hook CSTeachableMomentsContainerView
-(void)_layoutControlCenterGrabberAndGlyph  {
   %orig;
   self.controlCenterGrabberEffectContainerView.frame = CGRectMake(self.frame.size.width - 75.5,24,60.5,2.5);
   self.controlCenterGrabberView.frame = CGRectMake(0,0,60.5,2.5);
   self.controlCenterGlyphView.frame = CGRectMake(320,35,16.6,19.3);
}
%end

// Keyboard
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
   UIEdgeInsets orig = %orig;
if (!NSClassFromString(@"BarmojiCollectionView")) 
   orig.bottom = 45;
if (orig.left == 75)  {
   orig.left = 0;
   orig.right = 0;
}
   return orig;
}
%end

%hook UIKeyboardDockView
-(CGRect)bounds {
if (NSClassFromString(@"BarmojiCollectionView")) 
   return %orig;
   CGRect bounds = %orig;
   bounds.size.height += 15;
   return bounds;
}
%end

// Hardware button original
%hook SBLockHardwareButtonActions
-(id)initWithHomeButtonType:(long long)arg1 proximitySensorManager:(id)arg2 {
   return %orig(1, arg2);
}
%end

%hook SBHomeHardwareButtonActions
-(id)initWitHomeButtonType:(long long)arg1 {
   return %orig(1);
}
%end

int applicationDidFinishLaunching;
%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
   applicationDidFinishLaunching = 2;
   %orig;
}
%end

%hook SBPressGestureRecognizer
-(void)setAllowedPressTypes:(NSArray *)arg1 {
   NSArray * lockHome = @[@104, @101];
   NSArray * lockVol = @[@104, @102, @103];
if ([arg1 isEqual:lockVol] && applicationDidFinishLaunching == 2) {
   %orig(lockHome);
   applicationDidFinishLaunching--;
   return;
}
%orig;
}
%end

%hook SBClickGestureRecognizer
-(void)addShortcutWithPressTypes:(id)arg1 {
if (applicationDidFinishLaunching == 1) {
   applicationDidFinishLaunching--;
   return;
}
   %orig;
}
%end

%hook SBHomeHardwareButton
-(id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 buttonActions:(id)arg3 gestureRecognizerConfiguration:(id)arg4 {
   return %orig(arg1,1,arg3,arg4);
}
-(id)initWithScreenshotGestureRecognizer:(id)arg1 homeButtonType:(long long)arg2 {
   return %orig(arg1,1);
}
%end

%hook SBLockHardwareButton
-(id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 buttonActions:(id)arg6 homeButtonType:(long long)arg7 createGestures:(_Bool)arg8 {
   return %orig(arg1,arg2,arg3,arg4,arg5,arg6,1,arg8);
}
-(id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 proximitySensorManager:(id)arg3 homeHardwareButton:(id)arg4 volumeHardwareButton:(id)arg5 homeButtonType:(long long)arg6 {
   return %orig(arg1,arg2,arg3,arg4,arg5,1);
}
%end

%hook SBVolumeHardwareButton
-(id)initWithScreenshotGestureRecognizer:(id)arg1 shutdownGestureRecognizer:(id)arg2 homeButtonType:(long long)arg3 {
   return %orig(arg1,arg2,1);
}
%end
