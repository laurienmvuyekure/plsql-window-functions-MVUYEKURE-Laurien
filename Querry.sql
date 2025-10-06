CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    Region VARCHAR(50)
);
INSERT INTO Customer VALUES (101, 'Alice Umuhoza', 'Gasabo');
INSERT INTO Customer VALUES (102, 'Eric Mugisha', 'Rulindo');
INSERT INTO Customer VALUES (103, 'Sarah Ingabire', 'Musanze');
INSERT INTO Customer VALUES (104, 'David Nkurunziza', 'Nyamata');
INSERT INTO Customer VALUES (105, 'Moise Ndaruhutse', 'Kicukiro');
CREATE TABLE Product (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(50),
    Category VARCHAR(30)
);
INSERT INTO Product VALUES (201, 'Mango', 'Fruit');
INSERT INTO Product VALUES (202, 'Orange', 'Fruit');
INSERT INTO Product VALUES (203, 'Milk', 'Beverage');
INSERT INTO Product VALUES (204, 'Coffee', 'Beverage');
INSERT INTO Product VALUES (205, 'Juice', 'Drink');
CREATE TABLE Sales (
    Transaction_ID INT PRIMARY KEY,
    Customer_ID INT,
    Product_ID INT,
    Sale_Date DATE,
    Amount DECIMAL(10,2),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);
INSERT INTO Sales VALUES (001, 101, 201, DATE '2025-01-01', 2500);
INSERT INTO Sales VALUES (002, 102, 203, DATE '2025-01-01', 1800);
INSERT INTO Sales VALUES (003, 103, 204, DATE '2025-01-02', 3000);
INSERT INTO Sales VALUES (004, 101, 205, DATE '2025-01-03', 2200);
INSERT INTO Sales VALUES (005, 104, 202, DATE '2025-01-03', 2700);
INSERT INTO Sales VALUES (006, 105, 203, DATE '2025-01-04', 1500);
INSERT INTO Sales VALUES (007, 103, 201, DATE '2025-01-04', 2600);
INSERT INTO Sales VALUES (008, 102, 205, DATE '2025-01-05', 3100);
INSERT INTO Sales VALUES (009, 104, 204, DATE '2025-01-05', 4000);
INSERT INTO Sales VALUES (010, 105, 202, DATE '2025-01-06', 2800);

-- runking
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    SUM(s.Amount) AS Total_Revenue,
    ROW_NUMBER() OVER (ORDER BY SUM(s.Amount) DESC) AS Row_Num,
    RANK()       OVER (ORDER BY SUM(s.Amount) DESC) AS Rank_Num,
    DENSE_RANK() OVER (ORDER BY SUM(s.Amount) DESC) AS Dense_Rank_Num,
    PERCENT_RANK() OVER (ORDER BY SUM(s.Amount) DESC) AS Percent_Rank
FROM Customer c
JOIN Sales s ON c.Customer_ID = s.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name;
--Aggregate
SELECT 
    s.Customer_ID,
    c.Customer_Name,
    s.Sale_Date,
    s.Amount,
    SUM(s.Amount) OVER (
        PARTITION BY s.Customer_ID
        ORDER BY s.Sale_Date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total,
    AVG(s.Amount) OVER (
        PARTITION BY s.Customer_ID
        ORDER BY s.Sale_Date
        RANGE BETWEEN INTERVAL '3' DAY PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_3Days
FROM Sales s
JOIN Customer c ON s.Customer_ID = c.Customer_ID
ORDER BY s.Customer_ID, s.Sale_Date;
--Navigation
SELECT
    s.Customer_ID,
    c.Customer_Name,
    s.Sale_Date,
    s.Amount,
    LAG(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date) AS Prev_Amount,
    LEAD(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date) AS Next_Amount,
    ROUND(
        (s.Amount - LAG(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date)) 
        / NULLIF(LAG(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date), 0) * 100,
    2) AS Growth_Percent
FROM Sales s
JOIN Customer c ON s.Customer_ID = c.Customer_ID
ORDER BY s.Customer_ID, s.Sale_Date;
--Distribution
SELECT
    s.Customer_ID,
    c.Customer_Name,
    s.Sale_Date,
    s.Amount,
    LAG(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date) AS Prev_Amount,
    LEAD(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date) AS Next_Amount,
    ROUND(
        (s.Amount - LAG(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date)) 
        / NULLIF(LAG(s.Amount, 1) OVER (PARTITION BY s.Customer_ID ORDER BY s.Sale_Date), 0) * 100,
    2) AS Growth_Percent
FROM Sales s
JOIN Customer c ON s.Customer_ID = c.Customer_ID
ORDER BY s.Customer_ID, s.Sale_Date;