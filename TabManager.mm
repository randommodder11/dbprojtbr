//
//  TabManager.mm
//  tbrapp
//
//  Created by Carson Mobile on 12/11/25.
//

// TabManager.mm

#import "TabManager.h"
#import "FMDatabase.h" // Needed for database operations (connectDatabase, executeQuery, etc.)

int Insecure_Account_ID = -1;

// --- New Classes and Prototypes for Find Books Tab ---

// Simple struct to hold book data for display
typedef struct {
    NSString *title;
    NSArray<NSString *> *authors;
    NSArray<NSString *> *genres;
    NSString *publisher;
} BookData;











// --- FindBooksManager Class (Handles state and logic for the Find Books tab) ---
// This class will manage the search term, results, and pagination.
@interface SocialsManager : NSObject

@property (nonatomic, strong) NSPopUpButton *SocialTypePopup;
@property (nonatomic, strong) NSScrollView *resultsScrollView;
@property (nonatomic, strong) NSView *resultsContainerView; // The view inside the scroll view

@property (nonatomic, copy) NSString *currentSearchTerm;
@property (nonatomic, copy) NSString *currentSearchType;
@property (nonatomic, strong) NSArray<NSString *> *allResultsTitles; // All results from DB

- (void)searchButtonClicked:(id)sender;
- (void)nextPage:(id)sender;
- (void)backPage:(id)sender;
- (void)bookRowClicked:(NSButton *)sender;

@end

@implementation SocialsManager

//Follow, CreateFriends, CurrentFriends
- (instancetype)init {
    NSLog(@"init");
    self = [super init];
    if (self) {
        _currentSearchType = @"Follow"; // Default search type
    }
    return self;
}


- (void)updateResultsDisplay {
    NSLog(@"updateResultsDisplay");
    self.currentSearchTerm = [self.SocialTypePopup titleOfSelectedItem];
    // Clear the current results view
    for (NSView *subview in [self.resultsContainerView subviews]) {
        [subview removeFromSuperview];
    }
    CGFloat containerWidth = self.resultsScrollView.frame.size.width;
    
    if (Insecure_Account_ID == -1) {
        NSTextField *label = [NSTextField labelWithString:@"Please sign in via the Profile tab to access socials."];
        [label setFrame:NSMakeRect(20, 10, 400, 20)];
        [self.resultsContainerView addSubview:label];
        [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, 40)];
        return;
    }
    
    CGFloat currentY = 0;
    CGFloat rowHeight = 50; // Height for a single book row
    
    // --- Database Fetch Logic (based on user's comments) ---
    
    // 1. Get the User Profile Index linked to Insecure_Account_ID
    // Assume this is available:
    int userProfileIndex = [[DatabaseManager sharedManager] FetchUserProfileIndex:Insecure_Account_ID];
    //Follow, CreateFriends, CurrentFriends
    if([self.currentSearchTerm isEqualToString:@"Follow"]){
        NSArray<NSNumber*>* Users = [[DatabaseManager sharedManager] GetAllFollowableUsers:userProfileIndex];
        for (NSNumber* current : Users) {
            NSString *bookTitle = [NSString stringWithFormat:@"User %@", current];
            
            // Create a clickable button/view for the row
            NSButton *rowButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, currentY, containerWidth, rowHeight)];
            [rowButton setTarget:self];
            [rowButton setAction:@selector(followUser:)];
            [rowButton setTag:[current integerValue]]; // Use the index for identification (or pass the bookTitle in a better way if needed)
            [rowButton setBordered:NO];
            [rowButton setButtonType:NSButtonTypeMomentaryChange];
            [rowButton setBezelStyle:NSBezelStyleTexturedSquare];
            
            // Add text labels to the button's cell/view
            NSTextField *titleLabel = [NSTextField labelWithString:bookTitle];
            [titleLabel setFrame:NSMakeRect(10, rowHeight - 25, containerWidth - 20, 20)];
            [titleLabel setFont:[NSFont boldSystemFontOfSize:14]];
            [rowButton addSubview:titleLabel];
            
            // Draw a separator line
            NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, containerWidth, 1)];
            [separator setBoxType:NSBoxSeparator];
            [rowButton addSubview:separator];
            
            [self.resultsContainerView addSubview:rowButton];
            currentY += rowHeight;
        }
    }
    if([self.currentSearchTerm isEqualToString:@"CreateFriends"]){
        NSArray<NSNumber*>* Users = [[DatabaseManager sharedManager] GetAllFriendableUsers:userProfileIndex];
        for (NSNumber* current : Users) {
            NSString *bookTitle = [NSString stringWithFormat:@"User %@", current];
            
            // Create a clickable button/view for the row
            NSButton *rowButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, currentY, containerWidth, rowHeight)];
            [rowButton setTarget:self];
            [rowButton setAction:@selector(friendUser:)];
            [rowButton setTag:[current integerValue]]; // Use the index for identification (or pass the bookTitle in a better way if needed)
            [rowButton setBordered:NO];
            [rowButton setButtonType:NSButtonTypeMomentaryChange];
            [rowButton setBezelStyle:NSBezelStyleTexturedSquare];
            
            // Add text labels to the button's cell/view
            NSTextField *titleLabel = [NSTextField labelWithString:bookTitle];
            [titleLabel setFrame:NSMakeRect(10, rowHeight - 25, containerWidth - 20, 20)];
            [titleLabel setFont:[NSFont boldSystemFontOfSize:14]];
            [rowButton addSubview:titleLabel];
            
            // Draw a separator line
            NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, containerWidth, 1)];
            [separator setBoxType:NSBoxSeparator];
            [rowButton addSubview:separator];
            
            [self.resultsContainerView addSubview:rowButton];
            currentY += rowHeight;
        }
    }
    if([self.currentSearchTerm isEqualToString:@"CurrentFriends"]){
        NSArray<NSNumber*>* Users = [[DatabaseManager sharedManager] GetAllFriends:userProfileIndex];
        for (NSNumber* current : Users) {
            NSString *bookTitle = [NSString stringWithFormat:@"User %@", current];
            
            // Create a clickable button/view for the row
            NSButton *rowButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, currentY, containerWidth, rowHeight)];
            [rowButton setTarget:self];
            [rowButton setTag:[current integerValue]]; // Use the index for identification (or pass the bookTitle in a better way if needed)
            [rowButton setBordered:NO];
            [rowButton setButtonType:NSButtonTypeMomentaryChange];
            [rowButton setBezelStyle:NSBezelStyleTexturedSquare];
            
            // Add text labels to the button's cell/view
            NSTextField *titleLabel = [NSTextField labelWithString:bookTitle];
            [titleLabel setFrame:NSMakeRect(10, rowHeight - 25, containerWidth - 20, 20)];
            [titleLabel setFont:[NSFont boldSystemFontOfSize:14]];
            [rowButton addSubview:titleLabel];
            
            // Draw a separator line
            NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, containerWidth, 1)];
            [separator setBoxType:NSBoxSeparator];
            [rowButton addSubview:separator];
            
            [self.resultsContainerView addSubview:rowButton];
            currentY += rowHeight;
        }
    }
    // Draw the results
    
    
    
    
    // Resize the container view to fit all results, flipping the coordinate system for scrolling
    CGFloat containerHeight = MAX(self.resultsScrollView.contentView.bounds.size.height, currentY);
    [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, containerHeight)];
    
    // Adjust the scroll view's document view and scroll to top
    if (currentY > self.resultsScrollView.contentView.bounds.size.height) {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, containerHeight - self.resultsScrollView.contentView.bounds.size.height)];
    } else {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, 0)];
    }
}

// --- Book Row Click Action ---
- (void)followUser:(NSButton *)sender {
    NSUInteger otherUserID = sender.tag;
    int userProfileIndex = [[DatabaseManager sharedManager] FetchUserProfileIndex:Insecure_Account_ID];
    [[DatabaseManager sharedManager] FollowUser:userProfileIndex Follows:otherUserID];
}
- (void)friendUser:(NSButton *)sender {
    NSUInteger otherUserID = sender.tag;
    int userProfileIndex = [[DatabaseManager sharedManager] FetchUserProfileIndex:Insecure_Account_ID];
    [[DatabaseManager sharedManager] Friend:userProfileIndex Friends:otherUserID];
}
- (void)callUpdate:(NSButton *)sender {
    [self updateResultsDisplay];
}


@end

SocialsManager* s_SocialsManager = nil;


























@interface MyAuditLogs : NSObject

@property (nonatomic, strong) NSPopUpButton *listSelectionPopup;
@property (nonatomic, strong) NSScrollView *resultsScrollView;
@property (nonatomic, strong) NSView *resultsContainerView;


- (void)UpdateAuditDisplay;

@end

@implementation MyAuditLogs

- (instancetype)init {
    self = [super init];
    return self;
}

// Helper to check if the user is signed in
- (BOOL)isUserSignedIn {
    return Insecure_Account_ID != -1;
}

