use ZOMATO
SELECT * FROM ZOMATO

---DELETING DUPLICATES
 WITH DUPLICATES AS (
 SELECT *, ROW_NUMBER() OVER (PARTITION BY RESTAURANT_ID ORDER BY RESTAURANT_ID) AS ROW
 FROM ZOMATO )
 DELETE FROM ZOMATO
 WHERE Restaurant_ID IN (SELECT Restaurant_ID FROM DUPLICATES WHERE ROW>1)

 --DELETING UNNECESSARY ROWS
DELETE FROM ZOMATO
WHERE Country_Code NOT IN (1,214);

--delete a column
ALTER table zomato
drop column [INDEX]

--Checking datatype
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ZOMATO' AND COLUMN_NAME = 'Rank_class';

--Maximizing The length of VARCHAR
ALTER TABLE ZOMATO
ALTER COLUMN rank_class VARCHAR(100);  

--ADD A COLUMN Country
ALTER TABLE ZOMATO
ADD Country VARCHAR
UPDATE ZOMATO
SET Country =
CASE 
WHEN Country_Code = 1 THEN 'INDIA'
WHEN Country_Code = 214 THEN 'UAE'
ELSE null
END 
SELECT * FROM ZOMATO

--Converting currencies to a common unit
ALTER TABLE ZOMATO
ADD COMMON_CURRENCY_PRICE FLOAT;
UPDATE ZOMATO
SET COMMON_CURRENCY_PRICE =
CASE
WHEN CURRENCY = 'Emirati Diram(AED)' THEN AVERAGE_COST_FOR_TWO * 23.58
WHEN CURRENCY ='Indian Rupees(Rs.)' THEN AVERAGE_COST_FOR_TWO
ELSE NULL
END 
select * from ZOMATO


--To understand the restaurants price range in india
WITH INDIA AS (
    SELECT price_range, ROUND(AVG(COMMON_CURRENCY_PRICE), 2) AS avg_price, COUNT(restaurant_id) AS total_restaurants 
    FROM zomato
    WHERE Country_Code = 1
    GROUP BY Price_range ),
UAE AS (
    SELECT price_range, ROUND(AVG(COMMON_CURRENCY_PRICE), 2) AS avg_price, COUNT(restaurant_id) AS total_restaurants 
    FROM zomato
    WHERE Country_Code = 214
    GROUP BY Price_range )

SELECT A.*, B.*
FROM INDIA A
FULL JOIN UAE B ON A.price_range = B.price_range;

SELECT * FROM ZOMATO

--ADD A COLUMN RATING CLASS
ALTER TABLE ZOMATO
ADD RANK_CLASS VARCHAR

UPDATE ZOMATO
SET RANK_CLASS =
    CASE
        WHEN AGGREGATE_RATING >= 4 THEN 'Very Good'  
        WHEN AGGREGATE_RATING BETWEEN 3 AND 3.99 THEN 'Average'    
        WHEN AGGREGATE_RATING BETWEEN 1 AND 2.99 THEN 'Poor' 
        ELSE 'No Rating'  
    END;


--Find areas with the highest aggregate rating 
SELECT CITY,LOCALITY,COUNTRY,ROUND(AGGREGATE_RATING,2) AS AGG_RATING,RANK() OVER(PARTITION BY COUNTRY,CITY ORDER BY AGGREGATE_RATING DESC) AS HIGHEST_RATING
FROM ZOMATO
WHERE RANK_CLASS='VERY GOOD'
GROUP BY City,Locality,AGGREGATE_RATING,COUNTRY 
--Find areas with the lowest aggregate rating 
SELECT CITY,LOCALITY,COUNTRY,ROUND(AGGREGATE_RATING,2) AS AGG_RATING,RANK() OVER(PARTITION BY COUNTRY,CITY ORDER BY AGGREGATE_RATING) AS LOWEST_RATING
FROM ZOMATO
WHERE RANK_CLASS='POOR'
GROUP BY City,Locality,AGGREGATE_RATING,COUNTRY

