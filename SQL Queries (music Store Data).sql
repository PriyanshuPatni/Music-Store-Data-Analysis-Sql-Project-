-- Q1. Who is the senior most employee based on job title?	


SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1	;


-- Q2. Which countries have the most Invoices?

SELECT 
    c.country, COUNT(i.invoice_id) AS invoices
FROM
    customer AS c
        INNER JOIN
    invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY invoices DESC;


-- 3. What are top 3 values of total invoice?

SELECT 
    total
FROM
    invoice
ORDER BY total DESC
LIMIT 3;


/* Q4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

 
 SELECT 
    billing_city, SUM(total) AS Total
FROM
    invoice
GROUP BY billing_city
ORDER BY Total DESC; 


/*5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */


SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(i.total), 2) AS total
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.first_name , c.last_name , c.customer_id
ORDER BY total DESC
LIMIT 1;


/* Q6. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */


SELECT 
    c.first_name, c.last_name, c.email
FROM
    customer AS c
        JOIN
    invoice AS i ON c.customer_id = i.customer_id
        JOIN
    invoice_line AS il ON i.invoice_id = il.invoice_id
WHERE
    track_id IN (SELECT 
            t.track_id
        FROM
            genre AS g
                JOIN
            track AS t ON g.genre_id = t.genre_id
        WHERE
            g.name LIKE 'rock')
ORDER BY c.email;



/* Q7. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */


SELECT 
    a.artist_id, a.name, COUNT(a.artist_id) AS number_of_songs
FROM
    track AS t
        JOIN
    album AS al ON al.album_id = t.album_id
        JOIN
    artist AS a ON a.artist_id = al.artist_id
        JOIN
    genre AS g ON g.genre_id = t.genre_id
WHERE
    g.name LIKE 'Rock'
GROUP BY a.artist_id , a.name
ORDER BY number_of_songs DESC
LIMIT 10;

/*Q8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */

SELECT 
    name, milliseconds
FROM
    track
WHERE
    milliseconds > (SELECT 
            AVG(milliseconds) AS avg_song_length
        FROM
            track)
ORDER BY milliseconds DESC;



/* Q9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent */

with best_selling_artist as (
     select a.artist_id as artist_id, a.name as artist_name , 
     sum(il.unit_price*il.quantity)as total_spent 
     from invoice_line as il 
     join track as t on t.track_id=il.track_id
     join album as alb on alb.album_id=t.album_id
     join artist as a on a.artist_id=alb.artist_id 
     group by 1,2
     order by 3 desc
     limit 1)
select c.customer_id, c.first_name,c.last_name,bsa.artist_name as artist_name,
round(sum(il.unit_price*il.quantity),2)as total_spent
from customer as c  
join invoice as i on c.customer_id = i.customer_id 
join invoice_line as il on il.invoice_id=i.invoice_id
join track as t on t.track_id=il.track_id
join album as alb on alb.album_id=t.album_id
join best_selling_artist as bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc
;



/* Q10. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */


with popular_music_genre as (
  select count(il.invoice_id)as purchases , c.country,g.name,g.genre_id,
  row_number()over(partition by c.country order by count(il.invoice_id)desc) as Row_No
  from invoice_line as il 
  join invoice as i on il.invoice_id = i.invoice_id
  join customer as c on c.customer_id = i.customer_id
  join track as t on t.track_id = il.track_id
  join genre as g on g.genre_id = t.genre_id
  group by 2 , 3 , 4 
  order by  1 desc)
select * from popular_music_genre where Row_No <=1 ;



/* Q11.Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */

with customer_with_country as (
   select  c.customer_id,c.first_name,c.last_name,c.country,
   round(sum(i.total),2)as total_spending,
   row_number()over(partition by c.country order by sum(i.total))as Row_No
   from invoice as  i 
   join customer as c on c.customer_id = i.customer_id
   group by 1,2,3,4
   order by 4 asc, 5 desc )
select * from customer_with_country where row_no <= 1;














































































































