- (void)UpdateAuditDisplay {
    NSLog(@"updateSettingsDisplay");
    
    // Clear the current results view
    for (NSView *subview in [self.resultsContainerView subviews]) {
        [subview removeFromSuperview];
    }
    
    CGFloat containerWidth = self.resultsScrollView.frame.size.width;
    NSArray<NSString*>* auditLogs = [[DatabaseManager sharedManager] GetAllAuditLogs];
    if (auditLogs.count == 0) {
        NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"This list is empty. Something is wrong."]];
        [label setFrame:NSMakeRect(20, 10, 400, 20)];
        [self.resultsContainerView addSubview:label];
        [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, 40)];
        return;
    }
    
    // --- Draw the results ---
    
    CGFloat currentY = 0;
    CGFloat rowHeight = 40; // Increased height to accommodate ratings/reviews
    for (NSString *log in auditLogs) {
        NSView *rowView = [[NSView alloc] initWithFrame:NSMakeRect(0, currentY, containerWidth, rowHeight)];
        
        // Title Label
        NSTextField *titleLabel = [NSTextField labelWithString:log];
        [titleLabel setFrame:NSMakeRect(10, rowHeight - 5, containerWidth, 30)];
        [rowView addSubview:titleLabel];
    
        // Draw a separator line
        NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, rowHeight - 1, containerWidth, 1)];
        [separator setBoxType:NSBoxSeparator];
        [rowView addSubview:separator];

        [self.resultsContainerView addSubview:rowView];
        currentY += rowHeight;
    }
    
    // Resize the container view to fit all results
    CGFloat containerHeight = MAX(self.resultsScrollView.contentView.bounds.size.height, currentY);
    [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, containerHeight)];
    
    // Adjust the scroll view's document view and scroll to top
    if (currentY > self.resultsScrollView.contentView.bounds.size.height) {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, containerHeight - self.resultsScrollView.contentView.bounds.size.height)];
    } else {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, 0)];
    }
}


@end


static MyAuditLogs *s_MyAuditLogs = nil;

















@interface MySettingsManager : NSObject

@property (nonatomic, strong) NSPopUpButton *listSelectionPopup;
@property (nonatomic, strong) NSScrollView *resultsScrollView;
@property (nonatomic, strong) NSView *resultsContainerView;


- (void)updateSettingsDisplay;
- (void)updateSettingsClicked:(NSButton *)sender;

@end

@implementation MySettingsManager

- (instancetype)init {
    self = [super init];
    return self;
}

// Helper to check if the user is signed in
- (BOOL)isUserSignedIn {
    return Insecure_Account_ID != -1;
}

- (void)updateSettingsClicked:(NSButton *)sender {
    
    //[self updateSettingsDisplay]; // Assuming this refreshes the UI list (before showing the alert)
    int userProfileIndex = [[DatabaseManager sharedManager] FetchUserProfileIndex:Insecure_Account_ID];
    NSArray<NSString*>* userSettings = [[DatabaseManager sharedManager] GetAllSettingsKeys:userProfileIndex];
    
    // Check if the tag is valid
    if ([sender tag] < 0 || [sender tag] >= [userSettings count]) {
        NSLog(@"Error: Invalid sender tag for settings array.");
        return;
    }
    
    NSString* SettingToUpdate = userSettings[[sender tag]];
    NSString* UpdateText = [NSString stringWithFormat:@"Update Setting '%@':", SettingToUpdate];
    
    // --- Setup the Alert ---
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:UpdateText];
    [alert setInformativeText:[NSString stringWithFormat:@"Enter the new value for '%@' below:", SettingToUpdate]];
    
    NSWindow *parentWindow = [sender window];

    NSTextField *inputField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 25)];
    [inputField setPlaceholderString:[NSString stringWithFormat:@"New value for %@", SettingToUpdate]];
    [inputField setStringValue:@""];
    
    [alert setAccessoryView:inputField];
    
    // --- Add Buttons ---
    [alert addButtonWithTitle:@"Update"]; // NSAlertFirstButtonReturn
    [alert addButtonWithTitle:@"Cancel"]; // NSAlertSecondButtonReturn
    [alert beginSheetModalForWindow:parentWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSString *newValue = [inputField stringValue];
            if ([newValue length] > 0) {
                NSLog(@"Updating setting '%@' for user %d with new value: '%@'", SettingToUpdate, userProfileIndex, newValue);
                [[DatabaseManager sharedManager] SetSettingsValueForKey:userProfileIndex SettingsName:SettingToUpdate newValue:newValue];
                [self updateSettingsDisplay];
            } else {
                NSLog(@"Update cancelled or empty value entered.");
            }
        }
    }];
}

/*
 Add buttons "move to DNF" "move to Finished" "move to Currently Reading" "move to Wants To Read" below the rating / review
 calls this function - (void)MoveUserBookToList:(int)UserBookIndex toList:(int)listIndex;
 */
- (void)updateSettingsDisplay {
    NSLog(@"updateSettingsDisplay");
    
    // Clear the current results view
    for (NSView *subview in [self.resultsContainerView subviews]) {
        [subview removeFromSuperview];
    }
    
    CGFloat containerWidth = self.resultsScrollView.frame.size.width;
    
    if (![self isUserSignedIn]) {
        NSTextField *label = [NSTextField labelWithString:@"Please sign in via the Profile tab to view your settings."];
        [label setFrame:NSMakeRect(20, 10, 400, 20)];
        [self.resultsContainerView addSubview:label];
        [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, 40)];
        return;
    }
    
    // --- Database Fetch Logic (based on user's comments) ---
    
    // 1. Get the User Profile Index linked to Insecure_Account_ID
    // Assume this is available:
    int userProfileIndex = [[DatabaseManager sharedManager] FetchUserProfileIndex:Insecure_Account_ID];
    NSArray<NSString*>* userSettings = [[DatabaseManager sharedManager] GetAllSettingsKeys:userProfileIndex];
    if (userSettings.count == 0) {
        NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"This list is empty. Something is wrong."]];
        [label setFrame:NSMakeRect(20, 10, 400, 20)];
        [self.resultsContainerView addSubview:label];
        [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, 40)];
        return;
    }
    
    // --- Draw the results ---
    
    CGFloat currentY = 0;
    CGFloat rowHeight = 60; // Increased height to accommodate ratings/reviews
    int index = 0;
    for (NSString *userSetting in userSettings) {
        NSString* SettingsValue = [[DatabaseManager sharedManager] GetSettingsValueForKey:userProfileIndex SettingsName:userSetting];
        NSView *rowView = [[NSView alloc] initWithFrame:NSMakeRect(0, currentY, containerWidth, rowHeight)];
            
            // Title Label
            NSTextField *titleLabel = [NSTextField labelWithString:userSetting];
            [titleLabel setFrame:NSMakeRect(10, rowHeight - 50, ( containerWidth / 2 ) - 20, 20)];
            [rowView addSubview:titleLabel];

            NSTextField *valueLabel = [NSTextField labelWithString:SettingsValue];
            [valueLabel setFrame:NSMakeRect((containerWidth / 2 ) + 10, rowHeight - 50, ( containerWidth / 2 ) - 20, 20)];
            [rowView addSubview:valueLabel];

            NSButton *ratingButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, rowHeight - 25, 100, 20)];
            [ratingButton setTitle:@"Change Value"];
            [ratingButton setTag:index];
            [ratingButton setTarget:self];
            [ratingButton setAction:@selector(updateSettingsClicked:)];
            [rowView addSubview:ratingButton];
        
            // Draw a separator line
            NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, rowHeight - 1, containerWidth, 1)];
            [separator setBoxType:NSBoxSeparator];
            [rowView addSubview:separator];

            [self.resultsContainerView addSubview:rowView];
            currentY += rowHeight;
        index++;
    }
    
    // Resize the container view to fit all results
    CGFloat containerHeight = MAX(self.resultsScrollView.contentView.bounds.size.height, currentY);
    [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, containerHeight)];
    
    // Adjust the scroll view's document view and scroll to top
    if (currentY > self.resultsScrollView.contentView.bounds.size.height) {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, containerHeight - self.resultsScrollView.contentView.bounds.size.height)];
    } else {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, 0)];
    }
}


@end


static MySettingsManager *s_MySettingsManager = nil;







































// --- MyShelfManager Class (Handles state and logic for the My Shelf tab) ---
@interface MyShelfManager : NSObject

@property (nonatomic, strong) NSPopUpButton *listSelectionPopup;
@property (nonatomic, strong) NSScrollView *resultsScrollView;
@property (nonatomic, strong) NSView *resultsContainerView;

@property (nonatomic, assign) NSInteger currentListIndex; // 0=Current, 1=Finished, 2=DNF, 3=Wants to Read

- (void)listSelectionChanged:(id)sender;
- (void)updateShelfDisplay;
- (void)leaveRatingClicked:(NSButton *)sender;
- (void)leaveReviewClicked:(NSButton *)sender;

@end

@implementation MyShelfManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentListIndex = 0; // Default to "Currently Reading"
    }
    return self;
}

// Helper to check if the user is signed in
- (BOOL)isUserSignedIn {
    return Insecure_Account_ID != -1;
}

