-- Include your create table DDL statements in this file.
-- Make sure to terminate each statement with a semicolon (;)

-- LEAVE this statement on. It is required to connect to your database.
CONNECT TO COMP421;

-- Remember to put the create table ddls for the tables with foreign key references
--    ONLY AFTER the parent tables have already been created.


CREATE TABLE Product
(
	product_id INTEGER PRIMARY KEY NOT NULL,
	description CLOB,
	name VARCHAR(50) NOT NULL,
	amount_in_stock INTEGER NOT NULL,
	price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Toy
(
	product_id INTEGER PRIMARY KEY NOT NULL,
	material VARCHAR(20) NOT NULL,
	min_age INTEGER,           -- age_group would be hard to query as string (need to match pattern exactly, bad design) 
	max_age INTEGER,
	dimensions VARCHAR(50) NOT NULL,    -- str: "L x H x W"
	manufacturer VARCHAR(50) NOT NULL,
	FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Movie
(
	product_id INTEGER PRIMARY KEY NOT NULL,
	rating VARCHAR(10),
	duration INTEGER NOT NULL,          -- in mins
	director VARCHAR(50) NOT NULL,
	release_date DATE NOT NULL,
	FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Book
(
	product_id INTEGER PRIMARY KEY NOT NULL,
	published_date DATE NOT NULL,
	publisher VARCHAR(50) NOT NULL,
	ISBN VARCHAR(20) NOT NULL UNIQUE,
	page_count INTEGER NOT NULL,
	FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

CREATE TABLE Payment
(
	payment_id INTEGER PRIMARY KEY NOT NULL,
	payment_timestamp TIMESTAMP NOT NULL,
	payment_method VARCHAR(30) NOT NULL,
	transaction_token VARCHAR(100) NOT NULL UNIQUE,
	amount DECIMAL(10, 2) NOT NULL,
	last_four_digit CHAR(4) NOT NULL
);

CREATE TABLE Shipping
(
	shipping_id INTEGER PRIMARY KEY NOT NULL,
	from_address VARCHAR(100) NOT NULL,
	to_address VARCHAR(100) NOT NULL,
	tracking_number VARCHAR(50) NOT NULL,
	carrier_name VARCHAR(50) NOT NULL,
	status VARCHAR(20) NOT NULL DEFAULT 'pending',
	expected_delivery DATE NOT NULL,
	UNIQUE(tracking_number, carrier_name)
);

CREATE TABLE Customer
(
	customer_id INTEGER PRIMARY KEY NOT NULL,
    	first_name VARCHAR(50) NOT NULL,
    	last_name VARCHAR(50) NOT NULL,
    	email VARCHAR(100) NOT NULL UNIQUE,
    	password VARCHAR(100) NOT NULL
);

CREATE TABLE "Order"
(
	order_id INTEGER PRIMARY KEY NOT NULL,
	order_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	customer_id INTEGER NOT NULL,
	payment_id INTEGER,                -- allow NULL until payment is processed
	shipping_id INTEGER,               -- allow NULL until shipping is ready
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
	FOREIGN KEY (payment_id) REFERENCES Payment(payment_id),
	FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id)
);

CREATE TABLE Author
(
	author_id INTEGER PRIMARY KEY NOT NULL,
	author_name VARCHAR(50) NOT NULL,
	biography CLOB
);

CREATE TABLE Genre
(
	genre_name VARCHAR(50) PRIMARY KEY NOT NULL
);

---------------- RELATIONSHIP SETS ---------------
CREATE TABLE OrderItem
(
	order_id INTEGER NOT NULL,
	product_id INTEGER NOT NULL,
	quantity INTEGER NOT NULL,
	price_at_purchase DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY (order_id, product_id),
	FOREIGN KEY (order_id) REFERENCES "Order"(order_id),
	FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

	--- WEAK ENTITY ---
CREATE TABLE "Return"
(
	return_timestamp TIMESTAMP NOT NULL, 
	order_id INTEGER NOT NULL,
	product_id INTEGER NOT NULL,
	quantity INTEGER NOT NULL,
	shipping_id INTEGER,
	PRIMARY KEY (return_timestamp, order_id, product_id),
	FOREIGN KEY (order_id, product_id) REFERENCES OrderItem(order_id, product_id),
	FOREIGN KEY (shipping_id) REFERENCES Shipping(shipping_id)
);

CREATE TABLE BookAuthor
(
  	author_id INTEGER NOT NULL,
	product_id INTEGER NOT NULL,
	PRIMARY KEY (author_id, product_id),
	FOREIGN KEY (author_id) REFERENCES Author(author_id),
	FOREIGN KEY (product_id) REFERENCES Book(product_id)
);

CREATE TABLE BookGenre
(
	product_id INTEGER NOT NULL,
	genre_name VARCHAR(50) NOT NULL,
	PRIMARY KEY (product_id, genre_name),
	FOREIGN KEY (product_id) REFERENCES Book(product_id),
	FOREIGN KEY (genre_name) REFERENCES Genre(genre_name)
);

CREATE TABLE MovieGenre
(
	product_id INTEGER NOT NULL,
	genre_name VARCHAR(50) NOT NULL,
	PRIMARY KEY (product_id, genre_name),
	FOREIGN KEY (product_id) REFERENCES Movie(product_id),
	FOREIGN KEY (genre_name) REFERENCES Genre(genre_name)
);



-- ---Constraints---
-- ALTER TABLE Product
-- ADD CONSTRAINT positive_price
-- CHECK (price > 0);

-- ALTER TABLE "Return"
-- ADD CONSTRAINT valid_return_quantity
-- CHECK (quantity > 0);

-- ALTER TABLE Movie
-- ADD CONSTRAINT valid_movie_rating
-- CHECK (rating IN ('G', 'PG', 'PG-13', 'R', 'NC-17') OR rating IS NULL);