//
//  Menu.m
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Copyright © 2019 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"
#import "HelperFiles/utils.h"

#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]



// Wouldnt recommend changing these
// but if you want to change them go for it
int OffsetSwitchHeight = 35;
int TextFieldSwitchHeight = 50;
int SliderSwitchHeight = 50;

UIColor *dividerColor = UIColorFromHex(0x8b342e);

UIColor *glowColor = UIColorFromHex(0xff9a01);




@interface Menu ()

@property (assign, nonatomic) CGPoint lastMenuLocation;
@property (strong, nonatomic) UILabel *menuTitle;
@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) UIView *footer;

@end


@implementation Menu

NSUserDefaults *defaults;

UIScrollView *scrollView;
CGFloat menuWidth;
CGFloat scrollViewX;
NSString *credits;
UIColor *switchOnColor;
NSString *switchTitleFont;
UIColor *switchTitleColor;
UIColor *infoButtonColor;
NSString *menuButtonBase64;
float scrollViewHeight = 0;
BOOL hasRestoredLastSession = false;
UIButton *menuButton;

const char *frameworkName = NULL;

UIWindow *mainWindow;
UILabel *watermark;

// init the menu
// global variabls, extern in Macros.h
Menu *menu = [[Menu alloc]init];
Switches *switches = [[Switches alloc]init];


-(id)initWithHeaderTitle:(NSString *)obftitle_ watermarkText:(NSString *)watermarkText_ watermarkTextColor:(UIColor *)watermarkTextColor_ watermarkVisible:(float)watermarkVisible_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuButton:(NSString *)menuButtonBase64_ {

    mainWindow = [UIApplication sharedApplication].keyWindow;
    defaults = [NSUserDefaults standardUserDefaults];

    menuWidth = menuWidth_;
    switchOnColor = switchOnColor_;
    credits = credits_;
    switchTitleFont = switchTitleFont_;
    switchTitleColor = switchTitleColor_;
    infoButtonColor = infoButtonColor_;
    menuButtonBase64 = menuButtonBase64_;

NSString *WMTEXT = [watermarkText_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];

watermark = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, mainWindow.frame.size.width/4, 20)];
watermark.textColor = watermarkTextColor_;
watermark.backgroundColor = [UIColor clearColor];
watermark.text = WMTEXT;
watermark.adjustsFontSizeToFitWidth = YES;
watermark.layer.opacity = watermarkVisible_;
watermark.center = CGPointMake(CGRectGetMinX(mainWindow.frame)+watermark.frame.size.width/2+10, CGRectGetMaxY(mainWindow.frame)-watermark.frame.size.height -5);
[mainWindow addSubview:watermark];
    // Base of the Menu UI.
    self = [super initWithFrame:CGRectMake(0,0,menuWidth_, maxVisibleSwitches_ * 35 + 40)];
    self.center = mainWindow.center;
    self.layer.opacity = 0.0f;
self.layer.shadowColor = glowColor.CGColor;
self.layer.shadowRadius = 10.0f;
self.layer.shadowOpacity = 1.0f;
self.layer.shadowOffset = CGSizeZero;
    self.header = [[UIView alloc]initWithFrame:CGRectMake(0, 1, menuWidth_, 40)];
    self.header.backgroundColor = headerColor_;
    CAShapeLayer *headerLayer = [CAShapeLayer layer];
    headerLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.header.bounds byRoundingCorners: UIRectCornerTopRight cornerRadii: (CGSize){13.0, 13.0}].CGPath;
    self.header.layer.mask = headerLayer;
    [self addSubview:self.header];


    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.header.bounds), menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.header.bounds))];
    scrollView.backgroundColor = switchOffColor_;
[scrollView setShowsVerticalScrollIndicator:NO];
    [self addSubview:scrollView];

    // we need this for the switches, do not remove.
    scrollViewX = CGRectGetMinX(scrollView.self.bounds);

    self.menuTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, menuWidth_ -16, 35)];
