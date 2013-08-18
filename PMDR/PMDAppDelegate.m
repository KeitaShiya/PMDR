#import "PMDAppDelegate.h"
#import "PMDTimer.h"

@interface PMDAppDelegate () <PMDTimerDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSMenuItem *countItem;

@end


@implementation PMDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    self.statusItem = [statusBar statusItemWithLength:60.f];
    self.statusItem.title = @"Stop";
    self.statusItem.target = self;
    self.statusItem.action = @selector(showMenu);
    [self.statusItem setEnabled:YES];
    self.countItem = [[NSMenuItem alloc] init];
}

- (void)showMenu
{
    PMDTimer *timer = [PMDTimer sharedTimer];
    timer.delegate = self;
    
    NSInteger minutes = timer.remainingSeconds / 60;
    NSInteger seconds = timer.remainingSeconds % 60;
    self.countItem.title  = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
    
    NSMenuItem *startMenuItem = [[NSMenuItem alloc] init];
    startMenuItem.title = (timer.phase == PMDPhaseStopped)?@"Start":@"Restart";
    startMenuItem.target = timer;
    startMenuItem.action = @selector(start);
    
    NSMenuItem *stopMenuItem = [[NSMenuItem alloc] init];
    stopMenuItem.title = @"Stop";
    stopMenuItem.target = timer;
    stopMenuItem.action = @selector(stop);
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] init];
    quitMenuItem.title = @"Quit";
    quitMenuItem.target = [NSApplication sharedApplication];
    quitMenuItem.action = @selector(terminate:);
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"weeeeei"];
    [menu addItem:self.countItem];
    [menu addItem:startMenuItem];
    [menu addItem:stopMenuItem];
    [menu addItem:quitMenuItem];
    
    [self.statusItem popUpStatusItemMenu:menu];
}

#pragma mark - PMDTimerDelegate

- (void)timerDidChangePhase:(PMDTimer *)timer
{
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center removeAllDeliveredNotifications];
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    switch (timer.phase) {
        case PMDPhaseWorking:{
            notification.title = @"Breaking -> Working";
            self.statusItem.title = @"Working";
            break;
        }
        case PMDPhaseBreaking:{
            notification.title = @"Working -> Breaking";
            self.statusItem.title = @"Breaking";
            break;
        }
        case PMDPhaseStopped:{
            self.statusItem.title = @"Stop";
            break;
        }
        default: break;
    }
    
    [center deliverNotification:notification];
}

@end