// Helper to fetch the actual book details (Title, Authors, Genres, Publisher)
- (BookData)fetchDetailsForBookTitle:(NSString *)title {
    // Reusing the BookData struct and DatabaseManager calls from FindBooksManager
    NSArray<NSString*>* Authors = [[DatabaseManager sharedManager] fetchAuthorsForBookTitle:title];
    NSArray<NSString*>* Genres = [[DatabaseManager sharedManager] fetchGenresForBookTitle:title];
    NSString* Publishers = [[DatabaseManager sharedManager] fetchPublisherForBookTitle:title];
     
    BookData data;
    data.title = title;
    data.authors = Authors;
    data.genres = Genres;
    data.publisher = Publishers;
    return data;
}

- (void)listSelectionChanged:(id)sender {
    self.currentListIndex = [self.listSelectionPopup indexOfSelectedItem];
    [self updateShelfDisplay];
}

// --- New Action Method ---
- (void)moveToListClicked:(NSButton *)sender {
    // The tag stores the UserBookID
    int userBookID = (int)(sender.tag / 10);
    // The button's title or an auxiliary tag can define the destination list.
    // We use the button's auxiliary tag (tag % 10) to store the destination index (0-3).
    int destinationListIndex = (int)(sender.tag % 10);
    
    NSLog(@"Moving user_book ID %d to list index %d", userBookID, destinationListIndex);
    
    //    NSArray<NSString *> *listTitles = @[@"Currently Reading", @"Finished", @"DNF", @"Wants To Read"];
    //NSArray<NSNumber *> *listIndices = @[@0, @1, @2, @3];
    // Call the assumed database function
    [[DatabaseManager sharedManager] MoveUserBookToList:userBookID toList:destinationListIndex];
    
    // Check if the book was moved *out* of the current list.
    // If the destination is NOT the currently displayed list, we need to refresh.
    if (destinationListIndex != self.currentListIndex) {
        // Refresh the display to show the book has disappeared from the current view
        [self updateShelfDisplay];
    } else {
        // If they clicked "move to X" and X is the current list, nothing changes, but refresh anyway if needed.
        [self updateShelfDisplay];
    }
}

/*
 Add buttons "move to DNF" "move to Finished" "move to Currently Reading" "move to Wants To Read" below the rating / review
 calls this function - (void)MoveUserBookToList:(int)UserBookIndex toList:(int)listIndex;
 */
- (void)updateShelfDisplay {
    NSLog(@"updateShelfDisplay for List Index: %ld", (long)self.currentListIndex);
    
    // Clear the current results view
    for (NSView *subview in [self.resultsContainerView subviews]) {
        [subview removeFromSuperview];
    }
    
    CGFloat containerWidth = self.resultsScrollView.frame.size.width;
    
    if (![self isUserSignedIn]) {
        NSTextField *label = [NSTextField labelWithString:@"Please sign in via the Profile tab to view your shelf."];
        [label setFrame:NSMakeRect(20, 10, 400, 20)];
        [self.resultsContainerView addSubview:label];
        [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, 40)];
        return;
    }
    
    // --- Database Fetch Logic (based on user's comments) ---
    
    // 1. Get the User Profile Index linked to Insecure_Account_ID
    // Assume this is available:
    int userProfileIndex = [[DatabaseManager sharedManager] FetchUserProfileIndex:Insecure_Account_ID];
    NSLog(@"BookShelf userProfileIndex: %d Insecure_Account_ID: %d", userProfileIndex, Insecure_Account_ID);
    // 2. Fetch the User Book List ID (the primary key for the list)
    int bookListID = [[DatabaseManager sharedManager] FetchUserBookListID:self.currentListIndex ForUser:userProfileIndex];
    NSLog(@"BooksShelf bookListID: %d currentListIndex: %d ForUser: %d", bookListID, self.currentListIndex, userProfileIndex);
    // 3. Fetch all User_Book entries for the current list and user profile
    // This method is assumed to return an array of user_book IDs (integers/NSNumbers)
    NSArray<NSNumber *> *userBooks = [[DatabaseManager sharedManager] fetchUserBookList:bookListID linked_user_profile:userProfileIndex];
    
    if (userBooks.count == 0) {
        NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"This list is empty. Add books from the 'Find Books' tab."]];
        [label setFrame:NSMakeRect(20, 10, 400, 20)];
        [self.resultsContainerView addSubview:label];
        [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, 40)];
        return;
    }
    
    // --- Draw the results ---
    
    CGFloat currentY = 0;
    CGFloat rowHeight = 135; // Increased height to accommodate ratings/reviews

    for (NSNumber *userBookIDNum in userBooks) {
            int userBookID = [userBookIDNum intValue];
            
            // Fetch book data
            int bookID = [[DatabaseManager sharedManager] getBookFromUserBook:userBookID];
            NSString *bookTitle = [[DatabaseManager sharedManager] getBookNameFromBookID:bookID];
            BookData bookData = [self fetchDetailsForBookTitle:bookTitle]; // Reuse helper
            
            // --- Draw Row Content ---
            
            NSView *rowView = [[NSView alloc] initWithFrame:NSMakeRect(0, currentY, containerWidth, rowHeight)];
            
            // 1. Title, Author, Publisher, Progress (Y positions adjusted for new row height)
            
            // Title Label
            NSTextField *titleLabel = [NSTextField labelWithString:bookData.title];
            [titleLabel setFrame:NSMakeRect(10, rowHeight - 25, containerWidth - 20, 20)];
            [rowView addSubview:titleLabel];

            // Author and Publisher
            NSString *authorPublisherString = [NSString stringWithFormat:@"Author: %@ | Publisher: %@",
                                               bookData.authors.firstObject, bookData.publisher];
            NSTextField *authorPublisherLabel = [NSTextField labelWithString:authorPublisherString];
            [authorPublisherLabel setFrame:NSMakeRect(10, rowHeight - 45, containerWidth - 20, 16)];
            [rowView addSubview:authorPublisherLabel];
            
            // Progress
            int progress = [[DatabaseManager sharedManager] getProgressForUserBook:userBookID];
            NSTextField *progressLabel = [NSTextField labelWithString:[NSString stringWithFormat:@"Progress: %d%%", progress]];
            [progressLabel setFrame:NSMakeRect(containerWidth - 100, rowHeight - 25, 90, 20)];
            [progressLabel setAlignment:NSRightTextAlignment];
            [rowView addSubview:progressLabel];

            // 4. Rating Logic (Y position adjusted to be 40px from bottom)
            int linkedRatingID = [[DatabaseManager sharedManager] getLinkedRatingForUserBook:userBookID];
            
            if (linkedRatingID > 0) {
                int starRating = [[DatabaseManager sharedManager] getStarRatingForRating:linkedRatingID];
                NSTextField *ratingLabel = [NSTextField labelWithString:[NSString stringWithFormat:@"Rating: %d/5 Stars", starRating]];
                [ratingLabel setFrame:NSMakeRect(10, 40, 150, 20)];
                [rowView addSubview:ratingLabel];
            } else {
                NSButton *ratingButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 40, 120, 20)];
                [ratingButton setTitle:@"Leave Rating"];
                [ratingButton setTag:userBookID];
                [ratingButton setTarget:self];
                [ratingButton setAction:@selector(leaveRatingClicked:)];
                [rowView addSubview:ratingButton];
            }

            // 5. Review Logic (Y position adjusted to be 40px from bottom)
            int linkedReviewID = [[DatabaseManager sharedManager] getLinkedReviewForUserBook:userBookID];
            
            if (linkedReviewID > 0) {
                NSString *reviewText = [[DatabaseManager sharedManager] getReviewTextForReview:linkedReviewID];
                NSString *displayReview = [reviewText length] > 30 ? [NSString stringWithFormat:@"Review: %@...", [reviewText substringToIndex:30]] : [NSString stringWithFormat:@"Review: %@", reviewText];
                NSTextField *reviewLabel = [NSTextField labelWithString:displayReview];
                [reviewLabel setFrame:NSMakeRect(150, 40, containerWidth - 160, 20)];
                [rowView addSubview:reviewLabel];
            } else {
                NSButton *reviewButton = [[NSButton alloc] initWithFrame:NSMakeRect(150, 40, 120, 20)];
                [reviewButton setTitle:@"Leave Review"];
                [reviewButton setTag:userBookID];
                [reviewButton setTarget:self];
                [reviewButton setAction:@selector(leaveReviewClicked:)];
                [rowView addSubview:reviewButton];
            }

            // --- 6. New: Move to List Buttons (Bottom Row) ---
            
            NSArray<NSString *> *listTitles = @[@"Currently Reading", @"Finished", @"DNF", @"Wants To Read"];
            NSArray<NSNumber *> *listIndices = @[@0, @1, @2, @3];
            CGFloat buttonY = 10;
            CGFloat buttonWidth = (containerWidth - 5 * 1) / 4.0; // Distribute horizontally
            
            for (int i = 0; i < listTitles.count; i++) {
                int destinationIndex = [listIndices[i] intValue];
                
                // Skip creating the button if the destination is the CURRENTLY viewed list
                if (destinationIndex == self.currentListIndex) {
                    continue;
                }
                
                NSButton *moveButton = [[NSButton alloc] initWithFrame:NSMakeRect(1 + i * (buttonWidth + 1), buttonY, buttonWidth, 20)];
                
                // Set the title
                NSString *title = [NSString stringWithFormat:@"Move to %@", listTitles[i]];
                [moveButton setTitle:title];
                
                // Set the tag: Combine UserBookID and destination list index
                // Formula: UserBookID * 10 + destinationIndex
                [moveButton setTag:(userBookID * 10) + destinationIndex];
                
                [moveButton setTarget:self];
                [moveButton setAction:@selector(moveToListClicked:)];
                [rowView addSubview:moveButton];
            }


            // Draw a separator line
            NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, rowHeight - 1, containerWidth, 1)];
            [separator setBoxType:NSBoxSeparator];
            [rowView addSubview:separator];

            [self.resultsContainerView addSubview:rowView];
            currentY += rowHeight;
    }
    
    // Resize the container view to fit all results
    CGFloat containerHeight = MAX(self.resultsScrollView.contentView.bounds.size.height, currentY);
    [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, containerHeight)];
    
    // Adjust the scroll view's document view and scroll to top
    if (currentY > self.resultsScrollView.contentView.bounds.size.height) {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, containerHeight - self.resultsScrollView.contentView.bounds.size.height)];
    } else {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, 0)];
    }
}

