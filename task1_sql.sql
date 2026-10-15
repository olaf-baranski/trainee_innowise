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
