CREATE TABLE applestore_description_combined as 

select * FROm appleStore_description1

UNion all 

select * from appleStore_description2

union all 

select * from appleStore_description3

union ALL

select * from appleStore_description4

**EXPLORATORY DATA ANALYSIS**

--check the number of unique apps in both tablesApplestore

select count(distinct id) AS UniqueAppIDs
FROM AppleStore

select count(distinct id) AS UniqueAppIDs
FROM applestore_description_combined

--check for any missing values

select count(*) MissingValues
FROM AppleStore
WHERE track_name is NULL OR user_rating IS NULL OR prime_genre is NULL

select count(*) MissingValues
FROM applestore_description_combined
WHERE app_desc is NULL

--find out the number of apps per genre

select prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--get an overview of the apps ratings

select min(user_rating) as MinRating,
       max(user_rating) AS MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

--get the distribution of app prices

select
   (price / 2) AS PriceBinStart,
   ((price / 2) *2) +2 AS PriceBinEnd,
    COunt(*) AS NumApps
FROM AppleStore
    
GROup by PriceBinStart
Order by PriceBinStart

** DATA ANALYSIS**

--determine whether paid apps have higher ratings then free apps

SELECT CASE
            WHEN price > 0 THEN 'Paid'
            ELSE 'Free'
         END AS App_Type,
         avg(user_rating) AS Avg_Rating
FROM AppleStore
Group By App_Type

--check if apps with more supported langauges have higher ratings

SElect case 
            when lang_num < 10 Then '<10 languages'
            when lang_num BETWEEN 10 and 30 then '10-30 languages'
            ELSE '>30 languages'
         END AS language_bucket,
         avg(user_rating) as Avg_Rating
from AppleStore
group by language_bucket
order by Avg_Rating DESC

--check genres with low ratings

Select prime_genre,
       avg(user_rating) As AVg_Rating
FROM AppleStore
GROUP BY prime_genre
order by Avg_Rating ASC
limit 10

--check if there is correlation between the length of the app description and the user rating

SELECT case
       when length(b.app_desc) <500 THEn 'Short'
       when length(b.app_desc) between 500 and 1000 then 'Medium'
       else 'Long'
    ENd As description_length_bucket,
    avg(a.user_rating) AS average_rating
from AppleStore as A
join applestore_description_combined as b
On a.id = b.id
group by description_length_bucket
order by average_rating desc

--check the top rated apps for each genre 

SELECT
   prime_genre,
   track_name,
   user_rating
from (
      select 
      prime_genre,
      track_name,
      user_rating,
      RANK() OVER(PARTITION by prime_genre order by user_rating desc, rating_count_tot desc) AS rank
      FROM 
      AppleStore
     ) AS a
where 
a.rank = 1
