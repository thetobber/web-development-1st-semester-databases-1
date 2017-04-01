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

/*
Password has type binary because one spot is 8-BITs and would fit a SHA-256 hash (32*8=256). This 
should also include space for a salt of a fixed binary length.
*/
CREATE TABLE `users` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `role_id`       int UNSIGNED NOT NULL,
    `firstname`     varchar(100) NOT NULL,
    `lastname`      varchar(100) NOT NULL,
    `email`         varchar(255) NOT NULL,
    `password`      binary(32) NOT NULL,
    `verified`      tinyint(1) NOT NULL DEFAULT 0,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;


CREATE TABLE `books` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `publisher_id`  int UNSIGNED NOT NULL,
    `isbn`          varchar(13) NOT NULL, #An ISBN code can be 10-13 characters long
    `title`         varchar(255) NOT NULL,
    `description`   text NULL,
    `quantity`      int UNSIGNED NOT NULL DEFAULT 0,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `book_genres` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `book_id`       int UNSIGNED NOT NULL,
    `genre_id`      int UNSIGNED NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `roles` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `role`          varchar(50) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `publishers` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `publisher`     varchar(100) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `book_authors` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `book_id`       int UNSIGNED NOT NULL,
    `author_id`     int UNSIGNED NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `rented` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`       int UNSIGNED NOT NULL,
    `book_id`       int UNSIGNED NOT NULL,
    `rent_date`     datetime NOT NULL ON UPDATE CURRENT_TIMESTAMP,
    `return_date`   datetime NOT NULL,
    `returned`      tinyint(1) NOT NULL DEFAULT 0,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `genres` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `genre`         varchar(100) NOT NULL,

    PRIMARY KEY (`id`)
);

CREATE TABLE `authors` (
    `id`           int UNSIGNED NOT NULL AUTO_INCREMENT,
    `firstname`     varchar(100) NOT NULL,
    `lastname`      varchar(100) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

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

ALTER TABLE `book_genres`
    ADD CONSTRAINT `book_genres_book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

ALTER TABLE `book_authors`
    ADD CONSTRAINT `book_authors_book_id`
    FOREIGN KEY (`book_id`)
    REFERENCES `books` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

ALTER TABLE `users`
    ADD CONSTRAINT `users_role_id`
    FOREIGN KEY (`role_id`)
    REFERENCES `roles` (`id`);

ALTER TABLE `book_genres`
    ADD CONSTRAINT `book_genres_genre_id`
    FOREIGN KEY (`genre_id`)
    REFERENCES `genres` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;

ALTER TABLE `book_authors`
    ADD CONSTRAINT `book_authors_author_id`
    FOREIGN KEY (`author_id`)
    REFERENCES `authors` (`id`)
        ON DELETE CASCADE
        ON UPDATE CASCADE;