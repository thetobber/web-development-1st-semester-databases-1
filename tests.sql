USE `library`;

CALL getUser(1);
CALL getUser(10, 0);

CALL getBook(1);
CALL getBooks(10, 0);

SELECT * FROM `users_view`;
SELECT * FROM `books_view`;