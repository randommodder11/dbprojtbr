//
//  DatabaseManager.mm
//  tbrapp
//
//  Created by Carson Mobile on 12/10/25.
//

// DatabaseManager.h

// DatabaseManager.m

#import "DatabaseManager.h"

// Note: Replace "your_database_path.sqlite" with the actual path to your DB file.
static NSString * const kDatabaseName = @"test5_mbyfinal.db";

@implementation DatabaseManager {
    FMDatabaseQueue *_dbQueue; // Use FMDatabaseQueue for thread safety
}

+ (instancetype)sharedManager {
    static DatabaseManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *dbPath = [docsPath stringByAppendingPathComponent:kDatabaseName];
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:dbPath]) {
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"test5_mbyfinal" ofType:@"db"];
            if (!sourcePath) {
                NSLog(@"❌ Error: Source database file not found in the application bundle.");
                return NULL;
            }
            NSError *error = nil;
            BOOL success = [fileManager copyItemAtPath:sourcePath toPath:dbPath error:&error];
            
            if (success) {
                NSLog(@"✅ Database copied successfully to Documents folder: %@", dbPath);
            } else {
                NSLog(@"❌ Error copying database: %@", error.localizedDescription);
                return NULL;
            }
        } else {
            NSLog(@"✅ Database already exists in Documents folder: %@", dbPath);
        }
        // Initialize the queue
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    return self;
}
/*
 NSString *sql = @"update settings set settting_value = ? where user_profile_id = ? AND setting_name = ?";

 // Execute the query safely on the database queue
 [_dbQueue inDatabase:^(FMDatabase *db) {
     [db executeUpdate:sql withArgumentsInArray:@[nv, @(UserProfileID), SettingsName]];
     [self WriteToAuditLog:sql];
 }];
 return;
 
 Insert Into NSLog(text) VALUES(?)
 */
- (void) WriteToAuditLog:(NSString *)NewEntry {
    NSLog(@"AUDIT %@", NewEntry);
    
    

    // Execute the query safely on the database queue
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *sql = @"Insert Into NSLog(message) VALUES(?)";
        [_dbQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql withArgumentsInArray:@[NewEntry]];
        }];
    });
    return;
}
- (NSArray<NSString *> *)fetchBookTitlesForGenre:(NSString *)genreName {
    // Array to store the book names
    NSMutableArray<NSString *> *bookTitles = [NSMutableArray array];

    // SQL query to join book, link, and genre tables
    NSString *sql = @"SELECT b.book_name "
                     "FROM book b "
                     "INNER JOIN book_genre_link bgl ON b.id = bgl.book_id "
                     "INNER JOIN genre g ON bgl.genre_id = g.id "
                     "WHERE TRIM(g.genre_name) = ?"; // Use ? for safe parameter substitution

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // Use executeQuery:withArgumentsInArray: for parameterized queries to prevent SQL injection
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[genreName]];
        [self WriteToAuditLog:genreName];
        
        while ([rs next]) {
            // Retrieve the book_name column from the result set
            NSString *title = [rs stringForColumn:@"book_name"];
            if (title) {
                [bookTitles addObject:title];
            }
        }
        [rs close]; // Always close the result set
    }];

    return [bookTitles copy];
}
- (NSArray<NSString *> *)fetchBookTitlesForAuthor:(NSString *)authorName {
    // Array to store the book names
    NSMutableArray<NSString *> *bookTitles = [NSMutableArray array];

    // SQL query to join book, link, and genre tables
    NSString *sql = @"SELECT b.book_name "
                     "FROM book b "
                     "INNER JOIN book_author_link bgl ON b.id = bgl.book_id "
                     "INNER JOIN author g ON bgl.author_id = g.id "
                     "WHERE TRIM(g.author_name) = ?"; // Use ? for safe parameter substitution

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // Use executeQuery:withArgumentsInArray: for parameterized queries to prevent SQL injection
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[authorName]];
        [self WriteToAuditLog:authorName];
        
        while ([rs next]) {
            // Retrieve the book_name column from the result set
            NSString *title = [rs stringForColumn:@"book_name"];
            if (title) {
                [bookTitles addObject:title];
            }
        }
        [rs close]; // Always close the result set
    }];

    return [bookTitles copy];
}
//- (NSArray<NSString *> *)fetchBookTitlesForPublisher:(NSString *)publisherName;
- (NSArray<NSString *> *)fetchBookTitlesForPublisher:(NSString *)publisherName {
    // Array to store the book names
    NSMutableArray<NSString *> *bookTitles = [NSMutableArray array];

    // SQL query to join book, link, and genre tables
    NSString *sql = @"SELECT b.book_name "
                     "FROM book b "
                     "INNER JOIN book_publisher_link bgl ON b.id = bgl.book_id "
                     "INNER JOIN publisher g ON bgl.publisher_id = g.id "
                     "WHERE TRIM(g.publisher_name) = ?"; // Use ? for safe parameter substitution

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // Use executeQuery:withArgumentsInArray: for parameterized queries to prevent SQL injection
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[publisherName]];
        [self WriteToAuditLog:publisherName];
        
        while ([rs next]) {
            // Retrieve the book_name column from the result set
            NSString *title = [rs stringForColumn:@"book_name"];
            if (title) {
                [bookTitles addObject:title];
            }
        }
        [rs close]; // Always close the result set
    }];

    return [bookTitles copy];
}
- (NSArray<NSString *> *)fetchBookTitlesForBook:(NSString *)imcompleteBookName {
    // Array to store the book names
    NSMutableArray<NSString *> *bookTitles = [NSMutableArray array];

    // SQL query to join book, link, and genre tables
    NSString *sql = @"SELECT book_name "
                     "FROM book "
                     "WHERE LOWER(book_name) LIKE LOWER(?)";
    
    NSString *searchPattern = [NSString stringWithFormat:@"%%%@%%", imcompleteBookName]; // e.g., becomes "%Lord Of%"
    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // Use executeQuery:withArgumentsInArray: for parameterized queries to prevent SQL injection
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[searchPattern]];
        [self WriteToAuditLog:sql];
        
        while ([rs next]) {
            // Retrieve the book_name column from the result set
            NSString *title = [rs stringForColumn:@"book_name"];
            if (title) {
                [bookTitles addObject:title];
            }
        }
        [rs close]; // Always close the result set
    }];

    return [bookTitles copy];
}

