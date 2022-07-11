IF OBJECT_ID('dbo.ProductCostSales') IS NOT NULL
    BEGIN
            DROP TABLE dbo.ProductCostSales 
    END
    
SELECT DISTINCT

    pc.ProductCategoryID as category_id,
    pc.Name as product_name,
    p.ProductID as product_id,
    ProductNumber as product_model,
    Color,
    StandardCost as cost,
    ListPrice as list_price,
    OrderQty as order_quantity,
    UnitPrice as sales_price,
    UnitPriceDiscount as discount,
    LineTotal as total_price,
    AddressType,
    City,
    CompanyName as company,
    StateProvince,
    CountryRegion

INTO ProductCostSales 

FROM SalesLT.ProductCategory pc

LEFT JOIN SalesLT.Product p ON p.ProductCategoryID = pc.ProductCategoryID
LEFT JOIN SalesLT.SalesOrderDetail sd ON p.ProductID = sd.ProductID
LEFT JOIN SalesLT.SalesOrderHeader sh ON sd.SalesOrderID = sh.SalesOrderID
INNER JOIN SalesLT.CustomerAddress ca ON sh.CustomerID = ca.CustomerID
INNER JOIN SalesLT.Customer c ON ca.CustomerID = c.CustomerID
LEFT JOIN SalesLT.Address a ON ca.AddressID = a.AddressID


-----------------------------------------------------------------------------------------------------------


-- Now let see which company getting discount and in which product we that discount has been given and why



IF OBJECT_ID('dbo.ProfitAndLoss') IS NOT NULL
    BEGIN
            DROP TABLE dbo.ProfitAndLoss
    END
    



SELECT

    product_id,
    product_name,
    company,
    City,
    cost,
    list_price,
    sales_price,
    discount,
    (sales_price-(1-discount)) as final_price,
    ((sales_price-(1-discount))-cost) as profit_loss,
    (((sales_price-(1-discount))-cost)*order_quantity) as total_profit,
    order_quantity

INTO ProfitAndLoss
FROM dbo.ProductCostSales
WHERE discount > 0


-- There are a loss in some items, to be shown in the dashboard


-------------------------------------------------------------------------------------------


-- Let see if we get profit from that companies in total, maybe we loss in some items but getting profit in other


IF OBJECT_ID('dbo.accounts_profit_withDiscount') IS NOT NULL
    BEGIN
            DROP TABLE dbo.accounts_profit_withDiscount
    END



SELECT company,

    SUM(list_price) as total_list_price,
    SUM(sales_price) as total_sales,
    SUM(discount) as total_discount,
    SUM(total_profit) as total_lossOrProfit,
    AVG(total_profit) as lossOrProfit_average

INTO accounts_profit_withDiscount
FROM dbo.ProfitAndLoss
GROUP BY company
ORDER BY total_lossOrProfit ASC;

-- We got loss recorded in 10 accounts

--------------------------------------------------------------------------------------


-- Let see which products losses 


IF OBJECT_ID('dbo.product_profit_withDiscount') IS NOT NULL
    BEGIN
            DROP TABLE dbo.product_profit_withDiscount
    END

    
SELECT 
    product_name,
    SUM(list_price) as total_list_price,
    SUM(sales_price) as total_sales,
    SUM(discount) as total_discount,
    SUM(total_profit) as total_lossOrProfit,
    AVG(total_profit) as lossOrProfit_average

INTO product_profit_withDiscount
FROM dbo.ProfitAndLoss
GROUP BY product_name
ORDER BY total_lossOrProfit ASC;



-- 5 product losses


-- Let see if we lossing also without discount


IF OBJECT_ID('dbo.Profit_withoutDiscount') IS NOT NULL
    BEGIN
            DROP TABLE dbo.Profit_withoutDiscount
    END

SELECT

    product_id,
    product_name,
    company,
    cost,
    list_price,
    sales_price,
    discount,
    (sales_price-(1-discount)) as final_price,
    ((sales_price-(1-discount))-cost) as profit_loss,
    (((sales_price-(1-discount))-cost)*order_quantity) as total_profit,
    order_quantity

INTO Profit_withoutDiscount
FROM dbo.ProductCostSales
WHERE discount = 0

--SELECT* FROM Profit_withoutDiscount

-- the total of profit and loss by company

IF OBJECT_ID('dbo.accounts_profit_withoutDiscount') IS NOT NULL
    BEGIN
            DROP TABLE dbo.accounts_profit_withoutDiscount
    END



SELECT company,

    SUM(list_price) as total_list_price,
    SUM(sales_price) as total_sales,
    SUM(discount) as total_discount,
    SUM(total_profit) as total_lossOrProfit,
    AVG(total_profit) as lossOrProfit_average

INTO accounts_profit_withoutDiscount
FROM dbo.Profit_withoutDiscount
GROUP BY company
ORDER BY total_lossOrProfit ASC;

-- Results showing 17 account losss--------------------------------------------------


--By product without discount---------------------------------


IF OBJECT_ID('dbo.product_profit_withoutDiscount') IS NOT NULL
    BEGIN
            DROP TABLE dbo.product_profit_withoutDiscount
    END



SELECT 
    product_name,
    SUM(list_price) as total_list_price,
    SUM(sales_price) as total_sales,
    SUM(discount) as total_discount,
    SUM(total_profit) as total_lossOrProfit,
    AVG(total_profit) as lossOrProfit_average

INTO product_profit_withoutDiscount
FROM dbo.Profit_withoutDiscount
GROUP BY product_name
ORDER BY total_lossOrProfit ASC;

-- 7 products increase the company loss even without discount ----------------------------------