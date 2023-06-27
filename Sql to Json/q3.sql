drop table if exists t1
go
create table t1(id int, [key] int, [value] varchar(10))
go
insert into t1 values (100, 1, 'value11')
insert into t1 values (100, 2, 'value12')
insert into t1 values (100, 3, 'value13')
insert into t1 values (100, 4, 'value14')
go
insert into t1 values (200, 1, 'value21')
insert into t1 values (200, 2, 'value22')
insert into t1 values (200, 3, 'value23')
insert into t1 values (200, 4, 'value24')
go
select  
    t.id, t.[key], t.[value]
from t1 as t
for json path--,  WITHOUT_ARRAY_WRAPPER

select t.id, 
    '{' + STRING_AGG(concat(quotename([key],'"'),':',quotename(value,'"')),',') within group( order by value ) + '}' value
from t1 as t
group by id 
order by id