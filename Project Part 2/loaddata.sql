-- Include your INSERT SQL statements in this file.
-- Make sure to terminate each statement with a semicolon (;)

-- LEAVE this statement on. It is required to connect to your database.
CONNECT TO COMP421;

-- Remember to put the INSERT statements for the tables with foreign key references
--    ONLY AFTER the insert for the parent tables!

INSERT INTO Product (product_id, description, name, amount_in_stock, price) VALUES
(1, 'A fun wooden toy for kids', 'Wooden Train', 50, 29.99),
(2, 'Fantasy adventure novel', 'Dragon Quest', 30, 15.50),
(3, 'Action-packed movie DVD', 'Superhero Saga', 20, 19.99),
(4, 'Educational puzzle toy', 'Math Puzzle', 40, 12.75),
(5, 'Science fiction book', 'Space Odyssey', 25, 18.00),
(6, 'Remote controlled car', 'Speed Racer', 35, 49.99),
(7, 'Children''s board game', 'Candy Kingdom', 60, 22.50),
(8, 'Romantic novel', 'Love in Paris', 40, 14.25),
(9, 'Horror movie DVD', 'Nightmare Street', 15, 17.99),
(10, 'Classic literature book', 'Pride & Prejudice', 20, 12.50),
(11, 'Plush stuffed animal', 'Cuddly Bear', 80, 9.99),
(12, 'Puzzle cube toy', 'Brain Twister', 50, 11.75),
(13, 'Animated movie DVD', 'Flying Friends', 25, 16.50),
(14, 'Cookbook for kids', 'Tiny Chefs', 30, 13.99),
(15, 'Science experiment kit', 'Junior Scientist', 20, 34.99),
(16, 'Superhero action figure', 'Captain Bold', 45, 24.50),
(17, 'Mystery novel', 'The Secret Diary', 35, 15.75),
(18, 'Documentary movie DVD', 'Nature Wonders', 40, 18.99),
(19, 'Educational book', 'Math Made Easy', 30, 14.50),
(20, 'Wooden building blocks', 'Block Builder', 70, 27.99),
(21, NULL, 'Robot Dog', 25, 59.99),
(22, NULL, 'Magic Puzzle', 30, 19.50),
(23, NULL, 'Kids Tablet', 20, 89.99),
(24, NULL, 'Coloring Book', 40, 7.99),
(25, NULL, 'High School Musical 2', 35, 29.50),
(26, NULL, 'Building Blocks Deluxe', 50, 39.99),
(27, NULL, 'Science Lab Kit', 15, 49.99),
(28, NULL, 'Stuffed Bunny', 45, 14.75),
(29, NULL, 'Mini Drone', 10, 99.99),
(30, NULL, 'Puzzle Cube Advanced', 25, 12.50);


INSERT INTO Toy (product_id, material, min_age, max_age, dimensions, manufacturer) VALUES
(1, 'Wood', 3, 6, '30x15x10 cm', 'ToyCo'),
(4, 'Cardboard', 5, 10, '25x25x5 cm', 'EduToys'),
(6, 'Plastic', 4, 8, '20x10x8 cm', 'SpeedyToys'),
(7, 'Wood', 6, 12, '30x30x10 cm', 'FunGames Inc.'),
(11, 'Plush', 1, 4, '15x20x10 cm', 'CuddleCorp'),
(12, 'Plastic', 8, 12, '5x5x5 cm', 'BrainyToys'),
(15, 'Plastic & Metal', 10, 14, '30x20x10 cm', 'ScienceKits Ltd.'),
(16, 'Plastic', 5, 12, '12x20x8 cm', 'ActionFigures Co.'),
(20, 'Wood', 3, 8, '25x25x15 cm', 'Blocks Inc.'),
(21, 'Plastic', 5, 12, '20x15x10 cm', 'RoboToys Inc.'),
(22, 'Wood', 6, 10, '25x20x10 cm', 'MagicGames'),
(23, 'Plastic', 7, 14, '18x12x8 cm', 'TechKids'),
(26, 'Wood', 3, 10, '30x20x15 cm', 'BlockMasters'),
(27, 'Plastic & Metal', 8, 14, '25x15x10 cm', 'ScienceKits Ltd.'),
(28, 'Plush', 0, 4, '20x15x10 cm', 'Softies Co.'),
(29, 'Plastic', 13, NULL, '20x15x10 cm', 'TechKids'),
(30, 'Plastic', 8, 14, '5x5x5 cm', 'PuzzleWorld');

INSERT INTO Movie (product_id, rating, duration, director, release_date) VALUES
(3, 'PG-13', 120, 'Jane Smith', '2022-06-15'),
(9, 'R', 95, 'John Doe', '2021-10-31'),
(13, 'G', 80, 'Emily Johnson', '2023-03-20'),
(18, 'PG', 105, 'Michael Lee', '2022-12-10'),
(25, 'PG-13', 110, 'Action Director', '2022-12-05');

