# Q1 Who is senior most employee based on job title ?

SELECT title, first_name, last_name , levels
FROM employee
order by levels desc
limit 1;

#Q2 Which countries have the most Invoices? 

SELECT COUNT(*) AS C , billing_country
FROM invoice
GROUP by billing_country
ORDER BY C DESC;

# Q3 What are Top 3 values of total invoice ?

SELECT invoice_id , customer_id , total FROM invoice
order by total desc
limit 3;

#Q4 Which city has the best customers? city that has the highest sum of invoice totals ! Return both the city name & sum of all invoice totals 

SELECT SUM(total) AS invoice_total , billing_city 
FROM invoice
group by billing_city 
order by invoice_total desc;

#Q5 Who is the best customer? Write a query that returns the person who has spent the most money.

SELECT C.customer_id,C.first_name,C.last_name,sum(total) AS T
FROM customer AS C
JOIN invoice AS I ON C.customer_id = I.customer_id 
GROUP BY C.customer_id,C.first_name,C.last_name
order by T desc
limit 1;

#Q6 Write query to return the email, first name, last name, & Genre of all Rock Music . Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT email,first_name,last_name
FROM customer AS C
JOIN invoice AS I on C.customer_id = I.customer_id
JOIN invoice_line AS L on L.invoice_id = I.invoice_id
WHERE track_id IN (
			        SELECT track_id FROM track AS T
                    JOIN genre AS G on T.genre_id = G.genre_id
                    WHERE G.name LIKE 'Rock')
ORDER BY email; 


#Q7 Let's invite the artists who have written the most rock music in our dataset .Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT AR.artist_id,AR.name,AL.album_id,G.name , count(AR.artist_id) AS SONGS_COUNT
FROM artist AS AR
JOIN album2 AS AL on AR.artist_id = AL.artist_id
JOIN track AS T on T.album_id = AL.album_id
JOIN genre AS G on G.genre_id = T.genre_id
WHERE G.name LIKE 'Rock'
GROUP BY AR.artist_id,AR.name,AL.album_id,G.name
ORDER BY SONGS_COUNT DESC
LIMIT 10;

#Q8 Return all the track names that have a song length longer than the average song length. 

SELECT name,milliseconds
FROM track
WHERE milliseconds >
                     (SELECT avg(milliseconds) AS Averagetrack FROM track)
                     ORDER BY milliseconds DESC
                     limit 5;
                     
#Q9  Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent   

WITH Best_Selling_Artist AS (
SELECT AR.artist_id,AR.name,sum(I.quantity*I.unit_price) AS Totalsales
FROM invoice_line AS I
JOIN track AS T on T.track_id=I.track_id
JOIN album2 AS AL on AL.album_id=T.album_id
JOIN artist AS AR on AR.artist_id=AL.artist_id
GROUP BY AR.artist_id,AR.name
ORDER BY Totalsales DESC
LIMIT 1 
)
SELECT C.customer_id,C.first_name,C.last_name ,sum(I.quantity*I.unit_price) AS Amountspend
FROM invoice AS V
JOIN customer AS C on C.customer_id=V.customer_id
JOIN invoice_line AS I on I.invoice_id=V.invoice_id
JOIN track AS T on T.track_id=I.track_id
JOIN album2 AS AL on AL.album_id-T.album_id
JOIN Best_Selling_Artist AS BSA on BSA.artist_id=AL.artist_id
GROUP BY C.customer_id,C.first_name,C.last_name
ORDER BY Amountspend DESC;

#Q10 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.

WITH popular_genre AS
(SELECT count(V.quantity) AS purchase , C.country,G.genre_id,G.name,
ROW_NUMBER() OVER (PARTITION BY C.country ORDER BY count(V.quantity) DESC) AS rownum
FROM invoice_line AS V
JOIN invoice AS I on V.invoice_id=I.invoice_id
JOIN customer AS C on C.customer_id=I.customer_id
JOIN track AS T on T.track_id=V.track_id
JOIN genre AS G on G.genre_id=T.genre_id
GROUP BY C.country,G.genre_id,G.name
ORDER BY purchase ASC , C.country DESC
)
SELECT * FROM popular_genre WHERE rownum <= 1;

#Q11 Write a query that determines the customer that has spent the most on music for each country.
# Write a query that returns the country along with the top customer and how much they spent. 
# For countries where the top amount spent is shared, provide all customers who spent this amount.


WITH Customter_with_country AS (
		SELECT C.customer_id,C.first_name,C.last_name,I.billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice AS I
		JOIN customer AS C ON C.customer_id = I.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1




              