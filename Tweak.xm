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
    UIView *tabMain, *tabVisuals, *tabMisc;
    UIButton *btnMainTab, *btnVisualsTab, *btnMiscTab;
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
        
        // زر الفينكس العائم بالصورة المباشرة وقابل للتحريك
        UIButton *floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(30, 100, 55, 55);
        floatingBtn.backgroundColor = [UIColor colorWithRed:0.06 green:0.09 blue:0.11 alpha:0.95];
        floatingBtn.layer.cornerRadius = 27.5;
        floatingBtn.layer.masksToBounds = YES;
        floatingBtn.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0].CGColor;
        floatingBtn.layer.borderWidth = 2.0;
        
        // جلب الصورة مباشرة عبر رابط خادم موثوق يضمن ظهورها 100%
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://i.ibb.co/3s6Q1Q9/image.png"]];
            if (imgData) {
                UIImage *btnImage = [UIImage imageWithData:imgData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [floatingBtn setImage:btnImage forState:UIControlStateNormal];
                    floatingBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
                });
            }
        });
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragButton:)];
        [floatingBtn addGestureRecognizer:pan];
        [floatingBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [rootVC.view addSubview:floatingBtn];
        
        // إطار القائمة الرئيسية
        modMenu = [[UIView alloc] initWithFrame:CGRectMake(95, 100, 320, 420)];
        modMenu.backgroundColor = [UIColor colorWithRed:0.05 green:0.07 blue:0.09 alpha:0.97];
        modMenu.layer.cornerRadius = 16;
        modMenu.layer.borderWidth = 1.2;
        modMenu.layer.borderColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:0.4].CGColor;
        modMenu.hidden = YES;
        
        // شريط عنوان القائمة (قابل للسحب)
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 200, 24)];
        title.text = @"FINX PRO MENU";
        title.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0];
        title.font = [UIFont boldSystemFontOfSize:15];
        title.userInteractionEnabled = YES;
        UIPanGestureRecognizer *menuPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragMenu:)];
        [title addGestureRecognizer:menuPan];
        [modMenu addSubview:title];
        
        // زر الإغلاق (X)
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        closeBtn.frame = CGRectMake(280, 12, 26, 26);
        [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [modMenu addSubview:closeBtn];
        
        // شريط التنقل بين الأقسام (Tabs)
        UIView *tabBar = [[UIView alloc] initWithFrame:CGRectMake(15, 48, 290, 34)];
        tabBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.04];
        tabBar.layer.cornerRadius = 8;
        
        btnMainTab = [self createTabBtn:@"AIMBOT" frame:CGRectMake(0, 0, 96, 34) action:@selector(showMain)];
        btnVisualsTab = [self createTabBtn:@"ESP & VISUALS" frame:CGRectMake(96, 0, 98, 34) action:@selector(showVisuals)];
        btnMiscTab = [self createTabBtn:@"MISC" frame:CGRectMake(194, 0, 96, 34) action:@selector(showMisc)];
        
        [btnMainTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
        
        [tabBar addSubview:btnMainTab];
        [tabBar addSubview:btnVisualsTab];
        [tabBar addSubview:btnMiscTab];
        [modMenu addSubview:tabBar];
        
        // محتوى الأقسام
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(15, 92, 290, 310)];
        
        tabMain = [self createMainTabContent];
        tabVisuals = [self createVisualsTabContent];
        tabVisuals.hidden = YES;
        tabMisc = [self createMiscTabContent];
        tabMisc.hidden = YES;
        
        [container addSubview:tabMain];
        [container addSubview:tabVisuals];
        [container addSubview:tabMisc];
        [modMenu addSubview:container];
        
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

- (UIView *)createMainTabContent {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 310)];
    [v addSubview:[self createToggle:@"Aimbot Enable" desc:@"تفعيل التنشين التلقائي" y:0]];
    [v addSubview:[self createToggle:@"Silent Aim" desc:@"إطلاق نار بدون حركة" y:55]];
    [v addSubview:[self createToggle:@"Auto Fire" desc:@"إطلاق نار تلقائي عند الهدف" y:110]];
    [v addSubview:[self createToggle:@"Aim Lock" desc:@"تثبيت السلاح على الهدف" y:165]];
    return v;
}

- (UIView *)createVisualsTabContent {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 310)];
    [v addSubview:[self createToggle:@"ESP Box" desc:@"مربعات أماكن الأعداء" y:0]];
    [v addSubview:[self createToggle:@"ESP Line" desc:@"خطوط توصيل للأعداء" y:55]];
    [v addSubview:[self createToggle:@"ESP Distance" desc:@"إظهار المسافة للخصم" y:110]];
    [v addSubview:[self createToggle:@"Wallhack" desc:@"الرؤية خلف الجدران" y:165]];
    return v;
}

- (UIView *)createMiscTabContent {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 310)];
    [v addSubview:[self createToggle:@"No Recoil" desc:@"إلغاء ارتداد السلاح تماماً" y:0]];
    [v addSubview:[self createToggle:@"Fast Reload" desc:@"سرعة تعبئة الذخيرة" y:55]];
    [v addSubview:[self createToggle:@"Speed Hack" desc:@"زيادة سرعة الحركة" y:110]];
    [v addSubview:[self createToggle:@"FOV Changer" desc:@"تغيير منظور الكاميرا العريض" y:165]];
    return v;
}

- (UIView *)createToggle:(NSString *)title desc:(NSString *)desc y:(CGFloat)y {
    UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, y, 290, 45)];
    item.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    item.layer.cornerRadius = 8;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 190, 16)];
    lbl.text = title;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont boldSystemFontOfSize:12];
    
    UILabel *subLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 190, 14)];
    subLbl.text = desc;
    subLbl.textColor = [UIColor grayColor];
    subLbl.font = [UIFont systemFontOfSize:9];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(225, 7, 0, 0)];
    [sw setOn:NO];
    
    [item addSubview:lbl];
    [item addSubview:subLbl];
    [item addSubview:sw];
    return item;
}

- (void)showMain {
    tabMain.hidden = NO; tabVisuals.hidden = YES; tabMisc.hidden = YES;
    [btnMainTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
    [btnVisualsTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnMiscTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

- (void)showVisuals {
    tabMain.hidden = YES; tabVisuals.hidden = NO; tabMisc.hidden = YES;
    [btnMainTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnVisualsTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
    [btnMiscTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

- (void)showMisc {
    tabMain.hidden = YES; tabVisuals.hidden = YES; tabMisc.hidden = NO;
    [btnMainTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnVisualsTab setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [btnMiscTab setTitleColor:[UIColor colorWithRed:0.0 green:1.0 blue:0.67 alpha:1.0] forState:UIControlStateNormal];
}

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