// --- Rating/Review Popups ---

- (void)leaveRatingClicked:(NSButton *)sender {
    int userBookID = (int)sender.tag;
    // Assume there is a way to get the parent window
    NSWindow *parentWindow = [sender window];

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Rate this book (1 to 5 Stars)"];
    [alert setInformativeText:@"Select your star rating:"];
    
    // Add 5 buttons for 1 to 5 stars
    for (int i = 1; i <= 5; i++) {
        [alert addButtonWithTitle:[NSString stringWithFormat:@"%d Star%@", i, (i == 1 ? @"" : @"s")]];
    }

    [alert beginSheetModalForWindow:parentWindow completionHandler:^(NSModalResponse returnCode) {
        // NSAlertFirstButtonReturn is for the first button added (1 star),
        // NSAlertSecondButtonReturn for 2 stars, and so on.
        int starRating = (int)(returnCode - NSAlertFirstButtonReturn + 1);
        
        if (starRating >= 1 && starRating <= 5) {
            NSLog(@"Leaving rating %d for user_book ID: %d", starRating, userBookID);
            // Assume the following method is available in DatabaseManager:
            // - (void) leaveRating:(int)rating forUserBook:(int)userBookID;
            [[DatabaseManager sharedManager] leaveRating:starRating forUserBook:userBookID];
            
            // Refresh the shelf display
            [self updateShelfDisplay];
        }
    }];
}
/*
- (void)leaveReviewClicked:(NSButton *)sender {
    int userBookID = (int)sender.tag;
    NSWindow *parentWindow = [sender window];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Leave a Review"];
    [alert setInformativeText:@"Enter your review text below:"];

    // 1. Create a custom accessory view for the text field
    NSTextView *reviewTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 300, 100)];
    [reviewTextView setMinSize:NSMakeSize(300, 100)];
    [reviewTextView setMaxSize:NSMakeSize(500, 200)];
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:[reviewTextView frame]];
    [scrollView setDocumentView:reviewTextView];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setBorderType:NSBezelBorder];

    [alert setAccessoryView:scrollView];

    // 2. Add buttons (OK and Cancel)
    [alert addButtonWithTitle:@"Submit Review"];
    [alert addButtonWithTitle:@"Cancel"];

    [alert beginSheetModalForWindow:parentWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSString *reviewText = [reviewTextView string];
            
            if ([reviewText length] > 0) {
                NSLog(@"Submitting review for user_book ID: %d. Text: %@", userBookID, reviewText);
                // Assume the following method is available in DatabaseManager:
                // - (void) leaveReview:(NSString*)reviewText forUserBook:(int)userBookID;
                //[[DatabaseManager sharedManager] leaveReview:reviewText forUserBook:userBookID];
                
                // Refresh the shelf display
                [self updateShelfDisplay];
            } else {
                NSLog(@"Review submission cancelled or empty.");
            }
        }
    }];
}*/
- (void)leaveReviewClicked:(NSButton *)sender {
    int userBookID = (int)sender.tag;
    NSWindow *parentWindow = [sender window];
    
    // --- Setup the Alert ---
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Leave a Review and Rating"];
    [alert setInformativeText:@"Enter your review text and a star rating (1-5) below:"];

    // --- 1. Create the combined Accessory View ---
    
    CGFloat accessoryWidth = 350;
    CGFloat fieldHeight = 25;
    CGFloat reviewHeight = 100;
    CGFloat spacing = 10;
    
    // Total height calculation: Rating Input + spacing + Review Text Area
    CGFloat totalHeight = fieldHeight + spacing + reviewHeight;
    
    NSView *accessoryView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, accessoryWidth, totalHeight)];

    // 1a. Star Rating Input Field (Top Section)
    
    NSTextField *ratingLabel = [NSTextField labelWithString:@"Star Rating (1-5):"];
    [ratingLabel setFrame:NSMakeRect(0, reviewHeight + spacing, 120, fieldHeight)];
    [ratingLabel setAlignment:NSRightTextAlignment];
    [accessoryView addSubview:ratingLabel];
    
    NSTextField *ratingField = [[NSTextField alloc] initWithFrame:NSMakeRect(130, reviewHeight + spacing, 50, fieldHeight)];
    [ratingField setPlaceholderString:@"e.g., 5"];
    [ratingField setFormatter:[[NSNumberFormatter alloc] init]]; // Restricts to numbers
    [accessoryView addSubview:ratingField];

    // 1b. Review Text Field (Bottom Section)
    
    // The review text area now starts at Y=0
    NSTextView *reviewTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, accessoryWidth, reviewHeight)];
    [reviewTextView setMinSize:NSMakeSize(accessoryWidth, reviewHeight)];
    [reviewTextView setMaxSize:NSMakeSize(accessoryWidth, reviewHeight)];
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:[reviewTextView frame]];
    [scrollView setDocumentView:reviewTextView];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setBorderType:NSBezelBorder];
    [accessoryView addSubview:scrollView];
    
    // Set the combined accessory view
    [alert setAccessoryView:accessoryView];

    // 2. Add buttons
    [alert addButtonWithTitle:@"Submit"];
    [alert addButtonWithTitle:@"Cancel"];

    [alert beginSheetModalForWindow:parentWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSString *reviewText = [reviewTextView string];
            NSString *ratingString = [ratingField stringValue];
            int rating = [ratingString intValue];
            
            BOOL validRating = (rating >= 1 && rating <= 5);
            BOOL hasReview = ([reviewText length] > 0);
            
            if (validRating || hasReview) {
                
                if (validRating) {
                    NSLog(@"Submitting rating %d for user_book ID: %d", rating, userBookID);
                    // 1. Leave Rating
                    [[DatabaseManager sharedManager] leaveRating:rating forUserBook:userBookID];
                    if (hasReview) {
                        NSLog(@"Submitting review for user_book ID: %d. Text: %@", userBookID, reviewText);
                        // 2. Leave Review
                        [[DatabaseManager sharedManager]leaveReview:reviewText Stars:rating forUserBook:userBookID];
                        //[[DatabaseManager sharedManager] leaveReview:reviewText forUserBook:userBookID];
                    }
                } else if (ratingString.length > 0) {
                    // Invalid rating entered, but review might be present
                    NSAlert *errorAlert = [[NSAlert alloc] init];
                    [errorAlert setMessageText:@"Invalid Rating"];
                    [errorAlert setInformativeText:@"The star rating must be a number between 1 and 5. Only the review (if entered) will be saved."];
                    [errorAlert runModal];
                }
                
                
                
                // Refresh the shelf display
                [self updateShelfDisplay];
                
            } else {
                NSLog(@"Submission cancelled or empty fields.");
                NSAlert *emptyAlert = [[NSAlert alloc] init];
                [emptyAlert setMessageText:@"Submission Failed"];
                [emptyAlert setInformativeText:@"Please enter a valid rating (1-5) or a review to submit."];
                [emptyAlert runModal];
            }
        }
    }];
}

@end


// --- ProfileManager Class (Handles state and logic for the Profile tab) ---
// Assumed static variable `s_currentUserID` is managed externally or in a shared app state.
@interface ProfileManager : NSObject

@property (nonatomic, strong) NSPopUpButton *userSelectionPopup;
@property (nonatomic, strong) NSTextField *currentUserIDLabel;
@property (nonatomic, strong) NSView *accountCreationView;

// Input fields for creating a new user
@property (nonatomic, strong) NSTextField *usernameField;
@property (nonatomic, strong) NSSecureTextField *passwordField;
@property (nonatomic, strong) NSTextField *displayNameField;

- (void)updateProfileDisplay; // To show sign-in/creation or signed-in state
- (void)userSelected:(id)sender;
- (void)signOutClicked:(id)sender;
- (void)createAccountClicked:(id)sender;

@end

@implementation ProfileManager

