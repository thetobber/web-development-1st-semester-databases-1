DROP DATABASE IF EXISTS `library`;

/*
ENGINE = InnoDB is assigned ON every table created because I'm not sure which version of 
MySQL is in use. I know versions below 5.5.5 will default to the MyISAM engine.
*/

/*
The character set utf8 and collation utf8_general_ci uses a maximum of 3 bytes per character
whereas utf8mb4 and utf8mb4_unicode_ci uses a maximum of 4 bytes and supports supplementary 
characters such as emojis. The suffix _ci is an acronym for case insensitive.
*/
CREATE DATABASE `library`
    CHARACTER SET = 'utf8mb4'
    COLLATE 'utf8mb4_unicode_ci';

USE `library`;

DROP TRIGGER IF EXISTS `books_before_insert`;
DROP TRIGGER IF EXISTS `rented_before_insert`;
DROP TRIGGER IF EXISTS `rented_after_insert`;
DROP TRIGGER IF EXISTS `rented_after_delete`;
DROP VIEW IF EXISTS `users_view`;
DROP VIEW IF EXISTS `books_view`;
DROP PROCEDURE IF EXISTS `getUser`;
DROP PROCEDURE IF EXISTS `getUsers`;
DROP PROCEDURE IF EXISTS `getBook`;
DROP PROCEDURE IF EXISTS `getBooks`;

/*
Note:
When adding foreign keys then create the referenced table before the referencing table to avoid 
errors or add the constraints afterward by altering the table.
*/


CREATE TABLE `roles` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `role`          VARCHAR(50) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;


CREATE TABLE `publishers` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `publisher`     VARCHAR(100) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;


CREATE TABLE `genres` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `genre`         VARCHAR(100) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;


CREATE TABLE `authors` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `firstname`     VARCHAR(100) NOT NULL,
    `lastname`      VARCHAR(100) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

/*
Password has type binary because one spot is 8-BITs and would fit a SHA-256 hash (32*8=256). This 
should also include space for a salt of a fixed binary length.
*/
CREATE TABLE `users` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `role_id`       INT UNSIGNED NOT NULL,
    `firstname`     VARCHAR(100) NOT NULL,
    `lastname`      VARCHAR(100) NOT NULL,
    `email`         VARCHAR(255) NOT NULL,
    `password`      BINARY(32) NOT NULL,

    PRIMARY KEY (`id`),

    FOREIGN KEY (`role_id`)
        REFERENCES `roles` (`id`)
) ENGINE = InnoDB;

CREATE TABLE `books` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `publisher_id`  INT UNSIGNED NOT NULL,
    `isbn`          VARCHAR(13) NOT NULL, #An ISBN code can be 10-13 characters long
    `title`         VARCHAR(255) NOT NULL,
    `description`   TEXT NULL,
    `quantity`      INT UNSIGNED NOT NULL,

    PRIMARY KEY (`id`),

    FOREIGN KEY (`publisher_id`)
        REFERENCES `publishers` (`id`)
) ENGINE = InnoDB;

CREATE TABLE `book_genres` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `book_id`       INT UNSIGNED NOT NULL,
    `genre_id`      INT UNSIGNED NOT NULL,

    PRIMARY KEY (`id`),

    FOREIGN KEY (`book_id`)
        REFERENCES `books` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (`genre_id`)
        REFERENCES `genres` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE `book_authors` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `book_id`       INT UNSIGNED NOT NULL,
    `author_id`     INT UNSIGNED NOT NULL,

    PRIMARY KEY (`id`),

    FOREIGN KEY (`book_id`)
        REFERENCES `books` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (`author_id`)
        REFERENCES `authors` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE `rented` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`       INT UNSIGNED NOT NULL,
    `book_id`       INT UNSIGNED NOT NULL,
    `rent_date`     DATETIME NOT NULL,
    `return_date`   DATETIME NOT NULL,
    `returned`      TINYINT(1) NOT NULL,

    PRIMARY KEY (`id`),

    FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`),

    FOREIGN KEY (`book_id`)
        REFERENCES `books` (`id`)
) ENGINE = InnoDB;

#Sets a default quantity of books for each record inseted
CREATE TRIGGER `books_before_insert`
    BEFORE INSERT ON `books` FOR EACH ROW SET
        NEW.`quantity` = IFNULL(NEW.`quantity`, 0);


#Sets the default dates and the returned flag for each record inserted
CREATE TRIGGER `rented_before_insert`
    BEFORE INSERT ON `rented` FOR EACH ROW SET
        NEW.`rent_date` = NOW(),
        NEW.`return_date` = NOW() + INTERVAL 7 DAY,
        NEW.`returned` = 0;

#Decrements quantity of a book for each rented record inserted
CREATE TRIGGER `rented_after_insert`
    AFTER INSERT ON `rented` FOR EACH ROW UPDATE
        `books` SET `quantity` = `quantity` - 1 WHERE `id` = NEW.`id`;


#Increments quantity of a book for each rented record deleted
CREATE TRIGGER `rented_after_delete`
    AFTER DELETE ON `rented` FOR EACH ROW UPDATE
        `books` SET `quantity` = `quantity` + 1 WHERE `id` = OLD.`id`;

#Combines the users with a role
CREATE VIEW `users_view` AS
    SELECT `u`.`id`, `r`.`role`, `u`.`firstname`, `u`.`lastname`, `u`.`email`
        FROM `users` AS `u`
        JOIN `roles` AS `r`
        ON `u`.`role_id` = `r`.`id`;

