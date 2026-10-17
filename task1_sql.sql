--Output the number of movies in each category, sorted descending.

SELECT c.name, COUNT(fc.film_id) AS number_of_movies
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY number_of_movies DESC

--Output the 10 actors whose movies rented the most, sorted in descending order.

SELECT a.actor_id, a.first_name, a.last_name, COUNT(r.rental_id ) AS rented_number 
FROM film_actor fa
JOIN inventory i 
	ON fa.film_id = i.film_id 
JOIN rental r
	ON i.inventory_id = r.inventory_id 
JOIN actor a 
	ON fa.actor_id = a.actor_id 
GROUP BY a.actor_id, a.first_name, a.last_name 
ORDER BY rented_number DESC
LIMIT 10;


--Output the category of movies on which the most money was spent.

SELECT c.name, SUM(p.amount	) AS money_spent
FROM payment p 
JOIN rental r 
	ON p.rental_id = r.rental_id 
JOIN inventory i 
	ON r.inventory_id = i.inventory_id 
JOIN film_category fc 
	ON i.film_id = fc.film_id 
JOIN category c
	ON fc.category_id = c.category_id 
GROUP BY c.name
ORDER BY money_spent DESC
LIMIT 1;


--Print the names of movies that are not in the inventory. Write a query without using the IN operator.

SELECT f.title
FROM film f
LEFT JOIN inventory i 
	ON f.film_id = i.film_id
WHERE i.film_id IS NULL;


--Output the top 3 actors who have appeared the most in movies in the “Children” category. If several actors have the same number of movies, output all of them.

WITH ranked_actors AS (
SELECT a.first_name, a.last_name,a.actor_id, COUNT(fa.film_id) AS movies_count,
RANK() OVER(ORDER BY COUNT(fa.film_id) DESC) AS actor_rank
FROM actor a
JOIN film_actor fa 
	ON a.actor_id = fa.actor_id
JOIN film_category fc 
	ON fa.film_id = fc.film_id 
JOIN category c
	ON fc.category_id = c.category_id 
WHERE c.name = 'Children'
GROUP BY a.first_name, a.last_name, a.actor_id 
)
SELECT *
FROM ranked_actors 
WHERE actor_rank <= 3
ORDER BY movies_count DESC;


--Output cities with the number of active and inactive customers (active - customer.active = 1). Sort by the number of inactive customers in descending order.

SELECT ci.city, SUM(CASE WHEN cu.active = 1 THEN 1
	ELSE 0
	END) AS active_customers,
SUM(CASE WHEN cu.active = 0 THEN 1
	ELSE 0
	END) AS inactive_customers
FROM customer cu
JOIN address ad
	ON cu.address_id = ad.address_id 
JOIN city ci
	ON ad.city_id = ci.city_id 
GROUP BY ci.city_id, ci.city
ORDER BY inactive_customers DESC;


--Output the category of movies that have the highest number of total rental hours in the city (customer.address_id in this city) and that start with the letter “a”. Do the same for cities that have a “-” in them. Write everything in one query.

WITH city_category_hours AS (
	SELECT c.city_id, c.city, cat.name, 
	SUM(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600.0) AS rental_hours
	FROM rental r
	JOIN customer cu
    	ON r.customer_id = cu.customer_id
	JOIN address a
		ON cu.address_id = a.address_id 
	JOIN city c
		ON a.city_id = c.city_id 
	JOIN inventory i 
		ON r.inventory_id = i.inventory_id 
	JOIN film_category fc 
		ON i.film_id = fc.film_id 
	JOIN category cat
		ON fc.category_id = cat.category_id 
	WHERE c.city ILIKE 'a%' OR c.city LIKE '%-%'
	GROUP BY c.city_id,c.city, cat.name
),
ranked_categories AS (
	SELECT
    	city, 
    	city_id,
    	name,
    	rental_hours,
    	RANK() OVER (
        	PARTITION BY city_id
        	ORDER BY rental_hours DESC
    	) AS category_rank
	FROM city_category_hours
)
SELECT
    city,
    name,
    rental_hours,
    category_rank
FROM ranked_categories
WHERE category_rank = 1
ORDER BY rental_hours DESC, city;
