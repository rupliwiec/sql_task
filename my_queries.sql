SELECT COUNT(*) as film_count, category_id FROM film_category GROUP BY category_id ORDER BY film_count DESC;

SELECT film_actor.actor_id, film.film_id, film.rental_rate FROM film_actor INNER JOIN film ON film.film_id = film_actor.film_id ORDER BY rental_rate DESC;

WITH actor_info AS (
    SELECT film_actor.actor_id, film.film_id, film.rental_rate, film.title
    FROM film_actor
    INNER JOIN film ON film.film_id = film_actor.film_id
    ORDER BY rental_rate DESC
)
SELECT DISTINCT actor.actor_id, actor.first_name, actor.last_name, actor_info.rental_rate
FROM actor
JOIN actor_info ON actor.actor_id = actor_info.actor_id
ORDER BY rental_rate DESC
LIMIT 10;
/* WITH rental_info(
    SELECT rental.rental_id, inventory.inventory_id, inventory.film_id
    FROM rental
    INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
)
SELECT */

SELECT *
FROM sales_by_film_category
WHERE total_sales > (SELECT AVG(total_sales) FROM sales_by_film_category)

SELECT film.film_id, film.title
FROM film
WHERE 
    NOT EXISTS(
        SELECT 1 FROM inventory WHERE film.film_id = inventory.film_id
    );