--Output the number of movies in each category, sorted descending.

SELECT 
    cat.name, 
    COUNT(fc.film_id) AS number_of_movies
FROM category cat
LEFT JOIN film_category fc
    ON cat.category_id = fc.category_id
GROUP BY cat.category_id, cat.name
ORDER BY number_of_movies DESC;


--Output the 10 actors whose movies rented the most, sorted in descending order.

WITH ranked_actors AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        COUNT(r.rental_id) AS rented_number,
        DENSE_RANK() OVER (
            ORDER BY COUNT(r.rental_id) DESC
        ) AS rental_rank
        -- DENSE_RANK keeps ties, so the top 10 distinct rental counts may include more than 10 actors.
    FROM film_actor fa
    JOIN inventory i
        ON fa.film_id = i.film_id
    JOIN rental r
        ON i.inventory_id = r.inventory_id
    JOIN actor a
        ON fa.actor_id = a.actor_id
    GROUP BY a.actor_id, a.first_name, a.last_name
)
SELECT
    actor_id,
    first_name,
    last_name,
    rented_number
FROM ranked_actors
WHERE rental_rank <= 10
ORDER BY rented_number DESC, actor_id;


--Output the category of movies on which the most money was spent.

WITH ranked_categories AS (
    SELECT
        cat.category_id,
        cat.name,
        SUM(p.amount) AS money_spent,
        DENSE_RANK() OVER (
            ORDER BY SUM(p.amount) DESC
        ) AS category_rank
    FROM payment p
    JOIN rental r
        ON p.rental_id = r.rental_id
    JOIN inventory i
        ON r.inventory_id = i.inventory_id
    JOIN film_category fc
        ON i.film_id = fc.film_id
    JOIN category cat
        ON fc.category_id = cat.category_id
    GROUP BY cat.category_id, cat.name
)
SELECT
    name,
    money_spent
FROM ranked_categories
WHERE category_rank = 1
ORDER BY money_spent DESC, name;


--Print the names of movies that are not in the inventory. Write a query without using the IN operator.

SELECT 
	f.title
FROM film f
LEFT JOIN inventory i 
	ON f.film_id = i.film_id
WHERE i.film_id IS NULL;


--Output the top 3 actors who have appeared the most in movies in the “Children” category. If several actors have the same number of movies, output all of them.

WITH ranked_actors AS (
    SELECT 
        a.first_name, 
        a.last_name,
        a.actor_id, 
        COUNT(fa.film_id) AS movies_count,
        DENSE_RANK() OVER(ORDER BY COUNT(fa.film_id) DESC) AS actor_rank
    FROM actor a
    JOIN film_actor fa
        ON a.actor_id = fa.actor_id
    JOIN film_category fc
        ON fa.film_id = fc.film_id
    JOIN category cat
        ON fc.category_id = cat.category_id
    WHERE cat.name = 'Children'
    GROUP BY a.first_name, a.last_name, a.actor_id
)
SELECT
    actor_id,
    first_name,
    last_name,
    movies_count
FROM ranked_actors
WHERE actor_rank <= 3
ORDER BY movies_count DESC, actor_id;


--Output cities with the number of active and inactive customers (active - customer.active = 1). Sort by the number of inactive customers in descending order.

SELECT 
	ci.city, 
	SUM(CASE WHEN cu.active = 1 THEN 1 ELSE 0 END) AS active_customers,
	SUM(CASE WHEN cu.active = 0 THEN 1 ELSE 0 END) AS inactive_customers
FROM city ci
LEFT JOIN address ad
    ON ci.city_id = ad.city_id
LEFT JOIN customer cu
    ON ad.address_id = cu.address_id
GROUP BY ci.city_id, ci.city
ORDER BY inactive_customers DESC, ci.city;


--Output the category of movies that have the highest number of total rental hours in the city (customer.address_id in this city) and that start with the letter “a”. Do the same for cities that have a “-” in them. Write everything in one query.

WITH city_cohorts AS (
    SELECT city_id, 'Starts with A' AS city_group
    FROM city
    WHERE city ILIKE 'a%'

    UNION ALL

    SELECT city_id, 'Contains hyphen' AS city_group
    FROM city
    WHERE city LIKE '%-%'
),
city_category_hours AS (
    SELECT
        cc.city_group,
        cat.name,
        SUM(
            EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600.0
        ) AS rental_hours
    FROM rental r
    JOIN customer cu
        ON r.customer_id = cu.customer_id
    JOIN address ad
        ON cu.address_id = ad.address_id
    JOIN city ci
        ON ad.city_id = ci.city_id
    JOIN city_cohorts cc
        ON ci.city_id = cc.city_id
    JOIN inventory i
        ON r.inventory_id = i.inventory_id
    JOIN film_category fc
        ON i.film_id = fc.film_id
    JOIN category cat
        ON fc.category_id = cat.category_id
    WHERE r.return_date IS NOT NULL
    GROUP BY cc.city_group, cat.category_id, cat.name
),
ranked_categories AS (
    SELECT
        city_group,
        name,
        rental_hours,
        DENSE_RANK() OVER (
            PARTITION BY city_group
            ORDER BY rental_hours DESC
        ) AS category_rank
    FROM city_category_hours
)
SELECT
    city_group,
    name,
    rental_hours,
    category_rank
FROM ranked_categories
WHERE category_rank = 1
ORDER BY rental_hours DESC, city_group, name;