- (NSArray<NSString *> *)fetchGenresForBookTitle:(NSString *)bookTitle {
    NSMutableArray<NSString *> *genres = [NSMutableArray array];

    // SQL to join book -> book_genre_link -> genre
    NSString *sql = @"SELECT g.genre_name "
                     "FROM book b "
                     "INNER JOIN book_genre_link bgl ON b.id = bgl.book_id "
                     "INNER JOIN genre g ON bgl.genre_id = g.id "
                     "WHERE TRIM(b.book_name) = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[bookTitle]];
        [self WriteToAuditLog:bookTitle];
        
        while ([rs next]) {
            NSString *genreName = [rs stringForColumn:@"genre_name"];
            if (genreName) {
                [genres addObject:genreName];
            }
        }
        [rs close];
    }];

    return [genres copy];
}

- (NSArray<NSString *> *)fetchAuthorsForBookTitle:(NSString *)bookTitle {
    NSMutableArray<NSString *> *authors = [NSMutableArray array];

    // SQL to join book -> book_author_link -> author
    NSString *sql = @"SELECT a.author_name "
                     "FROM book b "
                     "INNER JOIN book_author_link bal ON b.id = bal.book_id "
                     "INNER JOIN author a ON bal.author_id = a.id "
                     "WHERE TRIM(b.book_name) = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[bookTitle]];
        [self WriteToAuditLog:bookTitle];
        
        while ([rs next]) {
            NSString *authorName = [rs stringForColumn:@"author_name"];
            if (authorName) {
                [authors addObject:authorName];
            }
        }
        [rs close];
    }];

    return [authors copy];
}

- (NSString *)fetchPublisherForBookTitle:(NSString *)bookTitle {
    __block NSString *publisherName = nil;

    // SQL to join book -> book_publisher_link -> publisher
    NSString *sql = @"SELECT p.publisher_name "
                     "FROM book b "
                     "INNER JOIN book_publisher_link bpl ON b.id = bpl.book_id "
                     "INNER JOIN publisher p ON bpl.publisher_id = p.id "
                     "WHERE TRIM(b.book_name) = ? "
                     "LIMIT 1"; // Limit to 1 result since it's typically a 1:1 relationship

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[bookTitle]];
        [self WriteToAuditLog:bookTitle];
        
        if ([rs next]) {
            publisherName = [rs stringForColumn:@"publisher_name"];
        }
        [rs close];
    }];

    return publisherName;
}



- (void) CreateDefaultImage {
    static bool created = false;
    if(created) return;
    created = true;
    /*
     drop table if exists image;
     create table image (
     id integer not null,
     data text not null,
     image_name text,
     created_at datetime default CURRENT_TIMESTAMP,
     primary key ("id" AUTOINCREMENT)
     );
     */
    // SQL to join book -> book_publisher_link -> publisher
    NSString *sql = @"INSERT INTO image (data, image_name) "
                     "SELECT "
                     "   '/9j/4AAQSkZJRgABAQEASABIAAD/4QtGaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLwA8P3hwYWNrZXQgYmVnaW49J++7vycgaWQ9J1c1TTBNcENlaGlIenJlU3pOVGN6a2M5ZCc/Pgo8eDp4bXBtZXRhIHhtbG5zOng9J2Fkb2JlOm5zOm1ldGEvJyB4OnhtcHRrPSdJbWFnZTo6RXhpZlRvb2wgMTIuMjQnPgo8cmRmOlJERiB4bWxuczpyZGY9J2h0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMnPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6ZGM9J2h0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvJz4KICA8ZGM6dGl0bGU+CiAgIDxyZGY6QWx0PgogICAgPHJkZjpsaSB4bWw6bGFuZz0neC1kZWZhdWx0Jz5XZWI8L3JkZjpsaT4KICAgPC9yZGY6QWx0PgogIDwvZGM6dGl0bGU+CiA8L3JkZjpEZXNjcmlwdGlvbj4KPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAg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', "
                     "   'book.jpg' "
                     " WHERE NOT EXISTS ( "
                     "     SELECT 1 "
                     "   FROM image i "
                     "   WHERE i.image_name = 'book.jpg'"
                     ")";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
        }
        [rs close];
    }];
    /*
     INSERT INTO image (image_name, file_path)
     SELECT
         'book.jpg',
         '/path/to/default/book.jpg'
     WHERE NOT EXISTS (
         SELECT 1
         FROM image i
         WHERE i.image_name = 'book.jpg'
     );
     */
    
}
- (int) CreateUser:(NSString*)username withpassword:(NSString*)password withname:(NSString*) displayName{
    [self CreateDefaultImage];
    int* rv = new int;
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 1. Insert User
        [db executeUpdate:@"INSERT INTO user (username, password) VALUES (?, ?)", username, password];
        long long userId = [db lastInsertRowId];
        
        //rv = (int)userId;
        *rv = (int)userId;
        // 2. Fetch Default Image ID
        long long imageId = [db longForQuery:@"SELECT id FROM image WHERE image_name = ?", @"book.jpg"];
        
        // 3. Insert User Profile
        [db executeUpdate:@"INSERT INTO user_profile (image_id, user_id, display_name) VALUES (?, ?, ?)",
                           @(imageId), @(userId), displayName];
        long long profileId = [db lastInsertRowId]; // Crucial ID for settings and lists

        // 4. Insert Settings
        [db executeUpdate:@"INSERT INTO settings (setting_name, settting_value, user_profile_id) VALUES (?, ?, ?)",
                           @"Profile_Publicity", @"Private", @(profileId)];

        // 5. Insert Default Book Lists (0, 1, 2, 3)
        for (int i = 1; i <= 4; i++) {
            [db executeUpdate:@"INSERT INTO user_book_list (list_index, user_id) VALUES (?, ?)",
                               @(i), @(profileId)];
        }
    }];
    return *rv;
}
/*
 drop table if exists user;
 create table user (
 id integer not null,
username text not null,
 password text not null,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key ("id" AUTOINCREMENT)
 );
 
 
 drop table if exists user_profile;
 create table user_profile (
id integer not null,
image_id integer not null,
user_id integer not null,
display_name text not null,
created_at datetime default CURRENT_TIMESTAMP,
primary key ("id" AUTOINCREMENT),
FOREIGN key (image_id) REFERENCES image(id),
FOREIGN key (user_id) REFERENCES user(id)
);
 
 select p.display_name from user_profile p where p.id = ?
 */
