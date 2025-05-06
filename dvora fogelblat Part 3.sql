drop procedure if exists calculateoptimallivingcost;
go

create procedure calculateoptimallivingcost @switchcost int
as
begin
declare @totalmonths int;
select @totalmonths = count(*) from monthlycosts;
--מקרה א-------------------------------------

declare @mina int = 2147483647;
declare @tempcost int;
DECLARE @i INT;

set @i = 1;
while @i <= @totalmonths + 1
begin
    select @tempcost = isnull(sum(costbneibrak), 0)
    from monthlycosts where monthnumber < @i;

    select @tempcost = @tempcost + isnull(sum(costjerusalem), 0)
    from monthlycosts where monthnumber >= @i;

    if @i > 1 and @i <= @totalmonths
        set @tempcost = @tempcost + @switchcost;

    if @tempcost < @mina
        set @mina = @tempcost;

    set @i = @i + 1;
end

set @i = 1;
while @i <= @totalmonths + 1
begin
    select @tempcost = isnull(sum(costjerusalem), 0)
    from monthlycosts where monthnumber < @i;

    select @tempcost = @tempcost + isnull(sum(costbneibrak), 0)
    from monthlycosts where monthnumber >= @i;

    if @i > 1 and @i <= @totalmonths
        set @tempcost = @tempcost + @switchcost;

    if @tempcost < @mina
        set @mina = @tempcost;

    set @i = @i + 1;
end

--מקרה ב-------------------------------------
create table #dp_j (
    monthnumber int primary key,
    cost int
);

create table #dp_b (
    monthnumber int primary key,
    cost int
);

set @i= 1;
declare @cj int, @cb int;
declare @prevcj int, @prevcb int;

select @cj = costjerusalem, @cb = costbneibrak
from monthlycosts where monthnumber = 1;

insert into #dp_j values (1, @cj);
insert into #dp_b values (1, @cb);

set @i = 2;
while @i <= @totalmonths
begin
    select @cj = costjerusalem, @cb = costbneibrak
    from monthlycosts where monthnumber = @i;

    select @prevcj = cost from #dp_j where monthnumber = @i - 1;
    select @prevcb = cost from #dp_b where monthnumber = @i - 1;

    insert into #dp_j values (
        @i,
        (SELECT MIN(val) FROM (VALUES (@prevcj + @cj), (@prevcb + @switchcost + @cj)) AS V(val))
    );

    insert into #dp_b values (
        @i,
        (SELECT MIN(val) FROM (VALUES (@prevcb + @cb), (@prevcj + @switchcost + @cb)) AS V(val))
    );

    set @i = @i + 1;
end

declare @finalb int;
select @finalb = (select min(cost) from (
    select cost from #dp_j where monthnumber = @totalmonths
    union all
    select cost from #dp_b where monthnumber = @totalmonths
)as allfinals)



print 'עלות מינימלית במקרה א (מעבר אחד בלבד): ' + cast(@mina as varchar);
print 'עלות מינימלית במקרה ב (מעברים חופשיים): ' + cast(@finalb as varchar);

drop table #dp_j;
drop table #dp_b;

end
