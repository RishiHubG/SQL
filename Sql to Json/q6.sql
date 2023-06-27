USE JUNK
GO

DROP TABLE IF EXISTS tmp1
create table tmp1 ([ID] int, ParentID int, SomeText varchar(50))
insert into tmp1 values
 (1, null, 'abc'    )
,(2,null, 'asd'    )
,(3, 1   , 'weqweq' )
,(4,  1   , 'lkjlkje')
,(5,  4   , 'noonwqe')
,(6, 4   , 'wet4t4' )
,(7, 2   , 'aaa' ),
(8,null,'xyz')

	
--select dbo.udf_create_json_tree(1)
BEGIN

			DECLARE @ColumnList VARCHAR(MAX),@strColumnList VARCHAR(MAX),@ColumnListDataType VARCHAR(MAX),@strColumnList2 VARCHAR(MAX)
			--DECLARE @SQL VARCHAR(MAX) 

		SELECT @ColumnList = STRING_AGG(Column_Name,',') ,
			 -- @strColumnList = STRING_AGG(CONCAT('@',Column_Name,'= [',Column_name,']'),',') ,
			  @strColumnList2 = STRING_AGG(CONCAT('"',Column_Name,'":',CHAR(39),', CONCAT(CHAR(34), CAST(@',Column_Name, ' AS NVARCHAR(MAX)), CHAR(34)),', CHAR(39)),',') 										
			 -- @ColumnListDataType = STRING_AGG(CONCAT('@',Column_Name,CONCAT(' ', DATA_TYPE),CASE WHEN DATA_TYPE IN ('varchar','Nvarchar') THEN CONCAT('(',CHARACTER_MAXIMUM_LENGTH,')') END),',' ) 
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'tmp1'
			  AND Column_Name <> 'ParentID'
		
		 
		SELECT @strColumnList = STRING_AGG(CONCAT('@',Column_Name,'= [',Column_name,']'),',') ,
			  @ColumnListDataType = STRING_AGG(CONCAT('@',Column_Name,CONCAT(' ', DATA_TYPE),CASE WHEN DATA_TYPE IN ('varchar','Nvarchar') THEN CONCAT('(',IIF(CHARACTER_MAXIMUM_LENGTH=-1,'MAX',CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR)),')') END),',' ) 
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'tmp1'

		
		--REMOVE THE LAST APOSTROPHE
		SET @strColumnList2 = SUBSTRING(@strColumnList2,1,LEN(@strColumnList2)-1);
		PRINT @strColumnList2

		SET @strColumnList2 = CONCAT(@strColumnList2,
										' CASE WHEN EXISTS(SELECT 1 FROM <TableName>  WHERE ParentID = @ID) THEN CONCAT('',"Child":'' , cast(@json as nvarchar(max))) END '
										,','''
										)

DECLARE @Sql_UDF VARCHAR(MAX) = 'CREATE OR ALTER FUNCTION dbo.udf_create_json_tree1(@currentId int) 
								 RETURNS VARCHAR(MAX)
BEGIN

    DECLARE @json NVARCHAR(MAX) 
    DECLARE <VariableDeclarations>
	 
    SELECT <StrColumnList>
    FROM <TableName> 
    WHERE [ID] = @currentId

    SET @json =  
        (
            SELECT <ColumnList>, json_query(dbo.udf_create_json_tree1([ID])) as Child 
            FROM <TableName> 
            WHERE ParentID = @currentId 
            FOR JSON AUTO
        );
		 
    IF @parentId IS NULL
	     SET @json = concat(''[{<StrColumnList2>}]'')
    	 
    RETURN @json  
END '
--PRINT @Sql_UDF
--CREATE TABLE TO HOLD DATA
DECLARE @TBL VARCHAR(100)=CONCAT('JSON', REPLACE(NEWID(),'-',''))
DECLARE @SQL VARCHAR(MAX) = CONCAT('SELECT * INTO ',@TBL,'	FROM TMP1 ')
PRINT @TBL
EXEC (@SQL)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<TableName>',@TBL)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<VariableDeclarations>',@ColumnListDataType)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<ColumnList>',@ColumnList)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<StrColumnList>',@StrColumnList)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<StrColumnList2>',@StrColumnList2)
SET @Sql_UDF = REPLACE(@Sql_UDF,'<TableName>',@TBL)

--PRINT @StrColumnList2
PRINT @Sql_UDF
EXEC (@Sql_UDF);

SELECT dbo.udf_create_json_tree1(1);
SELECT dbo.udf_create_json_tree1(2);
SELECT dbo.udf_create_json_tree1(8);
EXEC('DROP TABLE IF EXISTS dbo.'+ @TBL)

--DROP TABLE IF EXISTS Data
--CREATE TABLE Data (SerializedData nvarchar(max))
--INSERT INTO Data (SerializedData) 
--SELECT  REPLACE(dbo.udf_create_json_tree1(1) , '{}', '')
----SELECT  REPLACE(dbo.udf_create_json_tree1(2)  , '{}', '')

--SELECT * FROM Data
----UPDATE Data
----SET SerializedData = JSON_MODIFY(
----   SerializedData,
----   '$.Values',
----   JSON_QUERY(
----      (
----      SELECT CONCAT('{', STRING_AGG(CONCAT('"', [key] ,'":', [value]), ','), '}')
----      FROM OPENJSON(SerializedData, '$.Values') j
----      WHERE LEN([key]) >= 0
----      )
----   )
----)

--SELECT JSON_QUERY(d.SerializedData, '$.Values') AS [Values]
--FROM Data d


END

 