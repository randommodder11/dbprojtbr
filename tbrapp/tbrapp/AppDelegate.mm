//  AppDelegate.m
//  tbrapp
//
//  Created by Carson Mobile on 12/1/25.
//

#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
@interface TabActionTarget : NSObject
@end

class FirstTab {
public:
    static FirstTab& GetInstance(){
        static FirstTab instance;
        return instance;
    }
    void DrawTab(NSWindow* inWindow, NSTabView* tv) {
        NSString *tabTitle = @"Profile";
        
        // 1. Create a Tab View Item
        NSTabViewItem *tabViewItem = [NSTabViewItem tabViewItemWithViewController:nil];
        tabViewItem.label = tabTitle;
        
        // --- CREATE A MASTER CONTAINER VIEW ---
        // The ScrollView and the Button need a common parent view (Container)
        // inside the tab item.
        NSRect containerFrame = inWindow.contentView.bounds;
        NSView *containerView = [[NSView alloc] initWithFrame:containerFrame];
        containerView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        

        static TabActionTarget *actionTarget = nil;
        if (actionTarget == nil) {
            actionTarget = [[TabActionTarget alloc] init];
        }
        
        NSButton* MenuButton[5];
        NSString* ButtonNames[5] = {@"Read", @"Write", @"Update", @"Delete", @"Filter"};
        for(int i = 0; i<5; ++i){
            NSRect buttonFrame = NSMakeRect(10 + (i*140), 10, 120, 32); // Position at the bottom left
            MenuButton[i] = [[NSButton alloc] initWithFrame:buttonFrame];
            MenuButton[i].title = ButtonNames[i];
            MenuButton[i].bezelStyle = NSBezelStyleRounded;
            
            MenuButton[i].target = actionTarget;
            MenuButton[i].tag = i+1;
            MenuButton[i].action = @selector(buttonClicked:);
        }
        
        // 3. Create a Scroll View
        // Make the Scroll View's frame smaller to make room for the button at the bottom.
        //CGFloat buttonHeight = buttonFrame.size.height + 20; // Button height + margin
        NSRect scrollViewFrame = NSMakeRect(0, 52, containerFrame.size.width, containerFrame.size.height - 52);
        
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:scrollViewFrame];
        scrollView.hasVerticalScroller = YES;
        scrollView.hasHorizontalScroller = NO;
        scrollView.autohidesScrollers = YES;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMinYMargin;

        // 4. Create the document view (NSTextView)
        NSRect textViewFrame = NSMakeRect(0, 0, scrollViewFrame.size.width, scrollViewFrame.size.height * 2.0);
        NSTextView *textView = [[NSTextView alloc] initWithFrame:textViewFrame];
        
        NSMutableString *text = [NSMutableString string];
        for (int j = 1; j <= 50; j++) {
            [text appendFormat:@"This is line %d of content for %@.\n", j, tabTitle];
        }
        textView.string = text;
        textView.editable = NO;
        textView.verticallyResizable = YES;
        textView.horizontallyResizable = NO;
        
        // Set the text view as the document view of the scroll view
        scrollView.documentView = textView;
        
        // 5. Add the scroll view and the button to the container view
        [containerView addSubview:scrollView];
        for(int i = 0 ; i<5 ; ++i){
            [containerView addSubview:MenuButton[i]];
        }
        
        // 6. Set the container view as the view for the tab item
        tabViewItem.view = containerView;
        
        // 7. Add the tab item to the tab view
        [tv addTabViewItem:tabViewItem];
    }
    
    
};
@interface AppDelegate ()

// Retain a reference to the main window
@property (nonatomic, strong) NSWindow *window;

@end

#include <stdio.h>
#import "FMDatabase.h" // Ensure this is imported
#import <Foundation/Foundation.h>
// Assuming you have imported FMDB header elsewhere or have it in your bridging header
// #import "FMDatabase.h"