INSERT INTO Book (product_id, published_date, publisher, ISBN, page_count) VALUES
(2, '2020-05-12', 'Fantasy Press', '978-0-123456-47-2', 320),
(5, '2019-08-20', 'SciFi House', '978-0-987654-32-1', 280),
(8, '2021-02-14', 'Romance Co.', '978-1-234567-89-0', 250),
(10, '1813-01-28', 'Classic Books', '978-0-111111-22-3', 432),
(14, '2022-09-01', 'KidCook Press', '978-0-222222-33-4', 120),
(17, '2021-07-15', 'Mystery House', '978-0-333333-44-5', 310),
(19, '2020-11-10', 'EduBooks', '978-0-444444-55-6', 200),
(24, '2020-09-01', 'ColorFun House', '978-0-888888-99-0', 80);


INSERT INTO Customer (customer_id, last_name, first_name, email, password) VALUES
(1, 'Ursa', 'Giles', 'quisque@yahoo.ca', 'ornare'),
(2, 'Kelly', 'Guerra', 'ridiculus.mus.proin@outlook.com', 'ipsum'),
(3, 'Kuame', 'Paul', 'nulla@aol.couk', 'nec'),
(4, 'Jorden', 'Oneil', 'gravida.non@google.ca', 'sed'),
(5, 'Maxwell', 'Lopez', 'gravida@icloud.org', 'elit'),
(6, 'Blossom', 'Ellis', 'turpis.egestas@protonmail.couk', 'Vivamus'),
(7, 'Jasmine', 'Weber', 'vulputate.mauris@outlook.couk', 'amet'),
(8, 'Wendy', 'Ellis', 'ac.libero@yahoo.edu', 'feugiat'),
(9, 'Todd', 'Washington', 'nulla.interdum.curabitur@hotmail.couk', 'cursus'),
(10, 'Todd', 'Haney', 'ullamcorper.magna.sed@yahoo.net', 'dapibus'),
(11, 'Quemby', 'Savage', 'lectus.pede.ultrices@protonmail.edu', 'mattis'),
(12, 'Courtney', 'Trevino', 'orci@yahoo.edu', 'est'),
(13, 'Risa', 'Mcbride', 'a.arcu@google.couk', 'quam'),
(14, 'Walker', 'Duran', 'quis.lectus@icloud.edu', 'Nunc'),
(15, 'Ignatius', 'Park', 'quis.diam@outlook.com', 'senectus');


INSERT INTO Author (author_id, author_name, biography) VALUES
(1, 'Emily Carter', 'Fantasy author known for epic adventures.'),
(2, 'James Holloway', 'SciFi and dystopian novelist.'),
(3, 'Laura Bennett', 'Romance writer with international acclaim.'),
(4, 'Michael Grant', 'Mystery and thriller specialist.'),
(5, 'Sophia Turner', 'Educational children book writer.'),
(6, 'Daniel Brooks', 'Classic literature contributor.'),
(7, 'Olivia Reed', 'Horror novelist.'),
(8, 'Nathan Cole', 'Documentary screenplay writer.');


INSERT INTO Genre (genre_name) VALUES
('Fantasy'),
('SciFi'),
('Romance'),
('Mystery'),
('Horror'),
('Educational'),
('Animation'),
('Documentary');


INSERT INTO BookAuthor (author_id, product_id) VALUES
(1,2),
(8,5),
(2,5),
(3,8),
(6,10),
(5,14),
(4,17),
(5,19),
(7,19),
(5,24);


INSERT INTO BookGenre (product_id, genre_name) VALUES
(2,'Fantasy'),
(5,'SciFi'),
(8,'Romance'),
(8,'Horror'),
(10,'Mystery'),
(17,'Mystery'),
(17,'Romance'),
(19,'Educational'),
(24,'Educational');


INSERT INTO MovieGenre (product_id, genre_name) VALUES
(3,'Animation'),
(9,'Horror'),
(9,'SciFi'),
(13,'Animation'),
(13,'Educational'),
(18,'Documentary'),
(18,'Educational'),
(25,'Romance');