- (void)updateProfileDisplay {
    // 1. Update the pop-up list of users
    [self.userSelectionPopup removeAllItems];
    NSArray<NSString *> *allUserIDs = [[DatabaseManager sharedManager] fetchAllUserID];

    if (allUserIDs.count > 0) {
        // Display as UserID - Display Name
        for (NSString *userID in allUserIDs) {
            NSString *displayName = [[DatabaseManager sharedManager] FetchDisplayNameForUserID:userID];
            NSString *title = [NSString stringWithFormat:@"%@ - %@", userID, displayName ? displayName : @"[No Name]"];
            [self.userSelectionPopup addItemWithTitle:title];
            
            // Set the selection if it matches the current user (assuming a shared state variable)
            // You must define how `s_currentUserID` is accessed/set.
            // For now, we assume `s_currentUserID` is an integer defined in TabManager.mm
           // int currentID = -1; // Placeholder for actual ID fetch
            
            if (Insecure_Account_ID > -1 && [userID integerValue] == Insecure_Account_ID) {
                [self.userSelectionPopup selectItemWithTitle:title];
            }
        }
    } else {
        [self.userSelectionPopup addItemWithTitle:@"No Accounts Found"];
        [self.userSelectionPopup selectItemAtIndex:0];
    }
    
    // 2. Toggle visibility of the account creation view based on signed-in status
   // int currentID = -1; // Placeholder: replace with actual user ID
    
    if (Insecure_Account_ID == -1) {
        [self.currentUserIDLabel setStringValue:@"Not Signed In"];
        [self.accountCreationView setHidden:NO];
    } else {
        NSString *displayName = [[DatabaseManager sharedManager] FetchDisplayNameForUserID:[NSString stringWithFormat:@"%d", Insecure_Account_ID]];
        [self.currentUserIDLabel setStringValue:[NSString stringWithFormat:@"Current User: %d (%@)", Insecure_Account_ID, displayName]];
        [self.accountCreationView setHidden:YES];
    }
}

- (void)userSelected:(id)sender {
    NSLog(@"User Selected");
    // Get the selected string (e.g., "1 - Alice")
    NSString *selectedTitle = [self.userSelectionPopup titleOfSelectedItem];
    if (!selectedTitle || [selectedTitle isEqualToString:@"No Accounts Found"]) return;

    // Parse out the UserID (e.g., "1")
    NSString *userIDString = [[selectedTitle componentsSeparatedByString:@" - "] firstObject];
    Insecure_Account_ID = [userIDString intValue];
    // Log in (assuming an external state manager sets the user_id)
    // int newUserID = [userIDString intValue];
    // [SharedStateManager setUserID:newUserID];
    
    [self updateProfileDisplay];
 
    [s_MySettingsManager updateSettingsDisplay];
    [s_MyAuditLogs UpdateAuditDisplay];
}


- (void)signOutClicked:(id)sender {
    // Log out (assuming an external state manager sets the user_id to 0)
    // [SharedStateManager setUserID:0];
    NSLog(@"Signed Out (UserID set to 0)");
    Insecure_Account_ID = -1;
    [self updateProfileDisplay];
}

- (void)createAccountClicked:(id)sender {
    NSString *username = [self.usernameField stringValue];
    NSString *password = [self.passwordField stringValue];
    NSString *displayName = [self.displayNameField stringValue];
    
    if ([username length] > 0 && [password length] > 0 && [displayName length] > 0) {
        // 1. Create the user in the database
        // NOTE: This assumes CreateUser returns the new UserID or success status
        //- (int) CreateUser:(NSString*)username withpassword:(NSString*)password withname:(NSString*) displayName;
        //[[DatabaseManager sharedManager] CreateUser:username withPassword:password withName:displayName];
        [[DatabaseManager sharedManager] CreateUser:username withpassword:password withname:displayName];
        NSLog(@"New User Created: %@", username);
        
        // 2. Clear fields and refresh the display
        [self.usernameField setStringValue:@""];
        [self.passwordField setStringValue:@""];
        [self.displayNameField setStringValue:@""];
        
        // 3. Refresh the pop-up and display status
        [self updateProfileDisplay];
    } else {
        // Show an error/alert that fields are empty
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Creation Failed"];
        [alert setInformativeText:@"All fields (Username, Password, Display Name) must be filled to create an account."];
        [alert runModal];
    }
}

@end
















// --- FindBooksManager Class (Handles state and logic for the Find Books tab) ---
// This class will manage the search term, results, and pagination.
@interface FindBooksManager : NSObject

@property (nonatomic, strong) NSTextField *searchField;
@property (nonatomic, strong) NSPopUpButton *searchTypePopup;
@property (nonatomic, strong) NSScrollView *resultsScrollView;
@property (nonatomic, strong) NSView *resultsContainerView; // The view inside the scroll view
@property (nonatomic, strong) NSButton *nextButton;
@property (nonatomic, strong) NSButton *backButton;

@property (nonatomic, copy) NSString *currentSearchTerm;
@property (nonatomic, copy) NSString *currentSearchType;
@property (nonatomic, strong) NSArray<NSString *> *allResultsTitles; // All results from DB
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger resultsPerPage;

- (void)searchButtonClicked:(id)sender;
- (void)nextPage:(id)sender;
- (void)backPage:(id)sender;
- (void)bookRowClicked:(NSButton *)sender;

@end

@implementation FindBooksManager

- (instancetype)init {
    NSLog(@"init");
    self = [super init];
    if (self) {
        _resultsPerPage = 25;
        _currentPage = 0;
        _allResultsTitles = @[];
        _currentSearchType = @"Book"; // Default search type
    }
    return self;
}

// Helper to fetch the actual book details (Title, Authors, Genres, Publisher)
- (BookData)fetchDetailsForBookTitle:(NSString *)title {
    NSLog(@"fetch details for book title");
    // These methods are assumed to be implemented in DatabaseManager
    NSArray<NSString*>* Authors = [[DatabaseManager sharedManager] fetchAuthorsForBookTitle:title];
    NSArray<NSString*>* Genres = [[DatabaseManager sharedManager] fetchGenresForBookTitle:title];
    NSString* Publishers = [[DatabaseManager sharedManager] fetchPublisherForBookTitle:title];
    
    BookData data;
    data.title = title;
    data.authors = Authors;
    data.genres = Genres;
    data.publisher = Publishers;
    return data;
}

// --- Search and Display Logic ---

- (void)searchButtonClicked:(id)sender {
    NSLog(@"start search button clicked");
    // 1. Get current search term and type
    self.currentSearchTerm = [self.searchField stringValue];
    self.currentSearchType = [self.searchTypePopup titleOfSelectedItem];

    if ([self.currentSearchTerm length] == 0) {
        self.allResultsTitles = @[];
    } else {
        // 2. Fetch all results from the database based on type
        // NOTE: This assumes a method like fetchBookTitlesForSearch is available in DatabaseManager
        // which takes the type ("Book", "Author", "Publisher") and the search string.
        if ([self.currentSearchType isEqualToString:@"Book"]) {
            self.allResultsTitles = [[DatabaseManager sharedManager] fetchBookTitlesForBook:self.currentSearchTerm];
        } else if ([self.currentSearchType isEqualToString:@"Author"]) {
            NSLog(@"Search Button Clicked Author");
            self.allResultsTitles = [[DatabaseManager sharedManager] fetchBookTitlesForAuthor:self.currentSearchTerm];
        } else if ([self.currentSearchType isEqualToString:@"Publisher"]) {
            NSLog(@"Search Button Clicked Publisher");
            self.allResultsTitles = [[DatabaseManager sharedManager] fetchBookTitlesForPublisher:self.currentSearchTerm];
        } else {
            self.allResultsTitles = @[];
        }
    }
    
    NSLog(@"searchButtonClicked");
    
    // 3. Reset to first page and redraw
    self.currentPage = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateResultsDisplay];
    });
    
}

- (void)nextPage:(id)sender {
    NSUInteger maxPage = (self.allResultsTitles.count > 0) ? (self.allResultsTitles.count - 1) / self.resultsPerPage : 0;
    if (self.currentPage < maxPage) {
        self.currentPage++;
        [self updateResultsDisplay];
    }
}

- (void)backPage:(id)sender {
    if (self.currentPage > 0) {
        self.currentPage--;
        [self updateResultsDisplay];
    }
}