#Combines books with their publisher, authors and genres
CREATE VIEW `books_view` AS
    SELECT `b`.`id`,
        `p`.`publisher`,
        `b`.`isbn`,
        `b`.`title`,
        `b`.`description`,
        GROUP_CONCAT(DISTINCT CONCAT(`a`.`firstname`, ' ', `a`.`lastname`) SEPARATOR ', ') `authors`,
        GROUP_CONCAT(DISTINCT `g`.`genre` SEPARATOR ', ') `genres`,
        `b`.`quantity`
        FROM `books` AS `b`
        INNER JOIN `publishers` AS `p`
            ON `b`.`publisher_id` = `p`.`id`
        INNER JOIN `book_authors` AS `ba`
            ON `b`.`id` = `ba`.`book_id`
        INNER JOIN `authors` AS `a`
            ON `ba`.`author_id` = `a`.`id`
        INNER JOIN `book_genres` AS `bg`
            ON `b`.`id` = `bg`.`book_id`
        INNER JOIN `genres` AS `g`
            ON `bg`.`genre_id` = `g`.`id`
        GROUP BY `b`.`id`;

#Get a single user by id
DELIMITER //
CREATE PROCEDURE getUser(id1 INT)
BEGIN
    SELECT * FROM `users_view` WHERE `users_view`.`id` = id1;
END//

#Get all users with limit and offset
CREATE PROCEDURE getUsers(limit1 INT, offset1 INT)
BEGIN
    SELECT * FROM `users_view` LIMIT limit1 OFFSET offset1;
END//

#Get a single book by id
CREATE PROCEDURE getBook(id1 INT)
BEGIN
    SELECT * FROM `books_view` WHERE `books_view`.`id` = id1;
END//

#Get all users with limit and offset
CREATE PROCEDURE getBooks(limit1 INT, offset1 INT)
BEGIN
    SELECT * FROM `books_view` LIMIT limit1 OFFSET offset1;
END//
DELIMITER ;

#Insert dummy data (requires new db)
START TRANSACTION;
    INSERT INTO `roles` (`role`) VALUES
        ('admin'),
        ('employee'),
        ('member');

    SET @password = X'5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8';

    INSERT INTO `users` VALUES
        (null, 1, 'Tobias', 'Wiedemann', 'tobias@example.dev', @password),
        (null, 1, 'Nikolaj', 'Fløjgaard', 'nikolaj@example.dev', @password),
        (null, 2, 'Casper', 'Johnsen', 'casper@example.dev', @password),
        (null, 3, 'Josefine', 'Brandt', 'josefine@example.dev', @password),
        (null, 2, 'Nina', 'Kjær', 'nina@example.dev', @password),
        (null, 3, 'Michael', 'Jeppesen', 'michael@example.dev', @password);

    INSERT INTO `publishers` (`publisher`) VALUES
        ('Mit Press Ltd'),
        ('John Wiley & Sons Inc'),
        ('Code Energy LLC'),
        ('O\'reilly Media, Inc, Usa');

    INSERT INTO `books` (`publisher_id`, `isbn`, `title`, `description`, `quantity`) VALUES
        (1, '9780262533058', 'Introduction to Algorithms', 'Her har du en introduktion til algoritmer, der er både skarp og alsidig på samme tid. "Introduction to Algorithms" er både bred og dyb i sin indføring i emnet, hvilket betyder, at du får al den nødvendige viden om emnet på ét sted.', 8),
        (2, '9781118531648', 'JavaScript & JQuery - Interactive Front-end Web Development', 'Learn JavaScript and jQuery a nicer way This full-color book adopts a visual approach to teaching JavaScript & jQuery, showing you how to make web pages more interactive and interfaces more intuitive through the use of inspiring code examples, infographics, and photography.', 5),
        (2, '9781119038634', 'Web Design with HTML, CSS, JavaScript and jQuery Set', 'A two-book set for web designers and front-end developers This two-book set combines the titles HTML & CSS: Designing and Building Web Sites and JavaScript & jQuery: Interactive Front-End Development.', 3),
        (3, '9780997316025', 'Computer Science Distilled - Learn the Art of Solving Computational Problems', null, 6),
        (4, '9780596517748', 'JavaScript: The Good Parts - Working with the Shallow Grain of JavaScript', 'Offers an explanation of the features that make JavaScript an object-oriented programming language, and warns you about the bad parts. This book defines a subset of JavaScript that\'s readable and maintainable than the language.', 2);

    INSERT INTO `authors` (`firstname`, `lastname`) VALUES
        ('Charles', 'Leiserson'),
        ('Thomas', 'Cormen'),
        ('Clifford', 'Stein'),
        ('Ronald', 'Rivest'),
        ('Jon', 'Duckett'),
        ('Wladston', 'Ferreira Filho'),
        ('Douglas', 'Crockford');

    INSERT INTO `book_authors` (`book_id`, `author_id`) VALUES
        (1, 1),
        (1, 2),
        (1, 3),
        (1, 4),
        (2, 5),
        (3, 5),
        (4, 6),
        (5, 7);

    INSERT INTO `genres` (`genre`) VALUES
        ('Computer Science'),
        ('Design'),
        ('Guide'),
        ('Science'),
        ('Math');

    INSERT INTO `book_genres` (`book_id`, `genre_id`) VALUES
        (1, 1),
        (1, 5),
        (1, 4),
        (1, 3),
        (2, 2),
        (2, 3),
        (3, 2),
        (3, 3),
        (4, 1),
        (4, 4),
        (5, 1),
        (5, 3);
COMMIT;