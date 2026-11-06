#import <UIKit/UIKit.h>

@interface FinxModMenu : NSObject
+ (instancetype)sharedInstance;
- (void)showMenu;
@end

@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    return (hitView == self || hitView == self.rootViewController.view) ? nil : hitView;
}
@end

@implementation FinxModMenu {
    PassThroughWindow *floatingWindow;
    UIView *modMenu;
    UIScrollView *contentScroll;
    UIView *tabAimbot, *tabVisuals, *tabMisc, *tabSettings;
    UIButton *btnAimbotTab, *btnVisualsTab, *btnMiscTab, *btnSettingsTab;
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
        
        UIWindowScene *scene = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                scene = (UIWindowScene *)s;
                break;
            }
        }
        
        if (scene) {
            floatingWindow = [[PassThroughWindow alloc] initWithWindowScene:scene];
        } else {
            floatingWindow = [[PassThroughWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        
        floatingWindow.windowLevel = UIWindowLevelAlert + 99999;
        floatingWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        floatingWindow.rootViewController = rootVC;
        
        // زر الفينكس العائم بالتاج الملكي القابل للتحريك
        UIButton *floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(30, 100, 55, 55);
        floatingBtn.backgroundColor = [UIColor colorWithRed:0.06 green:0.09 blue:0.11 alpha:0.95];
        [floatingBtn setTitle:@"👑" forState:UIControlStateNormal];
        floatingBtn.titleLabel.font = [UIFont systemFontOfSize:26];
        floatingBtn.layer.cornerRadius = 27.5;
        floatingBtn.layer.masksToBounds = YES;
        floatingBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0].CGColor;
        floatingBtn.layer.borderWidth = 2.0;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragButton:)];
        [floatingBtn addGestureRecognizer:pan];
        [floatingBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [rootVC.view addSubview:floatingBtn];
        
        // إطار القائمة الرئيسية الفخم (PRO ENGINE FINX)
        modMenu = [[UIView alloc] initWithFrame:CGRectMake(80, 70, 350, 460)];
        modMenu.backgroundColor = [UIColor colorWithRed:0.04 green:0.06 blue:0.08 alpha:0.98];
        modMenu.layer.cornerRadius = 16;
        modMenu.layer.borderWidth = 1.2;
        modMenu.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.5].CGColor;
        modMenu.hidden = YES;
        
        // عنوان القائمة العلوي
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 350, 20)];
        title.text = @"PRO ENGINE FINX";
        title.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0];
        title.font = [UIFont boldSystemFontOfSize:14];
        title.textAlignment = NSTextAlignmentCenter;
        title.userInteractionEnabled = YES;
        UIPanGestureRecognizer *menuPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
        [title addGestureRecognizer:menuPan];
        [modMenu addSubview:title];
        
        // زر الإغلاق (X)
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(315, 10, 26, 26);
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [modMenu addSubview:closeBtn];
        
        // شريط التنقل بين الأقسام (Tabs) - مرتبة كالصورة: Settings | Misc | Visuals | Aimbot
        UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(15, 42, 320, 36)];
        tabBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.04];
        tabBar.layer.cornerRadius = 8;
        
        btnSettingsTab = [self createTabBtn:@"SETTINGS" frame:CGRectMake(0, 0, 80, 36) action:@selector(showSettings)];
        btnMiscTab     = [self createTabBtn:@"MISC" frame:CGRectMake(80, 0, 80, 36) action:@selector(showMisc)];
        btnVisualsTab  = [self createTabBtn:@"VISUALS" frame:CGRectMake(160, 0, 80, 36) action:@selector(showVisuals)];
        btnAimbotTab   = [self createTabBtn:@"AIMBOT" frame:CGRectMake(240, 0, 80, 36) action:@selector(showAimbot)];
        
        // جعل Aimbot هو القسم الافتراضي النشط
        [btnAimbotTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
        
        [tabBar addSubview:btnSettingsTab];
        [tabBar addSubview:btnMiscTab];
        [tabBar addSubview:btnVisualsTab];
        [tabBar addSubview:btnAimbotTab];
        [modMenu addSubview:tabBar];
        
        // حاوية محتوى الأقسام مع دعم التمرير (Scroll View) لتسع كل الميزات المذهلة
        contentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 88, 320, 356)];
        contentScroll.showsVerticalScrollIndicator = YES;
        
        tabAimbot   = [self createAimbotContent];
        tabVisuals  = [self createVisualsContent];
        tabVisuals.hidden = YES;
        tabMisc     = [self createMiscContent];
        tabMisc.hidden = YES;
        tabSettings = [self createSettingsContent];
        tabSettings.hidden = YES;
        
        [contentScroll addSubview:tabAimbot];
        [contentScroll addSubview:tabVisuals];
        [contentScroll addSubview:tabMisc];
        [contentScroll addSubview:tabSettings];
        
        [modMenu addSubview:contentScroll];
        [rootVC.view addSubview:modMenu];
        
        [floatingWindow makeKeyAndVisible];
        floatingWindow.hidden = NO;
    });
}

