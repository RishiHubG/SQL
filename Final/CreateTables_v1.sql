USE JUNK
GO
 

DROP TABLE IF EXISTS TAB_Framework_Metafield_Lookups
drop table IF EXISTS TAB_Framework_Metafield_Attributes
drop table IF EXISTS TAB_Framework_Metafield
drop table IF EXISTS TAB_Framework_Metafield_steps
DROP TABLE IF EXISTS TAB_Frameworks_List

/*
DROP TABLE IF EXISTS TAB_Framework_Metafield_Lookups_history
drop table IF EXISTS TAB_Framework_Metafield_Attributes_history
drop table IF EXISTS TAB_Framework_Metafield_history
drop table IF EXISTS TAB_Framework_Metafield_steps_history
DROP TABLE IF EXISTS TAB_Frameworks_List_history
*/

DECLARE @NewTableName VARCHAR(100)='TAB'
DECLARE @TBL TABLE(ID INT IDENTITY(1,1),NewTableName VARCHAR(500),Item VARCHAR(MAX))
DECLARE @ID INT, @TemplateTableName VARCHAR(100),@ParentTableName VARCHAR(100), @SQL NVARCHAR(MAX)
DECLARE @TBL_List TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX))
DECLARE @TBL_List_Constraints TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX))
DECLARE @ConstraintSQL NVARCHAR(MAX),@HistoryTable VARCHAR(50)= '_history',@HistoryTableCheck VARCHAR(500)
DECLARE @DropConstraintsSQL NVARCHAR(MAX),@AddHistoryIdentitySQL VARCHAR(100) = ' ALTER TABLE DBO.T1 ALTER COLUMN HistoryID INT IDENTITY(1,1)' 

--DECLARE @DropConstraints_SQL VARCHAR(MAX) = 'ALTER TABLE [dbo].[Framework_Metafield] DROP CONSTRAINT [FK_Framework_Metafield_StepID];
--									ALTER TABLE [dbo].[Framework_Metafield_Attributes] DROP CONSTRAINT [FK_Framework_Metafield_Attributes_MetaFieldID];
--									ALTER TABLE [dbo].[Framework_Metafield_Lookups] DROP CONSTRAINT [FK_Framework_Metafield_Lookups_MetaFieldAttributeID];
--									ALTER TABLE [dbo].Framework_Metafield_Steps DROP CONSTRAINT PK_Framework_Metafield_StepID;
--									ALTER TABLE [dbo].Framework_Metafield DROP CONSTRAINT PK_Framework_Metafield_MetaFieldID;
--									ALTER TABLE [dbo].Framework_Metafield_Attributes DROP CONSTRAINT PK_Framework_Metafield_Attributes_MetaFieldAttributeID;'


INSERT INTO @TBL_List(TemplateTableName,ParentTableName,ConstraintSQL)
VALUES	('Framework_Metafield_Lookups','Framework_Metafield','ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_MetaFieldAttributeID] FOREIGN KEY ( [MetaFieldID] ) REFERENCES [dbo].[<ParentTableName>] ([MetaFieldID]) '),
		('Framework_Metafield_Attributes','Framework_Metafield','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_MetaFieldAttributeID  PRIMARY KEY(MetaFieldAttributeID); ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_MetaFieldID] FOREIGN KEY ( [MetaFieldID] ) REFERENCES [dbo].[<ParentTableName>] ([MetaFieldID]); '),		
		('Framework_Metafield','Framework_Metafield_Steps','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_MetaFieldID  PRIMARY KEY(MetaFieldID) ;ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT [FK_<TABLENAME>_StepID] FOREIGN KEY ( [StepID] ) REFERENCES [dbo].[<ParentTableName>] ([StepID]) '),
		('Framework_Metafield_Steps','','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepID PRIMARY KEY(StepID)'),
		('Frameworks_List','','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_ID PRIMARY KEY(ID)')

	INSERT INTO @TBL_List_Constraints(TemplateTableName)
		SELECT TemplateTableName FROM @TBL_List	

UPDATE @TBL_List SET NewTableName = CONCAT(@NewTableName,'_',TemplateTableName)
UPDATE @TBL_List SET ParentTableName = CONCAT(@NewTableName,'_',ParentTableName) WHERE ParentTableName <> ''

