# sql_UberEats
This project showcases my SQL problem-solving abilities through an in-depth analysis of Uber Eats, a leading food delivery platform. It involves designing and managing a relational database, importing and cleaning raw data, addressing missing values, and answering key business questions using advanced SQL queries.

## Schemas
```SQL
CREATE TABLE customers 
(
customer_id INT PRIMARY KEY,
customer_name VARCHAR(25),
reg_date DATE
);

CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    opening_hours VARCHAR(50)
);


CREATE TABLE riders (
    rider_id SERIAL PRIMARY KEY,
    rider_name VARCHAR(100) NOT NULL,
    sign_up DATE
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    order_item VARCHAR(255),
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    order_status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10, 2) NOT NULL
);

--adding FK contraints
ALTER TABLE Orders
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

ALTER TABLE Orders
ADD CONSTRAINT fk_restaurants
FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)

CREATE TABLE deliveries (
    delivery_id SERIAL PRIMARY KEY,
    order_id INT,
    delivery_status VARCHAR(20) DEFAULT 'Pending',
    delivery_time TIME,
    rider_id INT
);

ALTER TABLE deliveries
ADD CONSTRAINT fk_orders
FOREIGN KEY (order_id) REFERENCES Orders(order_id);

ALTER TABLE deliveries
ADD CONSTRAINT fk_riders
FOREIGN KEY (rider_id) REFERENCES riders(rider_id)


Select * FROM customers
Select * FROM deliveries
Select * FROM orders
Select * FROM restaurants
Select * FROM riders
```
## Data Import

### Data Cleaning and Handling Null Values

Before performing analysis, I ensured that the data was clean and free from null values where necessary. For instance:

```sql
UPDATE orders
SET total_amount = COALESCE(total_amount, 0)
```

## Advanced Business Problems ##

### Q.1: Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.

```SQL
select customer_id, customer_name, order_item, Total_count from 
(
select *, 
rank() over (partition by customer_id order by total_count desc) as item_rank_wihtout_dense ,
dense_rank() over (partition by customer_id order by total_count desc) as item_rank_with_dense
FROM
(
Select c.customer_id, c.customer_name, o.order_item, Count(*) as Total_count 
FROM customers cv 
Join orders o
on o.customer_id = c.customer_id
Where o.order_date >= CURRENT_DATE - Interval '2 Year'
and
 c.customer_name = 'Arjun Mehta'
Group by 1,2,3
Order by 4 desc
)
)
where item_rank_with_dense < 
```

###  Q2. Popular Time Slots 
**Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.**
```SQL
Select 
Case 
when EXTRACT(HOUR from order_time) BETWEEN 0 AND 1 then '00:00 - 02:00'
when EXTRACT(HOUR from order_time) BETWEEN 2 AND 3 then '02:00 - 04:00'
when EXTRACT(HOUR from order_time) BETWEEN 4 AND 5 then '04:00 - 06:00'
when EXTRACT(HOUR from order_time) BETWEEN 6 AND 7 then '06:00 - 08:00'
when EXTRACT(HOUR from order_time) BETWEEN 8 AND 9 then '08:00 - 10:00'
when EXTRACT(HOUR from order_time) BETWEEN 10 AND 11 then '10:00 - 12:00'
when EXTRACT(HOUR from order_time) BETWEEN 12 AND 13 then '12:00 - 14:00'
when EXTRACT(HOUR from order_time) BETWEEN 14 AND 15 then '14:00 - 16:00'
when EXTRACT(HOUR from order_time) BETWEEN 16 AND 17 then '16:00 - 18:00'
when EXTRACT(HOUR from order_time) BETWEEN 18 AND 19 then '18:00 - 20:00'
when EXTRACT(HOUR from order_time) BETWEEN 20 AND 21 then '20:00 - 22:00'
when EXTRACT(HOUR from order_time) BETWEEN 22 AND 23 then '22:00 - 00:00'

end as time_slot,
COUNT(order_id) as order_count
From orders
Group by time_slot
Order by order_count DESC
```
###  Q3. Order Value Analysis
**Question: Find the average order value per customer who has placed more than 750 orders.**
**Return customer_name, and aov(average order value)**
```SQL
Select c.customer_name, a.*
FROM

(
Select customer_id, Count(order_id) as total_orders, ROUND(Avg(total_amount),2) AS AOV
From Orders
Group by 1

) as a

Left join customers c
on a.customer_id = c.customer_id
where a.total_orders >750
```

