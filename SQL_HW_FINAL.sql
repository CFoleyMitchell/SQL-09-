-- For My Information:
		-- USE Sakila;
		-- SHOW TABLES;
		-- SHOW COLUMNS FROM actor;

-- 1a. Display the first and last names of all actors from the table actor.

USE Sakila;
SELECT * FROM actor;

SELECT first_name, last_name
	FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

USE Sakila;

SELECT UPPER(CONCAT(first_name," ", last_name)) AS 'Actor Name'
	FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

USE Sakila;

SELECT actor_id, first_name, last_name
	FROM actor
	WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

USE Sakila;

SELECT first_name, last_name
	FROM actor
	WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

USE Sakila;

SELECT last_name, first_name
	FROM actor
	WHERE last_name LIKE '%LI%'
	ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
		
USE Sakila;
SELECT * FROM country;

SELECT country_id, country
	FROM country
	WHERE country
    IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

USE Sakila;

ALTER TABLE actor
	ADD COLUMN description BLOB
	AFTER last_name;

SELECT * FROM actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

USE Sakila;

ALTER TABLE actor
	DROP COLUMN description;

SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

USE Sakila;

SELECT last_name, COUNT(last_name) AS 'last_name_count'
	FROM actor
	GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

USE Sakila;

SELECT last_name, COUNT(last_name) AS 'last_name_count'
	FROM actor
	GROUP BY last_name
	HAVING `last_name_count` >=2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

USE Sakila;

-- Confirm GROUCHO WILLIAMS is in the table
SELECT * FROM actor
	WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- Change GROUCHO to HARPO
UPDATE actor
	SET first_name = 'HARPO' 
	WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- Confirm that GROUCHO WILLIAMS was Changed to HARPO WILLIAMS
SELECT * FROM actor
	WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- **4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
	SET first_name = 'GROUCHO' 
	WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

USE Sakila;

SHOW CREATE TABLE address;
-- Result Grid, Form Editor, Field Types are to the right; select the Form Editor to see the actual query that created the table

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

USE Sakila;
SELECT * FROM address;
SELECT * FROM staff;

SELECT staff.first_name, staff.last_name, address.address, address.district, address.postal_code
	FROM staff
	JOIN address
	ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

USE Sakila;
SELECT * FROM staff;
SELECT * FROM payment;

SELECT staff.username, FORMAT(SUM(payment.amount),2) AS 'total_sales'
	FROM staff
	JOIN payment
	ON payment.staff_id = staff.staff_id
	WHERE payment_date >='2005-08-01 00:00:00' AND payment_date <'2005-09-01 00:00:00'
	GROUP BY staff.username; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

USE Sakila;
SELECT * FROM film;
SELECT * FROM film_actor;


SELECT film.title, COUNT(film_actor.actor_id) AS 'actor_count'
	FROM film
	INNER JOIN film_actor
	ON film_actor.film_id = film.film_id
	GROUP BY film.title; 

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

USE Sakila;
SELECT * FROM film;
SELECT * FROM inventory;

SELECT film.title, COUNT(inventory.inventory_id) AS 'film_copies'
	FROM film
    JOIN inventory
    ON film.film_id=inventory.film_id
	WHERE film.title = 'Hunchback Impossible';
    
    
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

USE Sakila;
SELECT * FROM payment;
SELECT * FROM customer;

SELECT customer.last_name, customer.first_name, FORMAT(SUM(payment.amount),2) AS 'total_paid'
	FROM customer
    JOIN payment
    ON customer.customer_id=payment.customer_id
	GROUP BY customer.customer_id
    ORDER BY last_name, first_name;
     
    
-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

-- join option:
USE Sakila;
SELECT * FROM film;
SELECT * FROM language;

SELECT film.title, language.name AS 'language'
	FROM film
    JOIN language
    ON film.language_id=language.language_id
    WHERE language.name = 'English' AND film.title LIKE 'K%' OR film.title LIKE 'Q%';

-- subquery option:
USE Sakila;
SELECT * FROM film;
SELECT * FROM language;

SELECT film.title
	FROM film
    WHERE film.title LIKE 'K%' OR film.title LIKE 'Q%'
    AND film.language_id IN
    (
		SELECT language.language_id
        FROM language
        WHERE language.name = 'English'
	);    

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