DROP TABLE IF EXISTS #TBL_ConstraintsList
SELECT * INTO #TBL_ConstraintsList FROM @TBL_List

 DECLARE @cols NVARCHAR(MAX) = N''
--SELECT * FROM @TBL_List

WHILE EXISTS(SELECT 1 FROM @TBL_List)
BEGIN
	 
	SELECT @ID = MIN(ID) FROM @TBL_List

	SELECT @TemplateTableName = TemplateTableName,
		   @NewTableName = NewTableName,
		   @ParentTableName = ParentTableName,
		   @ConstraintSQL = ConstraintSQL
	FROM @TBL_List 
	WHERE ID = @ID

		 --GENERATE COLUMNS LIST FOR TEMPLATE TABLE
		 -----------------------------------------------------------------------------------------------------------------------
		SELECT @cols += N', [' + name + '] ' + system_type_name + case is_nullable when 1 then ' NULL' else ' NOT NULL' end
		 FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.'+ @TemplateTableName , NULL, 1);

		SET @cols = STUFF(@cols, 1, 1, N'');

		--SET @SQL = CONCAT('DROP TABLE IF EXISTS ',@NewTableName)
		SET @SQL = CONCAT(@SQL, N'; CREATE TABLE ', @NewTableName , '(', @cols, ') ', CHAR(10), CHAR(10))
			
		PRINT @SQL
		--CREATE THE ACTUAL TABLE BASED ON THE TEMPLATE TABLE SCHEMA
		EXEC sp_executesql @SQL 
		---------------------------------------------------------------------------------------------------------------------------
	
		SELECT @SQL = '', @cols = ''

		 --GENERATE COLUMNS LIST FOR HISTORY TEMPLATE TABLE
		 -----------------------------------------------------------------------------------------------------------------------
		 SELECT @cols += N', [' + name + '] ' + system_type_name + case is_nullable when 1 then ' NULL' else ' NOT NULL' end + 
						CASE WHEN is_identity_column = 1 THEN ' IDENTITY(1,1) ' ELSE '' END
		 FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM dbo.', @TemplateTableName,@HistoryTable) , NULL, 1);

		SET @cols = STUFF(@cols, 1, 1, N'');

		--SET @SQL = CONCAT('DROP TABLE IF EXISTS ',@NewTableName)
		SET @SQL = CONCAT(N' CREATE TABLE ', @NewTableName ,@HistoryTable, '(', @cols, ') ')		
		SET @HistoryTableCheck = CONCAT('IF NOT EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME=''',@NewTableName ,@HistoryTable,''')')
		SET @SQL = CONCAT(@HistoryTableCheck,CHAR(10),@SQL,';', CHAR(10), CHAR(10))		
			
		PRINT @SQL
		--CREATE THE ACTUAL HISTORY TABLE BASED ON THE TEMPLATE TABLE SCHEMA
		EXEC sp_executesql @SQL 

		SELECT @SQL = '', @cols = ''

		--INSERT DATA INTO HISTORY TABLE		
		SELECT @cols += N', [' + name + '] ' 
		FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM dbo.', @TemplateTableName,@HistoryTable) , NULL, 1)
		WHERE NAME <> 'HistoryID';

		SET @cols = STUFF(@cols, 1, 1, N'');

		SET @SQL = CONCAT('INSERT INTO dbo.',@NewTableName,@HistoryTable,'(', @cols, ') ', CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'SELECT ', @cols, CHAR(10), ' FROM ', @TemplateTableName,@HistoryTable)
		PRINT @SQL
		EXEC sp_executesql @SQL 

		--TO DO: UPDATE CURRENT IDENTIFIER IN HISTORY TABLE
		---------------------------------------------------------------------------------------------------------------------------
		--RETURN


	--GENERATE CONSTRAINTS(PK/FK)
	--SET @ConstraintSQL = REPLACE(@ConstraintSQL,'<TABLENAME>',@NewTableName)
	--SET @ConstraintSQL = REPLACE(@ConstraintSQL,'<ParentTableName>',@ParentTableName)
	--PRINT @ConstraintSQL
	--EXEC sp_executesql @ConstraintSQL 
	--return
	---- PARTITION SWITCH PARTITION
	--SET @SQL = CONCAT('ALTER TABLE ', @TemplateTableName,' SWITCH PARTITION 1 TO ',@NewTableName,' PARTITION 1');
 
	--EXEC sp_executesql @SQL 
	--PRINT @sql  
	
	
	--DROP EXISTING CONSTRAINTS PRIOR TO MOVING DATA
	SET @DropConstraintsSQL = STUFF
						(
						(						 
						SELECT  
							CONCAT(' ;','ALTER TABLE [dbo].',OBJECT_NAME(O.parent_object_id),' DROP CONSTRAINT ',OBJECT_NAME(O.OBJECT_ID))
						FROM sys.objects O
								INNER JOIN sys.tables t on t.object_id=o.parent_object_id
							WHERE o.type_desc IN ('PRIMARY_KEY_CONSTRAINT','FOREIGN_KEY_CONSTRAINT')
								AND schema_name(t.schema_id)= 'dbo' 
								AND t.name = @TemplateTableName						 
						FOR XML PATH ('')
						)
						,1,1,'')
		PRINT @DropConstraintsSQL
		EXEC sp_executesql @DropConstraintsSQL 
	
		---- MOVE DATA: PARTITION SWITCH PARTITION
		SET @SQL = CONCAT('ALTER TABLE ', @TemplateTableName,' SWITCH PARTITION 1 TO ',@NewTableName,' PARTITION 1');
 
		EXEC sp_executesql @SQL 
		PRINT @sql  	
			
	DELETE FROM @TBL_List WHERE ID = @ID
	DELETE FROM @TBL WHERE NewTableName = @NewTableName
	SELECT @cols = '',@SQL='',@DropConstraintsSQL=''
	--RETURN
END
		
		 --SELECT * FROM @TBL		 	 
		 --SELECT * FROM #TBL_ConstraintsList
		 DROP TABLE IF EXISTS #TBL_List
		 SELECT * INTO #TBL_List FROM #TBL_ConstraintsList

		 SELECT * FROM #TBL_List
		 --RETURN

 /*
--MOVE DATA FROM TEMPLATE TABLES TO FRAMEWORK & FRAMEWORK HISTORY TABLES
WHILE EXISTS(SELECT 1 FROM #TBL_List)
BEGIN
	 
	SELECT @ID = MIN(ID) FROM #TBL_List

	SELECT @TemplateTableName = TemplateTableName,
		   @NewTableName = NewTableName,
		   @ParentTableName = ParentTableName,
		   @ConstraintSQL = ConstraintSQL
	FROM #TBL_List 
	WHERE ID = @ID
			 
	 
	---- PARTITION SWITCH PARTITION
	SET @SQL = CONCAT('ALTER TABLE ', @TemplateTableName,' SWITCH PARTITION 1 TO ',@NewTableName,' PARTITION 1');
 
	EXEC sp_executesql @SQL 
	PRINT @sql  

	---- PARTITION SWITCH PARTITION: FOR HISTORY TABLES
	SET @SQL = CONCAT('ALTER TABLE ', @TemplateTableName,@HistoryTable,' SWITCH PARTITION 1 TO ',@NewTableName,@HistoryTable,' PARTITION 1');	
	EXEC sp_executesql @SQL 
	PRINT @sql  
			
	DELETE FROM #TBL_List WHERE ID = @ID
	DELETE FROM #TBL_List WHERE NewTableName = @NewTableName
	SELECT @SQL=''
	--RETURN
END		
*/
		
		SELECT * from TAB_Frameworks_List
		SELECT * FROM  TAB_Framework_Metafield_steps
		SELECT * FROM  TAB_Framework_Metafield
		SELECT * FROM TAB_Framework_Metafield_Attributes		
		SELECT * FROM TAB_Framework_Metafield_Lookups
		

		SELECT * FROM Framework_Metafield_Lookups
		SELECT * FROM Framework_Metafield_Attributes
		SELECT * FROM  Framework_Metafield
		SELECT * FROM  Framework_Metafield_steps

		SELECT * from TAB_Frameworks_List_history
		SELECT * FROM  TAB_Framework_Metafield_steps_history
		SELECT * FROM  TAB_Framework_Metafield_history
		SELECT * FROM TAB_Framework_Metafield_Attributes_history		
		SELECT * FROM TAB_Framework_Metafield_Lookups_history
		