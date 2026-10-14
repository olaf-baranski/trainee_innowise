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