--CATEGORISING THE RESTAURANTS IN INDIA ON THE BASIS OF AGGREGATE RATING
SELECT TOP 5 * FROM ZOMATO

SELECT A.CITY,A.VERYGOOD_RESTAURANTS,B.POOR_RESTAURANTS,C.AVERAGE_RESTAURANTS
FROM (
SELECT CITY,COUNT(RESTAURANT_NAME) AS VERYGOOD_RESTAURANTS
FROM ZOMATO 
WHERE RANK_CLASS='VERY GOOD' AND Country_Code=1
GROUP BY City ) A

FULL JOIN ( 
SELECT CITY,COUNT(RESTAURANT_NAME) AS POOR_RESTAURANTS
FROM ZOMATO 
WHERE RANK_CLASS='POOR'AND Country_Code=1
GROUP BY City) B

ON A.CITY = B.CITY

FULL JOIN (
SELECT CITY, COUNT(RESTAURANT_NAME) AS AVERAGE_RESTAURANTS
FROM ZOMATO
WHERE RANK_CLASS='AVERAGE' AND Country_Code=1
GROUP BY City) C
ON A.CITY = C.CITY OR B.CITY = C.CITY

SELECT CITY, COUNT(DISTINCT CITY)  AS TOTALCITY, COUNT(DISTINCT Restaurant_Name) AS TOTAL FROM ZOMATO
WHERE COUNTRY_CODE =1 
GROUP BY City
ORDER BY TOTAL DESC


--CREATING A TABLE CITY_CATEGORY TO DIVIDE CITIES INTO METROPOLITAN,TIER 2 & TIER 3
CREATE TABLE City_Categories (
    City VARCHAR(50) PRIMARY KEY,
    Category VARCHAR(20) -- Values: 'Metropolitan', 'Tier 2', 'Tier 3'
);

INSERT INTO City_Categories (CITY,Category) 
VALUES 
('New Delhi','Metropolitan'),
('Gurgaon', 'Metropolitan'),
('Noida', 'Metropolitan'),
('Faridabad', 'Metropolitan'),
('Ghaziabad', 'Metropolitan'),
('Mumbai', 'Metropolitan'),
('Pune', 'Metropolitan'),
('Bangalore', 'Metropolitan'),
('Chennai', 'Metropolitan'),
('Hyderabad', 'Metropolitan'),
('Kolkata', 'Metropolitan'),

-- Tier 2 Cities
('Ahmedabad', 'Tier 2'),
('Jaipur', 'Tier 2'),
('Lucknow', 'Tier 2'),
('Indore', 'Tier 2'),
('Bhopal', 'Tier 2'),
('Chandigarh', 'Tier 2'),
('Surat', 'Tier 2'),
('Vadodara', 'Tier 2'),
('Coimbatore', 'Tier 2'),
('Goa', 'Tier 2'),

-- Tier 3 Cities
('Amritsar', 'Tier 3'),
('Bhubaneshwar', 'Tier 3'),
('Guwahati', 'Tier 3'),
('Ludhiana', 'Tier 3'),
('Mangalore', 'Tier 3'),
('Agra', 'Tier 3'),
('Mysore', 'Tier 3'),
('Nagpur', 'Tier 3'),
('Nashik', 'Tier 3'),
('Patna', 'Tier 3'),
('Puducherry', 'Tier 3'),
('Allahabad', 'Tier 3'),
('Aurangabad', 'Tier 3'),
('Dehradun', 'Tier 3'),
('Kanpur', 'Tier 3'),
('Kochi', 'Tier 3'),
('Varanasi', 'Tier 3'),
('Vizag', 'Tier 3'),
('Ranchi', 'Tier 3'),
('Secunderabad', 'Tier 3'),
('Panchkula', 'Tier 3'),
('Mohali', 'Tier 3') ;

UPDATE City_Categories
SET Category = 'Tier 2'
WHERE City IN ('Faridabad', 'Ghaziabad');

UPDATE City_Categories
SET Category = 'Metropolitan'
WHERE City = 'Ahmedabad';


