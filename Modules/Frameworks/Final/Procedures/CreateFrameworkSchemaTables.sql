--CreateTables_v1.sql and ParseJSON_v2.sql

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.CreateFrameworkSchemaTables
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		 
USAGE:          	EXEC dbo.CreateFrameworkSchemaTables @FrameworkID=1,@VersionNum=1

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/
 CREATE OR ALTER PROCEDURE dbo.CreateFrameworkSchemaTables
@NewTableName VARCHAR(100),
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

--DECLARE @NewTableName VARCHAR(100)='TAB'
DECLARE @TableInitial VARCHAR(100) = @NewTableName
DECLARE @TBL TABLE(ID INT IDENTITY(1,1),NewTableName VARCHAR(500),Item VARCHAR(MAX))
DECLARE @ID INT, @TemplateTableName VARCHAR(100),@ParentTableName VARCHAR(100), @SQL NVARCHAR(MAX) = '', @PK VARCHAR(100),@MAXID INT
DECLARE @TBL_List TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500),PK VARCHAR(100),KeyColName VARCHAR(100), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX),TableType VARCHAR(100))
DECLARE @TBL_List_Constraints TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX))
DECLARE @ConstraintSQL NVARCHAR(MAX),@HistoryTable VARCHAR(50)= '_history',@TableCheck VARCHAR(500)
DECLARE @DropConstraintsSQL NVARCHAR(MAX),@TableType VARCHAR(100),@KeyColName VARCHAR(100)
DECLARE @UQ_ConstraintName VARCHAR(MAX)

	--GET THE CURRENT VERSION NO.: THIS WILL ACTUALLY BE PASSED FROM THE PREVIOUS SCRIPT/CODE:ParseJSON_v2.sql
	--DECLARE @VersionNum INT = (SELECT MAX(VersionNum) FROM dbo.Frameworks_history)
 

--DECLARE @DropConstraints_SQL VARCHAR(MAX) = 'ALTER TABLE [dbo].[FrameworkStepItems] DROP CONSTRAINT [FK_FrameworkStepItems_StepID];
--									ALTER TABLE [dbo].[FrameworkAttributes] DROP CONSTRAINT [FK_FrameworkAttributes_StepItemID];
--									ALTER TABLE [dbo].[FrameworkLookups] DROP CONSTRAINT [FK_FrameworkLookups_StepItemID];
--									ALTER TABLE [dbo].FrameworkSteps DROP CONSTRAINT PK_FrameworkSteps_StepID;
--									ALTER TABLE [dbo].FrameworkStepItems DROP CONSTRAINT PK_FrameworkStepItems_StepItemID;
--									ALTER TABLE [dbo].FrameworkAttributes DROP CONSTRAINT PK_FrameworkAttributes_StepItemID;'


