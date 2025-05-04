# Database Name
CREATE DATABASE campaign_analysis;
USE campaign_analysis;

# Schema
CREATE TABLE campaign_performance (
    `Month` DATE,
    `Campaign_Name` VARCHAR(255),
    `Leads` INT,
    `Gross_Accepted` INT,
    `Duplicated` INT,
    `Errors` INT,
    `Gross_Profit` DECIMAL(10, 2),
    `Gross_Margin` DECIMAL(10, 4),
    `Gross_Cost` DECIMAL(10, 2),
    `Gross_Revenue` DECIMAL(10, 2),
    `Gross_Avg_Cost` DECIMAL(10, 2),
    `Gross_Avg_Revenue` DECIMAL(10, 2),
    `Net_Accepted` INT,
    `Net_Profit` DECIMAL(10, 2),
    `Net_Margin` DECIMAL(10, 4),
    `Net_Cost` DECIMAL(10, 2),
    `Net_Revenue` DECIMAL(10, 2),
    `Net_Avg_Cost` DECIMAL(10, 2),
    `Net_Avg_Revenue` DECIMAL(10, 2),
    `Pings_Accepted` INT,
    `Pings_Failed` INT,
    `Total_Pings` INT,
    `Ping_Post_Ratio` DECIMAL(10, 3),
    `Ping_Avg_Bid` DECIMAL(10, 3)
);


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Analysis2_Lead Prosper_Report_MTT(1-7)_Mar2024 to Jan2025.csv'
INTO TABLE campaign_performance
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select*from campaign_performance

## 1. Total gross profit by campaign
SELECT 
    Campaign_Name,
    SUM(Gross_Profit) AS Total_Gross_Profit
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Total_Gross_Profit DESC;

## 2. Lead Conversion Rate
SELECT 
    Campaign_Name,
    (SUM(Gross_Accepted) / SUM(Leads)) * 100 AS Conversion_Rate
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Conversion_Rate DESC;

## 3. Ping success rate
SELECT 
    Campaign_Name,
    (SUM(Pings_Accepted) / SUM(Total_Pings)) * 100 AS Ping_Success_Rate
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Ping_Success_Rate DESC;

## 4. Error rate
SELECT 
    Campaign_Name,
    (SUM(Errors) / SUM(Leads)) * 100 AS Error_Rate
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Error_Rate DESC;

## 5. Gross profit by month
SELECT 
    MONTHNAME(Month) AS Month_Name,
    SUM(Gross_Profit) AS Total_Gross_Profit
FROM campaign_performance
GROUP BY MONTHNAME(Month), MONTH(Month)
ORDER BY MONTH(Month);

## 6. Ping Average Bid vs. Conversion
SELECT 
    Campaign_Name,
    AVG(Ping_Avg_Bid) AS Avg_Ping_Bid,
    (SUM(Gross_Accepted) / SUM(Leads)) * 100 AS Conversion_Rate
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Avg_Ping_Bid DESC;

## 7. Gross profit margin
SELECT 
    Campaign_Name,
    AVG(Gross_Margin) * 100 AS Avg_Gross_Profit_Margin
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Avg_Gross_Profit_Margin DESC;

## 8. Net profit margin
SELECT 
    Campaign_Name,
    AVG(Net_Margin) * 100 AS Avg_Net_Profit_Margin
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Avg_Net_Profit_Margin DESC;

## 9. Highest Performing Campaigns (Top 5)
SELECT 
    Campaign_Name,
    SUM(Gross_Profit) AS Total_Gross_Profit
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Total_Gross_Profit DESC
LIMIT 5;

## 10. Lowest performing campaign (bottom 5)
SELECT 
    Campaign_Name,
    SUM(Gross_Profit) AS Total_Gross_Profit
FROM campaign_performance
GROUP BY Campaign_Name
ORDER BY Total_Gross_Profit ASC
LIMIT 5;

-- সমস্ত টেবিল ট্রাঙ্কেট করা
TRUNCATE TABLE campaign_performance;
TRUNCATE TABLE campaign_master_summary;