INSERT INTO Payment (payment_id, payment_timestamp, payment_method, transaction_token, amount, last_four_digit) VALUES
(1,'2025-01-10 10:00:00','Visa','TXN1001',89.98,'1234'),
(2,'2025-01-15 12:30:00','Mastercard','TXN1002',45.50,'5678'),
(3,'2025-02-01 09:15:00','PayPal','TXN1003',120.75,'0000'),
(4,'2025-02-10 14:20:00','Visa','TXN1004',65.00,'4321'),
(5,'2025-02-18 16:45:00','Interac','TXN1005',39.99,'9999'),
(6,'2025-03-02 11:10:00','Visa','TXN1006',74.25,'2222'),
(7,'2025-03-08 13:40:00','Mastercard','TXN1007',99.99,'8888'),
(8,'2025-03-20 17:00:00','PayPal','TXN1008',55.75,'0000'),
(9,'2025-04-01 10:30:00','Visa','TXN1009',44.00,'1111'),
(10,'2025-04-05 15:20:00','Mastercard','TXN1010',68.50,'7777'),
(11,'2025-04-12 18:15:00','Interac','TXN1011',90.00,'3333'),
(12,'2025-05-02 09:50:00','Visa','TXN1012',35.99,'4444'),
(13,'2025-05-08 14:00:00','PayPal','TXN1013',82.25,'0000'),
(14,'2025-05-15 12:10:00','Mastercard','TXN1014',60.00,'5555'),
(15,'2025-06-01 11:30:00','Visa','TXN1015',110.50,'6666'),
(16,'2025-06-10 16:40:00','Interac','TXN1016',48.75,'1010'),
(17,'2025-06-18 13:20:00','Visa','TXN1017',75.00,'2020'),
(18,'2025-07-01 10:00:00','Mastercard','TXN1018',59.99,'3030'),
(19,'2025-07-09 15:30:00','PayPal','TXN1019',88.80,'0000'),
(20,'2025-07-15 17:45:00','Visa','TXN1020',95.25,'4040'),
(21,'2025-07-30 19:24:00','Mastercard','TXN1021',105.93,'000');


