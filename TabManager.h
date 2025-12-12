//
//  TabManager.h
//  tbrapp
//
//  Created by Carson Mobile on 12/11/25.
//

// TabManager.h

#import <Cocoa/Cocoa.h>
#import "DatabaseManager.h" // Assuming DatabaseManager.h contains the necessary declarations

// Forward declaration for the Action Target class
@class TabActionTarget;

/**
 * @brief Objective-C class to handle button clicks for the Profile tab (Read/Write/Update/Delete/Filter).
 * * This is necessary because C++ classes cannot directly implement Objective-C methods
 * that are used as selectors (like buttonClicked:).
 */
@interface TabActionTarget : NSObject
- (void)buttonClicked:(id)sender;
@end

// --- C++ Wrapper for Tab Management ---

/**
 * @brief C++ class to manage the creation of all tabs.
 * * It uses static methods for simple access, acting as a utility class
 * rather than a strict singleton (though it mimics the usage of your original FirstTab).
 */
class TabManager {
public:
    // Main function to draw all tabs
    static void DrawAllTabs(NSWindow* inWindow, NSTabView* tv);

    // Individual tab drawing functions
    static void DrawMyShelfTab(NSWindow* inWindow, NSTabView* tv);
    static void DrawProfileTab(NSWindow* inWindow, NSTabView* tv);
    static void DrawFindBooksTab(NSWindow* inWindow, NSTabView* tv);
    static void DrawSocialTab(NSWindow* inWindow, NSTabView* tv);
    static void DrawFifthTab(NSWindow* inWindow, NSTabView* tv); // Placeholder for a 5th tab
    static void DrawAuditTab(NSWindow* inWindow, NSTabView* tv); // Placeholder for a 5th tab
};


/*
 TODO:
    - Rank books based off reviews of the app (analytical)
    - Book Recommendation (analytical)
    - view user reviews / comments on books (analytical)
 */
 
 
 
