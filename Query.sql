--Q1: In 2007, what were the names of our top 6  paying clients, how many monthly payments did they make, and how much money did they pay in total?--

SELECT 
  DATE_TRUNC('month', pa.payment_date) "Payment date", 
  cu.first_name || ' ' || cu.last_name "Coustmer Full name", 
  COUNT(pa.amount) "Pay Counter per month", 
  SUM(pa.amount) "Amount of payment" 
FROM 
  payment AS pa 
  JOIN customer AS cu ON cu.customer_id = pa.customer_id 
WHERE 
  cu.first_name || ' ' || cu.last_name IN (
    SELECT 
      sub1.full_name 
    FROM 
      (
        SELECT 
          SUM(pa.amount) Total, 
          cu.first_name || ' ' || cu.last_name full_name 
        FROM 
          payment AS pa 
          JOIN customer AS cu ON cu.customer_id = pa.customer_id 
        GROUP BY 
          2 
        ORDER BY 
          1 DESC 
        LIMIT 
          6
      ) sub1
  ) 
  AND (
    pa.payment_date BETWEEN '2007-01-01' 
    AND '2008-01-01'
  ) 
GROUP BY 
  2, 
  1 
ORDER BY 
  2, 
  3 DESC;


--Q2: Create a query to determine the total rental orders for each film genre.--
WITH Sub1 AS (
  SELECT 
    i.film_id 
  FROM 
    inventory i 
    JOIN rental ren ON ren.inventory_id = i.inventory_id
), 
Sub2 AS (
  SELECT 
    cat.name category_name, 
    fi.title film_title, 
    fi.film_id 
  FROM 
    film fi 
    JOIN film_category fcat ON fcat.film_id = fi.film_id 
    JOIN category cat ON cat.category_id = fcat.category_id
) 
SELECT 
  count(*) "Rental Count", 
  Sub2.category_name AS "Film Category" 
FROM 
  Sub2 
  JOIN Sub1 ON Sub2.film_id = Sub1.film_id 
GROUP BY 
  2 
ORDER BY 
  1 DESC;


 
/* Q3:
Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category. The resulting table should have three columns:
Category
Rental length category
Count

Solution:*/
SELECT 
  sub.name AS "Film Category", 
  sub.standard_quartile AS "Standard Quartile", 
  COUNT(*) AS "Rental Count" 
FROM 
  (
    SELECT 
      cat.name, 
      f.rental_duration, 
      NTILE(4) OVER(
        ORDER BY 
          f.rental_duration
      ) AS standard_quartile 
    FROM 
      category AS cat 
      JOIN film_category AS fcat ON cat.category_id = fcat.category_id 
      AND cat.name IN (
        'Animation', 'Children', 'Classics', 
        'Comedy', 'Family', 'Music'
      ) 
      JOIN film AS f ON f.film_id = fcat.film_id
  ) sub 
GROUP BY 
  1, 
  2 
ORDER BY 
  1, 
  2;


/*Q4:
We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for.ÊWrite a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.

Solution:*/
SELECT 
  s.store_id, 
  EXTRACT(
    ISOYEAR 
    FROM 
      r.rental_date
  ) AS "Rental year", 
  EXTRACT(
    MONTH 
    FROM 
      r.rental_date
  ) AS "Rental month", 
  COUNT(r.rental_id) AS "Count rentals" 
FROM 
  rental r 
  JOIN staff USING (staff_id) 
  JOIN store s USING (store_id) 
GROUP BY 
  1, 
  2, 
  3 
ORDER BY 
  1, 
  2, 
  3;

