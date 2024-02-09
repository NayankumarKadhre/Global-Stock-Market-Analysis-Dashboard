# Global Stock Market Analysis Dashboard

## Introduction

This project involves the creation of an interactive Tableau dashboard to analyze global stock market trends, compare regional performance, and assess risks. The analysis covers 16 years of intraday data from 9 major indices and commodities, providing insights into stock market behavior and potential risk factors.

## Demo

[Link to Tableau Dashboard](https://public.tableau.com/views/GlobalStockMarket2008-2023_17067356959110/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link)

## Problem and Objective

The primary objective of this project is to gain comprehensive insights into global stock market trends, regional performance, and volatility. Key challenges addressed include processing intraday data, handling missing technical indicators, and deriving meaningful conclusions from diverse datasets. The project aims to deepen understanding of financial data analysis while honing skills in SQL and Tableau.

## Environment

- **Data Analysis Tools:** SQL, Tableau, Microsoft Excel
- **Database:** MySQL

## About Data

### Dataset Overview:

The dataset includes daily price and volume data from major global stock indices. Due to project objective and too many inconsistencies in the data, commodities data (GC=F, CL=F) and the BSE SENSEX (^BSESN) index were excluded from the analysis.

### Key Columns:

- **Date:** The date of the data point.
- **Open, High, Low, Close, Adj Close:** Various price indicators for the given date.
- **Volume:** The number of shares traded on the given date.

#### [Link to Kaggle Dataset](https://www.kaggle.com/datasets/pavankrishnanarne/global-stock-market-2008-present)

### Additional Calculations:

Additional fields for Bollinger Bands were calculated during the analysis to provide insights into trend reversals.
However, for the purpose of this analysis and the resulting dashboard, the Bollinger Bands data was not utilized.
Feel free to explore the calculated Bollinger Bands data in the SQL scripts and Tableau workbook for further insights or potential future enhancements.

## Repository Structure

The repository is organized as follows:

- **/SQL:** Contains the SQL query files in .txt and .sql format used for data modeling, cleaning, and transformation.
- **/Tableau:** Includes Tableau workbook file for the interactive dashboard.
- **/Data:** Stores the raw and processed datasets.
- **/Screenshots:** Captures screenshots of the Tableau dashboard for a quick preview.

## References

- [Google Finance](https://finance.google.com/)
- [Yahoo Finance](https://finance.yahoo.com/)
- [NSE (National Stock Exchange) Website](https://www.nseindia.com/)
- Add youtube links
  
## Data Processing Tools

- [MySQL Workbench](https://www.mysql.com/products/workbench/)
- [Tableau Public](https://public.tableau.com/en-us/s/gallery/)

