//  AppDelegate.m
//  tbrapp
//
//  Created by Carson Mobile on 12/1/25.
//

#import "AppDelegate.h"
#import "TabManager.h"
#import <Cocoa/Cocoa.h>
@interface AppDelegate ()
@property (nonatomic, strong) NSWindow *window;
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect contentRect = NSMakeRect(100, 100, 800, 600);
    
    // Define the window style
    // ... (Window style definition remains the same) ...
    
    self.window = [[NSWindow alloc] initWithContentRect:contentRect
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
    
    self.window.title = @"Tabbed Scrollable App";
    
    // --- 2. Create the Tab View ---
    
    NSRect tabViewFrame = self.window.contentView.bounds;
    
    // Initialize the main tab view
    NSTabView *tabView = [[NSTabView alloc] initWithFrame:tabViewFrame];
    tabView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add the tab view to the window's content view
    [self.window.contentView addSubview:tabView];
    
    // Set up Auto Layout constraints to make the tab view fill the window
    [tabView.topAnchor constraintEqualToAnchor:self.window.contentView.topAnchor].active = YES;
    [tabView.bottomAnchor constraintEqualToAnchor:self.window.contentView.bottomAnchor].active = YES;
    [tabView.leadingAnchor constraintEqualToAnchor:self.window.contentView.leadingAnchor].active = YES;
    [tabView.trailingAnchor constraintEqualToAnchor:self.window.contentView.trailingAnchor].active = YES;
    
    // --- CALL THE NEW TAB MANAGER TO DRAW ALL TABS ---
    TabManager::DrawAllTabs(self.window, tabView);
    // You now have 5 tabs: My Shelf, Profile, Find Books, Social, and Settings.
    
    // --- 3. Display the Window ---
    
    // Center the window on the screen
    [self.window center];
    
    // Make the window key (active) and visible
    [self.window makeKeyAndOrderFront:nil];
}

// ... (Rest of AppDelegate methods remain the same) ...
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}
@end
