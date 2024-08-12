SELECT *
FROM VideoGameSales



SELECT title, console, genre, publisher, total_sales FROM VideoGameSales;



--Data types of different columns
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'VideoGameSales';




--Replace NULL values in numeric columns with 0
SELECT
    title,
    console,
    genre,
    publisher,
    ISNULL(total_sales, 0) AS total_sales,
    ISNULL(na_sales, 0) AS na_sales,
    ISNULL(jp_sales, 0) AS jp_sales,
    ISNULL(pal_sales, 0) AS pal_sales,
    ISNULL(other_sales, 0) AS other_sales,
    ISNULL(critic_score, 0) AS critic_score,
    release_date,
    developer
INTO VideoGameSales_NonNull
FROM VideoGameSales;




SELECT *
FROM VideoGameSales_NonNull;




--Filter by genre
SELECT title, console, genre, total_sales
FROM VideoGameSales_NonNull
WHERE genre = 'Action';




--Filter by release date
SELECT title, console, genre, release_date
FROM VideoGameSales_NonNull
WHERE release_date >= '2015-01-01';




--Count the number of games per genre
SELECT genre, COUNT(*) AS num_games
FROM VideoGameSales_NonNull
GROUP BY genre;




--Sum of total sales by console
SELECT console, SUM(total_sales) AS total_sales
FROM VideoGameSales_NonNull
GROUP BY console;




--Average critic score by genre
SELECT genre, AVG(critic_score) AS avg_critic_score
FROM VideoGameSales_NonNull
GROUP BY genre;




--Top 5 games by total sales
SELECT TOP 5 title, console, total_sales
FROM VideoGameSales_NonNull
ORDER BY total_sales DESC;




--Top 3 publishers by total sales
SELECT TOP 3 publisher, SUM(total_sales) AS total_sales
FROM VideoGameSales_NonNull
GROUP BY publisher
ORDER BY total_sales DESC;




--Games with sales greater than 10 million in North America
SELECT title, console, na_sales
FROM VideoGameSales_NonNull
WHERE na_sales > 10;




--Total sales for each genre by year
SELECT genre, YEAR(release_date) AS year, SUM(total_sales) AS total_sales
FROM VideoGameSales_NonNull
GROUP BY genre, YEAR(release_date)
ORDER BY year, genre;




--Games with the highest critic scores for each genre
WITH GenreMaxScores AS (
    SELECT genre, MAX(critic_score) AS max_critic_score
    FROM VideoGameSales_NonNull
    GROUP BY genre
)
SELECT vgs.genre, vgs.title, vgs.critic_score
FROM VideoGameSales_NonNull vgs
JOIN GenreMaxScores gms
ON vgs.genre = gms.genre AND vgs.critic_score = gms.max_critic_score;




--Total sales and average critic score for each developer
SELECT developer, SUM(total_sales) AS total_sales, AVG(critic_score) AS avg_critic_score
FROM VideoGameSales_NonNull
GROUP BY developer;




--Games released in the last 5 years with critic scores above 8
SELECT title, console, genre, critic_score, release_date
FROM VideoGameSales_NonNull
WHERE critic_score > 8 AND release_date >= DATEADD(YEAR, -5, GETDATE());




--Identifying best-selling game per year
WITH YearlyBestSellers AS (
    SELECT
        title,
        console,
        genre,
        release_date,
        total_sales,
        ROW_NUMBER() OVER (PARTITION BY YEAR(release_date) ORDER BY total_sales DESC) AS sales_rank
    FROM VideoGameSales_NonNull
)
SELECT
    YEAR(release_date) AS year,
    title,
    console,
    genre,
    total_sales
FROM YearlyBestSellers
WHERE sales_rank = 1
ORDER BY year;



--Temp table to store top games by genre based on total sales
SELECT
    genre,
    title,
    total_sales,
    RANK() OVER (PARTITION BY genre ORDER BY total_sales DESC) AS sales_rank
INTO #TopGamesByGenre
FROM VideoGameSales_NonNull;
--Top ggame for each genre for temp table
SELECT *
FROM #TopGamesByGenre
WHERE sales_rank = 1
ORDER BY genre;

DROP TABLE #TopGamesByGenre;



--Calculate yearly sales by genre
WITH YearlySales AS (
    SELECT
        genre,
        YEAR(release_date) AS year,
        SUM(total_sales) AS total_sales
    FROM VideoGameSales_NonNull
    GROUP BY genre, YEAR(release_date)
)
--Store the CTE result in temp table
SELECT *
INTO #YearlySales
FROM YearlySales;

--Use temp table to find yearly sales above 1 million
SELECT genre, year, total_sales
FROM #YearlySales
WHERE total_sales > 1
ORDER BY genre, year;


DROP TABLE #YearlySales;
