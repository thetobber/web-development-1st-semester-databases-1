START TRANSACTION;
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
COMMIT;