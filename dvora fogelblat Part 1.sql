--table for discount----
select he.[DocNum], 1-ISNULL(abs([DocDiscount]), 0) / SUM([LineSum]) as per
   into #discountfordoc
   from [dbo].[SalesLine]li
   left join [dbo].[SalesHeader]he on he.[DocNum]=li.[DocNum]
   group by li.[DocNum],he.[DocNum],[DocDiscount]
--ex1---------
select [ItemCode],sum([Qty])as sum_qty,count(distinct li.DocNum)as count_doc,sum([LineSum]*per) as cost
from [dbo].[SalesLine]li
left join #discountfordoc dis on li.[DocNum]=dis.[DocNum]
group by [ItemCode] 
--ex2------------------
select DocNum
from SalesLine
where ItemCode in (3611010, 3611600)
group by  DocNum
having count(distinct ItemCode) = 2;
--ex3-------------------
select s.SalesPersonCode,[SalesPersonName]
from SalesLine sl
join SalesHeader sh on sl.DocNum = sh.DocNum
join SalesPerson s on sh.SalesPersonCode = s.SalesPersonCode
group by s.SalesPersonCode,[SalesPersonName]
having count(distinct sl.ItemCode) = (select count(distinct ItemCode) from Items);
--ex4----------------
;with sales as (
    select 
        sl.ItemCode,
        sh.SalesPersonCode,
        count(distinct sl.ItemCode) as VarietyCount,
        sum(sl.Qty) as TotalQty
    from SalesLine sl
    join SalesHeader sh on sl.DocNum = sh.DocNum
    group by sl.ItemCode, sh.SalesPersonCode
),
MaxVariety as (
    select top 1 SalesPersonCode
    from sales
    group by SalesPersonCode
    order by sum(VarietyCount) desc
),
MaxQty as (
    select top 1 SalesPersonCode
    from sales
    group by SalesPersonCode
    order by sum(TotalQty) desc
),
MinVariety as (
    select top 1 SalesPersonCode
    from sales
    group by SalesPersonCode
    order by sum(VarietyCount)
)
select ItemCode
from sales
where SalesPersonCode in (select SalesPersonCode from MaxVariety)
intersect
select ItemCode
from sales
where SalesPersonCode in (select SalesPersonCode from MaxQty)
except
select ItemCode
from sales
where SalesPersonCode in (select SalesPersonCode from MinVariety)
--ex5--------------
;with SalesStats as (
  select sh.SalesPersonCode, sl.ItemCode,
         sum(sl.LineSum*per) as TotalSales,
         sum(sl.Qty) as TotalQty,
         sum(sl.LineSum) / nullif(sum(sl.Qty), 0) as AvgPerUnit
  from SalesHeader sh
  join SalesLine sl on sh.DocNum = sl.DocNum
  join #discountfordoc ex on sh.DocNum=ex.DocNum
  group by  sh.SalesPersonCode, sl.ItemCode
),
ItemAvg as (
  select SalesPersonCode, avg(AvgPerUnit) as PersonAvg
  from SalesStats
  group by SalesPersonCode
)
select s.SalesPersonCode, s.ItemCode, s.AvgPerUnit, s.TotalSales
from SalesStats s
join ItemAvg a on s.SalesPersonCode = a.SalesPersonCode
where s.AvgPerUnit < a.PersonAvg;