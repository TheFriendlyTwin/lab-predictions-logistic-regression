/*Lab | Making predictions with logistic regression*/

/*In this lab, you will be using the Sakila database of movie rentals.

In order to optimize our inventory, we would like to know which films will be rented next month and we are asked to create a model to predict it.*/

-- 1. Create a query or queries to extract the information you think may be relevant for building the prediction model. 
-- It should include some film features and some rental features.

-- Step 1: Count how many times each film was rented
select i.film_id, count(r.rental_id) as rental_count
from sakila.inventory i
join rental r
on i.inventory_id = r.inventory_id
group by i.film_id;

-- Step 2: Adding relevant columns to the previous query such as film_category, actor and language
with film_details as
(
	select f.film_id, f.release_year, f. language_id, f.original_language_id, f.length, f.rating, cat.category_id, fa.actor_id
    from sakila.film f
    join sakila.film_category cat
    on f.film_id = cat.film_id
    join sakila.film_actor fa
    on f.film_id = fa.film_id
), film_rental_count as 
(
	select i.film_id, count(r.rental_id) as rental_count
	from sakila.inventory i
	join rental r
	on i.inventory_id = r.inventory_id
	group by i.film_id
)
select fd.film_id, fd.release_year, fd. language_id, fd.original_language_id, fd.length, fd.rating, fd.category_id, fd.actor_id, frc.rental_count 
from film_details fd
join film_rental_count frc
on fd.film_id = frc.film_id
order by frc.rental_count desc;

-- Listing the different film categories
select category_id, name from sakila.category;

-- 4. Create a query to get the list of films and a boolean indicating if it was rented last month. This would be our target variable.

-- Step 1: check what months have had rentals
select month(rental_date), year(rental_date), count(*)
from sakila.rental
group by 1, 2;

-- Step 2 Let's assume last month was August from 2005 and create a query with boolean column rented_last_month
with film_rental_count as 
(
	select i.film_id, month(r.rental_date) as rental_month, count(r.rental_id) as rental_count
	from sakila.inventory i
	left join rental r
	on i.inventory_id = r.inventory_id
	group by i.film_id, rental_month
)
select film_id, rental_month, rental_count,
		case
			when rental_count > 0 then 'True'
			else 'False'
		end as rented_last_month
from film_rental_count frc
where rental_month = 8 or rental_month is NULL;

-- Final step join previous query with query from instruction 1.
with film_details as
(
	select f.film_id, f.release_year, f. language_id, f.length, f.rating, cat.category_id, fa.actor_id
    from sakila.film f
    join sakila.film_category cat
    on f.film_id = cat.film_id
    join sakila.film_actor fa
    on f.film_id = fa.film_id
), film_rental_count as 
(
	select i.film_id, month(r.rental_date) as rental_month, count(r.rental_id) as rental_count
	from sakila.inventory i
	left join rental r
	on i.inventory_id = r.inventory_id
	group by i.film_id, rental_month
), last_month_rented as
(
	select film_id, rental_month, rental_count,
		case
			when rental_count > 0 then 'True'
			else 'False'
		end as rented_last_month
	from film_rental_count frc
	where rental_month = 8 or rental_month is NULL
)
select fd.film_id, fd.release_year, fd. language_id, fd.length, fd.rating, fd.category_id, fd.actor_id, frc.rental_count, lmr.rented_last_month
from film_details fd
join film_rental_count frc
on fd.film_id = frc.film_id
join last_month_rented lmr
on fd.film_id = lmr.film_id
order by frc.rental_count desc;