- (void)updateResultsDisplay {
    NSLog(@"updateResultsDisplay");
    // Clear the current results view
    for (NSView *subview in [self.resultsContainerView subviews]) {
        [subview removeFromSuperview];
    }
    
    // Calculate the range of results to display
    NSUInteger startIndex = self.currentPage * self.resultsPerPage;
    NSUInteger endIndex = MIN(startIndex + self.resultsPerPage, self.allResultsTitles.count);
    
    // Update pagination button states
    [self.backButton setEnabled:(self.currentPage > 0)];
    NSUInteger maxPage = (self.allResultsTitles.count > 0) ? (self.allResultsTitles.count - 1) / self.resultsPerPage : 0;
    [self.nextButton setEnabled:(self.currentPage < maxPage)];

    // No results found message
    if (self.allResultsTitles.count == 0 && [self.currentSearchTerm length] > 0) {
        NSTextField *noResultsLabel = [NSTextField labelWithString:@"No results found."];
        [noResultsLabel setFrame:NSMakeRect(20, 10, 300, 20)];
        [self.resultsContainerView addSubview:noResultsLabel];
        [self.resultsContainerView setFrameSize:NSMakeSize(self.resultsScrollView.frame.size.width, 40)];
        return;
    } else if ([self.currentSearchTerm length] == 0) {
        NSTextField *promptLabel = [NSTextField labelWithString:@"Enter a search term above to find books."];
        [promptLabel setFrame:NSMakeRect(20, 10, 300, 20)];
        [self.resultsContainerView addSubview:promptLabel];
        [self.resultsContainerView setFrameSize:NSMakeSize(self.resultsScrollView.frame.size.width, 40)];
        return;
    }


    // Draw the results
    CGFloat currentY = 0;
    CGFloat rowHeight = 70; // Height for a single book row
    CGFloat containerWidth = self.resultsScrollView.frame.size.width;

    for (NSUInteger i = startIndex; i < endIndex; i++) {
        NSString *bookTitle = self.allResultsTitles[i];
        BookData bookData = [self fetchDetailsForBookTitle:bookTitle];

        // Create a clickable button/view for the row
        NSButton *rowButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, currentY, containerWidth, rowHeight)];
        [rowButton setTarget:self];
        [rowButton setAction:@selector(bookRowClicked:)];
        [rowButton setTag:i]; // Use the index for identification (or pass the bookTitle in a better way if needed)
        [rowButton setBordered:NO];
        [rowButton setButtonType:NSButtonTypeMomentaryChange];
        [rowButton setBezelStyle:NSBezelStyleTexturedSquare];
        
        // Add text labels to the button's cell/view
        NSTextField *titleLabel = [NSTextField labelWithString:bookData.title];
        [titleLabel setFrame:NSMakeRect(10, rowHeight - 25, containerWidth - 20, 20)];
        [titleLabel setFont:[NSFont boldSystemFontOfSize:14]];
        [rowButton addSubview:titleLabel];

        NSArray *displayAuthors = (bookData.authors.count > 3) ? [bookData.authors subarrayWithRange:NSMakeRange(0, 3)] : bookData.authors;
        NSString *authorString = [NSString stringWithFormat:@"Author: %@", bookData.authors.firstObject];
        NSTextField *authorLabel = [NSTextField labelWithString:authorString];
        [authorLabel setFrame:NSMakeRect(10, rowHeight - 45, containerWidth - 20, 16)];
        [rowButton addSubview:authorLabel];
        
        // Display up to first 3 genres
        NSArray *displayGenres = (bookData.genres.count > 3) ? [bookData.genres subarrayWithRange:NSMakeRange(0, 3)] : bookData.genres;
        NSString *genreString = [NSString stringWithFormat:@"Genres: %@... | Publisher: %@", [displayGenres componentsJoinedByString:@", "], bookData.publisher];
        NSTextField *genrePublisherLabel = [NSTextField labelWithString:genreString];
        [genrePublisherLabel setFrame:NSMakeRect(10, rowHeight - 60, containerWidth - 20, 16)];
        [rowButton addSubview:genrePublisherLabel];

        // Draw a separator line
        NSBox *separator = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, containerWidth, 1)];
        [separator setBoxType:NSBoxSeparator];
        [rowButton addSubview:separator];

        [self.resultsContainerView addSubview:rowButton];
        currentY += rowHeight;
    }
    
    // Resize the container view to fit all results, flipping the coordinate system for scrolling
    CGFloat containerHeight = MAX(self.resultsScrollView.contentView.bounds.size.height, currentY);
    [self.resultsContainerView setFrameSize:NSMakeSize(containerWidth, containerHeight)];
    
    // Adjust the scroll view's document view and scroll to top
    if (currentY > self.resultsScrollView.contentView.bounds.size.height) {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, containerHeight - self.resultsScrollView.contentView.bounds.size.height)];
    } else {
        [self.resultsContainerView setFrameOrigin:NSMakePoint(0, 0)];
    }
}

// --- Book Row Click Action ---

- (void)bookRowClicked:(NSButton *)sender {
    NSLog(@"book row clicked");
    // Get the title of the book that was clicked
    NSUInteger clickedIndex = sender.tag;
    NSString *bookTitle = self.allResultsTitles[clickedIndex];

    // Fetch full book data
    BookData bookData = [self fetchDetailsForBookTitle:bookTitle];
    
    // 1. Create the Popover/Sheet
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:[NSString stringWithFormat:@"Options for: %@", bookData.title]];
    [alert setInformativeText:[NSString stringWithFormat:@"By %@\nPublished by: %@",
                               [bookData.authors componentsJoinedByString:@", "],
                               bookData.publisher]];
    
    // 2. Add buttons for actions
    [alert addButtonWithTitle:@"Add to Current Reading List"]; // Tag 1
    [alert addButtonWithTitle:@"Recommend"];                  // Tag 2
    [alert addButtonWithTitle:@"Find books by author"];       // Tag 3
    [alert addButtonWithTitle:@"Find Books By Publisher"];    // Tag 4
    [alert addButtonWithTitle:@"Cancel"];                     // Tag 5

    // 3. Display the sheet modally
    [alert beginSheetModalForWindow:sender.window completionHandler:^(NSModalResponse returnCode) {
        NSString *action = nil;
        
        // Determine which action was chosen based on the button index (1-based from the first button)
        if (returnCode == NSAlertFirstButtonReturn) {
            action = @"Add to Current Reading List";
            NSLog(@"Action: %@", action);
            
            if(Insecure_Account_ID != -1)
                [[DatabaseManager sharedManager] addBookToReadingList:bookData.title toList:0 forUser:Insecure_Account_ID];
           // - (void) addBookToReadingList:(NSString *)bookTitle toList:(int)listID forUser:(int)UserID
            // Implement 'Add to Current Reading List' logic here
            //Add To Reading List
            //bookData.title
            
        } else if (returnCode == NSAlertSecondButtonReturn) {
            action = @"Recommend";
            NSLog(@"Action: %@", action);
            // Implement 'Recommend' logic here
            
        } else if (returnCode == NSAlertThirdButtonReturn) {
            action = @"Find books by author";
            NSLog(@"Action: %@", action);
            // Set up a new search by author
            self.currentSearchType = @"Author";
            self.currentSearchTerm = bookData.authors.firstObject; // Use the first author for search
            [self.searchTypePopup selectItemWithTitle:@"Author"];
            [self.searchField setStringValue:self.currentSearchTerm];
            [self searchButtonClicked:nil];

        } else if (returnCode == NSAlertThirdButtonReturn + 1) {
            action = @"Find Books By Publisher";
            NSLog(@"Action: %@", action);
            // Set up a new search by publisher
            self.currentSearchType = @"Publisher";
            self.currentSearchTerm = bookData.publisher;
            [self.searchTypePopup selectItemWithTitle:@"Publisher"];
            [self.searchField setStringValue:self.currentSearchTerm];
            [self searchButtonClicked:nil];
            
        } else {
            NSLog(@"Action: Cancelled");
        }
    }];
}

@end


// --- Tab Manager Implementation ---

static void DBTestFive(){ /* Filter/Complex Read */
    NSArray<NSString *> *fantasyTitles = [[DatabaseManager sharedManager] fetchBookTitlesForPublisher:@"Houghton Mifflin Company"];
    
    NSLog(@"\n--- Database Query Results (Filter/Complex Read) ---");
    for(NSString* curr in fantasyTitles){
        NSArray<NSString*>* Authors = [[DatabaseManager sharedManager] fetchAuthorsForBookTitle:curr];
        NSArray<NSString*>* Genres = [[DatabaseManager sharedManager] fetchGenresForBookTitle:curr];
        NSString* Publishers = [[DatabaseManager sharedManager] fetchPublisherForBookTitle:curr];
        NSLog(@"Book: %@ \n Authors: %@ \n Genres: %@ \n Publisher: %@", curr, Authors, Genres, Publishers);
    }
    NSLog(@"--- End of Results ---\n");
}


// --- TabActionTarget Implementation (Connects buttons to DB functions) ---

@implementation TabActionTarget

- (void)buttonClicked:(id)sender {
    NSLog(@"Button Clicked");
    NSButton* castButton = (NSButton*)(sender);
    
    switch (castButton.tag) {
        case 1: break;       // Read
        case 2: break;     // Write
        case 3: break;   // Update
        case 4: break;   // Delete
        case 5: DBTestFive(); break;    // Filter
        default: break;
    }
    NSLog(@"Button clicked: %@", castButton.title);
}

@end


// --- TabManager C++ Implementation ---

// NOTE: Since the FindBooksManager instance needs to persist for the lifetime of the tab
// to hold state (current search, page), it must be stored somewhere. In a simple setup,
// we can make it a static variable within the TabManager implementation file, or attach
// it to the parent view as a retained property, or to the window/delegate.
// For this example, we'll use a static instance scoped to this file.
static FindBooksManager *s_findBooksManager = nil;
static ProfileManager *s_profileManager = nil; // <-- Add this
static MyShelfManager *s_myShelfManager = nil; // <-- Add this


