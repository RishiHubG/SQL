--https://stackoverflow.com/questions/53767142/sql-to-json-parent-child-relationship
DROP TABLE IF EXISTS tmp
create table tmp ([ID] int, [Level] int, ParentID int, IsEnd bit, SomeText varchar(50))
insert into tmp values
 (1, 1, null,1, 'abc'    )
,(2, 1, null,1, 'asd'    )
,(3, 2, 1   ,1, 'weqweq' )
,(4, 2, 1   ,0, 'lkjlkje')
,(5, 3, 4   ,1, 'noonwqe')
,(6, 3, 4   ,0, 'wet4t4' )
GO

create OR ALTER function dbo.udf_create_json_tree(@currentId int) 
    returns varchar(max)
begin 
    declare @json nvarchar(max) 
    declare @id int, @parentId int, @someText varchar(50)
	 
    select @id =[ID], @parentId = ParentID, @someText = SomeText
    from dbo.tmp 
    where [ID] = @currentId

    set @json =  
        (
            select [ID], SomeText, json_query(dbo.udf_create_json_tree([ID])) as Child 
            from dbo.tmp   
            where ParentID = @currentId 
            for json auto
        );

    if(@parentId is null) 
       set @json = concat(
                          '[{"ID":' + cast (@id as nvarchar(50)) ,
                          ',"SomeText":"' , @someText , 
                          '","Child":' , cast(@json as nvarchar(max)) ,
                          '}]'
                          )
    return @json  
end 

GO

select dbo.udf_create_json_tree(1)