# SQL PROJECT- MUSIC STORE DATA ANALYSIS 
# 1. Who is the senior most employee based on job title?
SELECT * FROM employee 
ORDER BY levels DESC
LIMIT 1;


#2. Which countries have the most Invoices?
SELECT billing_country, COUNT(*) as COUNT_OF_INVOICE 
FROM invoice 
GROUP BY billing_country 
ORDER BY COUNT_OF_INVOICE
DESC LIMIT 1;

#3. What are top 3 values of total invoice? 
SELECT invoice_id ,total
FROM (
    SELECT invoice_id,total, DENSE_RANK() OVER (ORDER BY total DESC) AS rank_num 
    FROM invoice
) AS ranked_invoices
WHERE rank_num <= 3;


#4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
#Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 

SELECT  billing_city, SUM(total) as total 
FROM invoice 
GROUP BY billing_city
ORDER BY total DESC limit 1 ;


#5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
#Write a query that returns the person who has spent the most money 

SELECT  a.customer_id,a.first_name,a.last_name,
SUM(b.total) as total 
FROM invoice b JOIN customer a ON a.customer_id=b.customer_id
GROUP BY customer_id
ORDER BY total DESC limit 1 ;

#Project Phase II

#1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
#Return your list ordered alphabetically by email starting with A 

SELECT Distinct(c.email) , c.first_name, c.last_name,  g.name 
FROM customer c 
JOIN invoice i ON c.customer_id=i.customer_id
JOIN invoice_line l ON l.invoice_id=i.invoice_id
JOIN track t ON t.track_id=l.track_id
JOIN genre g ON g.genre_id=t.genre_id
WHERE g.name = 'Rock' 
ORDER BY c.email; 

#2. Let's invite the artists who have written the most rock music in our dataset. 
#Write a query that returns the Artist name and total track count of the top 10 rock bands 

SELECT  artist.name, artist.artist_id, COUNT(artist.artist_id) AS num_of_songs
FROM artist 
JOIN album ON artist.artist_id = album.artist_id
JOIN track ON album.album_id = track.album_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY num_of_songs DESC
LIMIT 10;


#3. Return all the track names that have a song length longer than the average song length. 
#Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT name, milliseconds FROM track 
where milliseconds  > (SELECT AVG(milliseconds) AS AVG_LENGHT 
FROM track)  
ORDER BY milliseconds DESC;


#Project Phase III

#1. Find how much amount spent by each customer on artists? 
#Write a query to return customer name, artist name and total spent 

WITH CTE AS ( SELECT artist.artist_id, artist.name , SUM(invoice_line .unit_price*invoice_line.quantity) AS total_spent
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY artist.artist_id
ORDER BY total_spent DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, CTE.name,
SUM(LI.unit_price*LI.quantity) AS sum_amt
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line li ON li.invoice_id = i.invoice_id
JOIN track t  ON t.track_id = li.track_id
JOIN album al ON al.album_id = t.album_id
JOIN CTE ON CTE.artist_id = al.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, CTE.name
ORDER BY sum_amt DESC



#2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
#Write a query that returns each country along with the top Genre. 
#For countries where the maximum number of purchases is shared return all Genres

SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	DENSE_RANK() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rnk
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY customer.country
)
SELECT * FROM popular_genre WHERE Rnk <= 1




#3. Write a query that determines the customer that has spent the most on music for each country.
 #Write a query that returns the country along with the top customer and how much they spent.
 #For countries where the top amount spent is shared, provide all customers who spent this amount
 
 WITH CTE AS (
SELECT customer.customer_id,customer.country, customer.first_name, customer.last_name,SUM(invoice.total) AS total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id,customer.country
ORDER BY total_spent DESC ,country ASC
)
SELECT customer_id,country, first_name, last_name, MAX(total_spent) AS MAX_spent
FROM CTE
GROUP BY country 
ORDER BY country ASC