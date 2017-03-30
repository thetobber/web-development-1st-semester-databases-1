/*
ENGINE = InnoDB is assigned on every table created because I'm not sure which version of 
MySQL is in use. I know versions below 5.5.5 will default to the MyISAM engine.
*/

DROP DATABASE IF EXISTS `library`;

/*
The character set utf8 and collation utf8_general_ci uses a maximum of 3 bytes per character
whereas utf8mb4 and utf8mb4_unicode_ci uses a maximum of 4 bytes and supports supplementary 
characters such as emojis. The suffix _ci is an acronym for case insensitive.
*/
CREATE DATABASE `library`
    CHARACTER SET = 'utf8mb4'
    COLLATE 'utf8mb4_unicode_ci';

USE `library`;

/*
Note to self:
When adding foreign keys then create the referenced table before the referencing table to avoid 
errors or use alter the tables afterwards by adding constraints.
*/

CREATE TABLE `roles` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `role`          VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

/*
Password has type binary because one spot is 8-BITs and would fit a SHA-256 hash (32*8=256). 
Optimally this should also include spaces for a salt, but it's not necessary for this exercise.
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

CREATE TABLE `publishers` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `publisher`     VARCHAR(100) NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `books` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `publisher_id`  INT UNSIGNED NOT NULL,
    `isbn`          VARCHAR(13) NOT NULL, #An ISBN code can be 10-13 characters long
    `title`         VARCHAR(255) NOT NULL,
    `description`   TEXT NULL,
    `quantity`      INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`) ,
    FOREIGN KEY (`publisher_id`)
        REFERENCES `publishers` (`id`)
) ENGINE = InnoDB;


/*
Note to self:
I should create a `book_genres` and `book_authors` table so that the genre and author 
is not repeated multiple times for multiple books.
*/

CREATE TABLE `genres` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `book_id`       INT UNSIGNED NOT NULL,
    `genre`         VARCHAR(100) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`book_id`)
        REFERENCES `books` (`id`)
) ENGINE = InnoDB;

CREATE TABLE `authors` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `book_id`       INT UNSIGNED NOT NULL,
    `firstname`     VARCHAR(100) NOT NULL,
    `lastname`      VARCHAR(100) NOT NULL,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`book_id`)
        REFERENCES `books` (`id`)
) ENGINE = InnoDB;

CREATE TABLE `rented` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`       INT UNSIGNED NOT NULL,
    `book_id`       INT UNSIGNED NOT NULL,
    `rent_date`     DATETIME NOT NULL ON UPDATE CURRENT_TIMESTAMP,
    `return_date`   DATETIME NOT NULL,
    `returned`      TINYINT NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`)
        REFERENCES `users` (`id`),
        ON DELETE CASCADE
    FOREIGN KEY (`book_id`)
        REFERENCES `books` (`id`)
        ON DELETE CASCADE
) ENGINE = InnoDB;

/*
ALTER TABLE `books`
    ADD CONSTRAINT `books_publisher_id`
    FOREIGN KEY (`publisher_id`)
    REFERENCES `publishers` (`id`);

ALTER TABLE `rented`
    ADD CONSTRAINT `rented_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`);

ALTER TABLE `rented`
    ADD CONSTRAINT `rented_book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`);

ALTER TABLE `genres`
    ADD CONSTRAINT `genres_book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`);

ALTER TABLE `authors`
    ADD CONSTRAINT `authors_book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`);

ALTER TABLE `users`
    ADD CONSTRAINT `users_role_id`
    FOREIGN KEY (`role_id`)
    REFERENCES `roles` (`id`);
*/