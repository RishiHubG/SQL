DROP TABLE IF EXISTS tmp
create table tmp ([ID] int, ParentID int, SomeText varchar(50))
insert into tmp values
 (1, null, 'abc'    )
,(2,null, 'asd'    )
,(3, 1   , 'weqweq' )
,(4,  1   , 'lkjlkje')
,(5,  4   , 'noonwqe')
,(6, 4   , 'wet4t4' )
,(7, 2   , 'aaa' )

	
--select dbo.udf_create_json_tree(1)
BEGIN

DECLARE @Sql_UDF VARCHAR(MAX) = 'create OR ALTER function dbo.udf_create_json_tree1(@currentId int) 
    returns varchar(max)
begin 
    declare @json nvarchar(max) 
    declare @id int, @parentId int, @someText varchar(50)
	 
    select @id =[ID], @parentId = ParentID, @someText = SomeText
    from <TableName> 
    where [ID] = @currentId

    set @json =  
        (
            select [ID], SomeText, json_query(dbo.udf_create_json_tree1([ID])) as Child 
            from <TableName> 
            where ParentID = @currentId 
            for json auto
        );
		
    if(@parentId is null) 
       set @json = concat(
                          ''[{"ID":'' + cast (@id as nvarchar(50)) ,
                          '',"SomeText":"'' , @someText , 
                          ''","Child":'' , cast(@json as nvarchar(max)) ,
                          ''}]''
                          )
    return @json  
end '

DECLARE @TBL VARCHAR(100)=CONCAT('TMP', REPLACE(NEWID(),'-',''))
DECLARE @SQL VARCHAR(MAX) = CONCAT('SELECT * INTO ',@TBL,'	FROM TMP ')
EXEC (@SQL)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<TableName>',@TBL)
EXEC (@Sql_UDF);
SELECT  dbo.udf_create_json_tree1(1) 
SELECT  dbo.udf_create_json_tree1(2) 
END


--DECLARE @STR VARCHAR(MAX) = '

--						''[{"ID":'' + cast (@id as nvarchar(50)) ,
--                          '',"SomeText":"'' , @someText , 
--                          ''","Child":'' , cast(@json as nvarchar(max)) ,
--                          ''}]''

							--'