- (NSArray<NSString *> *)fetchAllUserID {
    // Array to store the book names
    NSMutableArray<NSString *> *bookTitles = [NSMutableArray array];

    // SQL query to join book, link, and genre tables
    NSString *sql = @"SELECT id FROM user";

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // Use executeQuery:withArgumentsInArray: for parameterized queries to prevent SQL injection
        FMResultSet *rs = [db executeQuery:sql];
        [self WriteToAuditLog:sql];
        
        while ([rs next]) {
            // Retrieve the book_name column from the result set
            NSString *title = [rs stringForColumn:@"id"];
            if (title) {
                [bookTitles addObject:title];
            }
        }
        [rs close]; // Always close the result set
    }];

    return [bookTitles copy];
}
- (NSString *)FetchDisplayNameForUserID:(NSString *)UserID {
    __block NSString* Response;
    NSString *sql = @"select p.display_name from user_profile p where p.user_id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs stringForColumn:@"display_name"];
        }
        [rs close];
    }];

    return Response;
}


// User Profile From User
// in user id
// out user profile id
// Select id from user_profile where user_id = ?
- (int) FetchUserProfileIndex:(int)UserID{
    __block int Response = 0;
    NSString *sql = @"Select id from user_profile where user_id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:UserID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"id"];
        }
        [rs close];
    }];
    return Response;
}
/*
 drop table if exists user_book_list;
 create table user_book_list (
 id integer not null,
 list_index integer, --0 = Currently Reading 1 = Finished 2= DNF 3 = Wants to Read
 user_id integer not null,
 created_at datetime DEFAULT CURRENT_TIMESTAMP,
 FOREIGN key(user_id) REFERENCES user_profile(userid)
 );
 */
//
- (int) FetchUserBookListID:(int)ListIndex ForUser:(int)UserProfileIndex{
    __block int Response = 0;
    NSString *sql = @"Select id FROM user_book_list WHERE list_index = ? AND user_id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_ListIndex = [NSNumber numberWithInt:ListIndex+1];
        NSNumber* NS_UserProfileIndex = [NSNumber numberWithInt:UserProfileIndex];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_ListIndex,NS_UserProfileIndex]];
        [self WriteToAuditLog:sql];
        
        NSLog(@"Select id FROM user_book_list WHERE list_index = %@ AND user_id = %@", NS_ListIndex, NS_UserProfileIndex);
        if ([rs next]) {
            Response = [rs intForColumn:@"id"];
        }
        [rs close];
    }];
    return Response;
}

/*
 create table user_book (
 id integer not null,
 progress integer, --0-100
 linked_book integer not null,
 linked_rating integer,
 linked_review integer,
 linked_user_profile integer not null,
 user_book_list_id integer,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (linked_book) REFERENCES book(id),
 FOREIGN key (linked_rating) REFERENCES rating(id),
 FOREIGN key (linked_review) REFERENCES review(id),
 FOREIGN key (linked_user_profile) REFERENCES user_profile(id),
 FOREIGN key (user_book_list_id) REFERENCES user_book_list(id)
 );
 
 Select id from user_book WHERE linked_user_profile = ? AND user_book_list_id = ?
 */
