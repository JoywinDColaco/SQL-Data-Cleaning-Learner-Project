-- DATA CLEANING (LEARNER PROJECT)

# Looking at the given data
USE world_layoffs;

SELECT *
FROM layoffs;

# DATA CLEANING PROCEDURE
-- 1. Remove Duplicates
-- 2. Standardize Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns or Rows

# Creating a staging
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Removing Duplicates

# Table Preview
SELECT *
FROM layoffs_staging;

# Eliminating duplicates with the help of a row_no
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_no` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_no
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_no > 1;

# New Table Preview
SELECT *
FROM layoffs_staging2;

-- 2. Standardizing Data

# Preview Table
SELECT *
FROM layoffs_staging2;

# Trimming Unnecessary Blank Spaces in the company Column
UPDATE layoffs_staging2
SET company = TRIM(company);

# Sticking to one description of the Industry
UPDATE layoffs_staging2
SET industry = 'Crypto' # done based on trends seen in table
WHERE industry LIKE 'Crypto%';

# Fixing almost similar matches which shouldn't be treated as different
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country) # done based on trends seen in table
WHERE country LIKE 'United States%';

# Changing the type of date column
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Null Values or blank values

# Populating Blanks or Nulls using table trends
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. Remove Any Columns or Rows

# Preview Table
SELECT *
FROM layoffs_staging2;

# Removing the rows where both total_laid_off and percentage_laid_off IS NULL
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

# Remove the row column
ALTER TABLE layoffs_staging2
DROP COLUMN row_no;