### Q4. High-Value Customers
**Question: List the customers who have spent more than 100K in total on food orders.**
**return customer_name, and customer_id!**
```SQL
Select customer_id, customer_name as high_value_customers, total_spent
From
(
Select c.customer_id ,c.customer_name, SUM(o.total_amount) as total_spent
from customers c
 join orders o
on c.customer_id = o.customer_id

Group by 1,2
)
where total_spent > 100000

or

Select c.customer_id ,c.customer_name, SUM(o.total_amount) as total_spent
from customers c
 join orders o
on c.customer_id = o.customer_id

Group by 1,2
Having SUM(o.total_amount) > 100000
```

### Q5. Orders Without Delivery
**Question: Write a query to find orders that were placed but not delivered.**
**Return each restuarant name, city and number of not delivered orders**
```SQL
Select 
 r.restaurant_name , 
 r.city, 
 Count(o.order_id) as not_delivered 
from orders o
left join restaurants r
on o.restaurant_id= r.restaurant_id
left join deliveries d
on o.order_id = d.order_id

where d.delivery_id is NULL
Group by 1,2
Order by 3 desc
```

### Q6.
**Restaurant Revenue Ranking:**
**Rank restaurants by their total revenue from the last year, including their name, total revenue, and rank within their city.**
```SQL
SELECT *,
rank() over (partition by city order by total_revenue desc )
FROM
(
Select 
 r.restaurant_id, r.restaurant_name, r.city, Sum(o.total_amount) as total_revenue
From orders o
Left join restaurants r
on o.restaurant_id = r.restaurant_id
Where o.order_date= Current_date - Interval '2 years'
Group by 1,2
Order by 3 desc
) 
```

### Q. 7
**Most Popular Dish by City:** 
**Identify the most popular dish in each city based on the number of orders.**
```SQL
Select *
FROM
(
Select r.city,o.order_item,  
Count(distinct(o.order_id)) as total_orders, 
rank() over (partition by r.city order by Count(distinct(o.order_id)) desc) as item_rank

From orders o
Left join restaurants r 
on o.restaurant_id = r.restaurant_id
Group by 1,2
)
where item_rank =1
```

### Q.8 Customer Churn: 
**Find customers who haven’t placed an order in 2024 but did in 2023.**
```SQL
Select Distinct customer_id from orders o

Where 
 Extract(year from order_date) in (2023) 
 and 
 customer_id not in 
	(
	Select Distinct customer_id from orders 
	Where EXTRACT(YEAR FROM order_date)= (2024)
	)
```