- (void) LogShelf {
    // SQL query to join book, link, and genre tables
    NSString *sql = @"SELECT * FROM user_book";

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        // Use executeQuery:withArgumentsInArray: for parameterized queries to prevent SQL injection
        FMResultSet *rs = [db executeQuery:sql];
        [self WriteToAuditLog:sql];
        
        while ([rs next]) {
            // Retrieve the book_name column from the result set
            int lb_id = [rs intForColumn:@"id"];
            int linked_book = [rs intForColumn:@"linked_book"];
            int linked_user_profile = [rs intForColumn:@"linked_user_profile"];
            int user_book_list_id = [rs intForColumn:@"user_book_list_id"];
            
            NSLog(@"%d %d %d %d", lb_id, linked_book, linked_user_profile, user_book_list_id);

        }
        [rs close]; // Always close the result set
    }];
}
//book list id 5 for user 1
- (NSArray<NSNumber *>*) fetchUserBookList:(int)bookListID linked_user_profile:(int)userProfileIndex{
    [self LogShelf];
    __block NSMutableArray<NSNumber *>* Response = [NSMutableArray array];
    NSString *sql = @"Select id from user_book WHERE linked_user_profile = ? AND user_book_list_id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_bookListID = [NSNumber numberWithInt:bookListID];
        NSNumber* NS_userProfileIndex = [NSNumber numberWithInt:userProfileIndex];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_userProfileIndex,NS_bookListID]];
        [self WriteToAuditLog:sql];
        NSLog(@"Select id from user_book WHERE linked_user_profile = %@ AND user_book_list_id = %@", NS_userProfileIndex, NS_bookListID);
        while ([rs next]) {
            NSNumber *user_book = [NSNumber numberWithLong:[rs longForColumn:@"id"]];
            if (user_book) {
                [Response addObject:user_book];
                NSLog(@"fetchUserBookList response: %@", user_book);
            }
        }
        [rs close];
    }];
    return [Response copy];
}
/*
 Select linked_book FROM user_book WHERE id = ?
 Select progress FROM user_book WHERE id = ?
 create table user_book (
 id integer not null,
 progress integer, --0-100
 linked_book integer not null,
 linked_rating integer,
 linked_review integer,
 linked_user_profile integer not null,
 user_book_list_id integer,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (linked_book) REFERENCES book(id),
 FOREIGN key (linked_rating) REFERENCES rating(id),
 FOREIGN key (linked_review) REFERENCES review(id),
 FOREIGN key (linked_user_profile) REFERENCES user_profile(id),
 FOREIGN key (user_book_list_id) REFERENCES user_book_list(id)
 );
 */
- (int) getBookFromUserBook:(int)userBookID{
    __block int Response = 0;
    NSString *sql = @"Select linked_book FROM user_book WHERE id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:userBookID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"linked_book"];
        }
        [rs close];
    }];
    return Response;
}
- (int) getProgressForUserBook:(int)userBookID{
    __block int Response = 0;
    NSString *sql = @"Select progress FROM user_book WHERE id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:userBookID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"progress"];
        }
        [rs close];
    }];
    return Response;
}
/*
 Create Table book (
 id integer not null unique,
 book_name text,
 isbn_13 integer,
 isbn_10 integer,
 created_at datetime default current_timestamp,
 primary key("id" AUTOINCREMENT)
 );
 */
- (NSString*) getBookNameFromBookID:(int)bookID{
    __block NSString* Response;
    NSString *sql = @"Select book_name FROM book WHERE id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:bookID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs stringForColumn:@"book_name"];
        }
        [rs close];
    }];
    return Response;
}
- (int) getLinkedRatingForUserBook:(int)userBookID{
    __block int Response = 0;
    NSString *sql = @"Select linked_rating FROM user_book WHERE id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:userBookID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"linked_rating"];
        }
        [rs close];
    }];
    return Response;
}
- (int) getLinkedReviewForUserBook:(int)UserBookID{
    __block int Response = 0;
    NSString *sql = @"Select linked_review FROM user_book WHERE id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:UserBookID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"linked_review"];
        }
        [rs close];
    }];
    return Response;
}
/*
 drop table if exists rating;
 create table rating (
 id integer not null,
 star_rating integer not null,
 book_id integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key ("id" AUTOINCREMENT),
 FOREIGN key (book_id) REFERENCES book(id)
 );
 drop table if exists review;
 create table review (
 id integer not null,
 review_text text,
 rating_id integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key ("id" AUTOINCREMENT),
 FOREIGN key (rating_id) REFERENCES rating(id)
 );
 
 select star_rating from rating where id = ?
 select review_text from review where id = ?
 */
- (int) getStarRatingForRating:(int)linkedRatingID{
    __block int Response = 0;
    NSString *sql = @"select star_rating from rating where id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:linkedRatingID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"star_rating"];
        }
        [rs close];
    }];
    return Response;
}
- (NSString*) getReviewTextForReview:(int)linkedReviewID{
    __block NSString* Response;
    NSString *sql = @"select review_text from review where id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_UserID = [NSNumber numberWithInt:linkedReviewID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[NS_UserID]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs stringForColumn:@"review_text"];
        }
        [rs close];
    }];
    return Response;
}
/*
 - (void) leaveRating:(int)starRating forUserBook:(int)userBookID;
 
 CREATE TABLE rating (
  id integer not null,
  star_rating integer not null,
  book_id integer not null,
  created_at datetime default CURRENT_TIMESTAMP,
  primary key ("id" AUTOINCREMENT),
  FOREIGN key (book_id) REFERENCES book(id)
  )
 
 INSERT INTO rating(star_rating,book_id) VALUES(?,?)
 
 UPDATE user_book
 SET linked_review = last_insert_rowid()
 WHERE id = ?;
 */
- (void) leaveRating:(int)starRating forUserBook:(int)userBookID{
    NSString *sql = @"INSERT INTO rating(star_rating, book_id) VALUES( ? , ? )";
    NSString *sql2 = @"update user_book set linked_rating = ? where id = ?";
    int BookID = [self getBookFromUserBook:userBookID];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSNumber* NS_BookID = [NSNumber numberWithInt:BookID];
        NSNumber* NS_StarRating = [NSNumber numberWithInt:starRating];
        BOOL success = [db executeUpdate:sql withArgumentsInArray:@[NS_StarRating, NS_BookID]];
        if(success){
            [self WriteToAuditLog:sql];
            BOOL success2 = [db executeUpdate:sql2 withArgumentsInArray:@[@([db lastInsertRowId]), @(userBookID)]];
            if(success2){
                [self WriteToAuditLog:sql2];
            } else
                NSLog(@"Rating_Update_Failed: \n Reason: %@", [db lastErrorMessage]);
        }
        else
            NSLog(@"FAILED: \n %@ Reason: %@", sql, [db lastErrorMessage]);
        NSLog(@"INSERT INTO rating(star_rating,book_id) VALUES(%@ , %@)", NS_StarRating, NS_BookID);
    }];
    //1. get BookID from UserBookID
    //INSERT
    return;
}
/*
 CREATE TABLE review (
  id integer not null,
  review_text text,
  rating_id integer not null,
  created_at datetime default CURRENT_TIMESTAMP,
  primary key ("id" AUTOINCREMENT),
  FOREIGN key (rating_id) REFERENCES rating(id)
  )
 
 create table user_book (
     id integer not null,
     progress integer, --0-100
     linked_book integer not null,
     linked_rating integer,
     linked_review integer,
     linked_user_profile integer not null,
     user_book_list_id integer,
     created_at datetime default CURRENT_TIMESTAMP,
     primary key("id" AUTOINCREMENT),
     FOREIGN key (linked_book) REFERENCES book(id),
     FOREIGN key (linked_rating) REFERENCES rating(id),
     FOREIGN key (linked_review) REFERENCES review(id),
     FOREIGN key (linked_user_profile) REFERENCES user_profile(id),
     FOREIGN key (user_book_list_id) REFERENCES user_book_list(id)
 );
 
 update user book b where id = ? set linked_review = lastrowinsertid()
 insert into review(review_text,rating_id) values(?,?)
 */