NSString *title_ = [obftitle_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];
    self.menuTitle.text = title_;
    self.menuTitle.textColor = titleColor_;
    self.menuTitle.font = [UIFont fontWithName:titleFont_ size:27.0f];
    self.menuTitle.adjustsFontSizeToFitWidth = YES;
    self.menuTitle.textAlignment = NSTextAlignmentCenter;
    self.menuTitle.center = self.header.center;
    [self.header addSubview: self.menuTitle];

    self.footer = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, menuWidth_, 20)];
    self.footer.backgroundColor = headerColor_;
    CAShapeLayer *footerLayer = [CAShapeLayer layer];
    footerLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.footer.bounds byRoundingCorners: UIRectCornerBottomLeft cornerRadii: (CGSize){13.0, 13.0}].CGPath;
    self.footer.layer.mask = footerLayer;
    [self addSubview:self.footer];

    UIPanGestureRecognizer *dragMenuRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(menuDragged:)];
    [self.header addGestureRecognizer:dragMenuRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMenu:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.header addGestureRecognizer:tapGestureRecognizer];

    [mainWindow addSubview:self];
    [self showMenuButton];

    return self;
}

// Detects whether the menu is being touched and sets a lastMenuLocation.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.lastMenuLocation = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    [super touchesBegan:touches withEvent:event];
}

// Update the menu's location when it's being dragged
- (void)menuDragged:(UIPanGestureRecognizer *)pan {
    CGPoint newLocation = [pan translationInView:self.superview];
    self.frame = CGRectMake(self.lastMenuLocation.x + newLocation.x, self.lastMenuLocation.y + newLocation.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)hideMenu:(UITapGestureRecognizer *)tap {
    if(tap.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 0.0f;
            menuButton.alpha = 1.0f;
        }];
    }
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        menuButton.alpha = 0.0f;
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 1.0f;
        }];
    }
    // We should only have to do this once (first launch)
    if(!hasRestoredLastSession) {
        restoreLastSession();
        hasRestoredLastSession = true;
    }
}

/**********************************************************************************************
     This function will be called when the menu has been opened for the first time on launch.
     It'll handle the correct background color and patches the switches do.
***********************************************************************************************/
void restoreLastSession() {
    UIColor *clearColor = [UIColor clearColor];
    BOOL isOn = false;

    for(id switch_ in scrollView.subviews) {
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
            for(int i = 0; i < memoryPatches.size(); i++) {
                if(isOn){
                 memoryPatches[i].Modify();
                } else {
                 memoryPatches[i].Restore();
                }
            }
            ((OffsetSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }

        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            ((TextFieldSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }

        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            ((SliderSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }
    }
}

-(void)showMenuButton {
    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuButtonBase64 options:0];
    UIImage* menuButtonImage = [UIImage imageWithData:data];

    menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuButton.frame = CGRectMake((mainWindow.frame.size.width/2), (mainWindow.frame.size.height/2), 50, 50);
    menuButton.backgroundColor = [UIColor clearColor];
    [menuButton setBackgroundImage:menuButtonImage forState:UIControlStateNormal];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
    [menuButton addGestureRecognizer:tapGestureRecognizer];

    [menuButton addTarget:self action:@selector(buttonDragged:withEvent:)
       forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:menuButton];
}

// handler for when the user is draggin the menu.
- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];

    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;

    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);
}




-(void)showPopup:(NSString *)title_ description:(NSString *)description_ {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor purpleColor];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

    [alert addButton: @"Ok!" actionBlock: ^(void) {
        self.layer.opacity = 1.0f;
    }];

    [alert showInfo:title_ subTitle:description_ closeButtonTitle:nil duration:9999999.0f];
}

/*******************************************************************
    This method adds the given switch to the menu's scrollview.
    it also add's an action for when the switch is being clicked.
********************************************************************/
- (void)addSwitchToMenu:(id)switch_ switchHeight:(int)switchHeight_ {
    [switch_ addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchDown];
    scrollViewHeight += switchHeight_;
    scrollView.contentSize = CGSizeMake(menuWidth, scrollViewHeight);
    [scrollView addSubview:switch_];
}

