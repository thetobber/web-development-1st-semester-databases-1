CREATE TABLE `users` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `role_id`       int UNSIGNED NOT NULL,
    `firstname`     varchar(100) NOT NULL,
    `lastname`      varchar(100) NOT NULL,
    `email`         varchar(255) NOT NULL,
    `password`      binary(32) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `books` (
    `id`            int UNSIGNED NOT NULL AUTO_INCREMENT,
    `publisher_id`  int UNSIGNED NOT NULL,
    `isbn`          varchar(13) NOT NULL,
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
    `id `           int UNSIGNED NOT NULL AUTO_INCREMENT,
    `firstname`     varchar(100) NOT NULL,
    `lastname`      varchar(100) NOT NULL,

    PRIMARY KEY (`id `)
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