- (void) leaveReview:(NSString*) reviewText Stars:(int)starRating forUserBook:(int)userBookID{
    int BookID = [self getBookFromUserBook:userBookID];
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSNumber* NS_StarRating = [NSNumber numberWithInt:starRating];
        NSNumber* NS_BookID = [NSNumber numberWithInt:BookID];
        [db executeUpdate:@"INSERT INTO rating(star_rating,book_id) VALUES(?,?)", NS_StarRating, NS_BookID];
        
        long long ratingID = [db lastInsertRowId];
        NSNumber* NS_ratingID = [NSNumber numberWithLong:ratingID];
        if([db executeUpdate:@"insert into review(review_text,rating_id) values(?,?)", reviewText, NS_ratingID]){
            long long reviewID = [db lastInsertRowId];
            [db executeUpdate:@"update user_book set linked_rating = ? where id = ?", NS_ratingID, @(userBookID)];
            [db executeUpdate:@"update user_book set linked_review = ? where id = ?", [NSNumber numberWithLong:reviewID], @(userBookID)];
        }
        else {
            NSLog(@"HAHAAHHAHA FUCK U");
        }
    }];
    
    return;
}
/*
 
 - (void) leaveRating:(int)starRating forUserBook:(int)userBookID{
     NSString *sql = @"INSERT INTO rating(star_rating, book_id) VALUES( ? , ? )";
     NSString *sql2 = @"update user_book set linked_rating = ? where id = ?";
     int BookID = [self getBookFromUserBook:userBookID];
     [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
         NSNumber* NS_BookID = [NSNumber numberWithInt:BookID];
         NSNumber* NS_StarRating = [NSNumber numberWithInt:starRating];
         BOOL success = [db executeUpdate:sql withArgumentsInArray:@[NS_StarRating, NS_BookID]];
         if(success){
             [self WriteToAuditLog:sql];
             BOOL success2 = [db executeUpdate:sql2 withArgumentsInArray:@[@([db lastInsertRowId]), @(userBookID)]];
             if(success2){
                 [self WriteToAuditLog:sql2];
             } else
                 NSLog(@"Rating_Update_Failed: \n Reason: %@", [db lastErrorMessage]);
         }
         else
             NSLog(@"FAILED: \n %@ Reason: %@", sql, [db lastErrorMessage]);
         NSLog(@"INSERT INTO rating(star_rating,book_id) VALUES(%@ , %@)", NS_StarRating, NS_BookID);
     }];
     //1. get BookID from UserBookID
     //INSERT
     return;
 }
 drop table book;
 Create Table book (
 id integer not null unique,
 book_name text,
 isbn_13 integer,
 isbn_10 integer,
 created_at datetime default current_timestamp,
 primary key("id" AUTOINCREMENT)
 );
 */
// select id from book where book_name = ? limit 1
- (int) getFirstBookIDForTitle:(NSString *)BookTitle{
    __block int Response = 0;
    NSString *sql = @"select id from book where book_name = ? limit 1";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[BookTitle]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"id"];
        }
        [rs close];
    }];
    return Response;
}





/*

- (int) FetchUserProfileIndex:(int)UserID;
- (int) FetchUserBookListID:(int)ListIndex ForUser:(int)UserProfileIndex;
- (NSArray<NSNumber *>*) fetchUserBookList:(int)bookListID linked_user_profile:(int)userProfileIndex;
- (int) getBookFromUserBook:(int)userBookID;
- (int) getProgressForUserBook:(int)userBookID;
- (NSString*) getBookNameFromBookID:(int)bookID;
- (int) getLinkedRatingForUserBook:(int)userBookID;
- (int) getLinkedReviewForUserBook:(int)UserBookID;
- (int) getStarRatingForRating:(int)linkedRatingID;
- (NSString*) getReviewTextForReview:(int)linkedReviewID;
 */