// Helper function to get the Documents directory path
NSString *documentsPath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

// Connects to the database, ensuring the file is copied to the Documents folder first.
static FMDatabase* connectDatabase() {
    NSString *dbFileName = @"test3_somereal";
    NSString *dbFileType = @"db";
    
    // 1. Define the final path (in the Documents folder)
    NSString *destinationFileName = [NSString stringWithFormat:@"%@.%@", dbFileName, dbFileType];
    NSString *destPath = [documentsPath() stringByAppendingPathComponent:destinationFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 2. Check if the database file already exists in the Documents folder.
    if (![fileManager fileExistsAtPath:destPath]) {
        
        // 3. If it does NOT exist, find the original file in the App Bundle (read-only location)
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:dbFileName ofType:dbFileType];
        
        if (!sourcePath) {
            NSLog(@"❌ Error: Source database file '%@.%@' not found in the application bundle.", dbFileName, dbFileType);
            return NULL;
        }
        
        // 4. Copy the file from the App Bundle to the Documents folder.
        NSError *error = nil;
        BOOL success = [fileManager copyItemAtPath:sourcePath toPath:destPath error:&error];
        
        if (success) {
            NSLog(@"✅ Database copied successfully to Documents folder: %@", destPath);
        } else {
            NSLog(@"❌ Error copying database: %@", error.localizedDescription);
            return NULL;
        }
    } else {
        NSLog(@"✅ Database already exists in Documents folder: %@", destPath);
    }
    
    // 5. Connect to the database using the file in the Documents folder.
    FMDatabase *db = [FMDatabase databaseWithPath:destPath];
    
    if (![db open]) {
        NSLog(@"❌ Error: Could not open database at path: %@", destPath);
        return NULL;
    }
    
    // Enable Foreign Keys for SQLite (crucial for your friend table cascade)
    [db executeUpdate:@"PRAGMA foreign_keys = ON;"];
    
    return db;
}

static FMResultSet* executeQuery(FMDatabase* db, NSString* query){
    if(db == nullptr) return nullptr;
    
    NSLog(@"EXECUTING QUERY: %@", query);
    FMResultSet *s = [db executeQuery:query];

    if (!s) {
        NSLog(@"❌ Error executing query: %@", [db lastErrorMessage]);
        [db close];
        return nullptr;
    }
    
    return s;
}
static void closeQuery(FMResultSet* s){
    if(s)
    [s close];
}
static void closeDatabase(FMDatabase* db){
    if(db)
    [db close];
}

//Read
static void DBTest() {
    auto db = connectDatabase();
    auto query = executeQuery(db, @"SELECT * FROM user");
    
    if (query) {
        NSLog(@"\n--- Database Query Results ---");
        
        while ([query next]) {
            NSDictionary *rowDict = [query resultDictionary];
            NSLog(@"Read: %@", rowDict);
        }
        
        NSLog(@"--- End of Results ---\n");
        [query close];
    }
    closeQuery(query);
    closeDatabase(db);
}
//Write
static void DBTestTwo(){
    auto db = connectDatabase();
    NSString* insertString = @"INSERT INTO user(username,password) VALUES('Carson','Password');";
    auto query = executeQuery(db, insertString);
    if(query){
        while([query next]){
            NSDictionary* result = [query resultDictionary];
            NSLog(@"Write %@", result);
        }
    }
    closeQuery(query);
    closeDatabase(db);
}
//Update
static void DBTestThree(){
    auto db = connectDatabase();
    NSString* insertString = @"UPDATE user SET password = 'newpassword' WHERE username = 'Carson';";
    auto query = executeQuery(db, insertString);
    if(query){
        while([query next]){
            NSDictionary* result = [query resultDictionary];
            NSLog(@"Write %@", result);
        }
    }
    closeQuery(query);
    closeDatabase(db);
}
//Delete
static void DBTestFour(){
    auto db = connectDatabase();
    NSString* insertString = @"DELETE FROM user WHERE username = 'Carson';";
    auto query = executeQuery(db, insertString);
    if(query){
        while([query next]){
            NSDictionary* result = [query resultDictionary];
            NSLog(@"Write %@", result);
        }
    }
    closeQuery(query);
    closeDatabase(db);
}
static void DBTestFive(){
    auto db = connectDatabase();
    NSString* insertString = @"SELECT * FROM user WHERE username = 'Carson';";
    auto query = executeQuery(db, insertString);
    if(query){
        while([query next]){
            NSDictionary* result = [query resultDictionary];
            NSLog(@"Write %@", result);
        }
    }
    closeQuery(query);
    closeDatabase(db);
}