- (UIButton *)createTabBtn:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

// ==================== 1. محتوى قسم AIMBOT الكامل ====================
- (UIView *)createAimbotContent {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 850)];
    CGFloat y = 0;
    
    [v addSubview:[self createSectionHeader:@"AIMBOT CORE & ASSIST 🎯" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Aimbot State" desc:@"تفعيل نظام التنشين التلقائي" y:y]]; y += 52;
    [v addSubview:[self createToggle:@"Legit Aim Assist" desc:@"مساعدة تنشين دقيقة وطبيعية جداً للسلاح" y:y]]; y += 52;
    [v addSubview:[self createSlider:@"Aim Assist Strength (قوة الجذب الناعم)" min:0 max:100 current:45 y:y]]; y += 65;
    
    [v addSubview:[self createSectionHeader:@"AIM LOCK / TRIGGER MODE ⚡" y:y]]; y += 32;
    // أزرار الاختيار المربع (Grid 2x2)
    [v addSubview:[self createGridOptions:@[@"Scope Only 🎯", @"Fire Only 🔥", @"Always On ∞", @"Scope + Fire ⚡"] y:y]]; y += 105;
    [v addSubview:[self createToggle:@"Silent Aim" desc:@"إطلاق نار موجه بدون حركة الكاميرا" y:y]]; y += 52;
    
    [v addSubview:[self createSectionHeader:@"ADVANCED COMBAT MODS 🩸" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Bullet Track / Magic Bullet" desc:@"توجه الرصاص تلقائياً نحو العدو القريب" y:y]]; y += 52;
    [v addSubview:[self createToggle:@"Instant Hit (Zero Velocity)" desc:@"وصول فوري للرصاصة بدون تأخير" y:y]]; y += 62;
    
    [v addSubview:[self createSectionHeader:@"TARGET HITBOX (منطقة الاستهداف) 👤" y:y]]; y += 32;
    [v addSubview:[self createGridOptions:@[@"Neck ⚡", @"Head 👑", @"Legs 🏃", @"Chest 🛡️"] y:y]]; y += 105;
    
    [v addSubview:[self createSectionHeader:@"SMART TARGET FILTERS 🛡️" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Visible Check" desc:@"استهداف الأعداء المكشوفين فقط (فحص الساتر)" y:y]]; y += 52;
    [v addSubview:[self createToggle:@"Ignore Knocked" desc:@"تجاهل اللاعبين المصابين على الأرض" y:y]]; y += 52;
    [v addSubview:[self createToggle:@"Show FOV Circle" desc:@"رسم دائرة نطاق الأيم الأخضر على الشاشة" y:y]]; y += 52;
    [v addSubview:[self createSlider:@"Aimbot FOV Size" min:10 max:360 current:120 y:y]]; y += 65;
    [v addSubview:[self createSlider:@"Smoothness Factor" min:1 max:20 current:5 y:y]]; y += 65;
    
    v.frame = CGRectMake(0, 0, 320, y + 20);
    contentScroll.contentSize = CGSizeMake(320, y + 20);
    return v;
}

// ==================== 2. محتوى قسم VISUALS (ESP & RADAR) ====================
- (UIView *)createVisualsContent {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 750)];
    CGFloat y = 0;
    
    [v addSubview:[self createSectionHeader:@"PLAYER ESP PRO 👤" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"ESP Box Mode" desc:@"رسم إطار مربع (2D / 3D) حول الأعداء" y:y]]; y += 52;
    [v addSubview:[self createToggle:@"ESP Player Health" desc:@"إظهار شريط صحة وطاقة اللاعبين" y:y]]; y += 52;
    [v addSubview:[self createToggle:@"ESP Skeleton" desc:[cite: 8] stringByAppendingString:@"رسم مفصل وعظام الأعداء"] y:y]]; y += 52; //[cite: 8]
    [v addSubview:[self createToggle:@"Show Player Names & Team ID" desc:[cite: 8] stringByAppendingString:@"كشف اسم اللاعب ورقم فريقه"] y:y]]; y += 52; //[cite: 8]
    [v addSubview:[self createToggle:@"ESP Line (Tracer)" desc:[cite: 8] stringByAppendingString:@"خط متصل يتجه لموقع اللاعب"] y:y]]; y += 52; //[cite: 8]
    [v addSubview:[self createToggle:@"ESP Distance" desc:[cite: 8] stringByAppendingString:@"إظهار مسافة البعد بالأمتار"] y:y]]; y += 62; //[cite: 8]
    
    [v addSubview:[self createSectionHeader:@"RADAR & WARNING SYSTEM 📡" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Off-Screen Enemy Indicators" desc:[cite: 9] stringByAppendingString:@"أسهم تنبيه على جوانب الشاشة للأعداء الخلفيين"] y:y]]; y += 52; //[cite: 9]
    [v addSubview:[self createToggle:@"Crosshair Aim Warning" desc:[cite: 9] stringByAppendingString:@"تنبيه عند قيام عدو بالتنشين عليك مباشرة"] y:y]]; y += 62; //[cite: 9]
    
    [v addSubview:[self createSectionHeader:@"VEHICLE ESP 🚗" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Show Vehicles" desc:[cite: 9] stringByAppendingString:@"إظهار أماكن السيارات والمركبات"] y:y]]; y += 52; //[cite: 9]
    [v addSubview:[self createToggle:@"Vehicle Health & Distance" desc:[cite: 9] stringByAppendingString:@"إظهار قوة تحمل المركبة وبعدها"] y:y]]; y += 62; //[cite: 9]
    
    [v addSubview:[self createSectionHeader:@"ITEMS & WEAPON ESP 🎁" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Show Drop Weapons" desc:[cite: 9] stringByAppendingString:@"كشف الأسلحة والعتاد الأرضي"] y:y]]; y += 52; //[cite: 9]
    [v addSubview:[self createToggle:@"Show AirDrop / Crate" desc:[cite: 9] stringByAppendingString:@"كشف صناديق الإمداد والدروب"] y:y]]; y += 52; //[cite: 9]
    
    v.frame = CGRectMake(0, 0, 320, y + 20);
    return v;
}

// ==================== 3. محتوى قسم MISC (الأداء والتحكم) ====================
- (UIView *)createMiscContent {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)];
    CGFloat y = 0;
    
    [v addSubview:[self createSectionHeader:@"CAMERA & VIEW OPTIONS 🖥️" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"iPad View Mode" desc:[cite: 10] stringByAppendingString:@"تمديد منظور كاميرا السطور الأبعاد العريض"] y:y]]; y += 52; //[cite: 10]
    [v addSubview:[self createSlider:@"iPad View Distance (FOV)" min:100 max:150 current:125 y:y]]; y += 65;
    
    [v addSubview:[self createSectionHeader:@"CUSTOM CROSSHAIR & GRAPHIC 🎯" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Custom Pro Crosshair" desc:[cite: 10, 12] stringByAppendingString:@"إظهار مؤشر تصليب مخصص في منتصف الشاشة"] y:y]]; y += 52; //[cite: 10, 12]
    [v addSubview:[self createToggle:@"Night Mode / High Contrast" desc:[cite: 10, 12] stringByAppendingString:@"زيادة التباين لرؤية الأعداء في الظلام"] y:y]]; y += 62; //[cite: 10, 12]
    
    [v addSubview:[self createSectionHeader:@"GAMEPLAY MODS ⚡" y:y]]; y += 32;
    [v addSubview:[self createSlider:@"Recoil Control Factor (نسبة التحكم بالارتداد)" min:0 max:100 current:80 y:y]]; y += 65;
    [v addSubview:[self createSlider:@"Speed Hack Factor (سرعة الحركة)" min:1 max:3 current:1 y:y]]; y += 65;
    [v addSubview:[self createToggle:@"Fast Reload" desc:[cite: 12] stringByAppendingString:@"تعبئة الذخيرة بسرعة فائقة"] y:y]]; y += 52; //[cite: 12]
    
    v.frame = CGRectMake(0, 0, 320, y + 20);
    return v;
}

