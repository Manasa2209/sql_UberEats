-- UberEATS Data Analysis using SQL

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
