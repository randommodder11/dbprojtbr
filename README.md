As of Thursday, December 11 10:37 PM

Project Name: TBR / To Be Read Llist
Goal: Create an app where you can choose from a large list of books to add to your reading list, update progress and share books / recommendations with friends.
What I've actually managed due to bad time management (only worked on it for like 35h and 10h of that was just trying to get book databases to work together perfectly, until I talked with my mom who is a librarian and she said librarians will work for years to try to organize book databases together and it still has issues so i gave up and decided fuck it imperfect is ok)
  - Create user (username / password / display name)
  - Search through a large list of books by genre, author, publisher or book name
  - Add books to the To Be Read list.
  - Move a book from the To Be Read list to Already Read, DNF or Currently Reading
  - Find other users on the app to follow or add as friends
  - Settings
  - Audit Logs
Access Control?
  As I'm working with SQLlite in xcode since I usually work with iOS and wanted to try to get used to something that could actually be useful to me in the future, real access control is impossible considering the database is literally in the file system. If I were making this for real, I would host it on one of my servers but, I'm not making this for real so whatever. There are no sensitive actions since it's all local.
Error Handling / Data Validation
  - Minimal since I'm only working locally and have complete control over the database. I used some simple data control but nothing fancy.
Public Datasets?
https://www.kaggle.com/datasets/jealousleopard/goodreadsbooks
https://www.kaggle.com/datasets/bahramjannesarr/goodreads-book-datasets-10m?select=book1-100k.csv
https://www.kaggle.com/datasets/thedevastator/comprehensive-overview-of-52478-goodreads-best-b?resource=download

NOTE: at first I was attempting to use Open Library data sets, however my computer found that working with 100gb files not very enjoyable, so i used shitty datasets instead.


https://youtu.be/BxM4t_uVek8?si=jT6oa30RFmn1-wzi

Database:
My databse is over 100mb, download it and drag it into the root folder and include it into the app. 

Building:
Quite honestly i'm not 100% sure, as this is an xcode project obviously you need mac, and you will probalby need to fuck with some stuff since xcode is super picky
I was planning on spending more time making it buildable but I spent too long for studying for other shit like the exam and didnt budget enough time, so sorry about that. 
https://drive.google.com/file/d/1p0AsrB4vf42WiyZbzNEmAJp0ROUnc-zR/view?usp=sharing
