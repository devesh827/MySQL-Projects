-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

-- insert into books values("978-1-60129-456-2", "To Kill a Mockingbird", "Classic", 6.00, "yes", "Herper Lee", "J.B. Lippincott & Co.");
-- select * from books;

-- Task 2: Update an Existing Member's Address to '125 Main St' where member_id = C101

-- update members set member_address='125 Main St' where member_id='C101';
-- select * from members;

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
--  delete from issued_status where issued_id='IS121';
 
 -- Task 4: Retrieve All Books Issued by a Specific Employee 
 -- Objective: Select all books issued by the employee with emp_id = 'E101'.
--  select * from issued_status where issued_emp_id= "E101";
 
 -- Task 5: List Members Who Have Issued More Than One Book 
 -- Objective: Use GROUP BY to find members who have issued more than one book.

-- select count(issued_book_isbn) as Number_of_books_issued ,member_name, issued_member_id from issued_status i inner join members m on m.member_id=i.issued_member_id group by issued_member_id having Number_of_books_issued>1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

-- CREATE TABLE book_cnts
-- AS    
-- SELECT 
--     b.isbn,
--     b.book_title,
--     COUNT(ist.issued_id) as no_issued
-- FROM books as b
-- JOIN
-- issued_status as ist
-- ON ist.issued_book_isbn = b.isbn
-- GROUP BY 1, 2;
-- select * from book_cnts;

-- Task 7. Retrieve All Books in a Specific Category="classic":
-- select * from books where category="Classic";

-- Task 8: Find Total Rental Income by Category:
-- select b.Category,sum(rental_price) as total_rental_income from books b inner join issued_status i on b.isbn=i.issued_book_isbn group by category;

-- List Members Who Registered in the Last 180 Days:
-- INSERT INTO members(member_id, member_name, member_address, reg_date)
-- VALUES
-- ('C118', 'sam', '145 Main St', '2024-06-01'),
-- ('C119', 'john', '133 Main St', '2024-05-01');
-- select * from members;
--  select * from members where reg_date>=CURDATE() - INTERVAL 180 day	;

-- task 10 List Employees with Their Branch Manager's Name and their branch details:
-- SELECT 
--     e1.*,
--     b.manager_id,
--     e2.emp_name as manager
-- FROM employees as e1
-- JOIN  
-- branch as b
-- ON b.branch_id = e1.branch_id
-- JOIN
-- employees as e2
-- ON b.manager_id = e2.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
-- select rental_price from books;
-- CREATE table books_price_greater_than_seven
-- as 
-- select * from books where rental_price>7;

-- select * from books_price_greater_than_seven;issued_status

-- Task 12: Retrieve the List of Books Not Yet Returned
-- select * from return_status;
-- SELECT 
--     DISTINCT ist.issued_book_name
-- FROM issued_status as ist
-- LEFT JOIN
-- return_status as rs
-- ON ist.issued_id = rs.issued_id
-- WHERE rs.return_id IS NULL



-- Task 13: 
-- Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). 
-- Display the member's_id, member's name, book title, issue date, and days overdue.

-- select DATEDIFF(curdate(),issued_date) from issued_status;
-- select m.member_id,m.member_name,b.book_title,i.issue_date from issued_status i 
-- join members m on i.issued_member_id=m.member_id
-- join books b on i.issued_book_isbn=b.isbn
-- where DATEDIFF(curdate(),i.issued_date)>30;

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;


-- 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';


DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Get issued book details
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Show a message (for testing purposes only; not shown to application users)
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END $$

DELIMITER ;
CALL add_return_records('RS138', 'IS135', 'Good');


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals



CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;