/*
 drop table if exists user_book_list;
 create table user_book_list (
 id integer not null,
 list_index integer, --0 = Currently Reading 1 = Finished 2= DNF 3 = Wants to Read
 user_id integer not null,
 created_at datetime DEFAULT CURRENT_TIMESTAMP,
 FOREIGN key(user_id) REFERENCES user_profile(userid)
 );
 
 
 drop table if exists user_book;
 create table user_book (
 id integer not null,
 progress integer, --0-100
 linked_book integer not null,
 linked_rating integer,
 linked_review integer,
 linked_user_profile integer not null,
 user_book_list_id integer,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (linked_book) REFERENCES book(id),
 FOREIGN key (linked_rating) REFERENCES rating(id),
 FOREIGN key (linked_review) REFERENCES review(id),
 FOREIGN key (linked_user_profile) REFERENCES user_profile(id),
 FOREIGN key (user_book_list_id) REFERENCES user_book_list(id)
 );
 
 INSERT INTO user_book(progress, linked_book, linked_user_profile, user_book_list_id)
 VALUES(0, BookID, UserProfileIndex, ListID)
 - (int) FetchUserProfileIndex:(int)UserID;
 - (int) FetchUserBookListID:(int)ListIndex ForUser:(int)UserProfileIndex;
 
 add book to reading list (NSString* bookTitle, int toList, int User)
 
 int UserProfileIndex = fupi(userid)
 int fubli = ...
 Insert into user book (progress, linked_book, linked_user_profile, user_book_list_id)
 (0, getfirstbookidfortitle, fubli, upi)
 
 
 */
- (void) addBookToReadingList:(NSString *)bookTitle toList:(int)listID forUser:(int)UserID {
    __block int UserProfileIndex = [self FetchUserProfileIndex:UserID];
    __block int ListID = [self FetchUserBookListID:listID ForUser:UserProfileIndex];
    __block int BookID = [self getFirstBookIDForTitle:bookTitle];
    
    NSString *sql = @"Insert into user_book (progress, linked_book, linked_user_profile, user_book_list_id) VALUES(0, ?, ?, ?)";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* NS_linked_book = [NSNumber numberWithInt:BookID];
        NSNumber* NS_linked_user_profile = [NSNumber numberWithInt:UserProfileIndex];
        NSNumber* NS_user_book_list_id = [NSNumber numberWithInt:ListID];
        bool res = [db executeUpdate:sql withArgumentsInArray:@[NS_linked_book, NS_linked_user_profile, NS_user_book_list_id]];
        if(res){
            NSLog(@"SUCCESFULLY ADDED USER BOOK");
        }
        else {
            NSLog(@"USER BOOK ADDITION FAILED WITH REASON: %@", [db lastErrorMessage]);
        }
        NSLog(@"0, %@, %@, %@", NS_linked_book, NS_linked_user_profile, NS_user_book_list_id);
        [self WriteToAuditLog:sql];
    }];
    return;
}
/*
 create table user_book (
 id integer not null,
 progress integer, --0-100
 linked_book integer not null,
 linked_rating integer,
 linked_review integer,
 linked_user_profile integer not null,
 user_book_list_id integer,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (linked_book) REFERENCES book(id),
 FOREIGN key (linked_rating) REFERENCES rating(id),
 FOREIGN key (linked_review) REFERENCES review(id),
 FOREIGN key (linked_user_profile) REFERENCES user_profile(id),
 FOREIGN key (user_book_list_id) REFERENCES user_book_list(id)
 );
 Select linked_user_profile from user_book where id =
 */
- (int)GetUserProfileForUserBook:(int)UserBookIndex{
    __block int Response = 0;
    NSString *sql = @"Select linked_user_profile from user_book where id = ?";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[@(UserBookIndex)]];
        [self WriteToAuditLog:sql];
        
        if ([rs next]) {
            Response = [rs intForColumn:@"linked_user_profile"];
        }
        [rs close];
    }];
    return Response;
}

/*
 [db executeUpdate:@"update user_book set user_book_list_id = ? where id = ?", NS_ratingID, @(userBookID)];
 //    NSArray<NSString *> *listTitles = @[@"Currently Reading", @"Finished", @"DNF", @"Wants To Read"];
 //NSArray<NSNumber *> *listIndices = @[@0, @1, @2, @3];
 
 move to currently reading?

 Move to currently Reading -> Finished
 move to DNF - > Wants to Read. Somehow the index is getting increased too much.
 */
- (void)MoveUserBookToList:(int)UserBookIndex toList:(int)listIndex { //0,1,2,3
    __block int UserProfileID = [self GetUserProfileForUserBook:UserBookIndex];
    __block int NewListID = [self FetchUserBookListID:listIndex ForUser:UserProfileID];
    
    NSLog(@"MOVE USER BOOK TO LIST NEW LIST ID!!! %d", NewListID);
    NSString *sql = @"Insert into user_book (progress, linked_book, linked_user_profile, user_book_list_id) VALUES(0, ?, ?, ?)";

    [_dbQueue inDatabase:^(FMDatabase *db) {
        if([db executeUpdate:@"update user_book set user_book_list_id = ? where id = ?", @(NewListID), @(UserBookIndex)]){
            NSLog(@"SUCCESFULLY MOVED USER BOOK TO NEW LIST");
        }
        else {
            NSLog(@"USER BOOK MOVE FAILED WITH REASON: %@", [db lastErrorMessage]);
        }
        [self WriteToAuditLog:sql];
    }];
    return;
}

/*
 NSMutableArray<NSString *> *bookTitles = [NSMutableArray array];

 // SQL query to join book, link, and genre tables
 NSString *sql = @"SELECT b.book_name "
                  "FROM book b "
                  "INNER JOIN book_genre_link bgl ON b.id = bgl.book_id "
                  "INNER JOIN genre g ON bgl.genre_id = g.id "
                  "WHERE TRIM(g.genre_name) = ?"; // Use ? for safe parameter substitution

 // Execute the query safely on the database queue
 [_dbQueue inDatabase:^(FMDatabase *db) {
     // Use executeQuery:withArgumentsInArray: for parameterized queries to prevent SQL injection
     FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[genreName]];
     [self WriteToAuditLog:genreName];
     
     while ([rs next]) {
         // Retrieve the book_name column from the result set
         NSString *title = [rs stringForColumn:@"book_name"];
         if (title) {
             [bookTitles addObject:title];
         }
     }
     [rs close]; // Always close the result set
 }];

 return [bookTitles copy];
 
 CREATE TABLE settings (
 id INTEGER not null,
 setting_name text,
 settting_value text,
 user_profile_id integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (user_profile_id) REFERENCES user_profile(id)
 )
 Select setting_name from settings where user_profile_id = ?
 select setting_value from settings where user_profile_id = ? AND settings_name = ?
 */
