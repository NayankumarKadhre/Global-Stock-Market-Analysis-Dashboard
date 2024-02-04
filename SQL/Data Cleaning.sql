CREATE DATABASE global_stock_market;

USE global_stock_market;

-- Import Data using Table Data Import Wizard
SELECT * 
FROM globalstockcombinedcorrected 
LIMIT 1000;

ALTER TABLE globalstockcombinedcorrected 
RENAME COLUMN ï»¿Ticker TO Ticker;

ALTER TABLE globalstockcombinedcorrected 
MODIFY COLUMN `Date` DATE;

ALTER TABLE globalstockcombinedcorrected 
RENAME global_stock_market;

ALTER TABLE global_stock_market 
RENAME COLUMN `Adj Close` TO Adj_Close;

DESCRIBE global_stock_market;

SELECT * 
FROM global_stock_market 
limit 1000;

SELECT * 
FROM global_stock_market 
WHERE Ticker IS NULL OR 
	`Date` IS NULL OR 
	`Open` IS NUll OR 
    High IS NULL OR 
    Low IS NULL OR 
    `Close` IS NULL OR 
    Adj_Close IS NULL OR 
    Volume IS NULL;

ALTER TABLE global_stock_market RENAME COLUMN `Date` TO Trade_Date, 
	RENAME COLUMN `Open` TO Open_Price, 
	RENAME COLUMN `Close` TO Close_Price, 
	RENAME COLUMN `Adj_Close` TO Adj_Close_Price;
    
-- To make analysis simpler removing commodities ('GC=F', 'CL=F') Remove records with Ticker = ('GC=F', 'CL=F', '^BSESN')
DELETE FROM global_stock_market 
WHERE Ticker IN ('GC=F', 'CL=F', '^BSESN');

SELECT DISTINCT Ticker
FROM global_stock_market;

-- Cannot explain volumn = 0 for priod 2008-2012 for index NSEI, checked yahoo finance, google finance and NSE website, but same data
-- Will have to solve this issue as a missing data 
SELECT *
FROM global_stock_market
WHERE Ticker = '^NSEI' AND YEAR(Trade_Date) IN (2008, 2009, 2010, 2011, 2012);

ALTER TABLE global_stock_market
ADD COLUMN Region TEXT;

SET SQL_SAFE_UPDATES = 0;

UPDATE global_stock_market
SET Region = CASE 
                WHEN Ticker IN ('^NYA', '^IXIC', '^DJI', '^GSPC') THEN 'North America'
                WHEN Ticker IN ('^FTSE', '^N100') THEN 'Europe'
                WHEN Ticker IN ('^NSEI', '^N225', '000001.SS') THEN 'Asia'
                ELSE 'Unknown'
            END
WHERE Ticker IN ('^NYA', '^IXIC', '^FTSE', '^NSEI', '^N225', '000001.SS', '^N100', '^GSPC', '^DJI');

SELECT *
FROM global_stock_market
WHERE Region = 'Unknown';

-- validate columns for appropriate values 
SELECT * FROM global_stock_market
WHERE Open_Price < 0 OR Close_Price < 0 OR High < 0 OR Low < 0 OR Adj_Close_Price < 0 OR Volume < 0 
	OR Ticker NOT IN ('^NYA', '^IXIC', '^FTSE', '^NSEI', '^N225', '000001.SS', '^N100', '^GSPC', '^DJI')
	OR YEAR(Trade_Date) IS NULL 
    OR MONTH(Trade_Date) IS NULL 
    OR DAY(Trade_Date) IS NULL 
    OR Trade_Date NOT REGEXP '^[0-9]{4}-[0-1][0-9]-[0-3][0-9]$' 
    OR Trade_Date IS NULL
    OR YEAR(Trade_Date) IN (2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023);
 
-- Creating Seperate Tables for each Index 
CREATE TABLE nya_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^NYA'
ORDER BY Trade_Date ASC;

CREATE TABLE ixic_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^IXIC'
ORDER BY Trade_Date ASC;

CREATE TABLE ftse_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^FTSE'
ORDER BY Trade_Date ASC;

CREATE TABLE nsei_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^NSEI'
ORDER BY Trade_Date ASC;

CREATE TABLE n225_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^N225'
ORDER BY Trade_Date ASC;