----BUSINESS QUESTION 1: IF METROPOLITAN CITIES ARE PERFORMING BETTER THAN THE TIER 2 AND TIER 3 CITIES?
----BY DISTRIBUTION OF AGGREGATE PERFORMNACE OF RESTAURANTS BY CITY CATEGORY CHECKING THROUGH COUNT ()
SELECT c.Category, 
       RANK_CLASS, 
       COUNT(RESTAURANT_ID) AS Total_Restaurants 
FROM ZOMATO z
JOIN City_Categories c ON z.City = c.City
WHERE z.Country_Code=1
GROUP BY c.Category, RANK_CLASS
ORDER BY c.Category, Total_Restaurants DESC;


----BUSINESS QUESTION 2: What are the factors that are contributing to Metropolitan cities success ACROSS CITIES?
--- FACTOR 1 : Average_Cost_for_two : Is there a pricing mismatch across cities?

SELECT c.Category, ROUND(AVG(Average_Cost_for_two), 2) AS Avg_Cost
FROM ZOMATO z
JOIN City_Categories c ON z.City = c.City
GROUP BY c.Category;

----OBSERVATION: Fewer restaurants IN TIER 3 may lead to MORE competitive pricing.
----INSIGHT: PEOPLE ARE MORE AWARE AND PRICE SENSITIVE IN METROPOLITAN AREA. 
----RECOMMENDATION: Zomato can focus on expanding budget options in Tier 3 while promoting premium dining in metropolitan areas.


--- FACTOR 2 : Has_Online_delivery
SELECT B.CATEGORY,A.Has_Online_delivery,COUNT(A.Has_Online_delivery) AS OFFERING_ONLINE_DELIVERY_OPTION,
SUM(COUNT(A.Has_Online_delivery)) OVER(PARTITION BY B.CATEGORY) AS TOTAL_RESTAURANTS,
(COUNT(A.Has_Online_delivery)*1.0/SUM(COUNT(A.Has_Online_delivery)) OVER(PARTITION BY B.CATEGORY))*100 AS PERCENTAGE_OF_TOTAL,
 SUM(COUNT(A.Has_Online_delivery)) OVER() AS TOTAL_NUMBER_OF_RESTAURANTS,
 (COUNT(A.Has_Online_delivery)*1.0/SUM(COUNT(A.Has_Online_delivery)) OVER())*100 AS OUT_OF_TOTAL_RESTAURANTS
FROM ZOMATO A 
JOIN City_Categories B
ON A.City=B.City
WHERE A.Country_Code=1
GROUP BY B.Category,A.Has_Online_delivery

--- FACTOR 3 : Has_TABLE_BOOKING
SELECT B.CATEGORY,A.Has_Table_booking, COUNT(A.Has_Table_booking) AS TABLE_BOOOKING,SUM(COUNT(A.Has_Table_booking)) OVER(PARTITION BY B.CATEGORY) AS RESTAURANTS,
SUM(COUNT(A.Has_Table_booking)) OVER(PARTITION BY B.CATEGORY) AS TOTAL_RESTAURANTS,
(COUNT(A.Has_Table_booking)*1.0/SUM(COUNT(A.Has_Table_booking)) OVER(PARTITION BY B.CATEGORY))*100 AS PERCENTAGE_OF_TOTAL,
 SUM(COUNT(A.Has_Table_booking)) OVER() AS TOTAL_NUMBER_OF_RESTAURANTS,
 (COUNT(A.Has_Table_booking)*1.0/SUM(COUNT(A.Has_Table_booking)) OVER())*100 AS OUT_OF_TOTAL_RESTAURANTS
FROM ZOMATO A
JOIN CITY_CATEGORIES B
ON A.CITY=B.CITY
WHERE A.Country_Code=1
GROUP BY B.Category,A.Has_Table_booking

--FACTOR 4 : NUMBER OF VOTES
SELECT * FROM ZOMATO 
SELECT B.CATEGORY,SUM(A.VOTES) AS TOTAL_VOTES
FROM ZOMATO A
JOIN  City_Categories B
ON A.CITY=B.City
where A.Country_Code=1
GROUP BY  B.Category


