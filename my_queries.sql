SELECT COUNT(*) as film_count, category_id FROM film_category GROUP BY category_id ORDER BY film_count DESC;

