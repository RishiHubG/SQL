SELECT * FROM Framework_Metafield_Steps_1_1


drop table Framework_Metafield_Steps_1_1

exec sp_GetDDLa 'Framework_Metafield_Attributes'

DROP TABLE [dbo].[TAB_Framework_Metafield_Steps]
DROP TABLE TAB_Framework_Metafield_Steps
DROP TABLE TAB_Framework_Metafield
DROP TABLE TAB_Framework_Metafield_Attributes
DROP TABLE TAB_Framework_Metafield_Lookups

--Framework_Metafield_Steps
--Framework_Metafield
--Framework_Metafield_Attributes
--Framework_Metafield_Lookups


DECLARE @NewTableName VARCHAR(100)='TAB'
DECLARE @TBL TABLE(ID INT IDENTITY(1,1),NewTableName VARCHAR(500),Item VARCHAR(MAX))
DECLARE @ID INT, @TemplateTableName VARCHAR(100),@ParentTableName VARCHAR(100), @SQL NVARCHAR(MAX)
DECLARE @TBL_List TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500), NewTableName VARCHAR(500),ParentTableName VARCHAR(500))

INSERT INTO @TBL_List(TemplateTableName,ParentTableName)
VALUES('Framework_Metafield_Steps',''),
		('Framework_Metafield','Framework_Metafield_Steps'),
		('Framework_Metafield_Attributes','Framework_Metafield'),
		('Framework_Metafield_Lookups','Framework_Metafield_Attributes')

UPDATE @TBL_List SET NewTableName = CONCAT(@NewTableName,'_',TemplateTableName)

--SELECT * FROM @TBL_List

WHILE EXISTS(SELECT 1 FROM @TBL_List)
BEGIN
	 
	SELECT @ID = MIN(ID) FROM @TBL_List

	SELECT @TemplateTableName = TemplateTableName,
		   @NewTableName = NewTableName,
		   @ParentTableName = ParentTableName
	FROM @TBL_List 
	WHERE ID = @ID

	INSERT INTO @TBL (Item)
		EXEC sp_GetDDLa @TemplateTableName
	 
	UPDATE @TBL
		SET Item = REPLACE(Item,'<TABLENAME>',@NewTableName),			 
			NewTableName = @NewTableName
	WHERE NewTableName IS NULL
		 
	UPDATE @TBL
		SET Item = REPLACE(Item,'<ParentTableName>',@ParentTableName)
	UPDATE @TBL
		SET Item = REPLACE(Item,',','')
	
	DELETE FROM @TBL WHERE NewTableName =  @NewTableName AND Item = ''
	SELECT * FROM @TBL
	--RETURN
	SET @SQL = STUFF
				((SELECT CONCAT(', ',Item)
				FROM @TBL 
				WHERE NewTableName =  @NewTableName
					  AND ID>=2
				FOR XML PATH ('')
				),1,1,'')
					
	PRINT @SQL
	--EXEC sp_executesql @SQL 
	return
	-- PARTITION SWITCH PARTITION
	SET @SQL = 'ALTER TABLE ' + @TemplateTableName  + ' SWITCH PARTITION 1 TO ' + @NewTableName + ' PARTITION 1';
 
	EXEC sp_executesql @sql 
	PRINT @sql  
			
	DELETE FROM @TBL_List WHERE ID = @ID
	DELETE FROM @TBL WHERE NewTableName = @NewTableName
	RETURN
END
		
		 SELECT * FROM @TBL

	

