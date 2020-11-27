--CreateTables_v1.sql and ParseJSON_v2.sql
USE JUNK
GO
 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.CreateSchemaTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		 
USAGE:          	EXEC dbo.CreateSchemaTables @FrameworkID=1,@VersionNum=1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/
 CREATE OR ALTER PROCEDURE dbo.CreateSchemaTables
@FrameworkID INT,
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON;
	PRINT 'STARTING CreateSchemaTables...'

--DROP TABLE IF EXISTS TAB_FrameworkLookups
--drop table IF EXISTS TAB_FrameworkAttributes
--drop table IF EXISTS TAB_FrameworkStepItems
--drop table IF EXISTS TAB_FrameworkSteps
--DROP TABLE IF EXISTS TAB_Frameworks

/*
USE JUNK
GO
DROP TABLE IF EXISTS TAB_FrameworkLookups_history
drop table IF EXISTS TAB_FrameworkAttributes_history
drop table IF EXISTS TAB_FrameworkStepItems_history
drop table IF EXISTS TAB_FrameworkSteps_history
--DROP TABLE IF EXISTS TAB_Frameworks_history
*/

DECLARE @NewTableName VARCHAR(100)='TAB'
DECLARE @TableInitial VARCHAR(100) = @NewTableName
DECLARE @TBL TABLE(ID INT IDENTITY(1,1),NewTableName VARCHAR(500),Item VARCHAR(MAX))
DECLARE @ID INT, @TemplateTableName VARCHAR(100),@ParentTableName VARCHAR(100), @SQL NVARCHAR(MAX) = ''
DECLARE @TBL_List TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500),KeyColName VARCHAR(100), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX),TableType VARCHAR(100))
DECLARE @TBL_List_Constraints TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX))
DECLARE @ConstraintSQL NVARCHAR(MAX),@HistoryTable VARCHAR(50)= '_history',@TableCheck VARCHAR(500)
DECLARE @DropConstraintsSQL NVARCHAR(MAX),@TableType VARCHAR(100),@KeyColName VARCHAR(100)


	--GET THE CURRENT VERSION NO.: THIS WILL ACTUALLY BE PASSED FROM THE PREVIOUS SCRIPT/CODE:ParseJSON_v2.sql
	--DECLARE @VersionNum INT = (SELECT MAX(VersionNum) FROM dbo.Frameworks_history)
 

--DECLARE @DropConstraints_SQL VARCHAR(MAX) = 'ALTER TABLE [dbo].[FrameworkStepItems] DROP CONSTRAINT [FK_FrameworkStepItems_StepID];
--									ALTER TABLE [dbo].[FrameworkAttributes] DROP CONSTRAINT [FK_FrameworkAttributes_StepItemID];
--									ALTER TABLE [dbo].[FrameworkLookups] DROP CONSTRAINT [FK_FrameworkLookups_StepItemID];
--									ALTER TABLE [dbo].FrameworkSteps DROP CONSTRAINT PK_FrameworkSteps_StepID;
--									ALTER TABLE [dbo].FrameworkStepItems DROP CONSTRAINT PK_FrameworkStepItems_StepItemID;
--									ALTER TABLE [dbo].FrameworkAttributes DROP CONSTRAINT PK_FrameworkAttributes_StepItemID;'


INSERT INTO @TBL_List(TemplateTableName,KeyColName,ParentTableName,TableType,ConstraintSQL)
VALUES	('FrameworkLookups','LookupValue','FrameworkStepItems','Lookups','ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemsID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]) '),
		('FrameworkAttributes','AttributeKey','FrameworkStepItems','Attributes','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID); ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]); '),		
		('FrameworkStepItems','StepItemKey','FrameworkSteps','StepItems','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID) ;ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT [FK_<TABLENAME>_StepID] FOREIGN KEY ( [StepID] ) REFERENCES [dbo].[<ParentTableName>] ([StepID]) '),
		('FrameworkSteps','StepName','','Steps','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepID PRIMARY KEY(StepID)')
		--,('Frameworks','Name','','','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_ID PRIMARY KEY(ID)')

	INSERT INTO @TBL_List_Constraints(TemplateTableName)
		SELECT TemplateTableName FROM @TBL_List	