----BUSINESS QUESTION 3 : DOES HIGHER RATING = MORE VOTES ?
select A.RATING, A.AVG_VOTES_METRO,B.AVG_VOTES_TIER_2,C.AVG_VOTES_TIER_3
FROM (
select ROUND(AGGREGATE_RATING,0) AS RATING, AVG(VOTES) AS AVG_VOTES_METRO
FROM ZOMATO
JOIN City_Categories
on zomato.city=City_Categories.City
where category='metropolitan' and Country_Code=1
GROUP BY ROUND(AGGREGATE_RATING,0)) A

FULL JOIN 
(select ROUND(AGGREGATE_RATING,0) AS RATING, AVG(VOTES) AS AVG_VOTES_TIER_2
FROM ZOMATO
JOIN City_Categories
on zomato.city=City_Categories.City
where category='TIER 2'
and Country_Code=1
GROUP BY ROUND(AGGREGATE_RATING,0)) B

ON A.RATING=B.RATING

FULL JOIN 
( select ROUND(AGGREGATE_RATING,0) AS RATING, AVG(VOTES) AS  AVG_VOTES_TIER_3
FROM ZOMATO
JOIN City_Categories
on zomato.city=City_Categories.City
where category='TIER 3'
and Country_Code=1
GROUP BY ROUND(AGGREGATE_RATING,0)) C

ON C.RATING=B.RATING OR C.RATING=A.RATING
ORDER BY AVG_VOTES_METRO DESC,AVG_VOTES_TIER_2,AVG_VOTES_TIER_3

-- OBSERVATION: Poor-rated restaurants receive more votes than average-rated restaurants across all city categories (metro, tier 2, and tier 3).


----BUSINESS QUESTION 4 : Compare the total number of restaurants in each category → Are there just more poor-rated restaurants, leading to higher vote counts?

SELECT B.CATEGORY,A.RANK_CLASS, COUNT(A.RESTAURANT_ID) AS NUMBER_OF_RESTAURANTS,AVG(VOTES) AS AVERAGE_VOTES
FROM ZOMATO A
FULL JOIN City_Categories B
ON A.City = B.City
WHERE B.Category IS NOT NULL
AND A.Country_Code=1
GROUP BY B.CATEGORY, A.RANK_CLASS
ORDER BY B.CATEGORY, NUMBER_OF_RESTAURANTS

---Insight : Customers may be less inclined to review average restaurants but more likely to engage when dissatisfied.
--Insight : In metro cities , people prefer to engage with top-rated places rather than the large pool of average ones.

----BUSINESS QUESTION 5 : What are the the top cities with high online_deliver percentage?
WITH CTE AS (
select city,count(*) AS restaurants_offering_delivery, SUM(count(*)) OVER() AS total_restaurants
FROM ZOMATO
where Has_Online_delivery='yes' 
and Country_Code=1
group by City,Country_Code
)
select city, restaurants_offering_delivery, total_restaurants,(restaurants_offering_delivery * 1.0/total_restaurants)*100 AS PERCENTAGE
from CTE
ORDER BY PERCENTAGE DESC

----BUSINESS QUESTION 6 : Are cities with high online delivery usage also high in table bookings?
WITH online_delivery AS (
SELECT city, COUNT(*) AS restaurants_offering_delivery, SUM(COUNT(*)) OVER() AS total_restaurants_delivery
FROM ZOMATO
WHERE Has_Online_delivery = 'yes' AND Country_Code = 1
GROUP BY City ),

Table_booking AS (
SELECT city, COUNT(*) AS restaurants_offering_TableBooking, SUM(COUNT(*)) OVER() AS total_restaurants_booking
FROM ZOMATO
WHERE Has_Table_booking = 1 AND Country_Code = 1
GROUP BY City )
SELECT a.city,
       a.restaurants_offering_delivery,
       a.total_restaurants_delivery,
       b.restaurants_offering_TableBooking, 
       b.total_restaurants_booking,
       (a.restaurants_offering_delivery * 100.0 / a.total_restaurants_delivery) AS PERCENTAGE_delivery,
       (b.restaurants_offering_TableBooking * 100.0 / b.total_restaurants_booking) AS PERCENTAGE_booking