USE Sakila;
SELECT * FROM film;
SELECT * FROM film_actor;
SELECT * FROM actor;

SELECT actor.first_name, actor.last_name
FROM actor
WHERE actor.actor_id IN
	(
		SELECT film_actor.actor_id
		FROM film_actor
		WHERE film_actor.film_id IN
		(
			SELECT film.film_id
			FROM film
			WHERE film.title ='ALONE TRIP'
		)
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

-- join option
USE Sakila;
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT customer.first_name, customer.last_name, customer.email, country.country
	FROM customer
	JOIN address
	ON customer.address_id=address.address_id
		JOIN city
		ON address.city_id=city.city_id
			JOIN country
			ON city.country_id=country.country_id
			WHERE country.country = 'Canada';

-- subquery option
USE Sakila;
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT customer.first_name, customer.last_name, customer.email
FROM customer
WHERE customer.address_id IN
	(
		SELECT address.address_id
		FROM address
		WHERE address.city_id IN
		(
			SELECT city.city_id
			FROM city
			WHERE city.country_id IN
			(
				SELECT country.country_id
				FROM country
				WHERE country.country = 'Canada'
			)
		)
	);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

-- join option:
USE Sakila;
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM film;

SELECT film.title, category.name AS 'movie_genre'
	FROM film
	JOIN film_category
	ON film.film_id=film_category.film_id
		JOIN category
		ON film_category.category_id=category.category_id
		WHERE category.name = 'Family';

-- subquery option:
USE Sakila;
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM film;

SELECT film.title
FROM film
WHERE film.film_id IN
	(
		SELECT film_category.film_id
		FROM film_category
		WHERE film_category.category_id IN
		(
			SELECT category.category_id
			FROM category
			WHERE category.name ='Family'
		)
	);

-- 7e. Display the most frequently rented movies in descending order.

USE Sakila;
SELECT * FROM film;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM inventory;

SELECT film.title, COUNT(payment.rental_id) AS 'frequency_rented'
	FROM payment
	JOIN rental 
    ON payment.rental_id=rental.rental_id
		JOIN inventory
		ON rental.inventory_id=inventory.inventory_id
			JOIN film
			ON inventory.film_id=film.film_id
			GROUP BY film.title
			ORDER BY COUNT(payment.rental_id) DESC;
                

-- 7f. Write a query to display how much business, in dollars, each store brought in.

USE Sakila;
SELECT * FROM payment;
SELECT * FROM staff;

SELECT staff.store_id, format(SUM(payment.amount),2) AS 'total_sales'
	FROM staff 
	JOIN payment
	ON staff.staff_id=payment.staff_id
	GROUP BY staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

USE Sakila;
SELECT * FROM staff;
SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT staff.store_id, city.city, country.country 
	FROM staff
	JOIN address
    ON staff.address_id=address.address_id
		JOIN city
        ON address.city_id=city.city_id
			JOIN country
            ON city.country_id=country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

USE Sakila;
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;

SELECT category.name AS Genre, format(SUM(payment.amount),2) AS Gross_Revenue
	FROM category
	JOIN film_category
	ON category.category_id=film_category.category_id
		JOIN inventory
        ON film_category.film_id=inventory.film_id
			JOIN rental
            ON inventory.inventory_id=rental.inventory_id
				JOIN payment
                ON rental.rental_id=payment.rental_id
				GROUP BY Genre
				ORDER BY SUM(amount) DESC LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

USE Sakila;

CREATE VIEW top_five_genres_by_gross_revenue AS 
	(
		SELECT category.name AS Genre, format(SUM(payment.amount),2) AS Gross_Revenue
			FROM category
			JOIN film_category
			ON category.category_id=film_category.category_id
				JOIN inventory
				ON film_category.film_id=inventory.film_id
					JOIN rental
					ON inventory.inventory_id=rental.inventory_id
						JOIN payment
						ON rental.rental_id=payment.rental_id
						GROUP BY Genre
						ORDER BY SUM(amount) DESC LIMIT 5
	);

-- 8b. How would you display the view that you created in 8a?

USE Sakila;

SELECT * FROM top_five_genres_by_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

USE Sakila;

DROP VIEW top_five_genres_by_gross_revenue;