CREATE TABLE sse_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '000001.SS'
ORDER BY Trade_Date ASC;

CREATE TABLE n100_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^N100'
ORDER BY Trade_Date ASC;

CREATE TABLE gspc_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^GSPC'
ORDER BY Trade_Date ASC;

CREATE TABLE dji_data AS 
SELECT * 
FROM global_stock_market
WHERE Ticker = '^DJI'
ORDER BY Trade_Date ASC;

-- Convert High, Low, Open price, Close price and Adjusted close price to same currency
-- The prices are across the indices are not in same currency, source - yahoo finance

-- ^NYA: USD
-- No conversion needed, already in USD

-- ^IXIC: USD
-- No conversion needed, already in USD

-- ^FTSE: GBP to USD (1 GBP = 1.27 USD)
UPDATE ftse_data
SET
    High = High * 1.27,
    Low = Low * 1.27,
    Close_Price = Close_Price * 1.27,
    Open_Price = Open_Price * 1.27,
    Adj_Close_Price = Adj_Close_Price * 1.27;

-- ^NSEI: INR to USD (1 INR = 0.012 USD)
UPDATE nsei_data
SET
    High = High * 0.012,
    Low = Low * 0.012,
    Close_Price = Close_Price * 0.012,
    Open_Price = Open_Price * 0.012,
    Adj_Close_Price = Adj_Close_Price * 0.012;

-- ^N225: JPY to USD (1 JPY = 0.0068 USD)
UPDATE n225_data
SET
    High = High * 0.0068,
    Low = Low * 0.0068,
    Close_Price = Close_Price * 0.0068,
    Open_Price = Open_Price * 0.0068,
    Adj_Close_Price = Adj_Close_Price * 0.0068;

-- 000001.SS: CNY to USD (1 CNY = 0.14 USD)
UPDATE sse_data
SET
    High = High * 0.14,
    Low = Low * 0.14,
    Close_Price = Close_Price * 0.14,
    Open_Price = Open_Price * 0.14,
    Adj_Close_Price = Adj_Close_Price * 0.14;

-- ^N100: EUR to USD (1 EUR = 1.08 USD)
UPDATE n100_data
SET
    High = High * 1.08,
    Low = Low * 1.08,
    Close_Price = Close_Price * 1.08,
    Open_Price = Open_Price * 1.08,
    Adj_Close_Price = Adj_Close_Price * 1.08;

-- ^DJI: USD
-- No conversion needed, already in USD

-- Unsually high value for volume for the last date 
SELECT * FROM  sse_data
WHERE Trade_Date = "2023-07-28";

-- Jul 28, 2023	3,206.74	3,280.28	3,200.99	3,275.93	3,275.93	411,100
-- Data checked and collected from yahoo finance
UPDATE sse_data
SET Volume = 411100 
WHERE Trade_Date = "2023-07-28";

-- Unsually low value for volume 
SELECT * FROM  sse_data
WHERE Trade_Date = "2022-04-28";

-- Apr 28, 2022	2,945.81	2,991.51	2,936.79	2,975.48	2,975.48	100
-- Update to 423500 - Value calculated in Excel by Taking the Average of 1 value above and 1 value below of the value 100
-- Data checked and collected from yahoo finance for the SSE composite index
UPDATE sse_data
SET Volume = 423500 
WHERE Trade_Date = "2022-04-28";

-- Add technical indicators: MA50, MA200, Bollinger Bands(SMA20, UBB, LBB), Previous_Day_Close_Price, Change_in_Price, Percent_Change_in_Price, Previous_Day_Volume, Change_in_Volume, Percent_Change_in_Volume
CREATE TABLE dji_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM dji_data;

CREATE TABLE ftse_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM ftse_data;

CREATE TABLE gspc_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM gspc_data;

CREATE TABLE ixic_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM ixic_data;

CREATE TABLE n100_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM n100_data;

CREATE TABLE n225_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM n225_data;

CREATE TABLE nsei_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM nsei_data;

CREATE TABLE nya_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM nya_data;

