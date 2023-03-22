with t1 as
	(select *, extract(month from "sold_date") as "month"
	from "Sales_Data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "Car_Sales" cd
on cd.car_code = t1.customer_car_code
join "Sales_team" st
on st.sales_manager_id = t1.sales_manager_id)
select name,sum(car_price_usd) over(partition by months,name)as car_sum,months,
round(((monthly_target_usd - sum(car_price_usd))/monthly_target_usd)*100,2) as percentage_left
from t2
group by name,months,car_price_usd,monthly_target_usd
order by name;

-- question 2
with t1 as
	(select *, extract(month from "sold_date") as "month"
	from "Sales_Data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "Car_Sales" cd
on cd.car_code = t1.customer_car_code
join "Sales_team" st
on st.sales_manager_id = t1.sales_manager_id)

select car_name,sum(car_price_usd) over(partition by months)as car_sum,months,
((sum(car_price_usd))/monthly_target_usd)*100 as "percentage_target(%)"
from t2
where name = 'Ajay Alex'
group by car_name,months,car_price_usd,monthly_target_usd;

-- question 3
with t1 as
	(select *, extract(month from "sold_date") as "month"
	from "Sales_Data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "Car_Sales" cd
on cd.car_code = t1.customer_car_code
join "Sales_team" st
on st.sales_manager_id = t1.sales_manager_id),
t3 as
(select name,
round((sum(deposit_usd)/sum(car_price_usd))*100,2) as percentage_left
from t2
group by name
order by name),
t4 as
(select name,percentage_left,
case when percentage_left < lead(percentage_left) over() and
		percentage_left < lag(percentage_left) over() then 'min'
	when percentage_left > lead(percentage_left) over() and
		percentage_left < lead(percentage_left,2) over() then 'mid'
	when percentage_left > lag(percentage_left) over() and
		percentage_left > lag(percentage_left,2) over() then 'max'
else null end as min_max
from t3)
select name,percentage_left,min_max
from t4
where min_max in ('min','max');

-- question 4
with t1 as
	(select *, extract(month from "sold_date") as "month"
	from "Sales_Data"),
t2 as
(select *,first_name||' '||last_name as "name",
	case when "month" = 4 then 'April'
		 when "month" = 5 then 'May'
		 when "month" = 6 then 'June'
		 when "month" = 7 then 'July'
		 when "month" = 8 then 'August'
	else 'September' end as "months"
from t1
join "Car_Sales" cd
on cd.car_code = t1.customer_car_code
join "Sales_team" st
on st.sales_manager_id = t1.sales_manager_id),
t3 as
(select name,car_name,sum(car_price_usd) as "total_car_sum"
,row_number() over (partition by name order by sum(car_price_usd))  as rn
from t2
group by name,car_name
order by name,"total_car_sum")
select name,car_name,total_car_sum
from t3
where rn < 2;

-- question 5
select round(avg(s2.sold_date - s1.sold_date),2) as avg_diff
from "Sales_Data" s1
join "Sales_Data" s2 on s1.customer_car_code = s2.customer_car_code
and s1.sold_date < s2.sold_date;
