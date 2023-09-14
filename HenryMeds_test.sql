-- Ans 1) 

Select c.CustomerName,
    count(o.OrderID) as order_count
from Customers c
    left join Orders o on c.CustomerID = o.CustomerID
group by c.CustomerName
order by order_count desc;


-- Ans 2)
UPDATE Customers
SET City = 'New York'
WHERE City = 'London'
    AND CustomerID IN (
        SELECT DISTINCT CustomerID
        FROM Orders
    );


-- Ans 3)
SELECT YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    SUM(UnitsSold) as total_units_sold
FROM Orders
GROUP BY YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY Year,
    Month;


-- Ans 4)
-- Note: This will include customers with no orders as well.
Select c.CustomerName,
    sum(o.TotalAmount) as total_order_amount
from Customers c
    left join Orders o on c.CustomerID = o.CustomerID
group by c.CustomerName
order by total_order_amount desc
limit 5;


-- Ans 5) 
-- Note: This will include customers with no orders as well.
Select c.CustomerName,
    sum(o.TotalAmount) as total_order_amount
from Customers c
    Left Join Orders o on c.CustomerID = o.CustomerID
where DATEDIFF(month, OrderDate, now()) <= 3
group by c.CustomerName
order by total_order_amount desc
limit 3;


-- Ans 6) 
-- Note: Assuming there is column ProductName in ProductReviews, since no ProductName column is there in any tables
WITH MonthlySales AS (
    SELECT p.ProductID,
        p.ProductName,
        DATE_TRUNC('month', o.OrderDate) AS OrderMonth,
        EXTRACT(
            YEAR
            FROM o.OrderDate
        ) AS OrderYear,
        SUM(o.UnitsSold) AS MonthlyUnitsSold
    FROM Orders o
        JOIN ProductReviews p ON o.ProductID = pr.ProductID
    GROUP BY p.ProductID,
        p.ProductName,
        OrderMonth,
        OrderYear
),
MonthlyGrowth AS (
    SELECT ProductID,
        ProductName,
        OrderMonth,
        OrderYear,
        MonthlyUnitsSold,
        LAG(MonthlyUnitsSold) OVER (
            PARTITION BY ProductID
            ORDER BY OrderYear,
                OrderMonth
        ) AS PreviousMonthUnitsSold
    FROM MonthlySales
)
SELECT m.ProductID,
    m.ProductName,
    m.OrderYear AS Year,
    m.OrderMonth AS Month,
    CASE
        WHEN PreviousMonthUnitsSold IS NULL
        OR PreviousMonthUnitsSold = 0 THEN 0
        ELSE (m.MonthlyUnitsSold - PreviousMonthUnitsSold) * 100.0 / PreviousMonthUnitsSold
    END AS SalesGrowthRate
FROM MonthlyGrowth m
ORDER BY m.ProductID,
    m.OrderYear,
    m.OrderMonth;