CREATE TABLE sse_data_updated AS
SELECT *,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MA50,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MA200,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS SMA20,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) + (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS UBB,
    AVG(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) - (2 * (STDDEV(Close_Price) OVER (ORDER BY Trade_Date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW))) AS LBB,
    LAG(Close_Price) OVER (ORDER BY Trade_Date) AS Previous_Day_Close_Price,
    (Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) AS Change_in_Price,
    CASE
        WHEN LAG(Close_Price) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Close_Price - LAG(Close_Price) OVER (ORDER BY Trade_Date)) / LAG(Close_Price) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Price,
    LAG(Volume) OVER (ORDER BY Trade_Date) AS Previous_Day_Volume,
    (Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) AS Change_in_Volume,
    CASE
        WHEN LAG(Volume) OVER (ORDER BY Trade_Date) <> 0
        THEN ROUND(((Volume - LAG(Volume) OVER (ORDER BY Trade_Date)) / LAG(Volume) OVER (ORDER BY Trade_Date)) * 100, 5)
        ELSE NULL
    END AS Percent_Change_in_Volume
FROM sse_data;

-- Check data 
SELECT * FROM dji_data_updated;
SELECT * FROM ftse_data_updated;
SELECT * FROM gspc_data_updated;
SELECT * FROM ixic_data_updated;
SELECT * FROM n100_data_updated;
SELECT * FROM n225_data_updated;
SELECT * FROM nsei_data_updated;
SELECT * FROM nya_data_updated;
SELECT * FROM sse_data_updated;

-- Handle Volume = 0 
SELECT AVG(Volume) FROM n100_data_updated WHERE Volume > 0;
UPDATE n100_data_updated
SET Volume = 261159637.6080
WHERE Volume = 0;

SELECT AVG(Volume) FROM n225_data_updated WHERE Volume > 0;
UPDATE n225_data_updated
SET Volume = 120000930.7419
WHERE Volume = 0;

SELECT AVG(Volume) FROM nsei_data_updated WHERE Volume > 0;
UPDATE nsei_data_updated
SET Volume = 299151.7780
WHERE Volume = 0;

SELECT AVG(Volume) FROM nya_data_updated WHERE Volume > 0;
UPDATE nya_data_updated
SET Volume = 4106963177.5949
WHERE Volume = 0;

-- DROP TABLE IF EXISTS dji_data_updated;
-- DROP TABLE IF EXISTS ftse_data_updated;
-- DROP TABLE IF EXISTS gspc_data_updated;
-- DROP TABLE IF EXISTS ixic_data_updated;
-- DROP TABLE IF EXISTS n100_data_updated;
-- DROP TABLE IF EXISTS n225_data_updated;
-- DROP TABLE IF EXISTS nsei_data_updated;
-- DROP TABLE IF EXISTS nya_data_updated;
-- DROP TABLE IF EXISTS sse_data_updated;
-- DROP TABLE IF EXISTS global_stock_market_updated;

-- Combine all the tables 
CREATE TABLE global_stock_market_updated AS
SELECT * FROM dji_data_updated
UNION ALL
SELECT * FROM ftse_data_updated
UNION ALL
SELECT * FROM gspc_data_updated
UNION ALL
SELECT * FROM ixic_data_updated
UNION ALL
SELECT * FROM n100_data_updated
UNION ALL
SELECT * FROM n225_data_updated
UNION ALL
SELECT * FROM nsei_data_updated
UNION ALL
SELECT * FROM nya_data_updated
UNION ALL
SELECT * FROM sse_data_updated;

SELECT * FROM global_stock_market_updated;

DESCRIBE global_stock_market_updated;

SELECT DISTINCT Ticker FROM global_stock_market_updated;

-- Calculate Total Return for the period 2008-2023
SELECT Ticker, SUM(Percent_Change_in_Price) AS Total_Percent_Change
FROM global_stock_market_updated
WHERE Ticker IN ('^NYA', '^IXIC', '^FTSE', '^NSEI', '^N225', '000001.SS', '^N100', '^DJI', '^GSPC')
GROUP BY Ticker;

-- Calculate Volatility for the period of 1 year july 2022-july 2023
SELECT Ticker, ROUND(STDDEV(Percent_Change_in_Price),2) AS Volatility
FROM global_stock_market_updated
WHERE Ticker IN ('^NYA', '^IXIC', '^FTSE', '^NSEI', '^N225', '000001.SS', '^N100', '^DJI', '^GSPC') and Trade_Date between "2022-07-28" AND "2023-07-28"
GROUP BY Ticker;