FROM online_delivery a
FULL JOIN Table_booking b
ON a.City = b.City
ORDER BY PERCENTAGE_booking DESC, PERCENTAGE_delivery desc;
---The top 5 cities with the highest percentage of restaurants offering online delivery are also the top cities for table booking.
---RECOMMENDATION: For Cities With High Online + Table Booking Zomato can recommend premium subscription for example ZOMATO GOLD.
---RECOMMENDATION: For Cities With High Online + Table Booking Zomato can Push loyalty programs for users who use both services.


---BUSINESS QUESTION 7 : What are the top 5 localities in each city where there is high user engagement and the rating_text is good,very good and excellent?

SELECT * FROM (

SELECT CITY,LOCALITY,HAS_TABLE_BOOKING,HAS_ONLINE_DELIVERY,AVG(Average_Cost_for_two) AS AVERAGE_COST,
sum(VOTES) AS TOTAL_VOTES,RANK() OVER(PARTITION BY CITY ORDER BY sum(VOTES) DESC) AS RANK
FROM ZOMATO
WHERE Country_Code=1 
AND Rating_text IN ('GOOD','VERY GOOD','EXCELLENT') 
GROUP BY CITY,LOCALITY,HAS_TABLE_BOOKING,HAS_ONLINE_DELIVERY) X
WHERE X . RANK < = 5 


----BUSINESS QUESTION 8 :  What are the top 5 localities in each city where there is LOW user engagement and the rating_text is NOT RATED,POOR and AVERAGE?

SELECT * FROM (

SELECT CITY,LOCALITY,HAS_TABLE_BOOKING,HAS_ONLINE_DELIVERY,AVG(Average_Cost_for_two) AS AVERAGE_COST,
sum(VOTES) AS TOTAL_VOTES, RANK() OVER(PARTITION BY CITY ORDER BY sum(VOTES) ASC ) AS RANK
FROM ZOMATO
WHERE Country_Code=1 
AND Rating_text IN ('NOT RATED','POOR','AVERAGE') 
GROUP BY CITY,LOCALITY,HAS_TABLE_BOOKING,HAS_ONLINE_DELIVERY) X

WHERE X . RANK < = 5 

---BUSINESS QUESTION 9 : Which cities have the highest number of low-rated restaurants and what factors contribute to poor ratings?

SELECT city, COUNT(*) AS total_restaurants,
COUNT(CASE WHEN Aggregate_rating < 3.5 THEN 1 END) AS low_rated_restaurant_count,
  (COUNT(CASE WHEN Aggregate_rating < 3.5 THEN 1 END) * 100.0 / COUNT(*)) AS percentage_low_rated
FROM ZOMATO
WHERE Country_Code = 1
GROUP BY city
ORDER BY percentage_low_rated DESC;
--Recommendation : Zomato can work with restaurants in these areas to improve service quality through feedback programs.

---BUSINESS QUESTION 10 : Which localities have a high number of restaurants but low engagement (low votes, low ratings)?
SELECT city, LOCALITY, COUNT(*) AS total_restaurants, 

COUNT(CASE WHEN Votes < 20 THEN 1 END) AS low_votes,  

ROUND(AVG(CASE WHEN Aggregate_rating < 3.0 THEN Aggregate_rating END), 2) AS avg_low_ratings

FROM ZOMATO

GROUP BY City, LOCALITY

HAVING COUNT(CASE WHEN Votes < 20 THEN 1 END) > 3 

AND ROUND(AVG(CASE WHEN Aggregate_rating < 3.0 THEN Aggregate_rating END), 2) < 3.0  

ORDER BY low_votes DESC, avg_low_ratings DESC;

---OBSERVATION : These are the localities where many restaurants might exist, but they are failing to engage customers (fewer votes) and provide quality service (low ratings).