- (NSArray<NSString*>*) GetAllSettingsKeys:(int) UserProfileID {
    NSMutableArray<NSString *> *settings = [NSMutableArray array];
    
    NSString *sql = @"Select setting_name from settings where user_profile_id = ?";

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[@(UserProfileID)]];
        [self WriteToAuditLog:sql];
        while ([rs next]) {
            // Retrieve the book_name column from the result set
            NSString *setting = [rs stringForColumn:@"setting_name"];
            if (setting) {
                [settings addObject:setting];
            }
        }
        [rs close]; // Always close the result set
    }];
    return [settings copy];
}
- (NSString*) GetSettingsValueForKey:(int)UserProfileID SettingsName:(NSString*)SettingsName {
    __block NSString* retVal;
    NSString *sql = @"select settting_value from settings where user_profile_id = ? AND setting_name = ?";

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[@(UserProfileID), SettingsName]];
        [self WriteToAuditLog:sql];
        if([rs next]){
            retVal = [rs stringForColumn:@"settting_value"];
        }
        [rs close]; // Always close the result set
    }];
    return retVal;
}

/*
 NSString *sql2 = @"update user_book set linked_rating = ? where id = ?";
 update settings set settting_value = ? where user_profile_id = ? AND setting_name = ?
 */
- (void) SetSettingsValueForKey:(int)UserProfileID SettingsName:(NSString*)SettingsName newValue:(NSString*)nv {
    NSString *sql = @"update settings set settting_value = ? where user_profile_id = ? AND setting_name = ?";

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql withArgumentsInArray:@[nv, @(UserProfileID), SettingsName]];
        [self WriteToAuditLog:sql];
    }];
    return;
}

- (NSArray<NSString*>*) GetAllAuditLogs {
    NSMutableArray<NSString *> *settings = [NSMutableArray array];
    
    NSString *sql = @"Select message from NSLog";

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        [self WriteToAuditLog:sql];
        while ([rs next]) {
            NSString *setting = [rs stringForColumn:@"message"];
            if (setting) {
                [settings addObject:setting];
            }
        }
        [rs close]; // Always close the result set
    }];
    return [settings copy];
}


/*
 
 
 Select u.id from user_profile u
 Join friend f ON u.user_profile_id_1 <> ? AND u.user_profile_id_2 <> ?
 Join follow_link l ON l.user_profile_id_following <> u.id
 where id <> ? AND l.user_profile_id_follower = ?
 
 
 SELECT u.id, u.display_name FROM user_profile u WHERE u.id <> ?

 AND u.id NOT IN ( SELECT user_profile_id_2 FROM friend WHERE user_profile_id_1 = ?
                   UNION SELECT user_profile_id_1 FROM friend WHERE user_profile_id_2 = ? )

 -- 3. Check for Follow Links (Find all users who ARE followed by the target user)
 AND u.id NOT IN ( SELECT user_profile_id_following FROM follow_link WHERE user_profile_id_follower = ? )

 -- 4. Check for Follow Links (Find all users who ARE following the target user)
 -- This is optional, but often included for symmetry (i.e., you don't follow them, and they don't follow you)
 AND u.id NOT IN ( SELECT user_profile_id_follower FROM follow_link WHERE user_profile_id_following = ? );
 
 
 Select u.id from user_profile u
 Join friend f ON u.user_profile_id_1 <> ? AND u.user_profile_id_2 <> ?
 Join follow_link l ON l.user_profile_id_following <> u.id
 where id <> ? AND l.user_profile_id_follower = ?
 SELECT u.id, u.display_name FROM user_profile u WHERE u.id <> ?
 AND u.id NOT IN ( SELECT user_profile_id_2 FROM friend WHERE user_profile_id_1 = ?
                   UNION SELECT user_profile_id_1 FROM friend WHERE user_profile_id_2 = ? )
 AND u.id NOT IN ( SELECT user_profile_id_following FROM follow_link WHERE user_profile_id_follower = ? )
 AND u.id NOT IN ( SELECT user_profile_id_follower FROM follow_link WHERE user_profile_id_following = ? );
 
 CREATE TABLE follow_link (
 id integer not null,
 user_profile_id_follower integer not null,
 user_profile_id_following integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 PRIMARY key("id" AUTOINCREMENT),
 FOREIGN key (user_profile_id_follower) REFERENCES user_profile(id),
 FOREIGN key (user_profile_id_following) REFERENCES user_profile(id)
 )
 
 CREATE TABLE friend (
 id integer not null,
 user_profile_id_1 integer not null,
 user_profile_id_2 integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (user_profile_id_1) REFERENCES user_profile(id),
 FOREIGN key (user_profile_id_2) REFERENCES user_profile(id)
 )
 */