void TabManager::DrawAllTabs(NSWindow* inWindow, NSTabView* tv) {
    NSLog(@"Draw All Tabs");
    DrawMyShelfTab(inWindow, tv);
    DrawProfileTab(inWindow, tv);
    DrawFindBooksTab(inWindow, tv); // This is the new implementation
    DrawSocialTab(inWindow, tv);
    DrawFifthTab(inWindow, tv);
    DrawAuditTab(inWindow, tv);
}

// Helper to create a tab view item and add it to the tab view
static NSTabViewItem* CreateTabItem(NSString* title, NSTabView* tv) {
    NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:title];
    item.label = title;
    item.view = [[NSView alloc] initWithFrame:[tv bounds]];
    [item.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [tv addTabViewItem:item];
    return item;
}

// Helper to constrain a subview to its superview's edges
static void ConstrainToSuperview(NSView *subview, NSView *superview) {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [subview.topAnchor constraintEqualToAnchor:superview.topAnchor].active = YES;
    [subview.bottomAnchor constraintEqualToAnchor:superview.bottomAnchor].active = YES;
    [subview.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor].active = YES;
    [subview.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor].active = YES;
}


// --- IMPLEMENTATION OF DrawFindBooksTab ---
void TabManager::DrawFindBooksTab(NSWindow* inWindow, NSTabView* tv) {
    NSLog(@"draw find books tab");
    NSTabViewItem *item = CreateTabItem(@"Find Books", tv);
    NSView *contentView = item.view;
    NSRect bounds = contentView.bounds;

    // Initialize the manager (ensuring it's a singleton for the tab)
    if (!s_findBooksManager) {
        s_findBooksManager = [[FindBooksManager alloc] init];
    }
    
    // --- Layout Constants ---
    CGFloat padding = 20;
    CGFloat searchHeight = 30;
    CGFloat paginationHeight = 30;
    CGFloat searchBarY = bounds.size.height - searchHeight - padding;
    
    // 1. Search Bar Area
    
    // Search Type PopUp Button (Left side)
    NSPopUpButton *searchTypePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(padding, searchBarY, 120, searchHeight)];
    [searchTypePopup addItemsWithTitles:@[@"Book", @"Author", @"Publisher"]];
    [contentView addSubview:searchTypePopup];
    s_findBooksManager.searchTypePopup = searchTypePopup;
    
    // Search Text Field (Center)
    NSTextField *searchField = [[NSTextField alloc] initWithFrame:NSMakeRect(120 + padding * 2, searchBarY, bounds.size.width - 120 - 100 - padding * 4, searchHeight)];
    [searchField setPlaceholderString:@"Enter search term..."];
    [searchField setDelegate:(id)s_findBooksManager]; // Set manager as delegate for 'Enter' key
    [contentView addSubview:searchField];
    
    
    s_findBooksManager.searchField = searchField;
    
    // Search Button (Right side)
    NSButton *searchButton = [[NSButton alloc] initWithFrame:NSMakeRect(bounds.size.width - 100 - padding, searchBarY, 100, searchHeight)];
    [searchButton setTitle:@"Search"];
    [searchButton setTarget:s_findBooksManager];
    [searchButton setAction:@selector(searchButtonClicked:)];
    [contentView addSubview:searchButton];
    
    // Set search button to respond to 'Enter' press in the text field
    [searchField setNextKeyView:searchButton];
    [searchField setAction:@selector(searchButtonClicked:)];
    
    // 2. Results Scroll View
    
    NSRect resultsFrame = NSMakeRect(0, paginationHeight + padding, bounds.size.width, bounds.size.height - searchHeight - paginationHeight - padding * 3);
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:resultsFrame];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Create the document view (container) that sits inside the scroll view
    NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, resultsFrame.size.width, resultsFrame.size.height)];
    [scrollView setDocumentView:containerView];
    
    [contentView addSubview:scrollView];
    s_findBooksManager.resultsScrollView = scrollView;
    s_findBooksManager.resultsContainerView = containerView;

    
    // 3. Pagination Bar (Bottom)
    
    NSRect paginationFrame = NSMakeRect(0, 0, bounds.size.width, paginationHeight + padding);
    NSView *paginationBar = [[NSView alloc] initWithFrame:paginationFrame];
    [paginationBar setAutoresizingMask:NSViewWidthSizable];
    [contentView addSubview:paginationBar];
    
    // Back Button (Left)
    NSButton *backButton = [[NSButton alloc] initWithFrame:NSMakeRect(padding, padding, 100, paginationHeight)];
    [backButton setTitle:@"<< Back"];
    [backButton setTarget:s_findBooksManager];
    [backButton setAction:@selector(backPage:)];
    [backButton setEnabled:NO]; // Starts disabled
    [paginationBar addSubview:backButton];
    s_findBooksManager.backButton = backButton;
    
    // Next Button (Right)
    NSButton *nextButton = [[NSButton alloc] initWithFrame:NSMakeRect(bounds.size.width - 100 - padding, padding, 100, paginationHeight)];
    [nextButton setTitle:@"Next >>"];
    [nextButton setTarget:s_findBooksManager];
    [nextButton setAction:@selector(nextPage:)];
    [nextButton setEnabled:NO]; // Starts disabled
    [paginationBar addSubview:nextButton];
    s_findBooksManager.nextButton = nextButton;
    
    // Initial content setup (show the "Enter a search term" prompt)
    [s_findBooksManager updateResultsDisplay];
}

