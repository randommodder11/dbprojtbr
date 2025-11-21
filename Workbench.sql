use `Book Recommendations`;
select * from books;

WITH duplicate_cte AS (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY isbn13)
AS row_num
FROM books
)
SELECT * FROM duplicate_cte WHERE row_num > 1;

select * from books where isbn = 3.58;

CREATE TABLE books_nodup AS
SELECT 
    title, 
    authors, 
    average_rating,
    isbn,
    isbn13,
    num_pages,
    ratings_count, 
    publication_date, 
    publisher
FROM (
    SELECT  *,
        ROW_NUMBER() OVER(
            PARTITION BY title, authors 
            ORDER BY publication_date DESC   
		) AS row_num
    FROM 
        books
) AS numbered_books
WHERE 
    row_num = 1;
    
SELECT * FROM books_nodup;
SELECT Count(*) from books_nodup;



CREATE TABLE PrivateUser (
    private_user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password CHAR(60) NOT NULL, -- Use CHAR(60) for bcrypt hashes
    linked_public_user_id INT UNIQUE NOT NULL, -- Link to PublicUser
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE PublicUser (
    public_user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100) UNIQUE NOT NULL,
    profile_picture_url VARCHAR(500),
    account_token VARCHAR(255) UNIQUE NOT NULL,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE ListedBook (
    isbn VARCHAR(20) PRIMARY KEY, -- ISBN is a good unique identifier
    title VARCHAR(255) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    number_of_reviews INT DEFAULT 0,
    average_star_rating DECIMAL(2, 1) DEFAULT 0.0
);
CREATE TABLE Review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) NOT NULL, -- Foreign Key to ListedBook
    star_rating TINYINT CHECK (star_rating BETWEEN 1 AND 5),
    public_user_id INT, -- Optional Foreign Key to PublicUser
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (isbn) REFERENCES ListedBook(isbn) ON DELETE CASCADE,
    FOREIGN KEY (public_user_id) REFERENCES PublicUser(public_user_id) ON DELETE SET NULL
);
CREATE TABLE ReadingListType (
    list_type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) UNIQUE NOT NULL -- e.g., 'TBR', 'CurrentlyReading', 'Finished'
);
-- You would pre-populate this table with the required types.
CREATE TABLE ReadingList (
    reading_list_id INT PRIMARY KEY AUTO_INCREMENT,
    public_user_id INT NOT NULL, -- The owner of the list
    list_type_id INT NOT NULL, -- The type of the list (TBR, Finished, etc.)
    is_public_viewable BOOLEAN DEFAULT TRUE,
    
    UNIQUE KEY (public_user_id, list_type_id), -- A user can only have one of each list type
    FOREIGN KEY (public_user_id) REFERENCES PublicUser(public_user_id) ON DELETE CASCADE,
    FOREIGN KEY (list_type_id) REFERENCES ReadingListType(list_type_id)
);
CREATE TABLE ReadingListBook (
    reading_list_book_id INT PRIMARY KEY AUTO_INCREMENT,
    reading_list_id INT NOT NULL, -- Foreign Key to ReadingList
    isbn VARCHAR(20) NOT NULL, -- Foreign Key to ListedBook
    user_rating TINYINT CHECK (user_rating BETWEEN 1 AND 5),
    comment TEXT,
    extra_data JSON, -- For flexible, non-standard data
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY (reading_list_id, isbn), -- A book can only be in a specific list once
    FOREIGN KEY (reading_list_id) REFERENCES ReadingList(reading_list_id) ON DELETE CASCADE,
    FOREIGN KEY (isbn) REFERENCES ListedBook(isbn) ON DELETE CASCADE
);
CREATE TABLE FavoriteDisplayBook (
    favorite_id INT PRIMARY KEY AUTO_INCREMENT,
    public_user_id INT NOT NULL,
    isbn VARCHAR(20) NOT NULL, -- The book being favorited
    
    UNIQUE KEY (public_user_id, isbn),
    FOREIGN KEY (public_user_id) REFERENCES PublicUser(public_user_id) ON DELETE CASCADE,
    FOREIGN KEY (isbn) REFERENCES ListedBook(isbn) ON DELETE CASCADE
);
CREATE TABLE Follow (
    follower_id INT NOT NULL, -- The user who is FOLLOWING (followed By User)
    followed_id INT NOT NULL, -- The user being FOLLOWED (followed User)
    
    PRIMARY KEY (follower_id, followed_id), -- Composite key
    FOREIGN KEY (follower_id) REFERENCES PublicUser(public_user_id) ON DELETE CASCADE,
    FOREIGN KEY (followed_id) REFERENCES PublicUser(public_user_id) ON DELETE CASCADE,
    
    CHECK (follower_id != followed_id) -- A user cannot follow themselves
);
CREATE TABLE BookTag (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(100) UNIQUE NOT NULL, -- e.g., 'Mystery', 'Sci-Fi', 'Historical-Fiction'
    description VARCHAR(255)
);
CREATE TABLE BookTagLink (
    tag_link_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) NOT NULL, -- Foreign Key to ListedBook
    tag_id INT NOT NULL, -- Foreign Key to BookTag
    
    UNIQUE KEY (isbn, tag_id), -- Ensures a book can only have a tag once
    FOREIGN KEY (isbn) REFERENCES ListedBook(isbn) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES BookTag(tag_id) ON DELETE CASCADE
);
-- Link from PrivateUser to PublicUser (done in PrivateUser table)
ALTER TABLE PrivateUser
ADD CONSTRAINT fk_linked_public_user
FOREIGN KEY (linked_public_user_id) REFERENCES PublicUser(public_user_id) ON DELETE CASCADE;

