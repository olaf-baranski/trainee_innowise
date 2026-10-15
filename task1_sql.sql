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
