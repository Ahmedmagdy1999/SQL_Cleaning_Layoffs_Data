-- Cleaning_Data project

SELECT * 
FROM layoffs;


--  We made a copy of the original table to avoid any mistakes in the raw data


CREATE TABLE layoffs_staging
LIKE layoffs;                        #  copy the columns

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *                             # copy all data in all columns and rows
FROM layoffs;




-- 1-Remove_Duplicates (Here without a unique identifier like id) so we will make some effort

SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date') AS row_num                     # Here we identified duplicates in the data
FROM layoffs_staging;


WITH duplicate_cte AS                                   # Here we have made a common table expression to delete duplicates
			(
				SELECT * ,
				ROW_NUMBER() OVER(
				PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,stage,country,funds_raised_millions, 'date') AS row_num
				FROM layoffs_staging
            )
DELETE
FROM duplicate_cte
WHERE row_num > 1;	           # This would work if there is a unique identifier like id column



-- We made a new table to delete duplicates becasue MYSQl doesn't support DELETE 

	CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,                       # Here we copied the columns from the table to make a new one with  a new column (row_num) as a unique identifier
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
	 

INSERT INTO  layoffs_staging2
SELECT * ,
		ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,stage,country,funds_raised_millions, 'date') AS row_num
		FROM layoffs_staging;


SET SQL_SAFE_UPDATES = 0;         # To turn off safe update mode so we can delete

DELETE
FROM layoffs_staging2             # Here we have deleted duplicates to protect our data
WHERE row_num > 1 ;


SET SQL_SAFE_UPDATES = 1;       # To turn on safe update mode

SELECT * 
FROM layoffs_staging2;




-- 2 Standardizing DATE


SELECT * 
FROM layoffs_staging2;

INSERT into  layoffs_staging2
SELECT * ,
		ROW_NUMBER() OVER(
		PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,stage,country,funds_raised_millions, 'date') AS row_num
		FROM layoffs_staging;
        
        
        
SELECT * 
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2; 
                                                                    # Here we have removed extra spaces in company column
UPDATE  layoffs_staging2
SET company =  TRIM(company);



SELECT * 
FROM layoffs_staging2
WHERE industry LIKE ' crypto';

UPDATE layoffs_staging2                                         
SET industry ="Crypto"                                        # Here we have corrected spelling 
WHERE industry LIKE " crypto%";

SELECT DISTINCT industry 
FROM layoffs_staging2;



SELECT * 
FROM layoffs_staging2;

SELECT location
FROM layoffs_staging2                                        # Here we have tried to check the column for any issue but there is not 
ORDER BY 1;



SELECT  DISTINCT country, TRIM( TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;                                                   

UPDATE layoffs_staging2                                                              # Here we have removed extra spaces in country column and any extra ch
SET country = TRIM( TRAILING '.' FROM country)
WHERE country LIKE 'United states%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1 ;




SELECT `date`,
STR_TO_DATE (`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE (`date`,'%m/%d/%Y');                                    # Here we have converted the date into standard date

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;                                                        # Here we have converted the date column from text into date

SELECT * 
FROM layoffs_staging2;




-- 3- Null values or blank values


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '' ;

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = null                                # Here we have converted every blank value into null value so we can handle it 
WHERE industry ='';

SELECT t1.industry, t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company=t2.company
AND t1.location = t2.location
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2                                      # Here we have replaced null values with matches valuse that related to the same company in the same location
ON t1.company=t2.company
SET t1.industry = t2.industry 
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE                                                      # Here we have deleted thoes becasue they won't be useful for our analysis
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;




-- 4- Remove any column we don't need 



ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
                                                                             # We don't need this column any more
SELECT *
FROM layoffs_staging2;




