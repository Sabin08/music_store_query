-- Q1. Who is the senior most employee based on job title?

select first_name, last_name, title
from employee 
order by levels 
desc limit 1;

-- Q2. Which countries have the most invoices?
select count(*) as billing_count, billing_city from invoice group by billing_city
order by billing_count desc;

-- Q3.What are top 3 values of total invoices?
select total from invoice order by total desc limit 3;

-- Q4. Which country has the best customer? We would like to throw a promotional music festival in the city we made 
-- the most money. Write query that returns one city that has the highest sum of invoice total. Return both the city name and sum of all invoice total.
select billing_city, sum(total) as total from invoice 
group by billing_city order by total desc limit 1;

-- Q5. Who is the best customer? The customer who has spent the most money  will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.
select Customer.customer_id, first_name,last_name, sum(total) as total_spending from Customer
inner join Invoice on Customer.customer_id = Invoice.customer_id 
group by Customer.customer_id
order by total_spending desc limit 1;

-- 			moderate level
-- Q1. Write query to return the email, first name, last name, and genre of all rock music listner.
-- Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- Q.2 Lets invite the artist who have written the most rock music in our dataset. Write a query that returns the
-- artist names and total track count of top 10 rock bands.

select artist.artist_id,artist.name, count(track.track_id) as total_track from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by total_track desc
limit 10;

-- Q.3 Return all the track names that have a song length longer than the average song length. Return the name and milliseconds
-- for each track. order by the song length with the longest songs listed first.
select track_id,name, milliseconds from track
where milliseconds > (select avg(milliseconds) as average_length from track where milliseconds <>0)
order by milliseconds desc;

/* Question Set 3 - Advance */
/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with cte as (select 
artist.artist_id as artist_id,artist.name as artist_name,sum(invoice_line.unit_price*invoice_line.quantity) as total_spent from invoice_line 
join track on track.track_id = invoice_line.track_id
join album on track.album_id = album.album_id 
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc
limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, cte.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN cte ON cte.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
WITH cte AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM cte WHERE RowNo <= 1