### Q.9 Cancellation Rate Comparison: 
**Calculate and compare the order cancellation rate for each restaurant between the 2023 and 2024.**
```SQL
With cancel_orders_23
as 
(
Select 
 o.restaurant_id, 
 Count(o.order_id) as total_orders_23, 
 Count(Case when d.delivery_id is null then 1 end) as not_delivered_23 from orders o
Left join deliveries d
on o.order_id = d.order_id
Where 
Extract (YEAR FROM o.order_date) = 2023 
Group by 1
)
,
cancel_orders_24
as 
(
Select 
 o.restaurant_id, 
 Count(o.order_id) as total_orders_24, 
 Count(Case when d.delivery_id is null then 1 end) as not_delivered_24 from orders o
Left join deliveries d
on o.order_id = d.order_id
Where 
Extract (YEAR FROM o.order_date) = 2024 
Group by 1
),
cancellation_ratio_23 as
(
Select 
 restaurant_id, 
 total_orders_23, 
 not_delivered_23, 
 Round(not_delivered_23::numeric/total_orders_23::numeric *100,2) as cancellation_rate_23
From cancel_orders_23
),
cancellation_ratio_24 as
(
Select 
 restaurant_id, 
 total_orders_24, 
 not_delivered_24, 
 Round(not_delivered_24::numeric/total_orders_24::numeric *100,2) as cancellation_rate_24
From cancel_orders_24
)

Select t.restaurant_id, t.cancellation_rate_23, f.cancellation_rate_24
From cancellation_ratio_23 t
Left join cancellation_ratio_24 f
on t.restaurant_id = f.restaurant_id
```
###  Q.10 Rider Average Delivery Time: 
**Determine each riders average delivery time.**
```SQL
select *,

CASE 
  WHEN (delivery_hour * 60 + delivery_minute) < (order_hour * 60 + order_minute)
  THEN (delivery_hour * 60 + delivery_minute + 1440) - (order_hour * 60 + order_minute)
  ELSE (delivery_hour * 60 + delivery_minute) - (order_hour * 60 + order_minute)
END AS time_difference

from 
(
Select 
 o.order_id,
 d.rider_id,
 o.order_time,
 d.delivery_time,
EXTRACT(HOUR FROM o.order_time) AS order_hour,
EXTRACT(MINUTE FROM o.order_time) AS order_minute,
EXTRACT(HOUR FROM d.delivery_time) AS delivery_hour,
EXTRACT(MINUTE FROM d.delivery_time) AS delivery_minute
 
from orders o
left join deliveries d
on o.order_id= d.order_id
left join riders r
on r.rider_id = d.rider_id
Where d.delivery_status = 'Delivered'
)

-- Extract(Epoch FROM(d.delivery_time- o.order_time + (Case when d.delivery_time < o.order_time then interval '1 day' Else Interval '0 day' END)))/60 as time_difference
```

### Q.11 Monthly Restaurant Growth Ratio: 
**Calculate each restaurants growth ratio based on the total number of delivered orders since its joining**
```SQL
With growth_monthly
As
(
Select 
o.restaurant_id,
To_CHAR(o.order_date, 'mm-yy') as month_year,
Count(o.order_id) as Total_current_orders,
Lag(Count(o.order_id),1) Over (Partition by restaurant_id order by To_CHAR(o.order_date, 'mm-yy')) as prev_month_orders
from orders o
Left join deliveries d
on o.order_id = d.delivery_id
Where d.delivery_status = 'Delivered'

Group by 1,2
Order by 1,2
)

Select 
 restaurant_id, 
 month_year, 
 Total_current_orders,
 prev_month_orders,
Round((Total_current_orders::numeric- prev_month_orders::numeric)/ prev_month_orders::numeric *100,2)  as growth_ratio

From
growth_monthly
```

### Q.12 Customer Segmentation: 
**Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's total number of orders and total**
```SQL
Select 
 customer_segment, 
 Sum(total_orders) as total_category_orders,  
 Sum(total_spending) as total_category_rev
From
(
Select 
 customer_id, 
 Sum(total_amount) as total_spending,
 Count(order_id) as total_orders,
 Case 
 When Sum(total_amount) > (Select Avg(total_amount) From orders) then 'Gold'
 Else 'Silver'
 End as customer_segment
From Orders
Group by 1
)
Group by 1


Select Avg(total_amount) From orders
```

###  Q.13 Rider Monthly Earnings: 
**Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.**
```SQL
Select 
 d.rider_id,
 r.rider_name,
 To_CHAR(o.order_date,'mm-yy') as month_earnings,
 
 Sum(o.total_amount) as total_order_revenue,
 Sum(o.total_amount)*0.08 as total_rider_earnings
 

from orders o

Left join deliveries d 
on o.order_id = d.order_id
join riders r
on r.rider_id= d.rider_id

Group by 1,2,3
Order by 1,2,3
```