-- যদি স্কিমা সম্পূর্ণ ডিলিট করতে চান
DROP DATABASE IF EXISTS campaign_analysis;

## Campaign-based master table
CREATE TABLE master_analysis (
    Campaign_Name VARCHAR(255),
    Total_Gross_Profit DECIMAL(10, 2),
    Conversion_Rate DECIMAL(10, 2),
    Ping_Success_Rate DECIMAL(10, 2),
    Error_Rate DECIMAL(10, 2),
    Avg_Gross_Profit_Margin DECIMAL(10, 4),
    Avg_Net_Profit_Margin DECIMAL(10, 4)
);

INSERT INTO master_analysis (Campaign_Name, Total_Gross_Profit, Conversion_Rate, Ping_Success_Rate, Error_Rate, Avg_Gross_Profit_Margin, Avg_Net_Profit_Margin)
SELECT 
    Campaign_Name,
    SUM(Gross_Profit) AS Total_Gross_Profit,
    (CASE WHEN SUM(Leads) > 0 THEN (SUM(Gross_Accepted) / SUM(Leads)) * 100 ELSE 0 END) AS Conversion_Rate,
    (CASE WHEN SUM(Total_Pings) > 0 THEN (SUM(Pings_Accepted) / SUM(Total_Pings)) * 100 ELSE 0 END) AS Ping_Success_Rate,
    (CASE WHEN SUM(Leads) > 0 THEN (SUM(Errors) / SUM(Leads)) * 100 ELSE 0 END) AS Error_Rate,
    AVG(Gross_Margin) * 100 AS Avg_Gross_Profit_Margin,
    AVG(Net_Margin) * 100 AS Avg_Net_Profit_Margin
FROM campaign_performance
GROUP BY Campaign_Name;

select * from master_analysis

## Monthly master table
CREATE TABLE master_analysis_monthly (
    Campaign_Name VARCHAR(255),
    Month_Name VARCHAR(50),
    Total_Gross_Profit DECIMAL(10, 2)
);

INSERT INTO master_analysis_monthly (Campaign_Name, Month_Name, Total_Gross_Profit)
SELECT 
    Campaign_Name,
    MONTHNAME(Month) AS Month_Name,
    SUM(Gross_Profit) AS Total_Gross_Profit
FROM campaign_performance
GROUP BY Campaign_Name, MONTHNAME(Month), MONTH(Month)
ORDER BY Campaign_Name, MONTH(Month);

select * from master_analysis_monthly


## Add update trigger
DELIMITER //
CREATE TRIGGER update_master_analysis
AFTER INSERT ON campaign_performance
FOR EACH ROW
BEGIN
    -- Delete old data
    DELETE FROM master_analysis;

    -- Add new data
    INSERT INTO master_analysis (
        Campaign_Name, Total_Gross_Profit, Conversion_Rate, Ping_Success_Rate, Error_Rate,
        Avg_Gross_Profit_Margin, Avg_Net_Profit_Margin
    )
    SELECT 
        Campaign_Name,
        SUM(Gross_Profit) AS Total_Gross_Profit,
        (CASE WHEN SUM(Leads) > 0 THEN (SUM(Gross_Accepted) / SUM(Leads)) * 100 ELSE 0 END) AS Conversion_Rate,
        (CASE WHEN SUM(Total_Pings) > 0 THEN (SUM(Pings_Accepted) / SUM(Total_Pings)) * 100 ELSE 0 END) AS Ping_Success_Rate,
        (CASE WHEN SUM(Leads) > 0 THEN (SUM(Errors) / SUM(Leads)) * 100 ELSE 0 END) AS Error_Rate,
        AVG(Gross_Margin) * 100 AS Avg_Gross_Profit_Margin,
        AVG(Net_Margin) * 100 AS Avg_Net_Profit_Margin
    FROM campaign_performance
    GROUP BY Campaign_Name;
END //
DELIMITER ;

SELECT * FROM master_analysis;

