#import <UIKit/UIKit.h>

@interface FinxModMenu : NSObject
+ (instancetype)sharedInstance;
- (void)showMenu;
@end

@implementation FinxModMenu {
    UIWindow *floatingWindow;
    UIView *modMenu;
    UIView *tabAimbot, *tabVisuals, *tabMisc;
    UIButton *btnAimbotTab, *btnVisualsTab, *btnMiscTab;
}

+ (instancetype)sharedInstance {
    static FinxModMenu *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FinxModMenu alloc] init];
    });
    return sharedInstance;
}

- (void)showMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (floatingWindow) return;
        
        // النافذة المعائمة
        floatingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        floatingWindow.windowLevel = UIWindowLevelAlert + 100;
        floatingWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        floatingWindow.rootViewController = rootVC;
        
        // الزر العائم (FINX)
        UIButton *floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(30, 100, 60, 60);
        floatingBtn.backgroundColor = [UIColor colorWithRed:0.06 green:0.09 blue:0.11 alpha:0.95];
        [floatingBtn setTitle:@"FINX" forState:UIControlStateNormal];
        [floatingBtn setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
        floatingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        floatingBtn.layer.cornerRadius = 30;
        floatingBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0].CGColor;
        floatingBtn.layer.borderWidth = 2.0;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [floatingBtn addGestureRecognizer:panGesture];
        [floatingBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [rootVC.view addSubview:floatingBtn];
        
        // لوحة القائمة الرئيسية
        modMenu = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 330, 480)];
        modMenu.backgroundColor = [UIColor colorWithRed:0.05 green:0.07 blue:0.09 alpha:0.96];
        modMenu.layer.cornerRadius = 14;
        modMenu.layer.borderWidth = 1.0;
        modMenu.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.35].CGColor;
        modMenu.hidden = YES;
        
        // Header
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 330, 45)];
        header.backgroundColor = [UIColor colorWithRed:0.03 green:0.05 blue:0.06 alpha:0.9];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 250, 20)];
        titleLabel.attributedText = [self createStyledTitle];
        [header addSubview:titleLabel];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(288, 10, 26, 26);
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        closeBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
        closeBtn.layer.cornerRadius = 13;
        [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:closeBtn];
        [modMenu addSubview:header];
        
        // Tab Bar
        UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 330, 36)];
        tabBar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        
        btnAimbotTab = [self createTabButton:@"AIMBOT" frame:CGRectMake(0, 0, 110, 36) action:@selector(showAimbotTab)];
        btnVisualsTab = [self createTabButton:@"VISUALS" frame:CGRectMake(110, 0, 110, 36) action:@selector(showVisualsTab)];
        btnMiscTab = [self createTabButton:@"MISC" frame:CGRectMake(220, 0, 110, 36) action:@selector(showMiscTab)];
        
        [btnAimbotTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
        
        [tabBar addSubview:btnAimbotTab];
        [tabBar addSubview:btnVisualsTab];
        [tabBar addSubview:btnMiscTab];
        [modMenu addSubview:tabBar];
        
        // Content Area
        UIView *contentArea = [[UIView alloc] initWithFrame:CGRectMake(14, 95, 302, 370)];
        
        tabAimbot = [self createAimbotContent];
        tabVisuals = [self createVisualsContent];
        tabVisuals.hidden = YES;
        tabMisc = [self createMiscContent];
        tabMisc.hidden = YES;
        
        [contentArea addSubview:tabAimbot];
        [contentArea addSubview:tabVisuals];
        [contentArea addSubview:tabMisc];
        [modMenu addSubview:contentArea];
        
        [rootVC.view addSubview:modMenu];
        [floatingWindow makeKeyAndVisible];
    });
}

- (NSAttributedString *)createStyledTitle {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"FINX PRO ENGINE"];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] range:NSMakeRange(0, 4)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(4, 11)];
    return str;
}