### Q.14 Rider Ratings Analysis: 
**Find the number of 5-star, 4-star, and 3-star ratings each rider has. Riders receive this rating based on delivery time.**
**If orders are delivered less than 15 minutes of order received time the rider get 5 star rating, if they deliver 15 and 20 minute they get 4 star rating and if they deliver after 20 minute they get 3 star rating.**
```SQL
With time_diff 
as
(
Select 
 o.order_id,
 o.order_time,
 d.delivery_time,
 d.rider_id,
 ROUND(EXTRACT(EPOCH FROM (d.delivery_time - o.order_time +
        (CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
          ELSE INTERVAL '0 day' END))) / 60,2) AS delivery_time_taken

From orders o
Join deliveries d
on o.order_id = d.order_id
Where delivery_status = 'Delivered'
)


Select 
rider_id,
rider_rating,
Count(*)
From
(
Select 

 rider_id,
 order_time,
 delivery_time,
  delivery_time_taken,
 Case 
 When  delivery_time_taken <15 then '5-star'
  When  delivery_time_taken Between 15 and 20 then '4-star'
   When  delivery_time_taken >20 then '3-star'
   End as rider_rating

From time_diff
)
Group by 1,2
Order by 1, 3 desc
```

### Q.15 Order Frequency by Day: 
**Analyze order frequency per day of the week and identify the peak day for each restaurant.**
```SQL
Select * From
(
Select 
 r.restaurant_name,
 --o.order_date,
 TO_CHAR(o.order_date,'Day') as day_of_the_week,
 Count(o.order_id) as total_orders,
 Rank() OVER (Partition by r.restaurant_name Order by Count(o.order_id) desc)

from orders o
join restaurants r
on o.restaurant_id = r.restaurant_id
Group by 1,2
Order by 1,3 desc
)
Where rank=1
```
### Q.16 Customer Lifetime Value (CLV): 
**Calculate the total revenue generated by each customer over all their orders.**
```SQL
Select 
 o.customer_id, 
 customer_name, 
 Count(o.order_id) as total_orders, 
 Sum(total_amount) as total_revenue from orders o
 
Join customers c
on o.customer_id = c.customer_id
Group by 1,2 
```

### Q.17 Monthly Sales Trends: 
**Identify sales trends by comparing each month's total sales to the previous month.**
```SQL
Select 
 Extract(Year from order_date ) as year,
  Extract(Month from order_date ) as month,
  Sum(total_amount) as total_sales,
  LAG(Sum(total_amount),1) Over (Order by Extract(Year from order_date ), Extract(Month from order_date )) as prev_month
  

From orders
Group by 1,2
```

### Q.18 Rider Efficiency: 
**Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.**
```SQL
With time_diff_table
As
(
Select *,
 d.rider_id as riders_id,
Round(Extract (Epoch from (d.delivery_time - o.order_time + 
 (case when d.delivery_time < o.order_time then Interval '1 Day' 
 Else Interval '0 days' End)))/60,2) as delivery_time_diff 
From orders o
Join deliveries d
on o.order_id = d.order_id
Where d.delivery_status = 'Delivered'
),

avg_rider_table 
AS(
Select 
 riders_id, 
 AVG(delivery_time_diff ) as avg_delivery
From time_diff_table
Group by 1
)

Select 
Min(avg_delivery),
Max(avg_delivery)

From avg_rider_table
```

### Q.19 Order Item Popularity: 
**Track the popularity of specific order items over time and identify seasonal demand spikes.**
```SQL
Select
 order_item,
 seasons,
 Count(*)
From
(
Select 
 Order_item,
 
 Extract(Month from order_date) as months,
 Case
 when Extract(Month from order_date) Between 4 and 6 then 'Spring'
  when Extract(Month from order_date) Between 6 and 9 then 'Summer'
  Else 'Winter' End as seasons

From orders
)
Group by 1,2
Order by 1,3 desc
```

### Q.20 Rank each city based on the total revenue for last year 2023 
```SQL
Select 
 r.city,
 SUM(o.total_amount) as total_revenue,
 Rank() Over (order by SUM(o.total_amount) desc ) as city_rank
From orders o
Join restaurants r
on o.restaurant_id = r.restaurant_id
Group by 1
```




