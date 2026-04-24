-- Include your drop table DDL statements in this file.
-- Make sure to terminate each statement with a semicolon (;)

-- LEAVE this statement on. It is required to connect to your database.
CONNECT TO COMP421;

-- Remember to put the drop table ddls for the tables with foreign key references
--    BEFORE the ddls to drop the parent tables (reverse of the creation order).

DROP TABLE IF EXISTS "Return";

DROP TABLE IF EXISTS MovieGenre;
DROP TABLE IF EXISTS BookGenre;
DROP TABLE IF EXISTS BookAuthor;
DROP TABLE IF EXISTS OrderItem;

DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Shipping;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS "Order";

DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Movie;
DROP TABLE IF EXISTS Toy;
DROP TABLE IF EXISTS Product;

DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS Genre;