INSERT INTO Shipping (shipping_id, from_address, to_address, tracking_number, carrier_name, status, expected_delivery) VALUES
(1,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','1234 Rue Sherbrooke Ouest, Montréal, QC H3G 1G3','TRK1001','CanadaPost','delivered','2025-01-15'),
(2,'2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','5678 Boulevard Saint-Laurent, Montréal, QC H2T 1S6','TRK1001','FedEx','delivered','2025-01-20'),
(3,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','890 Avenue du Parc, Montréal, QC H2W 1S9','UPS1001','UPS','delivered','2025-02-05'),
(4,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','2450 Rue Ontario Est, Montréal, QC H2K 1W8','TRK1002','CanadaPost','delivered','2025-02-15'),
(5,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','3100 Boulevard Pie-IX, Montréal, QC H1X 2B3','TRK1002','FedEx','delivered','2025-02-22'),
(6,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','1450 Boulevard de la Concorde Est, Laval, QC H7G 2E5','UPS1002','UPS','delivered','2025-03-07'),
(7,'2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','2200 Boulevard Curé-Labelle, Laval, QC H7T 1R9','TRK1003','CanadaPost','delivered','2025-03-12'),
(8,'2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','750 Rue Principale, Saint-Eustache, QC J7R 5A8','TRK1003','FedEx','delivered','2025-03-25'),
(9,'2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','980 Boulevard Saint-Martin Ouest, Laval, QC H7S 1M9','UPS1003','UPS','delivered','2025-04-06'),
(10,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','4000 Boulevard Notre-Dame, Laval, QC H7W 1S7','TRK1004','CanadaPost','delivered','2025-04-10'),
(11,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','120 Chemin de Chambly, Longueuil, QC J4H 3L7','TRK1004','FedEx','delivered','2025-04-18'),
(12,'2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','5500 Boulevard Taschereau, Brossard, QC J4X 1C2','UPS1004','UPS','delivered','2025-05-06'),
(13,'2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','890 Boulevard des Promenades, Saint-Bruno, QC J3V 5J5','TRK1005','CanadaPost','delivered','2025-05-12'),
(14,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','3000 Rue King Ouest, Sherbrooke, QC J1L 1C9','TRK1005','FedEx','delivered','2025-05-20'),
(15,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','145 Rue Saint-Charles Ouest, Longueuil, QC J4H 1E9','UPS1005','UPS','delivered','2025-06-05'),
(16,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','1234 Rue Sherbrooke Ouest, Montréal, QC H3G 1G3','TRK1006','CanadaPost','delivered','2025-06-15'),
(17,'2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','5678 Boulevard Saint-Laurent, Montréal, QC H2T 1S6','TRK1006','FedEx','delivered','2025-06-25'),
(18,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','890 Avenue du Parc, Montréal, QC H2W 1S9','UPS1006','UPS','delivered','2025-07-05'),
(19,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','2450 Rue Ontario Est, Montréal, QC H2K 1W8','TRK1007','CanadaPost','delivered','2025-07-14'),
(20,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','3100 Boulevard Pie-IX, Montréal, QC H1X 2B3','TRK1007','FedEx','out for delivery','2025-07-20'),
(21,'5678 Boulevard Saint-Laurent, Montréal, QC H2T 1S6','2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','UPS1007','UPS','delivered','2025-01-30'),
(22,'5678 Boulevard Saint-Laurent, Montréal, QC H2T 1S6','2225 Autoroute des Laurentides, Laval, QC H7S 1Z6','TRK1008','CanadaPost','delivered','2025-02-14'),
(23,'2450 Rue Ontario Est, Montréal, QC H2K 1W8','4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','TRK1008','FedEx','delivered','2025-02-14'),
(24,'750 Rue Principale, Saint-Eustache, QC J7R 5A8','4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','UPS1008','UPS','delivered','2025-03-25'),
(25,'145 Rue Saint-Charles Ouest, Longueuil, QC J4H 1E9','4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','TRK1009','CanadaPost','delivered','2025-04-27'),
(26,'890 Boulevard des Promenades, Saint-Bruno, QC J3V 5J5','4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','TRK1009','FedEx','delivered','2025-05-30'),
(27,'5678 Boulevard Saint-Laurent, Montréal, QC H2T 1S6','4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','UPS1009','UPS','out for delivery','2025-07-15'),
(28,'4000 Rue Notre-Dame Est, Montréal, QC H1W 2K3','890 Avenue du Parc, Montréal, QC H2W 1S9','TRK1010','CanadaPost','shipped','2025-08-13')
;


INSERT INTO "Order" (order_id, order_timestamp, customer_id, payment_id, shipping_id) VALUES
(1,'2025-01-10 10:00:00',1,1,1),
(2,'2025-01-15 12:30:00',2,2,2),
(3,'2025-02-01 09:15:00',3,3,3),
(4,'2025-02-10 14:20:00',4,4,4),
(5,'2025-02-18 16:45:00',5,5,5),
(6,'2025-03-02 11:10:00',6,6,6),
(7,'2025-03-08 13:40:00',7,7,7),
(8,'2025-03-20 17:00:00',8,8,8),
(9,'2025-04-01 10:30:00',9,9,9),
(10,'2025-04-05 15:20:00',10,10,10),
(11,'2025-04-12 18:15:00',11,11,11),
(12,'2025-05-02 09:50:00',12,12,12),
(13,'2025-05-08 14:00:00',13,13,13),
(14,'2025-05-15 12:10:00',14,14,14),
(15,'2025-06-01 11:30:00',15,15,15),
(16,'2025-06-10 16:40:00',1,16,16),
(17,'2025-06-18 13:20:00',2,17,17),
(18,'2025-07-01 10:00:00',3,18,18),
(19,'2025-07-09 15:30:00',4,19,19),
(20,'2025-07-15 17:45:00',5,20,20),
(21,'2025-07-20 19:23:00',3,21,28);


INSERT INTO OrderItem (order_id, product_id, quantity, price_at_purchase) VALUES


(1,2,1,19.99),

(2,5,1,24.99),
(2,4,1,29.99),
(2,1,2,14.99),

(3,8,2,16.75),
(3,3,1,19.99),

(4,10,1,21.50),

(5,14,1,18.75),
(5,7,2,15.00),
(5,6,1,9.99),
(5,9,1,13.50),

(6,17,1,22.99),
(6,11,1,34.99),

(7,19,1,16.99),
(7,12,1,11.25),
(7,13,1,18.50),

(8,24,1,20.00),

(9,2,1,19.99),
(9,15,1,27.99),

(10,5,2,24.99),
(10,16,1,8.99),
(10,18,1,14.25),
(10,20,1,59.99),

(11,8,1,14.25),

(12,10,1,21.50),
(12,21,1,59.99),
(12,22,1,19.99),

(13,14,2,18.75),
(13,23,1,12.49),

(14,17,1,22.99),

(15,19,1,16.99),
(15,25,1,14.99),
(15,26,1,25.00),

(16,24,1,20.00),
(16,27,1,30.00),

(17,2,1,19.99),

(18,5,1,18.00),
(18,28,1,14.75),
(18,29,1,94.99),

(19,8,1,14.25),
(19,30,1,10.50),

(20,10,1,21.50),

(21,10,2,12.50),
(21,21,1,59.99),
(21,1,3,29.99)
;



INSERT INTO "Return" (return_timestamp, order_id, product_id, quantity, shipping_id) VALUES
('2025-01-25 10:00:00',2,1,1,21),
('2025-01-28 03:00:00',2,1,1,22),
('2025-02-10 14:00:00',3,8,1,23),
('2025-03-15 09:30:00',5,7,2,24),
('2025-04-20 16:45:00',10,5,1,25),
('2025-05-28 12:15:00',13,14,1,26),
('2025-07-02 11:00:00',18,29,1,27);










