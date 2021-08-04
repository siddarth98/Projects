
/*
Step1: Data include cancelled transaction that can be seen from the table above, 
       therefore any invoiceno containing ‘C’, NULLs in customerid and 0 in unitprice must be omitted
Step2: Segregating customer 4 tier groups for each dimensions (R, F and M). 
       1 indicates longest time of transaction, least transaction and lowest spend 
       while 4 indicates most recent, most transaction and highest spend groups using NTILE() 
       window funtion[Used to break the result set into a specified number of approximately equal groups with the specified order]
Step3: With those 3 scores further divding customers into 8 different groups
       Best Customers: Customers in this segment bought product very recent, very often and spend the most among others.
       Loyal: Loyal customers are those who spent good amount of money and they usually responsive to promotions.
       Potential Loyalist: Potential loyalists are recent customers that bought product more than once and spent good amount of money. We can offer membership and recommend other products to customers in this segment.
       Promising: This segment is for new shoppers that haven’t spent much. We can create brand awareness and offer free trials for them.
       Customers Needing Attention: This customers bought much and spent good money but have not bought very recently. 
       We can reactive them by make limited time offers and recommend products based on their past purchases.
       At Risk: This group of customers spent big money and purchased often a long time ago. We need to bring them back by sending emails to reconnect and offer renewals.
       Hibernating: This customers have been inactive for a long time, they have low number of orders and low spenders. We can offer other relevant products and special discounts.
       Lost: Customers with lowest performance of RFM, we can ignore them or reach them out to get back their interest
Step4: Vizualising the above resultant data by using any of the tools i have used MS-Excel */


use RFM
select * from rfmdata
with x as (select r.CustomerID, 
NTILE(4) over(order by r.Lastordered_date) 'Recency', 
NTILE(4) over(order by r.order_count)'Frequency',
NTILE(4) over(order by r.total_price) 'Monetary', r.total_price
from (
	select CustomerID, MAX(InvoiceDate) as Lastordered_date,
	COUNT(*) Order_count, SUM(UnitPrice*Quantity) as total_price
	from rfmdata
	where InvoiceNo not like '%c%' 
	and CustomerID is not null
	and UnitPrice != 0
	group by CustomerID) as r)
select *,
	case 
	when x.Recency >= 4 and x.Frequency >= 4 and x.Monetary >= 4 then 'Best Customers'
    when x.Recency >= 3 and x.Frequency >= 3 and x.Monetary >= 3 then 'Loyal'
    when x.Recency >= 3 and x.Frequency >= 1 and x.Monetary >= 2 then 'Potential Loyalist'
    when x.Recency >= 3 and x.Frequency >= 1 and x.Monetary >= 1 then 'Promising'
    when x.Recency >= 2 and x.Frequency >= 2 and x.Monetary >= 2 then 'Customers Needing Attention'
    when x.Recency >= 1 and x.Frequency >= 2 and x.Monetary >= 2 then 'At Risk'
    when x.Recency >= 1 and x.Frequency >= 1 and x.Monetary >= 2 then 'Hibernating'
    else 'Lost'
	end as CustomerType 
from x
