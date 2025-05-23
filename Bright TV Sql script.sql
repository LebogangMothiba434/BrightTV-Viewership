--Checking duplicates from user profiles table
SELECT userid, COUNT(*) AS record_count
FROM user_profiles
GROUP BY userid
HAVING COUNT(*) > 1;
--Checking duplicates from viewership table
SELECT userid, channel2, recorddate2, COUNT(*) AS record_count
FROM viewership
GROUP BY userid, channel2, recorddate2
HAVING COUNT(*) > 1;
--Removing viewership duplicates (keeping 1 record for eah duplicate)
DELETE FROM viewership
WHERE (userid, channel2, recorddate2, duration_2) NOT IN (
  SELECT userid, channel2, recorddate2, duration_2
  FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY userid, channel2, recorddate2 ORDER BY duration_2 DESC) AS rn
    FROM viewership
  ) AS deduped
  WHERE rn = 1
);
--CLEANING DATA and joining the tables
create or replace Temporary table viewership_temp_tbl AS (
SELECT
A.Userid,
A.Name,
A.Surname,
A.Email,
CASE
WHEN A.Gender IS NULL OR A.Gender = 'None'THEN 'other'
ELSE A.Gender
END AS gender,
CASE
WHEN A.Race IS NULL OR A.Race = 'None' THEN 'other'
ELSE A.Race
END AS Race,
A.Age,
CASE
WHEN A.Province IS NULL OR A.Province = 'None' THEN 'other'
ELSE A.Province
END AS Province,
B.Channel2 AS Channel,
B.Recorddate2 AS Date,
B.Duration_2 AS Duration
FROM
user_profiles AS A
INNER JOIN VIEWERSHIP AS B
ON A.userid=B.userid
)
--
SELECT*
FROM VIEWERSHIP_TEMP_TBL;
--
SELECT*
FROM VIEWERSHIP_TEMP_TBL;
--Creating joined table to be included as a table on the tables in the Bright TV dataset
create table viewership_temp_tbl AS (
SELECT
A.Userid,
A.Name,
A.Surname,
A.Email,
CASE
WHEN A.Gender IS NULL OR A.Gender = 'None'THEN 'other'
ELSE A.Gender
END AS gender,
CASE
WHEN A.Race IS NULL OR A.Race = 'None' THEN 'other'
ELSE A.Race
END AS Race,
A.Age,
CASE
WHEN A.Province IS NULL OR A.Province = 'None' THEN 'other'
ELSE A.Province
END AS Province,
B.Channel2 AS Channel,
B.Recorddate2 AS Date,
B.Duration_2 AS Duration
FROM
user_profiles AS A
INNER JOIN VIEWERSHIP AS B
ON A.userid=B.userid
)
-- Converting UTC to SA time
UPDATE VIEWERSHIP_TEMP_TBL
SET date = CONVERT_TIMEZONE('UTC', 'Africa/Johannesburg', TO_TIMESTAMP(date, 'YYYY-MM-DD HH24:MI:SS.FF3'));
-- Adding time column
ALTER TABLE VIEWERSHIP_TEMP_TBL
ADD COLUMN Time TIME;
--Adding timestamp to time
UPDATE VIEWERSHIP_TEMP_TBL
SET Time= TO_CHAR(TO_TIMESTAMP(date, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'HH24:MI');
--Adding date column
ALTER TABLE VIEWERSHIP_TEMP_TBL
ADD COLUMN Date2 DATE;
--adding timestamp to date
UPDATE VIEWERSHIP_TEMP_TBL
SET Date2= TO_CHAR(TO_TIMESTAMP(date, 'YYYY-MM-DD HH24:MI:SS.FF3'), 'YYYY-MM-DD');
--
ALTER TABLE VIEWERSHIP_TEMP_TBL
DROP COLUMN DATE,
THE_DATE;
--
SELECT*
FROM VIEWERSHIP_TEMP_TBL;
--QUESTION 1
 --create age buckets
  SELECT
  CASE
    WHEN age = 0 THEN 'Not specified'
    WHEN age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN age BETWEEN 13 AND 19 THEN 'Teenagers'
    WHEN age BETWEEN 20 AND 24 THEN 'Young Adults'
    WHEN age BETWEEN 25 AND 34 THEN 'Early Adulthood'
    WHEN age BETWEEN 35 AND 44 THEN 'Mid Adulthood'
    WHEN age BETWEEN 45 AND 54 THEN 'Mature Adults'
    ELSE 'Seniors'
  END AS age_group,
COUNT (*) AS viewer_count
FROM VIEWERSHIP_TEMP_TBL
GROUP BY age_group
ORDER BY viewer_count DESC;
--Create time of day buckets
SELECT
  CASE 
    WHEN TO_TIME(Time) BETWEEN '00:00:00' AND '05:59:59' THEN 'Late Night'
    WHEN TO_TIME(Time) BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TO_TIME(Time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
    WHEN TO_TIME(Time) BETWEEN '18:00:00' AND '23:59:59' THEN 'Evening'
    ELSE 'Unknown'
  END AS time_bucket,
  COUNT(*) AS total_views,
FROM VIEWERSHIP_TEMP_TBL
GROUP BY time_bucket
ORDER BY total_views DESC;
--Group by province
SELECT
  province,
  COUNT(*) AS total_views,
FROM VIEWERSHIP_TEMP_TBL
GROUP BY province
ORDER BY total_views DESC;
--Most viewed channels
SELECT
  channel,
  COUNT(*) AS total_views,
FROM VIEWERSHIP_TEMP_TBL
GROUP BY channel
ORDER BY total_views DESC;
--views per day
SELECT
  date2,
  COUNT(*) AS views,
FROM VIEWERSHIP_TEMP_TBL
GROUP BY date2
ORDER BY date2;
--Grouping gender and age
SELECT 
  gender,
  CASE
    WHEN age = 0 THEN 'Not specified'
    WHEN age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN age BETWEEN 13 AND 19 THEN 'Teenagers'
    WHEN age BETWEEN 20 AND 24 THEN 'Young Adults'
    WHEN age BETWEEN 25 AND 34 THEN 'Early Adulthood'
    WHEN age BETWEEN 35 AND 44 THEN 'Mid Adulthood'
    WHEN age BETWEEN 45 AND 54 THEN 'Mature Adults'
    ELSE 'Seniors'
  END AS age_group,
  COUNT(*) AS viewer_count,
FROM VIEWERSHIP_TEMP_TBL
GROUP BY gender, age_group
ORDER BY age_group, gender;
--Viewrship by days
SELECT 
  DAYNAME(TO_DATE(date, 'YYYY/MM/DD')) AS day_of_week,
  COUNT(*) AS view_count
FROM VIEWERSHIP_TEMP_TBL
GROUP BY DAYNAME(TO_DATE(date, 'YYYY/MM/DD'))
ORDER BY view_count DESC;
--top users by watch time
SELECT  
 userid,
 SUM(DATE_PART('minute', Duration) * 60 + DATE_PART('second', Duration)) / 60 AS total_minutes_watched
FROM VIEWERSHIP_TEMP_TBL
GROUP BY userid
ORDER BY total_minutes_watched DESC
LIMIT 10;