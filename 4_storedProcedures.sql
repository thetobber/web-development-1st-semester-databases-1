use `library`;

DELIMITER //
 CREATE PROCEDURE GetAllUsers()
   BEGIN
   SELECT *  FROM users;
   END //
 DELIMITER ;
 
 CALL GetAllUsers();
 
 DELIMITER //
 CREATE PROCEDURE GetAllBooks()
   BEGIN
   SELECT *  FROM books;
   END //
 DELIMITER ;
 
 CALL GetAllBooks();
 
  DELIMITER //
 CREATE PROCEDURE Rented()
   MODIFIES SQL DATA
   UPDATE rented SET returned = 0 WHERE book_id = 1;
  DELIMITER ;
 
 CALL Rented();

 
