DROP TABLE IF EXISTS tmp1
create table tmp1 ([ID] int, ParentID int, SomeText varchar(50))
insert into tmp1 values
 (1, null, 'abc'    )
,(2,null, 'asd'    )
,(3, 1   , 'weqweq' )
,(4,  1   , 'lkjlkje')
,(5,  4   , 'noonwqe')
,(6, 4   , 'wet4t4' )
,(7, 2   , 'aaa' )

	
--select dbo.udf_create_json_tree(1)
BEGIN

			DECLARE @ColumnList VARCHAR(MAX),@strColumnList VARCHAR(MAX),@ColumnListDataType VARCHAR(MAX),@strColumnList2 VARCHAR(MAX)
			--DECLARE @SQL VARCHAR(MAX) 

		SELECT @ColumnList = STRING_AGG(Column_Name,',') ,
			 -- @strColumnList = STRING_AGG(CONCAT('@',Column_Name,'= [',Column_name,']'),',') ,
			  @strColumnList2 = STRING_AGG(CONCAT('"',Column_Name,'":"',CHAR(39),', CAST(@',Column_Name, ' AS NVARCHAR(MAX)),', CHAR(39),'"'),',') 
			 -- @ColumnListDataType = STRING_AGG(CONCAT('@',Column_Name,CONCAT(' ', DATA_TYPE),CASE WHEN DATA_TYPE IN ('varchar','Nvarchar') THEN CONCAT('(',CHARACTER_MAXIMUM_LENGTH,')') END),',' ) 
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'tmp'
			  AND Column_Name <> 'ParentID'
		
		 
		SELECT @strColumnList = STRING_AGG(CONCAT('@',Column_Name,'= [',Column_name,']'),',') ,
			  @ColumnListDataType = STRING_AGG(CONCAT('@',Column_Name,CONCAT(' ', DATA_TYPE),CASE WHEN DATA_TYPE IN ('varchar','Nvarchar') THEN CONCAT('(',CHARACTER_MAXIMUM_LENGTH,')') END),',' ) 
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'tmp'

		--REMOVE THE LAST DOUBLE QUOTES
		SET @strColumnList2 = SUBSTRING(@strColumnList2,1,LEN(@strColumnList2)-1);
		--SELECT @strColumnList2
		--SELECT @ColumnListDataType,@strColumnList2
		--SELECT * FROM   INFORMATION_SCHEMA.COLUMNS 		WHERE TABLE_NAME = 'tmp'

		--RETURN

DECLARE @Sql_UDF VARCHAR(MAX) = 'create OR ALTER function dbo.udf_create_json_tree1(@currentId int) 
    returns varchar(max)
begin 
    declare @json nvarchar(max) 
    declare <VariableDeclarations>
	 
    select <StrColumnList>
    from <TableName> 
    where [ID] = @currentId

    set @json =  
        (
            select <ColumnList>, json_query(dbo.udf_create_json_tree1([ID])) as Child 
            from <TableName> 
            where ParentID = @currentId 
            for json auto
        );
		 
    if(@parentId is null) 
      set @json = concat(''[{<StrColumnList2>","Child":'' , cast(@json as nvarchar(max)) , ''}]''

						 /*
						  concat(
                          ''[{
						  "ID":'' , cast (@id as nvarchar(50)) ,
                          '',"SomeText":"'' , @someText , 
                          ''","Child":'' , cast(@json as nvarchar(max)) ,
                          ''}]''
						  */
                          )
                          
    return @json  
end '
--RETURN
DECLARE @TBL VARCHAR(100)=CONCAT('TMP', REPLACE(NEWID(),'-',''))
DECLARE @SQL VARCHAR(MAX) = CONCAT('SELECT * INTO ',@TBL,'	FROM TMP1 ')
EXEC (@SQL)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<TableName>',@TBL)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<VariableDeclarations>',@ColumnListDataType)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<ColumnList>',@ColumnList)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<StrColumnList>',@StrColumnList)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<StrColumnList2>',@StrColumnList2)

PRINT @Sql_UDF
--RETURN
EXEC (@Sql_UDF);
SELECT  dbo.udf_create_json_tree1(1) 
SELECT  dbo.udf_create_json_tree1(2) 
END

 