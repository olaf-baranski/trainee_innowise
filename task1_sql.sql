--Output the number of movies in each category, sorted descending.

SELECT c.name, COUNT(fc.film_id) AS number_of_movies
FROM category c
JOIN film_category fc
	ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY number_of_movies DESC