- (NSArray<NSNumber*>*) GetAllFollowableUsers:(int)UserProfileID {
    NSMutableArray<NSNumber *> *FollowableUsers = [NSMutableArray array];
    NSString* sql = @"Select id from user_profile where id <> ?";
   /* NSString *sql = @"Select u.id from user_profile u "
    "Join friend f ON u.user_profile_id_1 <> ? AND u.user_profile_id_2 <> ? "
    "Join follow_link l ON l.user_profile_id_following <> u.id "
    "where id <> ? AND l.user_profile_id_follower = ? "
    "SELECT u.id, u.display_name FROM user_profile u WHERE u.id <> ? "
    "AND u.id NOT IN ( SELECT user_profile_id_2 FROM friend WHERE user_profile_id_1 = ? "
    "                  UNION SELECT user_profile_id_1 FROM friend WHERE user_profile_id_2 = ? ) "
    "AND u.id NOT IN ( SELECT user_profile_id_following FROM follow_link WHERE user_profile_id_follower = ? ) "
    "AND u.id NOT IN ( SELECT user_profile_id_follower FROM follow_link WHERE user_profile_id_following = ? ) "; */
    
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* UPI = [NSNumber numberWithInt:UserProfileID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[UPI]];
        [self WriteToAuditLog:sql];
        while ([rs next]) {
            NSNumber *setting = @([rs intForColumn:@"id"]);
            if (setting) {
                [FollowableUsers addObject:setting];
            }
        }
        [rs close]; // Always close the result set
    }];
    return [FollowableUsers copy];
}
/*
 CREATE TABLE follow_link (
 id integer not null,
 user_profile_id_follower integer not null,
 user_profile_id_following integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 PRIMARY key("id" AUTOINCREMENT),
 FOREIGN key (user_profile_id_follower) REFERENCES user_profile(id),
 FOREIGN key (user_profile_id_following) REFERENCES user_profile(id)
 )
 Select user_profile_id_following from follow_link WHERE user_profile_id_follower = UserProfileID;
 

 */
- (NSArray<NSNumber*>*) GetAllFriendableUsers:(int)UserProfileID{
    NSMutableArray<NSNumber *> *FollowableUsers = [NSMutableArray array];
    NSString *sql = @"Select user_profile_id_follower from follow_link WHERE user_profile_id_following = ?";
    
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* UPI = [NSNumber numberWithInt:UserProfileID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[UPI]];
        [self WriteToAuditLog:sql];
        while ([rs next]) {
            NSNumber *setting = @([rs intForColumn:@"user_profile_id_follower"]);
            if (setting) {
                [FollowableUsers addObject:setting];
            }
        }
        [rs close]; // Always close the result set
    }];
    return [FollowableUsers copy];
}
/*
 CREATE TABLE friend (
 id integer not null,
 user_profile_id_1 integer not null,
 user_profile_id_2 integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (user_profile_id_1) REFERENCES user_profile(id),
 FOREIGN key (user_profile_id_2) REFERENCES user_profile(id)
 )
 Select user_profile_id_1 from friend WHERE user_profile_id_2 = ?
 Select user_profile_id_2 from friend WHERE user_profile_id_1 = ?
 */
- (NSArray<NSNumber*>*) GetAllFriends:(int)UserProfileID{
    NSMutableArray<NSNumber *> *FollowableUsers = [NSMutableArray array];
    NSString *sql = @"Select user_profile_id_1 from friend WHERE user_profile_id_2 = ?";
    NSString *sql2 = @"Select user_profile_id_2 from friend WHERE user_profile_id_1 = ?";
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSNumber* UPI = [NSNumber numberWithInt:UserProfileID];
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:@[UPI]];
        [self WriteToAuditLog:sql];
        while ([rs next]) {
            NSNumber *setting = @([rs intForColumn:@"user_profile_id_1"]);
            if (setting) {
                [FollowableUsers addObject:setting];
            }
        }
        
        FMResultSet *rs2 = [db executeQuery:sql2 withArgumentsInArray:@[UPI]];
        [self WriteToAuditLog:sql2];
        while ([rs2 next]) {
            NSNumber *setting = @([rs2 intForColumn:@"user_profile_id_2"]);
            if (setting) {
                [FollowableUsers addObject:setting];
            }
        }
        [rs2 close]; // Always close the result set
    }];
    return [FollowableUsers copy];
}
/*
 insert into follow_link(user_profile_id_follower,user_profile_id_following) VALUES(?,?)
 
 
 CREATE TABLE follow_link (
 id integer not null,
 user_profile_id_follower integer not null,
 user_profile_id_following integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 PRIMARY key("id" AUTOINCREMENT),
 FOREIGN key (user_profile_id_follower) REFERENCES user_profile(id),
 FOREIGN key (user_profile_id_following) REFERENCES user_profile(id)
 )
 */
- (void) FollowUser:(int)MyUser Follows:(int)FollowsUser {
    NSString *sql = @"insert into follow_link(user_profile_id_follower,user_profile_id_following) VALUES(?,?)";

    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql withArgumentsInArray:@[@(MyUser), @(FollowsUser)]];
        [self WriteToAuditLog:sql];
    }];
    return;
}
/*
 
 CREATE TABLE friend (
 id integer not null,
 user_profile_id_1 integer not null,
 user_profile_id_2 integer not null,
 created_at datetime default CURRENT_TIMESTAMP,
 primary key("id" AUTOINCREMENT),
 FOREIGN key (user_profile_id_1) REFERENCES user_profile(id),
 FOREIGN key (user_profile_id_2) REFERENCES user_profile(id)
 )
 
 first:
 DELETE FROM follow_link WHERE user_profile_id_following = ? (MyUser)
 insert into friend(user_profile_id_1,user_profile_id_2) VALUES (?,?)
 */
- (void) Friend:(int)MyUser Friends:(int)FriendsUser {
    NSString *sql = @"DELETE FROM follow_link WHERE user_profile_id_following = ?";
    NSString *sql2 = @"insert into friend(user_profile_id_1,user_profile_id_2) VALUES (?,?)";
    // Execute the query safely on the database queue
    [_dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql withArgumentsInArray:@[@(MyUser)]];
        [self WriteToAuditLog:sql];
        [db executeUpdate:sql2 withArgumentsInArray:@[@(FriendsUser), @(MyUser)]];
        [self WriteToAuditLog:sql2];
    }];
    
}
@end


