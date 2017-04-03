USE `library`;

CALL getUser(1);
CALL getUsers(10, 0);

CALL getBook(1);
CALL getBooks(10, 0);

CALL rentBook(1, 2);
CALL rentBook(3, 4);

SELECT * FROM `users_view`;
SELECT * FROM `books_view`;