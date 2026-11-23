
DROP DATABASE IF EXISTS LibraryDB;

CREATE DATABASE LibraryDB;

USE LibraryDB;

CREATE TABLE Authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(100) NOT NULL
);

CREATE TABLE Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    author_id INT NOT NULL,
    category VARCHAR(50),
    total_copies INT NOT NULL,
    available_copies INT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id),
    CHECK (total_copies >= 0),
    CHECK (available_copies >= 0),
    CHECK (available_copies <= total_copies)
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    user_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15)
);

CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE DEFAULT NULL,
    status ENUM('Issued', 'Returned') DEFAULT 'Issued',
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Authors (author_name)
VALUES
('R.K. Narayan'),
('J.K. Rowling'),
('Chetan Bhagat'),
('George Orwell'),
('Paulo Coelho');

INSERT INTO Books
(title, author_id, category, total_copies, available_copies)
VALUES
('Malgudi Days', 1, 'Fiction', 5, 5),
('Harry Potter', 2, 'Fantasy', 3, 3),
('Five Point Someone', 3, 'Novel', 4, 4),
('Animal Farm', 4, 'Political Fiction', 2, 2),
('The Alchemist', 5, 'Adventure', 3, 3);

INSERT INTO Users (user_name, email, phone)
VALUES
('Arun', 'arun@gmail.com', '9876543210'),
('Priya', 'priya@gmail.com', '9876543211'),
('Rahul', 'rahul@gmail.com', '9876543212'),
('Sneha', 'sneha@gmail.com', '9876543213');

DELIMITER //

CREATE PROCEDURE IssueBook(
    IN p_book_id INT,
    IN p_user_id INT
)
BEGIN
    DECLARE v_available INT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT available_copies
    INTO v_available
    FROM Books
    WHERE book_id = p_book_id
    FOR UPDATE;

    IF v_available IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book not found';

    ELSEIF v_available <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book is not available';

    ELSE
        UPDATE Books
        SET available_copies = available_copies - 1
        WHERE book_id = p_book_id;

        INSERT INTO Transactions
        (book_id, user_id, issue_date, due_date, status)
        VALUES
        (
            p_book_id,
            p_user_id,
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 14 DAY),
            'Issued'
        );
    END IF;

    COMMIT;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE ReturnBook(
    IN p_transaction_id INT
)
BEGIN
    DECLARE v_book_id INT DEFAULT NULL;
    DECLARE v_status VARCHAR(20) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT book_id, status
    INTO v_book_id, v_status
    FROM Transactions
    WHERE transaction_id = p_transaction_id
    FOR UPDATE;

    IF v_book_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction not found';

    ELSEIF v_status = 'Returned' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book already returned';

    ELSE
        UPDATE Transactions
        SET return_date = CURDATE(),
            status = 'Returned'
        WHERE transaction_id = p_transaction_id;

        UPDATE Books
        SET available_copies = available_copies + 1
        WHERE book_id = v_book_id;
    END IF;

    COMMIT;
END //

DELIMITER ;

SELECT * FROM Books;

SELECT * FROM Users;

SELECT title, available_copies
FROM Books
WHERE available_copies > 0;

SELECT
    Books.book_id,
    Books.title,
    Authors.author_name,
    Books.category,
    Books.available_copies
FROM Books
JOIN Authors
ON Books.author_id = Authors.author_id;

SELECT
    Transactions.transaction_id,
    Users.user_name,
    Books.title,
    Transactions.issue_date,
    Transactions.due_date
FROM Transactions
JOIN Users
ON Transactions.user_id = Users.user_id
JOIN Books
ON Transactions.book_id = Books.book_id
WHERE Transactions.status = 'Issued';

SELECT
    Transactions.transaction_id,
    Users.user_name,
    Books.title,
    Transactions.issue_date,
    Transactions.return_date
FROM Transactions
JOIN Users
ON Transactions.user_id = Users.user_id
JOIN Books
ON Transactions.book_id = Books.book_id
WHERE Transactions.status = 'Returned';

SELECT *
FROM Books
WHERE title LIKE '%Harry%';

SELECT
    Transactions.transaction_id,
    Users.user_name,
    Books.title,
    Transactions.due_date
FROM Transactions
JOIN Users
ON Transactions.user_id = Users.user_id
JOIN Books
ON Transactions.book_id = Books.book_id
WHERE Transactions.status = 'Issued'
AND Transactions.due_date < CURDATE();

SELECT SUM(total_copies) AS total_books
FROM Books;

SELECT SUM(available_copies) AS available_books
FROM Books;

SELECT COUNT(*) AS total_users
FROM Users;

SELECT
    Transactions.transaction_id,
    Users.user_name,
    Books.title,
    Transactions.issue_date,
    Transactions.due_date,
    Transactions.return_date,
    Transactions.status
FROM Transactions
JOIN Users
ON Transactions.user_id = Users.user_id
JOIN Books
ON Transactions.book_id = Books.book_id
ORDER BY Transactions.transaction_id DESC;

CALL IssueBook(1, 1);

CALL ReturnBook(1);

SELECT
    title,
    total_copies,
    available_copies
FROM Books;