- (UIButton *)createTabButton:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (UIView *)createAimbotContent {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 302, 370)];
    [view addSubview:[self createControlItemWithTitle:@"Aimbot State" desc:@"تفعيل نظام التنشين التلقائي" y:0 isOn:YES]];
    [view addSubview:[self createControlItemWithTitle:@"Silent Aim" desc:@"إطلاق نار موجه بدون حركة الكاميرا" y:55 isOn:NO]];
    
    UIView *hitboxContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 302, 85)];
    hitboxContainer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.025];
    hitboxContainer.layer.cornerRadius = 8;
    hitboxContainer.layer.borderWidth = 1.0;
    hitboxContainer.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;
    
    UILabel *hbLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 200, 15)];
    hbLabel.text = @"Target Hitbox (منطقة الاستهداف)";
    hbLabel.textColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
    hbLabel.font = [UIFont boldSystemFontOfSize:11];
    [hitboxContainer addSubview:hbLabel];
    
    NSArray *hitboxes = @[@"🎯 Head", @"🎽 Neck", @"🛡️ Chest", @"🦵 Legs"];
    for (int i = 0; i < 4; i++) {
        int row = i / 2;
        int col = i % 2;
        UIButton *hbBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        hbBtn.frame = CGRectMake(10 + col * 144, 28 + row * 26, 138, 24);
        [hbBtn setTitle:hitboxes[i] forState:UIControlStateNormal];
        hbBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        hbBtn.layer.cornerRadius = 6;
        hbBtn.layer.borderWidth = 1.0;
        
        if (i == 0) {
            hbBtn.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.15];
            [hbBtn setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
            hbBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0].CGColor;
        } else {
            hbBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.04];
            [hbBtn setTitleColor:[UIColor colorWithRed:0.53 green:0.53 blue:0.6 alpha:1.0] forState:UIControlStateNormal];
            hbBtn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.08].CGColor;
        }
        [hitboxContainer addSubview:hbBtn];
    }
    [view addSubview:hitboxContainer];
    return view;
}

- (UIView *)createVisualsContent {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 302, 370)];
    [view addSubview:[self createControlItemWithTitle:@"ESP Box" desc:@"مربعات رادار الأعداء" y:0 isOn:YES]];
    [view addSubview:[self createControlItemWithTitle:@"ESP Line" desc:@"خطوط متصلة باللاعبين" y:55 isOn:NO]];
    return view;
}

- (UIView *)createMiscContent {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 302, 370)];
    [view addSubview:[self createControlItemWithTitle:@"No Recoil" desc:@"إلغاء ارتداد السلاح تماماً" y:0 isOn:YES]];
    return view;
}

- (UIView *)createControlItemWithTitle:(NSString *)title desc:(NSString *)desc y:(CGFloat)y isOn:(BOOL)isOn {
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, y, 302, 48)];
    item.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.025];
    item.layer.cornerRadius = 8;
    item.layer.borderWidth = 1.0;
    item.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 7, 220, 16)];
    lblTitle.text = title;
    lblTitle.textColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
    lblTitle.font = [UIFont boldSystemFontOfSize:12];
    
    UILabel *lblDesc = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 220, 14)];
    lblDesc.text = desc;
    lblDesc.textColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.4 alpha:1.0];
    lblDesc.font = [UIFont systemFontOfSize:9];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(240, 9, 0, 0)];
    [sw setOn:isOn];
    
    [item addSubview:lblTitle];
    [item addSubview:lblDesc];
    [item addSubview:sw];
    return item;
}

- (void)showAimbotTab {
    tabAimbot.hidden = NO; tabVisuals.hidden = YES; tabMisc.hidden = YES;
    [btnAimbotTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
    [btnVisualsTab setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
    [btnMiscTab setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
}

- (void)showVisualsTab {
    tabAimbot.hidden = YES; tabVisuals.hidden = NO; tabMisc.hidden = YES;
    [btnAimbotTab setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
    [btnVisualsTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
    [btnMiscTab setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
}

- (void)showMiscTab {
    tabAimbot.hidden = YES; tabVisuals.hidden = YES; tabMisc.hidden = NO;
    [btnAimbotTab setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
    [btnVisualsTab setTitleColor:[UIColor colorWithRed:0.4 green:0.4 blue:0.45 alpha:1.0] forState:UIControlStateNormal];
    [btnMiscTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
}

- (void)handleDrag:(UIPanGestureRecognizer *)gesture {
    UIView *btn = gesture.view;
    CGPoint translation = [gesture translationInView:btn.superview];
    btn.center = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:btn.superview];
}

- (void)toggleMenu {
    modMenu.hidden = !modMenu.hidden;
}

@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FinxModMenu sharedInstance] showMenu];
    });
}