// ==================== 4. محتوى قسم SETTINGS (الحماية والحفظ) ====================
- (UIView *)createSettingsContent {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 350)];
    CGFloat y = 0;
    
    [v addSubview:[self createSectionHeader:@"PROTECTION & RECORDING 🛡️" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Streamproof / Anti-Record" desc: stringByAppendingString:@"إخفاء القائمة والـ ESP تماماً أثناء تصوير الشاشة"] y:y]]; y += 62; //
    
    [v addSubview:[self createSectionHeader:@"MENU CONFIGURATION 💾" y:y]]; y += 32;
    [v addSubview:[self createToggle:@"Save / Load Custom Config" desc: stringByAppendingString:@"حفظ خياراتك وتلقائيتها عند تشغيل اللعبة"] y:y]]; y += 62; //
    
    // أزرار الحفظ والتحميل (Load Config / Save Config)
    UIButton *loadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    loadBtn.frame = CGRectMake(0, y, 150, 40);
    loadBtn.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.15];
    [loadBtn setTitle:@"Load Config 📂" forState:UIControlStateNormal];
    [loadBtn setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
    loadBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    loadBtn.layer.cornerRadius = 8;
    loadBtn.layer.borderWidth = 1.0;
    loadBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.5].CGColor;
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    saveBtn.frame = CGRectMake(160, y, 160, 40);
    saveBtn.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.25];
    [saveBtn setTitle:@"Save Config 💾" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    saveBtn.layer.cornerRadius = 8;
    saveBtn.layer.borderWidth = 1.0;
    saveBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.6].CGColor;
    
    [v addSubview:loadBtn];
    [v addSubview:saveBtn];
    y += 55;
    
    v.frame = CGRectMake(0, 0, 320, y + 20);
    return v;
}

