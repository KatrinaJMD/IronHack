USE TheFinal;

# Top 5 Customers by Total Quantity
SELECT c.client_id, c.CustomerID, SUM(s.Quantity) AS total_quantity
FROM customer c
INNER JOIN sales s ON c.client_id = s.client_id
GROUP BY c.client_id, c.CustomerID
ORDER BY total_quantity DESC
LIMIT 5;

# Top 5 Products by Total Sales
SELECT p.product_id, p.Product, SUM(s.Quantity) AS total_sales
FROM product p
INNER JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.Product
ORDER BY total_sales DESC
LIMIT 5;

# Sales per Month
SELECT i.YearMonth, SUM(s.Quantity) AS total_sales
FROM invoice i
INNER JOIN sales s ON i.invoice_id = s.invoice_id
GROUP BY i.YearMonth
ORDER BY i.YearMonth;

# Top 5 Selling Products for the Most Frequent Customer
SELECT s.client_id, p.Product, SUM(s.Quantity) AS total_quantity
FROM sales s
INNER JOIN product p ON s.product_id = p.product_id
WHERE s.client_id = (
    SELECT client_id 
    FROM (
        SELECT client_id, SUM(Quantity) AS total_quantity
        FROM sales s
        GROUP BY client_id
        ORDER BY total_quantity DESC
        LIMIT 1
    ) AS most_freq_customer
)
GROUP BY s.client_id, p.Product
ORDER BY total_quantity DESC
LIMIT 5;

# Total Sales per Country
SELECT c.Country, SUM(s.Quantity) AS total_sales
FROM customer c
INNER JOIN sales s ON c.client_id = s.client_id
GROUP BY c.Country
ORDER BY total_sales DESC;