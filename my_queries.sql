/* 1. Вывести количество фильмов в каждой категории, отсортировать по убыванию. */
SELECT COUNT(*) as film_count, category_id 
FROM film_category 
GROUP BY category_id 
ORDER BY film_count DESC;

/* 2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию. */
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

/* 3. Вывести категорию фильмов, на которую потратили больше всего денег. */
SELECT *
FROM sales_by_film_category
WHERE total_sales > (SELECT AVG(total_sales) FROM sales_by_film_category);

/* 4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN. */
SELECT film.film_id, film.title
FROM film
WHERE 
    NOT EXISTS(
        SELECT 1 FROM inventory WHERE film.film_id = inventory.film_id
    );

/* Этот сделал чисто для себя */
WITH actor_category AS(
    SELECT fa.film_id, fa.actor_id, fc.category_id
    FROM film_actor fa
    INNER JOIN film_category fc ON fa.film_id = fc.film_id
    WHERE fc.category_id = 3
)
SELECT ac.actor_id, ac.first_name, ac.last_name, COUNT(*) AS actors_count
FROM actor ac
INNER JOIN actor_category acat ON ac.actor_id = acat.actor_id
GROUP BY ac.actor_id, ac.first_name, ac.last_name
HAVING COUNT(*) = (
    SELECT MAX(actors_count)
    FROM (
        SELECT
            ac.actor_id,
            COUNT(*) AS actors_count
        FROM
            actor ac
            INNER JOIN actor_category acat ON ac.actor_id = acat.actor_id
        GROUP BY
            ac.actor_id
    ) AS subquery
);

/* 5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. Если у нескольких актеров одинаковое кол-во фильмов, вывести всех. */
WITH actor_category AS(
    SELECT fa.film_id, fa.actor_id, fc.category_id
    FROM film_actor fa
    INNER JOIN film_category fc ON fa.film_id = fc.film_id
    WHERE fc.category_id = 3
)
SELECT ac.actor_id, ac.first_name, ac.last_name, COUNT(*) AS actors_count
FROM actor ac
INNER JOIN actor_category acat ON ac.actor_id = acat.actor_id
GROUP BY ac.actor_id, ac.first_name, ac.last_name
HAVING COUNT(*) BETWEEN 4 AND 7
ORDER BY actors_count DESC
LIMIT 3;

/* 6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). Отсортировать по количеству неактивных клиентов по убыванию. */
WITH address_customer AS (
    SELECT ad.address_id, ad.city_id, cu.active
    FROM public.address ad
    INNER JOIN customer cu ON ad.address_id = cu.address_id
)
SELECT ci.city_id, ci.city, ac.active
FROM city ci
INNER JOIN address_customer ac ON ci.city_id = ac.city_id
ORDER BY ac.active ASC;

/* 7. Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе.
Немного не понял условие, так что если будут ошибки, то поясни плиз. */
WITH film_rent_cat AS (
    SELECT fc.film_id, fc.category_id, f.rental_duration, f.title
    FROM film_category fc
    INNER JOIN film f ON fc.film_id = f.film_id
    WHERE f.title LIKE 'A%'
)
SELECT ci.city, frc.title, frc.category_id, frc.rental_duration,
SUM(rental_duration) OVER (PARTITION BY city ORDER BY category_id) AS cumulative_hours
FROM film_rent_cat frc, city ci
WHERE ci.city LIKE '%-%'
ORDER BY cumulative_hours DESC, city ASC;