
CREATE DATABASE LibraryDB;
USE LibraryDB;

CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    book_name VARCHAR(100),
    author VARCHAR(100),
    quantity INT
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT,
    user_id INT,
    issue_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Books VALUES
(1, 'Java Programming', 'James', 5),
(2, 'Python Basics', 'Guido', 3),
(3, 'Database Systems', 'Korth', 4);

INSERT INTO Users VALUES
(101, 'Arun', 'arun@gmail.com'),
(102, 'Priya', 'priya@gmail.com');

INSERT INTO Transactions
(book_id, user_id, issue_date, return_date)
VALUES (1, 101, CURDATE(), NULL);

UPDATE Books
SET quantity = quantity - 1
WHERE book_id = 1 AND quantity > 0;

UPDATE Transactions
SET return_date = CURDATE()
WHERE transaction_id = 1
AND return_date IS NULL;

UPDATE Books
SET quantity = quantity + 1
WHERE book_id = 1;

SELECT * FROM Books WHERE quantity > 0;

SELECT Users.user_name, Books.book_name,
       Transactions.issue_date
FROM Transactions
JOIN Users ON Transactions.user_id = Users.user_id
JOIN Books ON Transactions.book_id = Books.book_id
WHERE Transactions.return_date IS NULL;

SELECT * FROM Transactions;
SELECT * FROM Books;
SELECT * FROM Users;