INSERT INTO @TBL_List(TemplateTableName,PK,KeyColName,ParentTableName,TableType,ConstraintSQL)
VALUES	('FrameworkLookups','LookupID','LookupValue','FrameworkStepItems','Lookups','ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemsID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]) '),
		('FrameworkAttributes','AttributeID','AttributeKey','FrameworkStepItems','Attributes','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID); ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]); '),		
		('FrameworkStepItems','StepItemID','StepItemKey','FrameworkSteps','StepItems','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID) ;ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT [FK_<TABLENAME>_StepID] FOREIGN KEY ( [StepID] ) REFERENCES [dbo].[<ParentTableName>] ([StepID]); ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT UQ_<TABLENAME>_StepItemKey UNIQUE(StepItemKey) '),
		('FrameworkSteps','StepID','StepName','','Steps','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepID PRIMARY KEY(StepID)')
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
		   @KeyColName = KeyColName,
		   @PK = PK
	FROM @TBL_List 
	WHERE ID = @ID

		 --GENERATE COLUMNS LIST FOR TEMPLATE TABLE
		 -----------------------------------------------------------------------------------------------------------------------
		 SELECT @cols = CONCAT(@cols,N', [' , [NAME], '] ' , system_type_name , CASE WHEN is_identity_column = 1 THEN ' IDENTITY(1,1) PRIMARY KEY ' END,case is_nullable WHEN 1 THEN ' NULL' ELSE ' NOT NULL' END)
		 FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.'+ @TemplateTableName , NULL, 1);

		SET @cols = STUFF(@cols, 1, 1, N'');
				
		IF @TemplateTableName LIKE '%FrameworkLookups%' OR @TemplateTableName LIKE '%FrameworkAttributes%'
			SET @SQL = CONCAT('DROP TABLE IF EXISTS [',@NewTableName, '];',CHAR(10))

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

		--CHECK IF DATA ALREADY EXISTS, IF YES THEN INCREMENT THE PK ID-----------
		SET @SQL = CONCAT('SELECT @MAXID = MAX(',@PK,') FROM ',@NewTableName)
		PRINT @SQL
		EXEC sp_executesql @SQL,N'@MAXID INT OUTPUT',@MAXID OUTPUT

		-- COMMENTING THIS OUT AS NOW WE ARE NOT INSERTING NEW RECORDS FOR EACH SAVE IF STEPITEMKEY HAS ALREADY BEEN SVED BEFORE
		--IF DATA ALREADY EXISTS THEN REORGANIZE THE PK ID OF THE TABLE TO START FROM THE LAST ID+1
		/*
		IF @MAXID IS NOT NULL
		BEGIN
		
			SET @MAXID = @MAXID + 1
			DECLARE @PKEY_NAME VARCHAR(500)
			SET @SQL = CONCAT(' SELECT @PKEY_NAME = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME=''',@TemplateTableName,''' AND CONSTRAINT_TYPE = ''PRIMARY KEY''')
			PRINT @SQL
			EXEC sp_executesql @SQL,N'@PKEY_NAME VARCHAR(500) OUTPUT',@PKEY_NAME OUTPUT
			
			SET @SQL = CONCAT('ALTER TABLE ',@TemplateTableName, ' ADD UNIQUEID INT;', CHAR(10))
			PRINT @SQL
			EXEC sp_executesql @SQL
			
			SET @SQL = CONCAT(' UPDATE ',@TemplateTableName, ' SET UNIQUEID = ',@MAXID,'+',@PK,';', CHAR(10))
			IF @PKEY_NAME IS NOT NULL
				SET @SQL = CONCAT(@SQL, ' ALTER TABLE ',@TemplateTableName, ' DROP CONSTRAINT ',@PKEY_NAME,';', CHAR(10))
			
			SET @SQL = CONCAT(@SQL, ' ALTER TABLE ',@TemplateTableName, ' DROP COLUMN ',@PK,';', CHAR(10))
			--PRINT @SQL
			--EXEC sp_executesql @SQL			
			SET @SQL = CONCAT(@SQL,' EXEC sp_rename ''',@TemplateTableName,'.UNIQUEID'',''',@PK,''',''COLUMN''',';', CHAR(10))	
			PRINT @SQL
			EXEC sp_executesql @SQL		
			
		END	
		*/
		-------------------------------------------------------------------------
		
		SET @SQL = CONCAT('INSERT INTO dbo.[',@NewTableName,'](', @cols, ') ', CHAR(10))	
		IF @TemplateTableName = 'FrameworkSteps'
		BEGIN			  
			/*
			SELECT * FROM FrameworkSteps
			
			SELECT  [UserCreated] , [DateCreated] , [UserModified] , [DateModified] , [VersionNum] , [FrameworkID] , [StepName] , ROW_NUMBER()OVER(ORDER BY (SELECT NULL))+ ISNULL(@MaxID,0) AS StepID
			 FROM FrameworkSteps T
			WHERE NOT EXISTS(SELECT 1 FROM dbo.[BWEFindings_FrameworkSteps] WHERE FrameworkID=4 AND StepName = T.StepName);
			SELECT @cols,@PK
			*/
			IF @MaxID IS NULL SET @MaxID = 0

			SET @cols = REPLACE(@cols,CONCAT('[',@PK,']'),CONCAT('ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + ',@MaxID))
		END
		SET @SQL = CONCAT(@SQL, 'SELECT ', @cols, CHAR(10), ' FROM ', @TemplateTableName,' T', CHAR(10))		
		SET @SQL = CONCAT(@SQL, 'WHERE NOT EXISTS(SELECT 1 FROM dbo.[',@NewTableName, '] WHERE FrameworkID=',@FrameworkID,' AND ',@KeyColName,' = T.',@KeyColName,');', CHAR(10))
		IF @TemplateTableName NOT LIKE '%FrameworkStepItems%' AND @TemplateTableName NOT LIKE '%FrameworkLookups%' 
		SET @SQL = CONCAT('SET IDENTITY_INSERT [',@NewTableName,'] ON ;', CHAR(10),@SQL, CHAR(10),'SET IDENTITY_INSERT [',@NewTableName,'] OFF ;')
		PRINT @SQL
		EXEC sp_executesql @SQL
	
		IF @TemplateTableName LIKE '%FrameworkStepItems%' OR @TemplateTableName LIKE '%FrameworkLookups%'
		BEGIN
			DECLARE @IsExistingPK BIT = 0

			SET @SQL = CONCAT('IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME =''',@NewTableName,''' AND CONSTRAINT_TYPE = ''PRIMARY KEY'')', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsExistingPK = 1; ', CHAR(10))
			PRINT @SQL  
			EXEC sp_executesql @SQL, N'@IsExistingPK BIT OUTPUT',@IsExistingPK OUTPUT;

			IF @IsExistingPK  = 1
			BEGIN
				IF @TemplateTableName LIKE '%FrameworkStepItems%'
					SET @SQL = CONCAT('ALTER TABLE ',@NewTableName,' ADD CONSTRAINT PK_',@NewTableName,'_StepItemID PRIMARY KEY(StepItemID)')
				ELSE
					SET @SQL = CONCAT('ALTER TABLE ',@NewTableName,' ADD CONSTRAINT PK_',@NewTableName,'_LookupID PRIMARY KEY(LookupID)')

				PRINT @SQL
				EXEC sp_executesql @SQL
			END

			--CREATE UNIQUE CONSTRAINT ON Lookups
			IF @TemplateTableName LIKE '%FrameworkLookups%'
			BEGIN	
				SET @UQ_ConstraintName = CONCAT('ÚQ_',@NewTableName,'_LookupName');

				IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = @NewTableName AND CONSTRAINT_NAME = @UQ_ConstraintName)
				BEGIN
					SET @SQL = CONCAT(' ALTER TABLE dbo.[',@NewTableName,'] ADD CONSTRAINT ', @UQ_ConstraintName, ' UNIQUE(FrameworkID,StepItemID,LookupName)')
					PRINT @SQL
					EXEC sp_executesql @SQL
				END
			END

		END		
		------------------------------------------------------------------------------------------------------------------------------------------------
		--1. KEY MOVED TO A DIFFERENT STEP: UPDATE FROM FrameworkStepItems
		--2. CREATE UNIQUE CONSTRAINT ON StepItemKey
		IF @NewTableName LIKE '%_FrameworkStepItems'
		BEGIN
			
			SET @UQ_ConstraintName = CONCAT('ÚQ_',@NewTableName,'_StepItemKey');

			--CREATE UNIQUE CONSTRAINT ON StepItemKey
			IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = @NewTableName AND CONSTRAINT_NAME = @UQ_ConstraintName)
			BEGIN
				SET @SQL = CONCAT(' ALTER TABLE dbo.[',@NewTableName,'] ADD CONSTRAINT ', @UQ_ConstraintName, ' UNIQUE(StepItemKey)')
				PRINT @SQL
				EXEC sp_executesql @SQL
			END

			--CHECK IF KEY MOVED TO A DIFFERENT STEP
			SET @SQL = CONCAT('UPDATE TBL',CHAR(10))		
			SET @SQL = CONCAT(@SQL, 'SET StepID = T.StepID', CHAR(10))
			SET @SQL = CONCAT(@SQL, 'FROM ', @TemplateTableName,' T INNER JOIN dbo.[',@NewTableName,'] TBL ON T.FrameworkID=TBL.FrameworkID AND T.',@KeyColName,' = TBL.',@KeyColName, CHAR(10)) --@KeyColName=StepItemKey		
			SET @SQL = CONCAT(@SQL, 'WHERE T.StepID <> TBL.StepID', CHAR(10))
			PRINT @SQL
			EXEC sp_executesql @SQL
		END
		-----------------------------------------------------------------------------------------------------------------------------------------------

		--UPDATE VERSION NUMBER		
		--SET @SQL = CONCAT('UPDATE dbo.[',@NewTableName,']',CHAR(10))		
		--SET @SQL = CONCAT(@SQL, 'SET VersionNum = ',@VersionNum, CHAR(10))
		--SET @SQL = CONCAT(@SQL, 'WHERE FrameworkID = ',@FrameworkID, CHAR(10))
		--PRINT @SQL
		--EXEC sp_executesql @SQL
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

		SET @SQL = CONCAT('INSERT INTO dbo.[',@NewTableName,@HistoryTable,'](', @cols, ') ', CHAR(10))		
		--IF @VersionNum = 1
		--	SET @cols = REPLACE(@cols,'[OperationType]','''INSERT''')
		SET @SQL = CONCAT(@SQL, 'SELECT ', @cols, CHAR(10), ' FROM ', @TemplateTableName,@HistoryTable,';', CHAR(10))		
		PRINT @SQL
		EXEC sp_executesql @SQL 

		SET @SQL = ''

		--UPDATE CURRENT IDENTIFIER IN HISTORY TABLE FOR OLDER VERSIONS
		SET @SQL = CONCAT('UPDATE dbo.[',@NewTableName,@HistoryTable,']',CHAR(10))		
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
	
	/* COMMENTING THIS OUT AS NOW WE ARE NOT INSERTING NEW RECORDS FOR EACH SAVE IF STEPITEMKEY HAS ALREADY BEEN SVED BEFORE
	 --ADDING PK & IDENTITY BACK TO THE TEMPLATE TABLE	
	 IF @MAXID IS NOT NULL 
	 BEGIN		
		 SET @SQL = CONCAT(' ALTER TABLE ',@TemplateTableName,' DROP COLUMN ',@PK,';',CHAR(10))
		 SET @SQL = CONCAT(@SQL,' ALTER TABLE ',@TemplateTableName,' ADD ',@PK,' INT IDENTITY(1,1) NOT NULL;',CHAR(10))		 
		 PRINT @SQL
		 EXEC sp_executesql @SQL

		 IF @PKEY_NAME IS NOT NULL
			SET @SQL = CONCAT(' ALTER TABLE ',@TemplateTableName,' ADD CONSTRAINT ', @PKEY_NAME,' PRIMARY KEY(',@PK,');',CHAR(10))

		 PRINT @SQL
		 EXEC sp_executesql @SQL
	 END
	 */
	  SET @SQL = ''
END
		
		--UPDATE OPERATION TYPE FLAG IN FRAMEWORK HISTORY TABLES==============================================
		IF @VersionNum > 1
			EXEC dbo.UpdateFrameworkHistoryOperationType @FrameworkID = @FrameworkID, @TableInitial = @TableInitial, @VersionNum = @VersionNum	
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