- (void)changeSwitchBackground:(id)switch_ isSwitchOn:(BOOL)isSwitchOn_ {
    UIColor *clearColor = [UIColor clearColor];

    [UIView animateWithDuration:0.3 animations:^ {
        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            ((TextFieldSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            ((SliderSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            ((OffsetSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
    }];

    [defaults setBool:!isSwitchOn_ forKey:[switch_ getPreferencesKey]];
}

/*********************************************************************************************
    This method does the following handles the behaviour when a switch has been clicked
    TextfieldSwitch and SliderSwitch only change from color based on whether it's on or not.
    A OffsetSwitch does too, but it also applies offset patches
***********************************************************************************************/
-(void)switchClicked:(id)switch_ {
    BOOL isOn = [defaults boolForKey:[switch_ getPreferencesKey]];

    if([switch_ isKindOfClass:[OffsetSwitch class]]) {
        std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
        for(int i = 0; i < memoryPatches.size(); i++) {
            if(!isOn){
                memoryPatches[i].Modify();
            } else {
                memoryPatches[i].Restore();
           }
        }
    }

    // Update switch background color and pref value.
    [self changeSwitchBackground:switch_ isSwitchOn:isOn];
}

-(void)setFrameworkName:(const char *)name_ {
    frameworkName = name_;
}

-(const char *)getFrameworkName {
    return frameworkName;
}
@end // End of menu class!


/********************************
    OFFSET SWITCH STARTS HERE!
*********************************/

@implementation OffsetSwitch {
    std::vector<MemoryPatch> memoryPatches;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::vector<uint64_t>)offsets_ bytes:(std::vector<std::string>)bytes_ {
    description = description_;
    preferencesKey = hackName_;

    if(offsets_.size() != bytes_.size()){
        [menu showPopup:@"Invalid input count" description:[NSString stringWithFormat:@"Offsets array input count (%d) is not equal to the bytes array input count (%d)", (int)offsets_.size(), (int)bytes_.size()]];
    } else {
        // For each offset, we create a MemoryPatch.
        for(int i = 0; i < offsets_.size(); i++) {
            MemoryPatch patch = MemoryPatch::createWithHex([menu getFrameworkName], ((offsets_[i]^ _utils.cryptBases[1]) - _utils.cryptBases[0]), bytes_[i]);
            if(patch.isValid()) {
              memoryPatches.push_back(patch);
            } else {
              [menu showPopup:@"Invalid patch" description:[NSString stringWithFormat:@"Failing offset: 0x%llx, please re-check the hex you entered.", ((offsets_[i]^ _utils.cryptBases[1]) - _utils.cryptBases[0])]];
            }
        }
    }



    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight - 1, menuWidth + 2, OffsetSwitchHeight)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = dividerColor.CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, menuWidth - 60, OffsetSwitchHeight)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:20];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
switchLabel.center = CGPointMake(self.frame.size.width  / 2-5, self.frame.size.height / 2);
    [self addSubview:switchLabel];

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(0, 0, 20, 20);
    infoButton.tintColor = infoButtonColor;
infoButton.center = CGPointMake(CGRectGetMaxX(self.frame)-infoButton.frame.size.width, self.frame.size.height / 2);

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    return self;
}

-(void)showInfo:(UIGestureRecognizer *)gestureRec {
    if(gestureRec.state == UIGestureRecognizerStateEnded) {
        [menu showPopup:[self getPreferencesKey] description:[self getDescription]];
        menu.layer.opacity = 0.0f;
    }
}

-(NSString *)getPreferencesKey {
    return preferencesKey;
}

-(NSString *)getDescription {
    return description;
}

- (std::vector<MemoryPatch>)getMemoryPatches {
    return memoryPatches;
}

@end //end of OffsetSwitch class


/**************************************
    TEXTFIELD SWITCH STARTS HERE!
    - Note that this extends from OffsetSwitch.
***************************************/

@implementation TextFieldSwitch {
    UITextField *textfieldValue;
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;



    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, TextFieldSwitchHeight)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = dividerColor.CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, menuWidth - 60, TextFieldSwitchHeight)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:20];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
switchLabel.center = CGPointMake(self.frame.size.width  / 2-5, CGRectGetMinY(self.bounds)+12);
    [self addSubview:switchLabel];

    textfieldValue = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, menuWidth / 2+20, 18)];
    textfieldValue.layer.borderWidth = 2.0f;
    textfieldValue.layer.borderColor = inputBorderColor_.CGColor;
    textfieldValue.layer.cornerRadius = 5.0f;
    textfieldValue.textColor = switchTitleColor;
    textfieldValue.textAlignment = NSTextAlignmentCenter;
    textfieldValue.delegate = self;
    textfieldValue.backgroundColor = [UIColor clearColor];
textfieldValue.center = CGPointMake(self.frame.size.width  / 2-5, CGRectGetMaxY(self.bounds)-15);

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        textfieldValue.text = [[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(0, 0, 20, 20);
    infoButton.tintColor = infoButtonColor;
infoButton.center = CGPointMake(CGRectGetMaxX(self.frame)-infoButton.frame.size.width, self.frame.size.height / 2);

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:textfieldValue];

    return self;
}

