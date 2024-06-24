use music;

select * from album2;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

/* Q1: Who is the senior most employee based on job title? */
select first_name, last_name, title from employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */
select billing_country, count(*) as "total invoice" from invoice
group by billing_country
order by count(*) desc;

/* Q3: What are top 3 values of total invoice? */
select total from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select billing_city, sum(total) as "Invoice_total" from invoice
group by billing_city
order by sum(total) desc
limit 1;

/* Q5: Who is the best customer? 
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as "high spend customer"
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by sum(invoice.total) desc
limit 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select distinct(customer.email), customer.first_name, customer.last_name, genre.name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on genre.genre_id = track.genre_id
where genre.name = "Rock" and
customer.email like "A%"
order by  customer.email;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
select artist.artist_id, artist.name, count(track.track_id) as "total_track"
from artist
join album2 on artist.artist_id = album2.artist_id
join track on track.album_id = album2.album_id
join genre on genre.genre_id = track.genre_id
where genre.name = "Rock"
group by artist.name,  artist.artist_id
order by count(track.track_id) desc
limit 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first. */
select track.track_id, track.name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track
					order by milliseconds desc
                    );
                    
/* Q9: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. 
Now use this artist to find which customer spent the most on this artist. For this query, 
you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables. 
Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, 
and then multiply this by the price for each artist. */
select customer.customer_id, customer.first_name, customer.last_name, artist.name, 
sum(invoice_line.unit_price * invoice_line.quantity) as "total_spend"
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id = album2.artist_id
group by 1,2,3,4
order by 5 desc
limit 1;

/* Q10: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  
There are two parts in question- first most popular music genre and second need data at country level. */
select genre.name, invoice.billing_country, count(invoice_line.quantity) as "purchase",
row_number() over(partition by invoice.billing_country order by count(invoice_line.quantity) desc) as "rank_by_row_number"
from invoice
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 1,2
order by count(invoice_line.quantity) desc;

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as "total_spend",
invoice.billing_country,
row_number() over(partition by invoice.billing_country order by sum(invoice.total) desc) as "Rank"
from customer
join invoice on invoice.customer_id = customer.customer_id
group by 1,2,3,5
order by 4 desc;