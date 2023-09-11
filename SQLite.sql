CREATE TABLE applestore_description_combined AS 

SELECT * FROM appleStore_description1

UNION ALL 

SELECT * FROM appleStore_description2

UNION ALL 

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS**

--check the number of unique apps in both tablesApplestore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM applestore_description_combined

--check for any missing values

SELECT COUNT(*) MissingValues
FROM AppleStore
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL

SELECT COUNT(*) MissingValues
FROM applestore_description_combined
WHERE app_desc IS NULL

--find out the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--get an overview of the apps ratings

SELECT min(user_rating) AS MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

--get the distribution of app prices

SELECT
   (price / 2) AS PriceBinStart,
   ((price / 2) *2) +2 AS PriceBinEnd,
    COUNT(*) AS NumApps
FROM AppleStore
    
GROUP BY PriceBinStart
Order BY PriceBinStart

** DATA ANALYSIS**

--determine whether paid apps have higher ratings then free apps

SELECT CASE
            WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
         END AS App_Type,
         avg(user_rating) AS Avg_Rating
FROM AppleStore
Group BY App_Type

--check if apps with more supported langauges have higher ratings

SELECT CASE 
            WHEN lang_num < 10 THEN '<10 languages'
            WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
         END AS language_bucket,
         avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

--check genres with low ratings

SELECT prime_genre,
       avg(user_rating) AS AVg_Rating
FROM AppleStore
GROUP BY prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10

--check if there is correlation between the length of the app description and the user rating

SELECT CASE
       WHEN length(b.app_desc) <500 THEN 'Short'
       WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
       ELSE 'Long'
    END AS description_length_bucket,
    avg(a.user_rating) AS average_rating
FROM AppleStore AS A
JOIN applestore_description_combined AS b
ON a.id = b.id
GROUP BY description_length_bucket
ORDER average_rating DESC

--check the top rated apps for each genre 

SELECT
   prime_genre,
   track_name,
   user_rating
FROM (
      SELECT 
      prime_genre,
      track_name,
      user_rating,
      RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
      FROM 
      AppleStore
     ) AS a
WHERE 
a.rank = 1
