create or alter view dbo.monthly_sales_view as


with 
limits as (
    select 
        min([date]) as min_date, 
        max([date]) as max_date 
    from dbo.salesdata
),
daterange as (
    select 
        part,
        datefromparts(year(min([date])), month(min([date])), 1) as mindateperpart,
        (select max_date from limits) as maxdateallparts
    from dbo.salesdata
    group by part
),
months as (
    select 
        dateadd(month, recno-1, cast((select min_date from limits) as date)) as monthdate
    from dbo.autogenerate(((select datediff(month, min([date]), max([date]))from [dbo].[SalesData])+1))
),
calendar_per_part as (
    select 
        dr.part,
        m.monthdate,
        datefromparts(year(m.monthdate), month(m.monthdate), 1) as month_start
    from daterange dr
    join months m
        on m.monthdate >= dr.mindateperpart
        and m.monthdate <= dr.maxdateallparts
),
monthly_qty as (
    select 
        part,
        datefromparts(year([date]), month([date]), 1) as month_start,
        sum(case when quant<0 then 0 else quant end ) as monthly_qty
    from dbo.salesdata
    where quant > 0
    group by part, datefromparts(year([date]), month([date]), 1)
),
final as (
    select 
        cp.part,
        cp.month_start,
        isnull(mq.monthly_qty, 0) as monthly_qty,
        isnull((
            select sum(isnull(monthly_qty,0))
            from monthly_qty mq2
            where mq2.part = cp.part
              and mq2.month_start between dateadd(month, -11, cp.month_start) and cp.month_start
        ),0) as last_12_calendar_qty,
        (
            select sum(top12.monthly_qty)
            from (
                select top 12 mq3.monthly_qty
                from monthly_qty mq3
                where mq3.part = cp.part and mq3.month_start <= cp.month_start
                order by mq3.month_start desc
            ) as top12
        ) as last_12_nonempty_qty
    from calendar_per_part cp
    left join monthly_qty mq
        on mq.part = cp.part and mq.month_start = cp.month_start
)
select 
    part,
    format(month_start ,'yyyy-MM')as [date],
    monthly_qty,
    last_12_calendar_qty,
    last_12_nonempty_qty
from final;