// so when click "return" the keyboard goes way, got it from internet. Common thing apparantly
-(BOOL)textFieldShouldReturn:(UITextField*)textfieldValue_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    [defaults setObject:textfieldValue_.text forKey:[self getSwitchValueKey]];
    [textfieldValue_ resignFirstResponder];

    return true;
}

-(NSString *)getSwitchValueKey {
    return switchValueKey;
}

@end // end of TextFieldSwitch Class


/*******************************
    SLIDER SWITCH STARTS HERE!
    - Note that this extends from TextFieldSwitch
 *******************************/

@implementation SliderSwitch {
    UISlider *sliderValue;
    float valueOfSlider;
}

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_{
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;




    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, SliderSwitchHeight)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = dividerColor.CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, menuWidth - 60, SliderSwitchHeight)];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:20];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
switchLabel.center = CGPointMake(self.frame.size.width  / 2-5, CGRectGetMinY(self.bounds)+12);
    [self addSubview:switchLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, menuWidth / 2 + 20, 18)];
    sliderValue.thumbTintColor = sliderColor_;
    sliderValue.minimumTrackTintColor = switchTitleColor;
    sliderValue.maximumTrackTintColor = switchTitleColor;
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;
sliderValue.center = CGPointMake(self.frame.size.width  / 2-5, CGRectGetMaxY(self.bounds)-15);
    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", hackName_, sliderValue.value];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(0, 0, 20, 20);
    infoButton.tintColor = infoButtonColor;
infoButton.center = CGPointMake(CGRectGetMaxX(self.frame)-infoButton.frame.size.width, self.frame.size.height / 2);

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:sliderValue];

    return self;
}

-(void)sliderValueChanged:(UISlider *)slider_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    switchLabel.text = [NSString stringWithFormat:@"%@ %.2f", [self getPreferencesKey], slider_.value];
    [defaults setFloat:slider_.value forKey:[self getSwitchValueKey]];
}

@end // end of SliderSwitch class





@implementation Switches


-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_ {

NSString *deobfHN = [hackName_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];

NSString *deobfDS= [description_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];



    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:deobfHN description:deobfDS offsets:std::vector<uint64_t>{} bytes:std::vector<std::string>{}];
    [menu addSwitchToMenu:offsetPatch switchHeight:OffsetSwitchHeight];

}

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::initializer_list<uint64_t>)offsets_ bytes:(std::initializer_list<std::string>)bytes_ {
    std::vector<uint64_t> offsetVector;
    std::vector<std::string> bytesVector;

    offsetVector.insert(offsetVector.begin(), offsets_.begin(), offsets_.end());
    bytesVector.insert(bytesVector.begin(), bytes_.begin(), bytes_.end());

NSString *deobfHN = [hackName_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];

NSString *deobfDS= [description_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];



    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:deobfHN description:deobfDS offsets:offsetVector bytes:bytesVector];
    [menu addSwitchToMenu:offsetPatch switchHeight:OffsetSwitchHeight];
}

- (void)addTextfieldSwitch:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {

NSString *deobfHN = [hackName_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];

NSString *deobfDS= [description_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];



    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:deobfHN description:deobfDS inputBorderColor:inputBorderColor_];
    [menu addSwitchToMenu:textfieldSwitch switchHeight:TextFieldSwitchHeight];
}

- (void)addSliderSwitch:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {

NSString *deobfHN = [hackName_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];

NSString *deobfDS= [description_ stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];



    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:deobfHN description:deobfDS minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToMenu:sliderSwitch switchHeight:SliderSwitchHeight];
}

- (NSString *)getValueFromSwitch:(NSString *)name {

NSString *deobfHN = [name stringByReplacingOccurrencesOfString:@"@@OBFS@@" withString:@""];


    //getting the correct key for the saved input.
    NSString *correctKey =  [deobfHN stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];

    if([[NSUserDefaults standardUserDefaults] objectForKey:correctKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:correctKey];
    }
    else if([[NSUserDefaults standardUserDefaults] floatForKey:correctKey]) {
        NSString *sliderValue = [NSString stringWithFormat:@"%f", [[NSUserDefaults standardUserDefaults] floatForKey:correctKey]];
        return sliderValue;
    }

    return 0;
}

-(bool)isSwitchOn:(NSString *)switchName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:switchName];
}

@end