// ==================== دوال تصميم العناصر المساعدة ====================
- (UIView *)createSectionHeader:(NSString *)title y:(CGFloat)y {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(2, y, 316, 22)];
    lbl.text = title;
    lbl.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0];
    lbl.font = [UIFont boldSystemFontOfSize:11];
    return lbl;
}

- (UIView *)createToggle:(NSString *)title desc:(NSString *)desc y:(CGFloat)y {
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, 45)];
    item.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    item.layer.cornerRadius = 8;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 230, 16)];
    lbl.text = title;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont boldSystemFontOfSize:12];
    
    UILabel *subLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 230, 14)];
    subLbl.text = desc;
    subLbl.textColor = [UIColor grayColor];
    subLbl.font = [UIFont systemFontOfSize:9];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(255, 7, 0, 0)];
    [sw setOn:NO];
    [sw setOnTintColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0]];
    
    [item addSubview:lbl];
    [item addSubview:subLbl];
    [item addSubview:sw];
    return item;
}

- (UIView *)createSlider:(NSString *)title min:(float)min max:(float)max current:(float)current y:(CGFloat)y {
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, 55)];
    item.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    item.layer.cornerRadius = 8;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 220, 18)];
    lbl.text = title;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont boldSystemFontOfSize:11];
    
    UILabel *valLbl = [[UILabel alloc] initWithFrame:CGRectMake(235, 6, 75, 18)];
    valLbl.text = [NSString stringWithFormat:@"%.0f", current];
    valLbl.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0];
    valLbl.font = [UIFont boldSystemFontOfSize:11];
    valLbl.textAlignment = NSTextAlignmentRight;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 28, 300, 20)];
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = current;
    slider.minimumTrackTintColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0];
    
    [item addSubview:lbl];
    [item addSubview:valLbl];
    [item addSubview:slider];
    return item;
}

