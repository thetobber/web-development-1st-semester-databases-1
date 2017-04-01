USE `library`;

START TRANSACTION;

#Inserting a book
INSERT INTO `authors` VALUES
	(null, 'Jerome', 'Friedman');
SET @author_id = LAST_INSERT_ID();

INSERT INTO `genres` VALUES
	(null, 'Computing');
SET @genre_id = LAST_INSERT_ID();

INSERT INTO `publishers` VALUES
    (null, 'Springer-verlag New York Inc.');
SET @publisher_id = LAST_INSERT_ID();

INSERT INTO `books` VALUES
    (null, @publisher_id, '9780387848570', 'Elements of Statistical Learning', 'Lorem ipsum.', 4);
SET @book_id = LAST_INSERT_ID();

INSERT INTO `book_authors` VALUES
    (null, @book_id, @author_id);

INSERT INTO `book_genres` VALUES
    (null, @book_id, @genre_id);

#Inserting a user
INSERT INTO `roles` VALUES
    (null, 'Admin');
SET @role_id = LAST_INSERT_ID();

INSERT INTO `users` VALUES
    (null, @role_id, 'John', 'Johnsen', 'example@localhost.com', X'5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 0);
SET @user_id = LAST_INSERT_ID();

INSERT INTO `rented` VALUES
    (null, @user_id, @book_id, NOW(), NOW() + INTERVAL 7 DAY, 0);

COMMIT;