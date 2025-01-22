# Cleaning Layoffs Data


## Table of Contents

- [Project Overview](#Project-Overview)
- [Data Sources](#Data-Sources)


### Project Overview

This process involved creating a backup of the original table, removing duplicates using window functions, and standardizing the data (e.g., correcting spelling, removing extra spaces, and converting dates). Null and blank values were handled by replacing blanks with nulls and filling in missing data where applicable. Unnecessary columns were removed to ensure the dataset was clean and optimized for analysis.

### Data Sources

Layoffs: The primary dataset used for this analysis is the "Cleaning layoffs data.sql" file, containing detailed information about layoffs in companies.

### Tools

- SQL - Data Cleaning
- MYSQL

### Data Cleaning/Preparation

1. Data loading in MySQL database
2. A backup Creation ( a copy of the original table was made to avoid any accidental data loss. )
3. Removing Duplicates - 
   ( used a window function and a common table expression (CTE) to identify and remove duplicate records, as MySQL didn’t support the DELETE function for this purpose - 
Created a new table to store the cleaned data, and added a unique identifier column (row_num) for each row. )

4. Data Standardizing - ( removed extra spaces in the company name column - 
Corrected spelling errors (e.g., “Crypto”) - 
Converted date values into a standard format and changed the column type from text to date for consistency. )

5. Handling null and blank values ( converted any blank values to NULL for easier handling - 
Replaced NULL values with appropriate match values from the same company and location - 
Removed irrelevant records that were unnecessary for analysis. )

 6. Column Cleanup ( removed unneeded columns that didn’t contribute to the analysis. )

### Some Of My Codes

```SQL

CREATE TABLE layoffs_staging
LIKE layoffs;                        

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *                             
FROM layoffs;

```
```sql 
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date') AS row_num                     
FROM layoffs_staging;


WITH duplicate_cte AS                                  
			(
				SELECT * ,
				ROW_NUMBER() OVER(
				PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,stage,country,funds_raised_millions, 'date') AS row_num
				FROM layoffs_staging
            )
DELETE
FROM duplicate_cte
WHERE row_num > 1;

```

```sql
SELECT `date`,
STR_TO_DATE (`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE (`date`,'%m/%d/%Y');                                   

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;