- (UIView *)createGridOptions:(NSArray *)options y:(CGFloat)y {
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, 95)];
    CGFloat w = 152;
    CGFloat h = 40;
    
    for (int i = 0; i < options.count; i++) {
        int row = i / 2;
        int col = i % 2;
        CGFloat posX = col * (w + 10);
        CGFloat posY = row * (h + 8);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(posX, posY, w, h);
        btn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
        [btn setTitle:options[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        btn.layer.cornerRadius = 8;
        btn.layer.borderWidth = 1.0;
        btn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
        
        [item addSubview:btn];
    }
    return item;
}

// ==================== دوال التنقل بين الأقسام ====================
- (void)showSettings {
    tabSettings.hidden = NO; tabMisc.hidden = YES; tabVisuals.hidden = YES; tabAimbot.hidden = YES;
    [self updateTabColors:btnSettings];
    contentScroll.contentSize = tabSettings.frame.size;
}

- (void)showMisc {
    tabSettings.hidden = YES; tabMisc.hidden = NO; tabVisuals.hidden = YES; tabAimbot.hidden = YES;
    [self updateTabColors:btnMiscTab];
    contentScroll.contentSize = tabMisc.frame.size;
}

- (void)showVisuals {
    tabSettings.hidden = YES; tabMisc.hidden = YES; tabVisuals.hidden = NO; tabAimbot.hidden = YES;
    [self updateTabColors:btnVisualsTab];
    contentScroll.contentSize = tabVisuals.frame.size;
}

- (void)showAimbot {
    tabSettings.hidden = YES; tabMisc.hidden = YES; tabVisuals.hidden = YES; tabAimbot.hidden = NO;
    [self updateTabColors:btnAimbotTab];
    contentScroll.contentSize = tabAimbot.frame.size;
}

- (void)updateTabColors:(UIButton *)activeBtn {
    [btnSettingsTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnMiscTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnVisualsTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnAimbotTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [activeBtn setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
}

// ==================== دوال السحب والإظهار ====================
- (void)dragButton:(UIPanGestureRecognizer *)p {
    UIView *btn = p.view;
    CGPoint translation = [p translationInView:btn.superview];
    btn.center = CGPointMake(btn.center.x + translation.x, btn.center.y + translation.y);
    [p setTranslation:CGPointZero inView:btn.superview];
}

- (void)dragMenu:(UIPanGestureRecognizer *)p {
    CGPoint translation = [p translationInView:modMenu.superview];
    modMenu.center = CGPointMake(modMenu.center.x + translation.x, modMenu.center.y + translation.y);
    [p setTranslation:CGPointZero inView:modMenu.superview];
}

- (void)toggleMenu {
    modMenu.hidden = !modMenu.hidden;
}

@end

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FinxModMenu sharedInstance] showMenu];
    });
}