void TabManager::DrawMyShelfTab(NSWindow* inWindow, NSTabView* tv) {
    // CreateTabItem(@"My Shelf", tv);
    
    NSLog(@"Draw My Shelf Tab");
    NSTabViewItem *item = CreateTabItem(@"My Shelf", tv);
    NSView *contentView = item.view;
    NSRect bounds = contentView.bounds;
    
    if (!s_myShelfManager) {
        s_myShelfManager = [[MyShelfManager alloc] init];
    }
    
    // --- Layout Constants ---
    CGFloat padding = 20;
    CGFloat controlHeight = 30;
    CGFloat listControlY = bounds.size.height - controlHeight - padding;
    
    // 1. Reading List Selection PopUp
    NSPopUpButton *listSelectionPopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(padding, listControlY, 200, controlHeight)];
    [listSelectionPopup addItemsWithTitles:@[@"Currently Reading", @"Finished", @"DNF", @"Wants to Read"]];
    [listSelectionPopup setTarget:s_myShelfManager];
    [listSelectionPopup setAction:@selector(listSelectionChanged:)];
    [contentView addSubview:listSelectionPopup];
    s_myShelfManager.listSelectionPopup = listSelectionPopup;
    
    // 2. Results Scroll View
    NSRect resultsFrame = NSMakeRect(0, 0, bounds.size.width, bounds.size.height - controlHeight - padding * 2);
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:resultsFrame];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Create the document view (container) that sits inside the scroll view
    NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, resultsFrame.size.width, resultsFrame.size.height)];
    [scrollView setDocumentView:containerView];
    
    [contentView addSubview:scrollView];
    s_myShelfManager.resultsScrollView = scrollView;
    s_myShelfManager.resultsContainerView = containerView;
    
    // Initial content setup
    [s_myShelfManager updateShelfDisplay];
    // Implementation details for My Shelf Tab...
}
void TabManager::DrawSocialTab(NSWindow* inWindow, NSTabView* tv) {
    NSTabViewItem *item = CreateTabItem(@"Socials", tv);
    NSView *contentView = item.view;
    NSRect bounds = contentView.bounds;

    // Initialize the manager (ensuring it's a singleton for the tab)
    if (!s_SocialsManager) {
        s_SocialsManager = [[SocialsManager alloc] init];
    }
    
    // --- Layout Constants ---
    CGFloat padding = 20;
    CGFloat searchHeight = 30;
    CGFloat paginationHeight = 30;
    CGFloat searchBarY = bounds.size.height - searchHeight - padding;
    
    // 1. Search Bar Area
    
    // Search Type PopUp Button (Left side)
    NSPopUpButton *searchTypePopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(padding, searchBarY, 120, searchHeight)];
    [searchTypePopup addItemsWithTitles:@[@"Follow", @"CreateFriends", @"CurrentFriends"]];
    [contentView addSubview:searchTypePopup];
    s_SocialsManager.SocialTypePopup = searchTypePopup;
    ////Follow, CreateFriends, CurrentFriends
    ///
    NSButton *updateButton = [[NSButton alloc] initWithFrame:NSMakeRect(bounds.size.width - 200, searchBarY , 100, searchHeight)];
    [updateButton setTitle:@"Update"];
    [updateButton setTarget:s_SocialsManager];
    [updateButton setAction:@selector(callUpdate:)];
    [updateButton setEnabled:YES]; // Starts disabled
    [contentView addSubview:updateButton];
    
    // 2. Results Scroll View
    NSRect resultsFrame = NSMakeRect(0, searchHeight - 10, bounds.size.width, bounds.size.height - searchHeight - padding * 2);
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:resultsFrame];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Create the document view (container) that sits inside the scroll view
    NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, resultsFrame.size.width, resultsFrame.size.height)];
    [scrollView setDocumentView:containerView];
    
    [contentView addSubview:scrollView];
    s_SocialsManager.resultsScrollView = scrollView;
    s_SocialsManager.resultsContainerView = containerView;

    
    
    // Initial content setup (show the "Enter a search term" prompt)
    [s_SocialsManager updateResultsDisplay];
    // Implementation details for Social Tab...
}
void TabManager::DrawAuditTab(NSWindow* inWindow, NSTabView* tv) {
    NSTabViewItem *item =  CreateTabItem(@"Audit", tv);
     NSView *contentView = item.view;
     NSRect bounds = contentView.bounds;

    if (!s_MyAuditLogs) {
        s_MyAuditLogs = [[MyAuditLogs alloc] init];
     }
     
     // --- Layout Constants ---
     CGFloat padding = 20;
     CGFloat controlHeight = 0;
     CGFloat listControlY = bounds.size.height - controlHeight - padding;
    
     // 2. Results Scroll View
     NSRect resultsFrame = NSMakeRect(0, 0, bounds.size.width, bounds.size.height - controlHeight - padding * 2);
     NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:resultsFrame];
     [scrollView setHasVerticalScroller:YES];
     [scrollView setBorderType:NSNoBorder];
     [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
     
     // Create the document view (container) that sits inside the scroll view
     NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, resultsFrame.size.width, resultsFrame.size.height)];
     [scrollView setDocumentView:containerView];
     
     [contentView addSubview:scrollView];
    s_MyAuditLogs.resultsScrollView = scrollView;
    s_MyAuditLogs.resultsContainerView = containerView;
     
     // Initial content setup
    [s_MyAuditLogs UpdateAuditDisplay];
}
//MySettingsManager
void TabManager::DrawFifthTab(NSWindow* inWindow, NSTabView* tv) {
    NSTabViewItem *item =  CreateTabItem(@"Settings", tv);
     NSView *contentView = item.view;
     NSRect bounds = contentView.bounds;

     if (!s_MySettingsManager) {
         s_MySettingsManager = [[MySettingsManager alloc] init];
     }
     
     // --- Layout Constants ---
     CGFloat padding = 20;
     CGFloat controlHeight = 0;
     CGFloat listControlY = bounds.size.height - controlHeight - padding;
    
     // 2. Results Scroll View
     NSRect resultsFrame = NSMakeRect(0, 0, bounds.size.width, bounds.size.height - controlHeight - padding * 2);
     NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:resultsFrame];
     [scrollView setHasVerticalScroller:YES];
     [scrollView setBorderType:NSNoBorder];
     [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
     
     // Create the document view (container) that sits inside the scroll view
     NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, resultsFrame.size.width, resultsFrame.size.height)];
     [scrollView setDocumentView:containerView];
     
     [contentView addSubview:scrollView];
    s_MySettingsManager.resultsScrollView = scrollView;
    s_MySettingsManager.resultsContainerView = containerView;
     
     // Initial content setup
    [s_MySettingsManager updateSettingsDisplay];
    /*
     5th Tab
     Settings:
     Functions to use
     [DatabaseManager sharedManager] NSArray<NSString*>* GetAllSettingsKeys(int UserProfileID)
     [DatabaseManager sharedManager] NSString* GetSettingsValueForKey(int UserProfileID, NSString* SettingsName)
     [DatabaseManager sharedManager] NSString* SetSettingsValueForKey(int UserProfileID, NSSTring* SettingsName, NSString* SettingsValue)
     
     rough implimentation
     5th tab
     1. Check if logged in, by chekcing user ID
     if logged in, display all Settings and their value
     Settings1 Value1
     Settings2 Value2
     When you click on one of them, allow the user to input what they want the setting to be
     */
}
void TabManager::DrawProfileTab(NSWindow* inWindow, NSTabView* tv) {
    NSTabViewItem *item = CreateTabItem(@"Profile", tv);
    NSView *contentView = item.view;
    NSRect bounds = contentView.bounds;
    
    if (!s_profileManager) {
        s_profileManager = [[ProfileManager alloc] init];
    }

    // --- Layout Constants ---
    CGFloat padding = 20;
    CGFloat elementHeight = 30;
    CGFloat currentY = bounds.size.height - padding - elementHeight;
    CGFloat labelWidth = 150;
    CGFloat buttonWidth = 120;
    
    // 1. Current User Status Label
    NSTextField *statusLabel = [NSTextField labelWithString:@""];
    [statusLabel setFrame:NSMakeRect(padding, currentY, bounds.size.width - 2 * padding, elementHeight)];
    [statusLabel setFont:[NSFont boldSystemFontOfSize:16]];
    [contentView addSubview:statusLabel];
    s_profileManager.currentUserIDLabel = statusLabel;
    
    currentY -= (elementHeight + padding);

    // --- Account Selection/Sign In ---
    
    // User ID Selection Label
    NSTextField *selectUserLabel = [NSTextField labelWithString:@"Select Account:"];
    [selectUserLabel setFrame:NSMakeRect(padding, currentY, labelWidth, elementHeight)];
    [selectUserLabel setAlignment:NSRightTextAlignment];
    [contentView addSubview:selectUserLabel];
    
    // Multi Select Bar (NS Pop Up Button)
    NSPopUpButton *userSelectionPopup = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(padding + labelWidth + 10, currentY, bounds.size.width - labelWidth - buttonWidth - 4 * padding, elementHeight)];
    [userSelectionPopup setTarget:s_profileManager];
    [userSelectionPopup setAction:@selector(userSelected:)];
    [contentView addSubview:userSelectionPopup];
    s_profileManager.userSelectionPopup = userSelectionPopup;
    
    // Sign Out Button (placed below the selection area)
    NSButton *signOutButton = [[NSButton alloc] initWithFrame:NSMakeRect(bounds.size.width - padding - buttonWidth, currentY, buttonWidth, elementHeight)];
    [signOutButton setTitle:@"Sign Out"];
    [signOutButton setTarget:s_profileManager];
    [signOutButton setAction:@selector(signOutClicked:)];
    [contentView addSubview:signOutButton];
    
    currentY -= (elementHeight + padding);

    // --- Account Creation Area (Hidden when signed in) ---
    
    NSView *creationView = [[NSView alloc] initWithFrame:NSMakeRect(padding, padding, bounds.size.width - 2 * padding, currentY - padding)];
    [contentView addSubview:creationView];
    s_profileManager.accountCreationView = creationView;
    
    CGFloat creationY = creationView.bounds.size.height - elementHeight;

    NSTextField *headerLabel = [NSTextField labelWithString:@"Create New Account"];
    [headerLabel setFrame:NSMakeRect(0, creationY, creationView.bounds.size.width, elementHeight)];
    [headerLabel setFont:[NSFont systemFontOfSize:14]];
    [creationView addSubview:headerLabel];
    
    creationY -= (elementHeight + 10);

    // Username Field
    NSTextField *usernameLabel = [NSTextField labelWithString:@"Username:"];
    [usernameLabel setFrame:NSMakeRect(0, creationY, labelWidth, elementHeight)];
    [usernameLabel setAlignment:NSRightTextAlignment];
    [creationView addSubview:usernameLabel];

    NSTextField *usernameField = [[NSTextField alloc] initWithFrame:NSMakeRect(labelWidth + 10, creationY, creationView.bounds.size.width - labelWidth - 10, elementHeight)];
    [usernameField setPlaceholderString:@"Enter unique username"];
    [creationView addSubview:usernameField];
    s_profileManager.usernameField = usernameField;

    creationY -= (elementHeight + 10);

    // Password Field
    NSTextField *passwordLabel = [NSTextField labelWithString:@"Password:"];
    [passwordLabel setFrame:NSMakeRect(0, creationY, labelWidth, elementHeight)];
    [passwordLabel setAlignment:NSRightTextAlignment];
    [creationView addSubview:passwordLabel];

    NSSecureTextField *passwordField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(labelWidth + 10, creationY, creationView.bounds.size.width - labelWidth - 10, elementHeight)];
    [passwordField setPlaceholderString:@"Enter password"];
    [creationView addSubview:passwordField];
    s_profileManager.passwordField = passwordField;

    creationY -= (elementHeight + 10);

    // Display Name Field
    NSTextField *displayNameLabel = [NSTextField labelWithString:@"Display Name:"];
    [displayNameLabel setFrame:NSMakeRect(0, creationY, labelWidth, elementHeight)];
    [displayNameLabel setAlignment:NSRightTextAlignment];
    [creationView addSubview:displayNameLabel];

    NSTextField *displayNameField = [[NSTextField alloc] initWithFrame:NSMakeRect(labelWidth + 10, creationY, creationView.bounds.size.width - labelWidth - 10, elementHeight)];
    [displayNameField setPlaceholderString:@"Name shown to others"];
    [creationView addSubview:displayNameField];
    s_profileManager.displayNameField = displayNameField;
    
    creationY -= (elementHeight + 20);

    // Create Account Button
    NSButton *createButton = [[NSButton alloc] initWithFrame:NSMakeRect(creationView.bounds.size.width - buttonWidth, creationY, buttonWidth, elementHeight)];
    [createButton setTitle:@"Create Account"];
    [createButton setTarget:s_profileManager];
    [createButton setAction:@selector(createAccountClicked:)];
    [creationView addSubview:createButton];

    // Initial Display Update
    [s_profileManager updateProfileDisplay];
}