UPDATE @TBL_List SET NewTableName = CONCAT(@NewTableName,'_',TemplateTableName)
UPDATE @TBL_List SET ParentTableName = CONCAT(@NewTableName,'_',ParentTableName) WHERE ParentTableName <> ''

DROP TABLE IF EXISTS #TBL_ConstraintsList
SELECT * INTO #TBL_ConstraintsList FROM @TBL_List

DROP TABLE IF EXISTS #TBL_OperationTypeList
SELECT IDENTITY(INT,1,1) AS ID,TemplateTableName,KeyColName,TableType INTO #TBL_OperationTypeList FROM @TBL_List WHERE TableType <> ''

 DECLARE @cols NVARCHAR(MAX) = N''
--SELECT * FROM @TBL_List

WHILE EXISTS(SELECT 1 FROM @TBL_List)
BEGIN
	 
	SELECT @ID = MIN(ID) FROM @TBL_List

	SELECT @TemplateTableName = TemplateTableName,
		   @NewTableName = NewTableName,
		   @ParentTableName = ParentTableName,
		   @ConstraintSQL = ConstraintSQL,
		   @TableType = TableType,
		   @KeyColName = KeyColName
	FROM @TBL_List 
	WHERE ID = @ID

		 --GENERATE COLUMNS LIST FOR TEMPLATE TABLE
		 -----------------------------------------------------------------------------------------------------------------------
		 SELECT @cols = CONCAT(@cols,N', [' , [NAME], '] ' , system_type_name , CASE WHEN is_identity_column = 1 THEN ' IDENTITY(1,1) PRIMARY KEY ' END,case is_nullable WHEN 1 THEN ' NULL' ELSE ' NOT NULL' END)
		 FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.'+ @TemplateTableName , NULL, 1);

		SET @cols = STUFF(@cols, 1, 1, N'');
				
		IF @TemplateTableName LIKE '%FrameworkLookups%' OR @TemplateTableName LIKE '%FrameworkAttributes%'
			SET @SQL = CONCAT('DROP TABLE IF EXISTS ',@NewTableName, ';',CHAR(10))

		SET @SQL = CONCAT(@SQL,'IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME =''',@NewTableName,''')', CHAR(10))
		SET @SQL = CONCAT(@SQL, N' CREATE TABLE dbo.[', @NewTableName , '](', @cols, ') ', CHAR(10), CHAR(10))
		--SET @TableCheck = CONCAT('IF NOT EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME=''',@NewTableName ,''')')
		--SET @SQL = CONCAT(@TableCheck,CHAR(10),@SQL,';', CHAR(10), CHAR(10))	
		PRINT @SQL
		--CREATE THE ACTUAL TABLE BASED ON THE TEMPLATE TABLE SCHEMA
		EXEC sp_executesql @SQL 

		SELECT @SQL = '', @cols = ''

		--INSERT DATA INTO MAIN TABLE
		SELECT @cols += N', [' + name + '] ' 
		FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM dbo.', @TemplateTableName) , NULL, 1);		

		SET @cols = STUFF(@cols, 1, 1, N'');
		
		SET @SQL = CONCAT('INSERT INTO dbo.',@NewTableName,'(', @cols, ') ', CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'SELECT ', @cols, CHAR(10), ' FROM ', @TemplateTableName,' T', CHAR(10))
		SET @SQL = CONCAT(@SQL, 'WHERE NOT EXISTS(SELECT 1 FROM dbo.',@NewTableName, ' WHERE VersionNum = ', @VersionNum,' AND FrameworkID=',@FrameworkID,' AND ',@KeyColName,' = T.',@KeyColName,');', CHAR(10))
		--IF @TemplateTableName NOT LIKE '%FrameworkLookups%'
		SET @SQL = CONCAT('SET IDENTITY_INSERT ',@NewTableName,' ON ;', CHAR(10),@SQL, CHAR(10),'SET IDENTITY_INSERT ',@NewTableName,' OFF ;')
		PRINT @SQL
		EXEC sp_executesql @SQL 

		--UPDATE VERSION NUMBER		
		SET @SQL = CONCAT('UPDATE dbo.',@NewTableName,CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'SET VersionNum = ',@VersionNum, CHAR(10))
		SET @SQL = CONCAT(@SQL, 'WHERE FrameworkID = ',@FrameworkID, CHAR(10))
		PRINT @SQL
		EXEC sp_executesql @SQL
		---------------------------------------------------------------------------------------------------------------------------
	
		SELECT @SQL = '', @cols = ''

		 --GENERATE COLUMNS LIST FOR HISTORY TEMPLATE TABLE
		 -----------------------------------------------------------------------------------------------------------------------
		 SELECT @cols = CONCAT(@cols,N', [' + name + '] ', system_type_name,  CASE WHEN is_identity_column = 1 THEN ' IDENTITY(1,1) PRIMARY KEY ' END,case is_nullable when 1 then ' NULL' else ' NOT NULL' end)
		 FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM dbo.', @TemplateTableName,@HistoryTable) , NULL, 1);

		SET @cols = STUFF(@cols, 1, 1, N'');

		--SET @SQL = CONCAT('DROP TABLE IF EXISTS ',@NewTableName)
		SET @SQL = CONCAT(N' CREATE TABLE dbo.[', @NewTableName ,@HistoryTable, '](', @cols, ') ')		
		SET @TableCheck = CONCAT('IF NOT EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME=''',@NewTableName ,@HistoryTable,''')')
		SET @SQL = CONCAT(@TableCheck,CHAR(10),@SQL,';', CHAR(10), CHAR(10))		
			
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
		--IF @VersionNum = 1
		--	SET @cols = REPLACE(@cols,'[OperationType]','''INSERT''')
		SET @SQL = CONCAT(@SQL, 'SELECT ', @cols, CHAR(10), ' FROM ', @TemplateTableName,@HistoryTable,';', CHAR(10))		
		PRINT @SQL
		EXEC sp_executesql @SQL 

		SET @SQL = ''

		--UPDATE CURRENT IDENTIFIER IN HISTORY TABLE FOR OLDER VERSIONS
		SET @SQL = CONCAT('UPDATE dbo.',@NewTableName,@HistoryTable,CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'SET PeriodIdentifierID = 0', CHAR(10))
		SET @SQL = CONCAT(@SQL, 'WHERE FrameworkID = ',@FrameworkID, ' AND VersionNum < ',@VersionNum, CHAR(10))		
		PRINT @SQL
		EXEC sp_executesql @SQL

		SET @SQL = ''
		
		--UPDATE VERSION NUMBER (THIS APPLIES ONLY TO LIST/STEPS/STEPITEMS TABLES)			
		--SET @SQL = CONCAT('UPDATE dbo.',@NewTableName,@HistoryTable,CHAR(10))		
		--SET @SQL = CONCAT(@SQL, 'SET VersionNum = ',@VersionNum, CHAR(10))
		--SET @SQL = CONCAT(@SQL, 'WHERE FrameworkID = ',@FrameworkID, CHAR(10))
		--SET @SQL = CONCAT(@SQL, ' AND ''',@NewTableName,''' LIKE ''%List%'' OR ''',@NewTableName,''' LIKE ''%Steps%'' OR ''',@NewTableName,''' LIKE ''%StepItems%'' ', CHAR(10))
		--PRINT @SQL
		--EXEC sp_executesql @SQL		
		---------------------------------------------------------------------------------------------------------------------------
		--RETURN
			
	DELETE FROM @TBL_List WHERE ID = @ID
	DELETE FROM @TBL WHERE NewTableName = @NewTableName
	SELECT @cols = '',@SQL='',@DropConstraintsSQL=''
	--RETURN
END
		
		--UPDATE OPERATION TYPE FLAG IN FRAMEWORK HISTORY TABLES==============================================
		IF @VersionNum > 1
			EXEC dbo.UpdateHistoryOperationType @FrameworkID = @FrameworkID, @TableInitial = @TableInitial, @VersionNum = @VersionNum		
		--====================================================================================================

		 --SELECT * FROM @TBL		 	 
		 --SELECT * FROM #TBL_ConstraintsList
		 DROP TABLE IF EXISTS #TBL_List
		 SELECT * INTO #TBL_List FROM #TBL_ConstraintsList

		-- SELECT * FROM #TBL_List
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
		
		PRINT 'CreateSchemaTables Completed...'
END		