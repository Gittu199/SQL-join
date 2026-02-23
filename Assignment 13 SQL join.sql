-- ============================================================
-- Assignment 13: SQL Joins
-- ============================================================

-- ============================================================
-- STEP 1: CREATE DATABASE AND USE IT
-- ============================================================
CREATE DATABASE IF NOT EXISTS assignment13;
USE assignment13;

-- ============================================================
-- STEP 2: CREATE TABLES
-- ============================================================

-- Table 1: Customers
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID   INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City         VARCHAR(100)
);

-- Table 2: Orders
CREATE TABLE IF NOT EXISTS Orders (
    OrderID    INT PRIMARY KEY,
    CustomerID INT,
    OrderDate  DATE,
    Amount     DECIMAL(10,2)
);

-- Table 3: Payments
CREATE TABLE IF NOT EXISTS Payments (
    PaymentID   VARCHAR(10) PRIMARY KEY,
    CustomerID  INT,
    PaymentDate DATE,
    Amount      DECIMAL(10,2)
);

-- Table 4: Employees
CREATE TABLE IF NOT EXISTS Employees (
    EmployeeID   INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    ManagerID    INT
);

-- ============================================================
-- STEP 3: INSERT DUMMY DATA
-- ============================================================

INSERT INTO Customers VALUES
(1, 'John Smith',    'New York'),
(2, 'Mary Johnson',  'Chicago'),
(3, 'Peter Adams',   'Los Angeles'),
(4, 'Nancy Miller',  'Houston'),
(5, 'Robert White',  'Miami');

INSERT INTO Orders VALUES
(101, 1, '2024-10-01', 250),
(102, 2, '2024-10-05', 300),
(103, 1, '2024-10-07', 150),
(104, 3, '2024-10-10', 450),
(105, 6, '2024-10-12', 400);  -- CustomerID 6 does NOT exist in Customers

INSERT INTO Payments VALUES
('P001', 1, '2024-10-02', 250),
('P002', 2, '2024-10-06', 300),
('P003', 3, '2024-10-11', 450),
('P004', 4, '2024-10-15', 200);

INSERT INTO Employees VALUES
(1, 'Alex Green',  NULL),
(2, 'Brian Lee',   1),
(3, 'Carol Ray',   1),
(4, 'David Kim',   2),
(5, 'Eva Smith',   2);

-- ============================================================
-- QUESTION 1: Retrieve all customers who have placed at least one order.
-- JOIN TYPE: INNER JOIN
-- Logic: Only returns rows where CustomerID matches in BOTH tables.
--        Customers without orders are excluded automatically.
-- ============================================================
SELECT DISTINCT
    c.CustomerID,
    c.CustomerName,
    c.City
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID;

-- ============================================================
-- QUESTION 2: Retrieve all customers and their orders, including
--             customers who have NOT placed any orders.
-- JOIN TYPE: LEFT JOIN
-- Logic: Keeps ALL rows from Customers (left table).
--        For customers with no orders, order columns show NULL.
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    o.OrderID,
    o.OrderDate,
    o.Amount AS OrderAmount
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID;

-- ============================================================
-- QUESTION 3: Retrieve all orders and their corresponding customers,
--             including orders placed by unknown customers (CustomerID 6).
-- JOIN TYPE: RIGHT JOIN
-- Logic: Keeps ALL rows from Orders (right table).
--        For orders with no matching customer, customer columns show NULL.
-- ============================================================
SELECT
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.OrderDate,
    o.Amount     AS OrderAmount,
    c.CustomerName,
    c.City
FROM Customers c
RIGHT JOIN Orders o
    ON c.CustomerID = o.CustomerID;

-- ============================================================
-- QUESTION 4: Display all customers and orders, whether matched or not.
-- JOIN TYPE: FULL OUTER JOIN (simulated using LEFT JOIN + UNION + RIGHT JOIN,
--            because MySQL does not support FULL OUTER JOIN directly)
-- Logic: Returns all rows from both tables; NULL fills in the gaps.
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    o.OrderID,
    o.OrderDate,
    o.Amount AS OrderAmount
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID

UNION

SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    o.OrderID,
    o.OrderDate,
    o.Amount AS OrderAmount
FROM Customers c
RIGHT JOIN Orders o ON c.CustomerID = o.CustomerID;

-- ============================================================
-- QUESTION 5: Find customers who have NOT placed any orders.
-- JOIN TYPE: LEFT JOIN with NULL filter
-- Logic: LEFT JOIN brings all customers; WHERE o.OrderID IS NULL
--        filters only those with no matching order record.
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,
    c.City
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- ============================================================
-- QUESTION 6: Retrieve customers who made payments but did NOT place any orders.
-- JOIN TYPE: Multiple LEFT JOINs with NULL filter
-- Logic: Join Customers with Payments (INNER to find paying customers),
--        then LEFT JOIN with Orders; filter where no matching order exists.
-- ============================================================
SELECT DISTINCT
    c.CustomerID,
    c.CustomerName,
    c.City
FROM Customers c
INNER JOIN Payments p
    ON c.CustomerID = p.CustomerID
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

-- ============================================================
-- QUESTION 7: Generate a list of all possible combinations between
--             Customers and Orders.
-- JOIN TYPE: CROSS JOIN
-- Logic: Every customer is paired with every order — no condition needed.
--        Result = (number of customers) x (number of orders) rows.
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    o.OrderID,
    o.OrderDate,
    o.Amount AS OrderAmount
FROM Customers c
CROSS JOIN Orders o;

-- ============================================================
-- QUESTION 8: Show all customers along with order and payment amounts in one table.
-- JOIN TYPE: Multiple LEFT JOINs
-- Logic: Start from Customers, LEFT JOIN Orders to get order amounts,
--        LEFT JOIN Payments to get payment amounts.
--        All customers appear; NULL shows where no order/payment exists.
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,
    c.City,
    o.OrderID,
    o.OrderDate,
    o.Amount     AS OrderAmount,
    p.PaymentID,
    p.PaymentDate,
    p.Amount     AS PaymentAmount
FROM Customers c
LEFT JOIN Orders o
    ON c.CustomerID = o.CustomerID
LEFT JOIN Payments p
    ON c.CustomerID = p.CustomerID;

-- ============================================================
-- QUESTION 9: Retrieve all customers who have BOTH placed orders
--             AND made payments.
-- JOIN TYPE: INNER JOIN (on both Orders and Payments)
-- Logic: Two INNER JOINs ensure only customers who appear in
--        BOTH Orders AND Payments tables are returned.
-- ============================================================
SELECT DISTINCT
    c.CustomerID,
    c.CustomerName,
    c.City
FROM Customers c
INNER JOIN Orders o
    ON c.CustomerID = o.CustomerID
INNER JOIN Payments p
    ON c.CustomerID = p.CustomerID;

-- ============================================================
-- BONUS: Self Join on Employees table
-- Retrieve each employee along with their manager's name.
-- JOIN TYPE: SELF JOIN (LEFT JOIN on same table with alias)
-- Logic: e = employee, m = manager. ManagerID links back to EmployeeID.
--        Alex Green (ManagerID = NULL) appears with NULL manager name.
-- ============================================================
SELECT
    e.EmployeeID,
    e.EmployeeName AS Employee,
    m.EmployeeName AS Manager
FROM Employees e
LEFT JOIN Employees m
    ON e.ManagerID = m.EmployeeID;

-- ============================================================
-- END OF ASSIGNMENT 13: SQL Joins
-- ============================================================
