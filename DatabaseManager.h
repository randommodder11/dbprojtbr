//
//  DatabaseManager.h
//  tbrapp
//
//  Created by Carson Mobile on 12/10/25.
//

#import <Foundation/Foundation.h>
#import "FMDB.h" // Assuming you've imported FMDB

@interface DatabaseManager : NSObject

// Shared instance for easy access
+ (instancetype)sharedManager;

// Method to fetch book titles by genre
- (NSArray<NSString *> *)fetchBookTitlesForGenre:(NSString *)genreName;
- (NSArray<NSString *> *)fetchBookTitlesForAuthor:(NSString *)authorName;
- (NSArray<NSString *> *)fetchBookTitlesForPublisher:(NSString *)publisherName;
- (NSArray<NSString *> *)fetchBookTitlesForBook:(NSString *)imcompleteBookName;
- (NSString *)fetchPublisherForBookTitle:(NSString *)bookTitle;
- (NSArray<NSString *> *)fetchAuthorsForBookTitle:(NSString *)bookTitle;
- (NSArray<NSString *> *)fetchGenresForBookTitle:(NSString *)bookTitle;

/*

 */
- (void) CreateDefaultImage;
- (int) CreateUser:(NSString*)username withpassword:(NSString*)password withname:(NSString*) displayName;
- (NSArray<NSString *> *)fetchAllUserID;
- (NSString *)FetchDisplayNameForUserID:(NSString *)UserID;

- (void) LogShelf;
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

- (int)GetUserProfileForUserBook:(int)UserBookIndex;
- (void)MoveUserBookToList:(int)UserBookIndex toList:(int)listIndex;
/*
 Add Book To List For User
 
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
 
 - (int) FetchUserProfileIndex:(int)UserID;
 - (int) FetchUserBookListID:(int)ListIndex ForUser:(int)UserProfileIndex;
 
 add book to reading list (NSString* bookTitle, int toList, int User)
 
 int UserProfileIndex = fupi(userid)
 int fubli = ...
 Insert into user book (progress, linked_book, linked_user_profile, user_book_list_id)
 (0, getfirstbookidfortitle, fubli, upi)
 */
- (void) addBookToReadingList:(NSString *)bookTitle toList:(int)listID forUser:(int)UserID;
- (void) leaveRating:(int)starRating forUserBook:(int)userBookID;
- (void) leaveReview:(NSString*) reviewText Stars:(int)starRating forUserBook:(int)userBookID;

- (int) getFirstBookIDForTitle:(NSString *)BookTitle;
/*
 [[DatabaseManager sharedManager] leaveRating:starRating forUserBook:userBookID];
 [[DatabaseManager sharedManager] leaveReview:reviewText forUserBook:userBookID];
 
 */
- (NSArray<NSString*>*) GetAllSettingsKeys:(int) UserProfileID;
- (NSString*) GetSettingsValueForKey:(int)UserProfileID SettingsName:(NSString*)SettingsName;
- (void) SetSettingsValueForKey:(int)UserProfileID SettingsName:(NSString*)SettingsName newValue:(NSString*)nv;

- (NSArray<NSString*>*) GetAllAuditLogs;



- (NSArray<NSNumber*>*) GetAllFollowableUsers:(int)UserProfileID;
- (NSArray<NSNumber*>*) GetAllFriendableUsers:(int)UserProfileID;
- (NSArray<NSNumber*>*) GetAllFriends:(int)UserProfileID;
- (void) FollowUser:(int)MyUser Follows:(int)FollowsUser;
- (void) Friend:(int)MyUser Friends:(int)FriendsUser;
/*
[DatabaseManager sharedManager] NSArray<NSString*>* GetAllSettingsKeys(int UserProfileID)
[DatabaseManager sharedManager] NSString* GetSettingsValueForKey(int UserProfileID, NSString* SettingsName)
[DatabaseManager sharedManager] NSString* SetSettingsValueForKey(int UserProfileID, NSSTring* SettingsName, NSString* SettingsValue)
 */

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


@end