@implementation TabActionTarget

- (void)buttonClicked:(id)sender {
    NSButton* castButton = (NSButton*)(sender);
    if(castButton.tag == 1){
        DBTest();
    }
    if(castButton.tag == 2){
        DBTestTwo();
    }
    if(castButton.tag == 3){
        DBTestThree();
    }
    if(castButton.tag == 4){
        DBTestFour();
    }
    if(castButton.tag == 5){
        DBTestFive();
    }
    NSLog(@"button clicked");
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect contentRect = NSMakeRect(100, 100, 800, 600);
    
    // Define the window style: Titled, Closable, Minimizable, Resizable
    NSUInteger windowStyle = NSWindowStyleMaskTitled |
                             NSWindowStyleMaskClosable |
                             NSWindowStyleMaskMiniaturizable |
                             NSWindowStyleMaskResizable;
    
    self.window = [[NSWindow alloc] initWithContentRect:contentRect
                                              styleMask:windowStyle
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    // Set a title for the window
    self.window.title = @"Tabbed Scrollable App";
    
    // --- 2. Create the Tab View and Scroll Views ---
    
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
    
    NSString* PageNames[] = {@"My Shelf",@"Profile",@"Find Books", @"Social"};
    FirstTab::GetInstance().DrawTab(self.window, tabView);
    // Create 3 Tabs, each with a Scroll View
    for (int i = 1; i <= 3; i++) {
        NSString *tabTitle = PageNames[i];// [NSString stringWithFormat:@"Page %d", i];
        
        // 1. Create a Tab View Item
        NSTabViewItem *tabViewItem = [NSTabViewItem tabViewItemWithViewController:nil];
        tabViewItem.label = tabTitle;
        
        // 2. Create a Scroll View
        NSRect scrollViewFrame = self.window.contentView.bounds; // Initial frame
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:scrollViewFrame];
        scrollView.hasVerticalScroller = YES;
        scrollView.hasHorizontalScroller = NO;
        scrollView.autohidesScrollers = YES;
        
        // 3. Create the document view (the view that will be scrolled)
        // We'll use a large NSTextView to ensure we can scroll
        NSRect textViewFrame = NSMakeRect(0, 0, scrollViewFrame.size.width, scrollViewFrame.size.height * 2.0); // Make it twice as tall
        NSTextView *textView = [[NSTextView alloc] initWithFrame:textViewFrame];
        
        // Setup the text content
        NSMutableString *text = [NSMutableString string];
        for (int j = 1; j <= 50; j++) {
            [text appendFormat:@"This is line %d of content for %@.\n", j, tabTitle];
        }
        textView.string = text;
        textView.editable = NO;
        textView.verticallyResizable = YES;
        textView.horizontallyResizable = NO;
        
        // Set the text view as the document view of the scroll view
        scrollView.documentView = textView;
        
        // Set the scroll view as the view for the tab item
        tabViewItem.view = scrollView;
        
        // Add the tab item to the tab view
        [tabView addTabViewItem:tabViewItem];
    }
    
    // --- 3. Display the Window ---
    
    // Center the window on the screen
    [self.window center];
    
    // Make the window key (active) and visible
    [self.window makeKeyAndOrderFront:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
