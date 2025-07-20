-- Select * from retail_sales;
-- Data Exploration

-- Q1. How many sales we have? 
-- select count(*) as total_sale from retail_sales; 
-- 1987

-- Q2. How many unique customer we have?
-- select count(distinct customer_id) from retail_sales;
-- 155
 
 -- Q3. Write a SQL query to retrieve all columns for sales made on '2022-11-05?
--  select * from retail_sales where sale_date="2022-11-05";
 
 -- Q4 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or equal to 4 in the month of Nov-2022?
--  select * from retail_sales where category="Clothing" and quantity>=4 and sale_date like "2022-11%";

-- Q.5 Write a SQL query to calculate the total sales (total_sale) for each category?
-- select category, sum(total_Sale) as total_sales from retail_sales group by category;
 
 -- Q6 Write a SQL query to find the average age of customers and their gender who purchased items from the 'Beauty' category?
--  select avg(age) as Average_age_of_customer,gender from retail_sales where category="Beauty" group by gender;
 
 -- Q.7 Write a SQL query to find all transactions where the total_sale is greater than 1000?
--  select * from retail_sales where total_sale>1000;
 
 -- Q.8 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
--  select count(transaction_id),gender,category from retail_sales group by gender,category order by category;

-- Q.9 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- select extract(YEAR from sale_date) as years, extract(MONTH from sale_date) as months,round(avg(total_sale),0) as average_sale from retail_sales 
-- group by months,years order by average_sale desc; 
-- July was the best selling month of the year

-- Q.10 Write a SQL query to find the top 5 customers based on the highest total sales 
-- select customer_id,sum(total_sale) as total_sales from retail_sales group by customer_id order by total_sales desc limit 5;
-- customer_id 3,1,5,2,4 are the top 5 customer based on highest total_sale

-- Q.11 Write a SQL query to find the number of unique customers who purchased items from each category.
-- select category,count(distinct customer_id) as total_number_of_customer from retail_sales group by category;
-- Beauty-141, Clothing-149, Electronics-144

-- Q.12 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale as
(SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales)
select shift,count(*) as number_of_orders from hourly_sale group by shift;
-- Evening-1062, Morning-548, Afternoon-377