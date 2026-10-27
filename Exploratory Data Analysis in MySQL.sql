-- Exploratory Data Analysis

-- Here we are going to explore the data and find trends or patterns or anything interesting like outliers.

-- 1. Exploring the Dataset

-- 2. Identifying Maximum Layoffs

-- 3. Companies That Laid Off 100% of Their Workforce

-- 4. Comparing Layoffs With Company Funding

-- 5. Companies With the Highest Total Layoffs

-- 6. Identifying the Date Range

-- 7. Layoffs by Industry, Country, Year, and Company Stage.

-- 8. Monthly Layoff Trends

-- 9. Rolling Total of Layoffs

-- 10. Layoffs by Company and Year

-- -----------------------------------

-- Exploring the Dataset

SELECT *
FROM layoffs_staging2;

-- Verifying the MAX of total_laid_off and percentage_laid_off

-- Looking at Percentage to see how big these layoffs were 
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- If we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- Checking the MIN and MAX date for the layoffs.
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Checking per Industry, country, year, stage and compay.
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Rolling Total of Layoffs Per Month

SELECT substring(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC;

WITH Rolling_Total AS
(
SELECT substring(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC)
SELECT `MONTH`, total_off
,SUM(total_off) OVER (ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


-- Now let's look at that per year. 

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
From Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;