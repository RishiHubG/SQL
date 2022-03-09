--https://www.red-gate.com/simple-talk/blogs/consuming-hierarchical-json-documents-sql-server-using-openjson/
--CreateTables_v1.sql and ParseJSON_v2.sql
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseFrameworkJSONData
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		NOTES:
					Steps: ASSUMPTION: 1. STEPS VERSIONING CAN ONLY BE LIMITED TO INSERT OR DELETE (i.e. A STEP(A TAB) CAN BE ADDED OR REMOVED ONLY)
									   2. STEPNAME/STEPITEM (FOR _DATA COLUMNS) WILL BE IN FORMAT: STEPNAME.STEPITEM 
										  IT CAN HAVE MULTIPLE DOTS IN BETWEEN BUT TEXT BEFORE THE 1ST DOT IS ALWAYS A STEP NAME, TEXT AFTER THE LAST DOT IS ALWAYS A STEP ITEM (FOR _DATA COLUMNS)
										  SO THE FIRST PART IS STEPNAME, THE LAST PART IS THE NAME OF THE COLUMN FOR _DATA TABLE, THE STEPITEM NAME IS THE ONE WITH "LABEL"
USAGE:          	EXEC dbo.ParseFrameworkJSONData  @Name = 'TAB',
													 @UserLoginID=100,
													 @inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.ParseFrameworkJSONData
@Name VARCHAR(100),
@InputJSON VARCHAR(MAX),
@FullSchemaJSON VARCHAR(MAX),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL, 
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     
	
	IF @UserID IS NOT NULL
	BEGIN

	 
	 DECLARE @Params VARCHAR(MAX),
			 @ObjectName VARCHAR(100)

--EMPTY THE TEMPLATE TABLES----------------------
TRUNCATE TABLE dbo.FrameworkLookups_history
TRUNCATE TABLE dbo.FrameworkAttributes_history
TRUNCATE TABLE dbo.FrameworkStepItems_history
TRUNCATE TABLE dbo.FrameworkSteps_history

TRUNCATE TABLE dbo.FrameworkLookups
TRUNCATE TABLE dbo.FrameworkAttributes
TRUNCATE TABLE dbo.FrameworkStepItems
TRUNCATE TABLE dbo.FrameworkSteps
------------------------------------------------
 
DROP TABLE IF EXISTS #TMP_ALLSTEPS 

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@inputJSON)
 WHERE NOT (Name = 'actions' AND ValueType ='array')		--EXCLUDING A PARENT NODE WHICH HAS A CALCULATION FORMULA
	   
 SET @Name = REPLACE(@NAME,' ','')

 DECLARE @FrameWorkTblName VARCHAR(500) = CONCAT('[', @Name,'_data]')
 DECLARE @FrameWorkHistTblName VARCHAR(500) = CONCAT('[', @Name,'_data_history]')
 DECLARE @FrameWorkTblName_WhereClause VARCHAR(500)
 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =2
 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =20

 --SELECT * FROM #TMP_ALLSTEPS
 --RETURN
	
		------------------------------------------------------------------------------
		DECLARE @TBL_DELETECOLUMNS TABLE(NAME VARCHAR(100))
		
		--ADD TO THIS LIST ANY COLUMNS WHICH WERE ARE HARD-CODED/EXCLUDED
		INSERT INTO @TBL_DELETECOLUMNS(NAME)
			SELECT 'DateCreated'
			UNION
			SELECT 'DateModified'
			UNION
			SELECT 'UserCreated'
			UNION
			SELECT 'UsermModified'
			UNION
			SELECT 'referencenum'
			UNION
			SELECT 'registerReference'
			UNION
			SELECT 'knowledgebasereference'
			UNION
			SELECT 'showAdminTab'
			UNION
			SELECT 'loggedInUserRole'
			UNION
			SELECT 'loggedInUserGroup'
			UNION
			SELECT 'isModuleAdmin'
			UNION
			SELECT 'isSystemAdmin'
			UNION
			SELECT 'isModuleAdminGroup'
			UNION
			SELECT 'CurrentStateowner'
			UNION
			SELECT 'submit'
		------------------------------------------------------------------------------

 DROP TABLE IF EXISTS #TMP_Objects

 SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS T
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS
	   --AND Element_ID<=12 --FILTERING OUT USERCREATED,DATECREATED,SUBMIT ETC.
	   AND NOT EXISTS(SELECT 1 FROM @TBL_DELETECOLUMNS WHERE T.NAME LIKE CONCAT('%',NAME))
	   /*
	   AND NOT (Name LIKE '%userCreated' OR NAME LIKE '%dateModified' 
			OR NAME LIKE '%dateCreated' OR NAME LIKE '%userModified'
			OR NAME LIKE '%dateModified' OR NAME LIKE '%submit' 
			OR NAME LIKE '%referencenum' OR NAME LIKE '%registerReference' OR NAME LIKE '%knowledgebasereference')
	 	*/	    
 
	 	DECLARE @ID INT,		
			@StepID INT,
			@StepName VARCHAR(500), --='XYZ',
			@StepItemType VARCHAR(500),		 
			@StepItemName VARCHAR(MAX),
			@LookupValues VARCHAR(1000),
			@StepItemID INT,			
			@VersionNum INT,
			@StepItemKey VARCHAR(100),
			--@Name VARCHAR(100) = 'TAB',
			@SQL NVARCHAR(MAX),
			@FrameworkID INT,
			@IsAvailable BIT,
			@TemplateTableName SYSNAME,
			@Counter INT = 1,
			@AttributeID INT, @LookupID INT
	 	
	--BUILD SCHEMA FOR _DATA TABLE============================================================================================	 
	 
	 DECLARE @DayString VARCHAR(20)='day'
	 DECLARE @SQL_ID VARCHAR(MAX)='ID INT'
	 DECLARE @SQL_HistoryID VARCHAR(MAX)='HistoryID INT IDENTITY(1,1)'
	 DECLARE @StaticCols VARCHAR(MAX) =	 
	 'UserCreated INT NOT NULL, 
	 DateCreated DATETIME2(0) NOT NULL DEFAULT GETDATE(), 
	 UserModified INT,
	 DateModified DATETIME2(0),
	 VersionNum INT NOT NULL,
	 registerid INT,
	 referencenum nvarchar(250) NULL,
	 registerReference nvarchar(250) NULL,
     knowledgebasereference nvarchar(250)  NULL'
	 
	 DROP TABLE IF EXISTS #TMP_DATA
     DROP TABLE IF EXISTS #TMP_DATA_DAY
	 DROP TABLE IF EXISTS #TMP_DATA_DOT
	 DROP TABLE IF EXISTS #TMP_DATA_StepName	 

	 SELECT TOB.Element_ID, TOB.NAME,TA.StringValue, CAST(NULL AS VARCHAR(50)) AS DataType,
			CAST(NULL AS VARCHAR(50)) AS DataTypeLength,
			CAST(NULL AS VARCHAR(500)) AS StepName
		INTO #TMP_DATA
	 FROM #TMP_Objects TOB
		 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = TOB.Element_ID
	 WHERE TA.Name = 'type'
	
	 UPDATE #TMP_DATA
		SET DataType = CASE WHEN StringValue IN ('textfield','selectboxes','select','textarea','email','URL','phoneNumber','tags','signature','password','button','colorPicker','colored','entityLinkGrid','datagrid','checkbox','radio','tableTemplate','dynamicTable','rangecolored','entityTab','queryGrid','customTreeSelection') THEN 'NVARCHAR' 
							WHEN StringValue = 'number' THEN 'BIGINT'
							WHEN StringValue = 'datetime' THEN 'DATETIME' 							
							WHEN StringValue = 'currency' THEN 'DECIMAL(18,2)'
							WHEN StringValue = 'time' THEN 'TIME'
					   END
	
	UPDATE #TMP_DATA
		SET DataTypeLength = CASE WHEN DataType = 'NVARCHAR' THEN '(MAX)'
							 END
		
		--UPDATE FOR DECIMAL DATA TYPE: FIND "decimalLimit" AND MAKE SURE IT'S TYPE IS "NUMBER";IF FOUND CHANGE THE DATA TYPE FROM INT TO DECIMAL========
		SELECT TA.Parent_ID,
			  CONCAT('DECIMAL(18,',TA.StringValue,')') AS DecimalDataType
			INTO #TMP_DecimalDataType
		FROM #TMP_ALLSTEPS TA
			 INNER JOIN #TMP_ALLSTEPS TATN ON TATN.Parent_ID = TA.Parent_ID 
		WHERE TA.NAME LIKE '%decimalLimit%'
			  AND TATN.NAME = 'type' 
			  AND TATN.StringValue = 'number'
			  	
		UPDATE TMP
			SET DataType = TD.DecimalDataType
		FROM #TMP_DATA TMP
			 INNER JOIN #TMP_DecimalDataType TD ON TD.Parent_ID = TMP.Element_ID
	 
		--SELECT * FROM #TMP_DATA
		--=================================================================================================================================================
		
	 SELECT T.Element_ID,T.Name, MAX(TAB.pos) AS Pos
		INTO #TMP_DATA_DAY
	 FROM #TMP_DATA T
		  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB
	WHERE T.StringValue= @DayString
	GROUP BY T.Element_ID,T.Name
	
	INSERT INTO #TMP_DATA(Element_ID, NAME,StringValue,DataType)
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Day'),@DayString,'INT'
		FROM #TMP_DATA_DAY
		UNION
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Month'),@DayString,'INT'
		FROM #TMP_DATA_DAY
		UNION
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Year'),@DayString,'INT'
		FROM #TMP_DATA_DAY
		UNION
		SELECT Element_ID,CONCAT(SUBSTRING(Name,Pos+1,len(Name)),'_Date'),@DayString,'INT'
		FROM #TMP_DATA_DAY
	
	--SINCE WE HAVE CREATED 4 NEW COLUMNS OUT OF THIS REMOVE THIS RECORD
	DELETE TD FROM #TMP_DATA TD WHERE EXISTS(SELECT 1 FROM #TMP_DATA_DAY WHERE Name=TD.Name) AND StringValue='day'
	
	--EXTRACT STEP ITEM(AFTER LAST DOT) & STEP NAME(BEFORE FIRST DOT)-----------------
	SELECT T.Element_ID,T.Name, MAX(TAB.pos) AS Pos,MIN(TAB.pos) AS MinPos
		INTO #TMP_DATA_DOT
	 FROM #TMP_DATA T
		  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB		
	GROUP BY T.Element_ID,T.Name

	--STEP ITEM FOR _DATA COLUMNS
	UPDATE TD
		SET Name = SUBSTRING(TDD.Name,TDD.Pos+1,len(TDD.Name))
	FROM #TMP_DATA TD
		 INNER JOIN #TMP_DATA_DOT TDD ON TD.Element_ID=TDD.Element_ID
	WHERE TD.StringValue <> @DayString
	 
	--STEP NAME
	UPDATE TD
		SET StepName = SUBSTRING(TDD.Name,1,TDD.MinPos-1)
	FROM #TMP_DATA TD
		 INNER JOIN #TMP_DATA_DOT TDD ON TD.Element_ID=TDD.Element_ID
	WHERE TD.StringValue <> @DayString
	-----------------------------------------------------------------------------------
	
	/*IF "type": "selectboxes", THEN CREATED 4 ADDITIONAL COLUMNS IN _DATA:
			reputational_Name
			reputational_Value
			reputational_Description
			reputational_Color
	*/
	------------------------------------------------------------------------------------
		INSERT INTO #TMP_DATA(Element_ID, NAME,StringValue,DataType,DataTypeLength)
			SELECT Element_ID, CONCAT(NAME,'_',TAB.TName),'selectboxes_DELETE',DataType,DataTypeLength
			FROM #TMP_DATA
				 CROSS APPLY (SELECT 'Name' UNION SELECT 'Value' UNION SELECT 'Description' UNION SELECT 'Color')TAB(TName)
			WHERE StringValue = 'selectboxes'			
	------------------------------------------------------------------------------------
	
	/*IF "type": "colored", THEN CREATE 1 ADDITIONAL COLUMN IN _DATA:
			colouredddl_Colour		 
	*/
	------------------------------------------------------------------------------------
		--INSERT INTO #TMP_DATA(Element_ID, NAME,StringValue,DataType,DataTypeLength)
		--	SELECT Element_ID, CONCAT(NAME,'_',TAB.TName),'colored_DELETE',DataType,DataTypeLength
		--	FROM #TMP_DATA
		--		 CROSS APPLY (SELECT 'Color')TAB(TName)
		--	WHERE StringValue = 'colored'			
	------------------------------------------------------------------------------------

	/*IF "type": "colored" OR "rangecolored", THEN CREATE 3 ADDITIONAL COLUMNS IN _DATA:
			For "rangecolored": Name nvarchar(500), SelectVal nvarchar(500),inputvalue - decimal(18,2)	
			For "colored": Name nvarchar(500), SelectVal nvarchar(500),value - decimal(18,2)	
	For ""rangecolored"" CREATE 2 MORE COLUMNS (APART FROM THE ABOVE 3): MinValue DECIMAL(18,2) , MaxValue DECIMAL(18,2)
	*/
	------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO #TMP_DATA(Element_ID, NAME,StringValue,DataType,DataTypeLength, StepName)
			SELECT Element_ID, CONCAT(NAME,'_',TAB.TName),StringValue,DataType,DataTypeLength, StepName
			FROM #TMP_DATA
				 CROSS APPLY (SELECT 'Name' UNION SELECT 'SelectVal' UNION SELECT 'Inputvalue')TAB(TName)
			WHERE StringValue = 'rangecolored'
			
			UNION

			SELECT Element_ID, CONCAT(NAME,'_',TAB.TName),StringValue,DataType,DataTypeLength, StepName
			FROM #TMP_DATA
				 CROSS APPLY (SELECT 'MinValue' UNION SELECT 'MaxValue')TAB(TName)
			WHERE StringValue = 'rangecolored'

			UNION

			SELECT Element_ID, CONCAT(NAME,'_',TAB.TName),StringValue,DataType,DataTypeLength, StepName
			FROM #TMP_DATA
				 CROSS APPLY (SELECT 'Name' UNION SELECT 'SelectVal' UNION SELECT 'value')TAB(TName)
			WHERE StringValue = 'colored'

		UPDATE #TMP_DATA
			SET DataType = 'DECIMAL(18,2)',
			    DataTypeLength = NULL
		WHERE StringValue  IN ('colored','rangecolored')
			  AND NAME LIKE '%_Value'

		UPDATE #TMP_DATA
			SET DataType = 'DECIMAL(18,2)',
			    DataTypeLength = NULL
		WHERE StringValue  = 'rangecolored'
			  AND (NAME LIKE '%_MinValue' OR NAME LIKE '%_MaxValue')
	------------------------------------------------------------------------------------------------------------------------------------

	--REMOVE THESE STATIC COLUMNS IF THEY ARE PART OF JSON AS THEY HAVE ALREADY BEEN CREATED/HARD-CODED---
		DELETE TMP FROM #TMP_DATA TMP
		WHERE EXISTS (SELECT 1 FROM @TBL_DELETECOLUMNS WHERE NAME = TMP.Name)
	------------------------------------------------------------------------------------------------------
	
	--SELECT * FROM #TMP_DATA
	--RETURN

	 DECLARE @DataCols VARCHAR(MAX), @HistDataCols VARCHAR(MAX), @MainDataCols VARCHAR(MAX), @NewDataCols VARCHAR(MAX) 
	 SET @DataCols = --STUFF(
					 (SELECT CONCAT(', [',[Name],']',
									CASE WHEN DataType = 'DECIMAL(18,2)' THEN CONCAT(' ', DataType) ELSE CONCAT(' [', DataType,'] ') END
									, DataTypeLength
					 
									)
					 FROM #TMP_DATA
					 FOR XML PATH('')
					 )
					 --,1,1,'')

	SET @DataCols = CONCAT(',FrameworkID INT',@DataCols)
	PRINT @DataCols
	
	--CHECK IF TABLE IS ALREADY AVAILABLE, THEN GET ANY NEW COLUMNS THAT ARE PART OF THE SCHEMA
	SET @SQL = CONCAT(N'SELECT @NewDataCols = STUFF(
						(SELECT CONCAT('', ['',[Name],'']'', 
									  CASE WHEN DataType = ''DECIMAL(18,2)'' THEN CONCAT('' '', DataType) ELSE CONCAT('' ['', DataType,''] '') END
									  , DataTypeLength)
						FROM #TMP_DATA TA								  
						WHERE NOT EXISTS(SELECT 1 FROM sys.columns C WHERE C.Name = TA.Name AND C.object_id =OBJECT_ID(',CHAR(39),@FrameWorkTblName,CHAR(39),'))
						FOR XML PATH('''')
						)
						,1,1,'''')'
						)
	EXEC sp_executesql @SQL,N'@NewDataCols VARCHAR(MAX) OUTPUT',@NewDataCols OUTPUT
	PRINT @SQL
	--SELECT * from #TMP_DATA
	--RETURN
	
	BEGIN TRAN

	SET @MainDataCols = CONCAT(@SQL_ID,' IDENTITY(1,1),',CHAR(10),@StaticCols,CHAR(10),@DataCols)
	SET @StaticCols = CONCAT(@StaticCols,',PeriodIdentifier INT')
	SET @HistDataCols = CONCAT(@SQL_HistoryID,',',CHAR(10),@SQL_ID,',', CHAR(10),@StaticCols,CHAR(10),',OperationType VARCHAR(50)',CHAR(10),@DataCols)
	
	--PRINT @HistDataCols
	SET @FrameWorkTblName_WhereClause = CONCAT(@Name,'_data')
	SET @SQL = ''
	SET @SQL = CONCAT(N'IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME=',CHAR(39),@FrameWorkTblName_WhereClause,CHAR(39),')', CHAR(10))
	SET @SQL = CONCAT(@SQL,N' BEGIN ',CHAR(10))
	SET @SQL = CONCAT(@SQL,N' CREATE TABLE dbo.', @FrameWorkTblName,CHAR(10), '(', @MainDataCols, ') ;',CHAR(10))
	SET @SQL = CONCAT(@SQL,N' CREATE TABLE dbo.', @FrameWorkHistTblName, CHAR(10), '(', @HistDataCols, ') ;',CHAR(10))	
	SET @SQL = CONCAT(@SQL,N' END ',CHAR(10))
	IF @NewDataCols IS NOT NULL	--_DATA TABLE ALREADY EXISTS
	BEGIN
		SET @SQL = CONCAT(@SQL,N' ELSE ',CHAR(10)) 
		SET @SQL = CONCAT(@SQL,N' BEGIN ',CHAR(10))	
		SET @SQL = CONCAT(@SQL,N' ALTER TABLE dbo.', @FrameWorkTblName ,' ADD ', CHAR(10), @NewDataCols, CHAR(10),';')
		SET @SQL = CONCAT(@SQL,N' ALTER TABLE dbo.', @FrameWorkHistTblName ,' ADD ', CHAR(10), @NewDataCols, CHAR(10),';')
		SET @SQL = CONCAT(@SQL,N' END ',CHAR(10))
	END
	PRINT @SQL
	
	EXEC sp_executesql @SQL	
	
	--CLEANUP THESE ROWS AS THEY ARE NO LONGER NEEDED
	DELETE FROM #TMP_DATA WHERE StringValue IN ('selectboxes_DELETE','colored_DELETE')

		--CREATE TRIGGER
		DECLARE @cols VARCHAR(MAX) = ''

		SELECT @SQL = CONCAT('SELECT @cols = CONCAT(@cols,N'', ['',name,''] '')
							  FROM sys.dm_exec_describe_first_result_set(N''SELECT * FROM dbo.',@FrameWorkTblName,''', NULL, 1)')
					
		SELECT @SQL = CONCAT(@SQL,CHAR(10),';SET @cols = STUFF(@cols, 1, 1, N'''');')
		PRINT @SQL
		EXEC sp_executesql @SQL,N'@cols VARCHAR(MAX) OUTPUT',@cols OUTPUT
		
		SET @SQL = ''

		--CREATE INSERT TRIGGER
		IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME = CONCAT(@Name,'_Data_Insert'))						
			SET @SQL = N'ALTER TRIGGER '
		ELSE
			SET @SQL = N'CREATE TRIGGER '

		SET @SQL = CONCAT(@SQL,N' dbo.[', @Name,'_Data_Insert]
							ON  dbo.',@FrameWorkTblName,'
							AFTER INSERT, UPDATE
						AS 
						BEGIN
							SET NOCOUNT ON;
																				
							IF EXISTS(SELECT 1 FROM INSERTED) AND  NOT EXISTS(SELECT 1 FROM DELETED) --INSERT
								INSERT INTO dbo.',@FrameWorkHistTblName,'(<ColumnList>)
									SELECT <columnList>
									FROM INSERTED
							ELSE IF EXISTS(SELECT 1 FROM INSERTED) AND  EXISTS(SELECT 1 FROM DELETED) --UPDATE
								INSERT INTO dbo.',@FrameWorkHistTblName,'(<ColumnList>)
									SELECT <columnList>
									FROM INSERTED
						END;',CHAR(10))
		SET @SQL = REPLACE(@SQL,'<columnList>',@cols)
		EXEC [LongPrint] @SQL	
		EXEC sp_executesql @SQL	
	--==SCHEMA FOR _DATA ENDS HERE=========================================================================================================================
				
	DECLARE @TableName SYSNAME = 'dbo.Frameworks'
	SET @SQL = ''
	
	--GET THE FrameworkID & VERSION NO.: CHECK FOR THE EXISTENCE OF THE JSONKEY		
		--SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10)) --ASSUSMPTION:Frameworks IS ALREADY AVAILABLE
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM ',@TableName,')', CHAR(10))	--ASSUSMPTION:Frameworks IS ALREADY AVAILABLE
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @FrameworkID = FrameworkID, @VersionNum = VersionNum + 1 FROM ',@TableName,' WHERE Name = ''', @Name,''' ORDER BY FrameworkID DESC');	
		SET @SQL = CONCAT(@SQL,' IF @FrameworkID IS NULL ')
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @FrameworkID = MAX(FrameworkID) + 1,@VersionNum = MAX(VersionNum) + 1 FROM ',@TableName);
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE SELECT @FrameworkID = 1, @IsAvailable = NULL, @VersionNum = 1;', CHAR(10))	--FIRST RECORD
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@FrameworkID INT OUTPUT, @VersionNum INT OUTPUT, @IsAvailable BIT OUTPUT',@FrameworkID OUTPUT, @VersionNum OUTPUT,@IsAvailable OUTPUT;

	IF @VersionNum IS NULL
		SET @VersionNum = 1

		
	
	--INSERT NEW JSONKEY(NAME) IF IT DOES NOT EXIST=====================================================================================		
	IF @IsAvailable IS NULL OR @IsAvailable = 0	
	BEGIN
		SET IDENTITY_INSERT dbo.Frameworks ON;

		INSERT INTO dbo.Frameworks (FrameworkID,Name,FrameworkFile,UserCreated,DateCreated,VersionNum,FullSchemaJSON,Frameworkstatus)
			SELECT  @FrameworkID,
					@Name,	
					@inputJSON,		
					@UserLoginID,
					GETUTCDATE(),
					@VersionNum,
					@FullSchemaJSON,
					'Active'

		--SET @FrameworkID = SCOPE_IDENTITY()	
		SET IDENTITY_INSERT dbo.Frameworks OFF;
	END	
	ELSE ---RECORDS ALREADY AVAILABLE FOR PREVIOUS VERSIONS		
		UPDATE dbo.Frameworks
			SET VersionNum = @VersionNum,
				UserModified = 1,
				DateModified = GETUTCDATE(),
				FullSchemaJSON=@FullSchemaJSON,
				FrameworkFile= @InputJSON,
				Frameworkstatus='Active'
		WHERE FrameworkID = @FrameworkID --AND Name = @Name
 --==================================================================================================================================
		--SELECT * FROM #TMP_Objects
		--ROLLBACK
		--RETURN
 				
--PROCESS THE STEP ITEMS ONE BY ONE
 WHILE EXISTS(SELECT 1 FROM #TMP_Objects)
 BEGIN
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups

		SELECT @ID = MIN(Element_ID) FROM #TMP_Objects
		
		--GET ALL THE CHILD ELEMENTS FOR A PARENT
		;WITH CTE
		AS
		(	--PARENT
			SELECT CAST('' AS VARCHAR(50)) ParentName, Element_ID,Parent_ID,SequenceNo,[Name] AS KeyName,StringValue,ValueType,CAST('Object' AS VARCHAR(50)) AS ElementType
			FROM #TMP_Objects
			WHERE Element_ID = @ID

			UNION ALL

			--CHILD ITEMS
			SELECT CAST(C.KeyName as varchar(50)),TMP.Element_ID,TMP.Parent_ID,TMP.SequenceNo,TMP.[Name],TMP.StringValue,TMP.ValueType,CAST('ObjectItems' AS VARCHAR(50)) AS ElementType
			FROM CTE C 
				 INNER JOIN #TMP_ALLSTEPS TMP ON TMP.Parent_ID = C.Element_ID			
		)

		SELECT *
			INTO #TMP 
		FROM CTE
		WHERE ValueType NOT IN ('Object','array')		
		--WHERE ISNULL(KeyName,'') <> '' 
		--	  AND Parent_ID > 0
		
		SELECT @StepItemType = (SELECT StringValue FROM #TMP WHERE KeyName ='type' AND Parent_ID = @ID),
			   @StepItemName = (SELECT StringValue FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
			   @StepItemKey = (SELECT StringValue FROM #TMP WHERE KeyName ='key' AND Parent_ID = @ID),	
			   @StepName  = (SELECT TOP 1 TD.StepName FROM #TMP T INNER JOIN #TMP_DATA TD ON T.Parent_ID = TD.Element_ID )  
			   			    		
	
		--CHECK FOR THE EXISTENCE OF THE STEP======================================================================================================		
		SELECT @SQL = '', @StepID= NULL,@IsAvailable = NULL
		SET @TemplateTableName = 'FrameworkSteps'
		SET @TableName = CONCAT('[',@Name,'_',@TemplateTableName,']')
		
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepID = StepID FROM ',@TableName,' WHERE FrameworkID = ', @FrameworkID,' AND StepName = ''', @StepName,''' ORDER BY StepID DESC;', CHAR(10));				
		SET @SQL = CONCAT(@SQL,' IF @StepID IS NULL ')
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = MAX(StepID) + 1 FROM ',@TemplateTableName,CHAR(10));	
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = MAX(StepID) + 1 FROM ',@TableName);	
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))		--FIRST VERSION
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS IN THE VERY FIRST VERSION
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = StepID FROM ',@TemplateTableName,' WHERE FrameworkID = ', @FrameworkID,' AND StepName = ''', @StepName,'''',CHAR(10));
		SET @SQL = CONCAT(@SQL,' IF @StepID IS NULL ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = MAX(StepID) + 1 FROM ',@TemplateTableName,CHAR(10));	
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = 1, @IsAvailable = NULL;', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@StepID INT OUTPUT,@IsAvailable BIT OUTPUT',@StepID OUTPUT,@IsAvailable OUTPUT;
		
		IF @IsAvailable IS NULL OR @IsAvailable = 0		
		BEGIN			
				SET IDENTITY_INSERT dbo.FrameworkSteps ON;
				
				INSERT INTO dbo.FrameworkSteps (StepID,FrameworkID,StepName,DateCreated,UserCreated,VersionNum)
					SELECT @StepID,@FrameworkID,@StepName,GETUTCDATE(),@UserLoginID,@VersionNum	
			
				--SET @StepID = SCOPE_IDENTITY()
				SET IDENTITY_INSERT dbo.FrameworkSteps OFF;
		END
		ELSE
			UPDATE dbo.FrameworkSteps
				SET VersionNum = @VersionNum,
					UserModified = 1,
					DateModified = GETUTCDATE()
			WHERE StepID = @StepID			
		--===========================================================================================================================================
	
		IF NOT EXISTS(SELECT 1 FROM [dbo].[FrameworkSteps_history] WHERE FrameworkID=@FrameworkID AND StepID=@StepID AND VersionNum=@VersionNum AND StepName=@StepName)
			INSERT INTO [dbo].[FrameworkSteps_history]
					   (StepID,
						FrameworkID,
						[StepName]
					   ,[UserCreated]
					   ,[DateCreated]				   
					   ,[VersionNum],
					   PeriodIdentifierID)
					SELECT	@StepID,
							@FrameworkID,
							@StepName,
							1,
							GETUTCDATE(),
							@VersionNum,
							1
										
		IF @StepID IS NOT NULL
		BEGIN
				
			--CHECK FOR THE EXISTENCE OF THE STEPITEM======================================================================================================
			SELECT @SQL = '', @StepItemID= NULL,@IsAvailable = NULL
			SET @TemplateTableName = 'FrameworkStepItems'
			SET @TableName = CONCAT('[',@Name,'_',@TemplateTableName,']')

			SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
			--STEPITEMKEY IS THE UNIQUE IDENTIFIER SO CAN OMIT STEPID
			--SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepItemID = StepItemID FROM ',@TableName,' WHERE FrameworkID =',@FrameworkID,' AND StepID = ', @StepID,' AND StepItemKey = ''', @StepItemKey,''' ORDER BY StepItemID DESC;', CHAR(10));	
			SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepItemID = StepItemID FROM ',@TableName,' WHERE FrameworkID =',@FrameworkID,' AND StepItemKey = ''', @StepItemKey,''' ORDER BY StepItemID DESC;', CHAR(10));	
			SET @SQL = CONCAT(@SQL,' IF @StepItemID IS NULL ')
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = MAX(StepItemID) + 1 FROM ',@TemplateTableName,CHAR(10));	
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = MAX(StepItemID) + 1 FROM ',@TableName);	
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))		--FIRST VERSION
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM dbo.',@TemplateTableName,')', CHAR(10))	--PROCESSING MULTIPLE STEPS IN THE VERY FIRST VERSION
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = StepItemID FROM ',@TemplateTableName,' WHERE FrameworkID = ', @FrameworkID,' AND StepItemKey = ''', @StepItemKey,'''',CHAR(10));
			SET @SQL = CONCAT(@SQL,' IF @StepItemID IS NULL ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = MAX(StepItemID) + 1 FROM ',@TemplateTableName,CHAR(10));	
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 0; ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = 1, @IsAvailable = NULL;', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))	
			PRINT @SQL  
			EXEC sp_executesql @SQL, N'@StepItemID INT OUTPUT,@IsAvailable BIT OUTPUT',@StepItemID OUTPUT,@IsAvailable OUTPUT;
		
		IF @IsAvailable IS NULL OR @IsAvailable = 0
		BEGIN
						
					SET IDENTITY_INSERT dbo.FrameworkStepItems ON;
					
					INSERT INTO dbo.FrameworkStepItems (StepItemID,FrameworkID,StepID,StepItemName,StepItemType,StepItemKey,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT  @StepItemID,
								@FrameworkID,
								@StepID,								
								@StepItemName,
								@StepItemType,
								@StepItemKey,
								(SELECT SequenceNo FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
								GETUTCDATE(),@UserLoginID,@VersionNum	

					--SET @StepItemID = SCOPE_IDENTITY()
					SET IDENTITY_INSERT dbo.FrameworkStepItems OFF;				
		END
		ELSE IF NOT EXISTS(SELECT 1 FROM FrameworkStepItems WHERE StepItemKey = @StepItemKey AND StepID = @StepID) --KEY MOVED TO A DIFFERENT STEP
				UPDATE dbo.FrameworkStepItems
					SET StepID = @StepID,
						VersionNum = @VersionNum
				WHERE StepItemKey = @StepItemKey
		ELSE
			UPDATE dbo.FrameworkStepItems
				SET VersionNum = @VersionNum,
					UserModified = 1,
					DateModified = GETUTCDATE()
			WHERE @StepItemID = StepItemID --StepItemKey = @StepItemKey
			
			IF NOT EXISTS(SELECT 1 FROM [dbo].[FrameworkStepItems_history] WHERE FrameworkID=@FrameworkID AND StepID=@StepID AND StepItemID=@StepItemID AND VersionNum=@VersionNum)
				INSERT INTO [dbo].[FrameworkStepItems_history]
						   (FrameworkID,
							StepItemID,
							[StepID]
						   ,[StepItemName]
						   ,[StepItemType]
						   ,[StepItemKey]
						   ,[OrderBy]
						   ,[UserCreated]
						   ,[DateCreated]						  
						   ,[VersionNum],
						   PeriodIdentifierID)
				SELECT @FrameworkID,
					   @StepItemID,
					   @StepID,
					   @StepItemName,
					   @StepItemType,
					   @StepItemKey,
					   (SELECT SequenceNo FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
					   1,
					   GETUTCDATE(),
					   @VersionNum,
					   1 
				--IF @StepItemID IS NULL
				--	SELECT @StepItemID = StepItemID
				--	FROM dbo.FrameworkStepItems
				--	WHERE StepItemKey = @StepItemKey
			
				DELETE FROM #TMP WHERE KeyName IN ('Label','type','key') AND Parent_ID = @ID	
								
				--SELECT * FROM #TMP 
				--RETURN				
					
		--GET ATTRIBUTE/LOOKUP ID FOR NEW DATA THAT NEEDS TO BE INSERTED
		--================================================================================================================================== 		
		SELECT @SQL = ''
		SET @TemplateTableName = 'FrameworkAttributes'
		SET @TableName = CONCAT('[',@Name,'_',@TemplateTableName,']')
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' SELECT @AttributeID = MAX(AttributeID) + 1 FROM ',@TableName);						
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@AttributeID INT OUTPUT',@AttributeID OUTPUT;

		
		IF @AttributeID IS NULL AND NOT EXISTS(SELECT 1 FROM dbo.FrameworkAttributes)
			SET @AttributeID = 0;
		ELSE IF EXISTS(SELECT 1 FROM dbo.FrameworkAttributes)
			SELECT @AttributeID  = MAX(AttributeID) + 1 FROM dbo.FrameworkAttributes
						
		SELECT @SQL = ''
		SET @TemplateTableName = 'FrameworkLookups'
		SET @TableName = CONCAT('[',@Name,'_',@TemplateTableName,']')
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM ',@TableName,')', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @LookupID = MAX(LookupID) + 1 FROM ',@TableName);						
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@LookupID INT OUTPUT',@LookupID OUTPUT;
			
		IF @LookupID IS NULL AND NOT EXISTS(SELECT 1 FROM dbo.FrameworkLookups)		
			SET @LookupID = 0;			
		ELSE IF EXISTS(SELECT 1 FROM dbo.FrameworkLookups)		
			SELECT @LookupID  = MAX(LookupID) + 1 FROM dbo.FrameworkLookups
		--==================================================================================================================================
					
					SET IDENTITY_INSERT dbo.[FrameworkAttributes] ON;
		
					--GET THE STEPITEM ATTRIBUTES					 				
					INSERT INTO dbo.FrameworkAttributes(AttributeID,FrameworkID,StepItemID,AttributeValue,AttributeKey,OrderBy,DateCreated,UserCreated,VersionNum)							
						SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @AttributeID,
							   @FrameworkID,@StepItemID,StringValue,KeyName,SequenceNo,GETUTCDATE(),@UserLoginID ,@VersionNum
							FROM #TMP T
							WHERE (Parent_ID = @ID
								 OR
								 ParentName = 'validate'	
								 )
						--AND NOT EXISTS (SELECT 1 
						--				FROM dbo.FrameworkAttributes FMA
						--				WHERE FMA.StepItemID=@StepItemID 
						--						AND FMA.AttributeKey=T.KeyName
						--				)
					
					 SET IDENTITY_INSERT dbo.[FrameworkAttributes] OFF;
				--UPDATE FMA
				--	SET VersionNum = @VersionNum
				--FROM dbo.FrameworkAttributes FMA
				--	 INNER JOIN #TMP TAB ON FMA.StepItemID=@StepItemID AND FMA.AttributeKey=TAB.KeyName
				--WHERE TAB.Parent_ID = @ID
				--	  OR
				--	 TAB.ParentName = 'validate'				

				SET IDENTITY_INSERT dbo.FrameworkLookups ON;
				
				--GET THE LOOKUPS ATTRIBUTES
				IF @StepItemType = 'selectboxes'
				BEGIN
			
					SET @LookupValues = STUFF
										((SELECT CONCAT(', ',StringValue)
										FROM #TMP 
										WHERE Parent_ID <> @ID
											 AND KeyName ='value'
										FOR XML PATH ('')
										),1,1,'')
						--SELECT @LookupValues

						--IF NOT EXISTS (SELECT 1 
						--				FROM dbo.FrameworkLookups FMA
						--				WHERE FrameworkID = @FrameworkID
						--					  AND StepItemID=@StepItemID 
						--					  AND LookupName=@StepItemName
						--			)

						
						 INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
							SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
								   @FrameworkID,@StepItemID,@LookupValues,@StepItemName,1,GETUTCDATE(),@UserLoginID,@VersionNum						
				END
				ELSE		
				IF @StepItemType = 'select'
				BEGIN				
						
						SELECT Parent_ID,
							   MAX(CASE WHEN KeyName='Label' THEN StringValue ELSE '' END) AS LookupName,
							   MAX(CASE WHEN KeyName='Value' THEN StringValue ELSE '' END) AS LookupValue,
							   CAST(NULL AS VARCHAR(50)) AS LookupType
							INTO #TMP_Lookups
						FROM #TMP 
						WHERE Parent_ID <> @ID
							 AND KeyName IN ('label','value')
							 GROUP BY Parent_ID

						UPDATE #TMP_Lookups
							SET LookupType = CASE WHEN TRY_PARSE(LookupValue AS INT) IS NOT NULL THEN 'Value'
												   ELSE 
												   CASE WHEN CHARINDEX('-',LookupValue)>0 THEN 'Range' 
												   ELSE
												   'String'
												   END
												   END

							 --SELECT * FROM #TMP_Lookups	
					
						 INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,LookupType,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   LookupValue,
										   LookupName,
										   LookupType,	 		  
											Parent_ID,
											GETUTCDATE(),
											@UserLoginID,
											@VersionNum	
									FROM #TMP_Lookups T
									--WHERE NOT EXISTS (SELECT 1 
									--					FROM dbo.FrameworkLookups FMA
									--					WHERE FrameworkID = @FrameworkID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.LookupName
									--				)					
							
				END				
				ELSE IF @StepItemType = 'colored'
				BEGIN	
				
				--SELECT @id,* FROM  #TMP T WHERE keyName IN ('Name','Value','Color') AND ValueType = 'string'

						SELECT Parent_ID,
							   MAX(CASE WHEN KeyName='Color' THEN StringValue ELSE '' END) AS LookupColor,
							   MAX(CASE WHEN KeyName='Value' THEN StringValue ELSE '' END) AS LookupValue,
							   CAST(NULL AS VARCHAR(50)) AS LookupType
							INTO #TMP_ColorLookups
						FROM #TMP 
						WHERE KeyName IN ('Color','value')
							 GROUP BY Parent_ID

						INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum, Color,MaxValue)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   @StepItemKey,
										   @StepItemType,
										   Parent_ID,
										   GETUTCDATE(),
										   @UserLoginID,
										   @VersionNum,
										   LookupColor,
										   LookupValue
									FROM #TMP_ColorLookups
			 
				END
				ELSE IF @StepItemType= 'rangecolored'
				BEGIN	
				
				--SELECT @id,* FROM  #TMP T WHERE keyName IN ('Name','Value','Color') AND ValueType = 'string'

						SELECT Parent_ID,
							   MAX(CASE WHEN KeyName='Color' THEN StringValue ELSE '' END) AS LookupColor,
							   MAX(CASE WHEN KeyName='MinValue' THEN StringValue ELSE '' END) AS LookupMinValue,
							   MAX(CASE WHEN KeyName='MaxValue' THEN StringValue ELSE '' END) AS LookupMaxValue,
							   CAST(NULL AS VARCHAR(50)) AS LookupType
							INTO #TMP_RangeColorLookups
						FROM #TMP 
						WHERE KeyName IN ('Color','Minvalue','MaxValue')
							 GROUP BY Parent_ID

						INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum, Color,MinValue,MaxValue)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   @StepItemKey,
										   @StepItemType,
										   Parent_ID,
										   GETUTCDATE(),
										   @UserLoginID,
										   @VersionNum,
										   LookupColor,
										   LookupMinValue,
										   LookupMaxValue
									FROM #TMP_RangeColorLookups
			 
				END				
				ELSE
								INSERT INTO dbo.FrameworkLookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   StringValue,
										   KeyName,
										   SequenceNo,
										   GETUTCDATE(),
										   @UserLoginID,
										   @VersionNum
									FROM #TMP T
									WHERE Parent_ID <> @ID
										AND KeyName ='value'
									--AND NOT EXISTS (SELECT 1 
									--					FROM dbo.FrameworkLookups FMA
									--					WHERE FrameworkID = @FrameworkID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.KeyName
									--				)			
					
					SET IDENTITY_INSERT dbo.FrameworkLookups OFF;
										
					--UPDATE dbo.FrameworkLookups SET VersionNum = @VersionNum
		
		END	--END OF OUTERMOST IF -> IF @StepID IS NOT NULL
		
		DELETE FROM #TMP_Objects WHERE Element_ID = @ID
		--DELETE FROM @Framework_Metafield
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups
		DROP TABLE IF EXISTS #TMP_ColorLookups
		DROP TABLE IF EXISTS #TMP_RangeColorLookups

		SELECT @StepID = NULL, @StepItemID = NULL, @IsAvailable = NULL, @SQL = NULL, @TemplateTableName = NULL,
			   @AttributeID = NULL, @LookupID = NULL
		
 END	--END OF WHILE LOOP	
		--SELECT 1/0
		--POPULATE TEMPLATE HISTORY TABLES**************************************************************************************
		--DECLARE @PeriodIdentifierID INT = (SELECT MAX(VersionNum) + 1 FROM dbo.Frameworks_history WHERE Name = @Name)

		--IF @PeriodIdentifierID IS NULL
		--	SET @PeriodIdentifierID = 1

		DECLARE @PeriodIdentifierID TINYINT = 1
		
		UPDATE [dbo].[Frameworks_history]
			SET PeriodIdentifierID = 0,
				UserModified = 1,
				DateModified = GETUTCDATE()
		WHERE FrameworkID = @FrameworkID
			  AND VersionNum < @VersionNum

		INSERT INTO [dbo].[Frameworks_history]
				   (FrameworkID,
					Name,
					FrameworkFile
				   ,[UserCreated]
				   ,[DateCreated]				   
				   ,[VersionNum],
				   PeriodIdentifierID,
				   FullSchemaJSON)
		SELECT  @FrameworkID,
				@Name,	
				@inputJSON,		
				@UserLoginID,
				GETUTCDATE(),
				@VersionNum,
				@PeriodIdentifierID,
				@FullSchemaJSON

		INSERT INTO [dbo].[FrameworkAttributes_history]
				   (FrameworkID,
					AttributeID,
				    [StepItemID]
				   ,[AttributeKey]
				   ,[AttributeValue]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT		@FrameworkID,
				    AttributeID,
					[StepItemID]
				   ,[AttributeKey]
				   ,[AttributeValue]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   @PeriodIdentifierID
		FROM dbo.[FrameworkAttributes]
		ORDER BY [OrderBy]

		
		INSERT INTO [dbo].[FrameworkLookups_history]
				   (FrameworkID,
					LookupID,
					[StepItemID]
				   ,[LookupName]
				   ,[LookupValue]
				   ,[LookupType]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT		@FrameworkID,
					LookupID,
					[StepItemID]
				   ,[LookupName]
				   ,[LookupValue]
				   ,[LookupType]
				   ,[OrderBy]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   @PeriodIdentifierID    
		FROM dbo.FrameworkLookups
		ORDER BY [OrderBy]

		--UPDATE dbo.Frameworks_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Steps_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Attributes_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Lookups_history SET PeriodIdentifierID = @VersionNum
		
	--**********************************************************************************************************************************	
		
		PRINT 'ParseJSONData Completed...'
			 
		EXEC dbo.CreateFrameworkSchemaTables @NewTableName = @Name, @FrameworkID = @FrameworkID, @VersionNum = @VersionNum
		
		----INSERT INTO FrameworksEntityGridMapping & FrameworkAttributesMapping:------------------------------------------------
			
			UPDATE FEGM
				SET UserModified = @UserID,	
					DateModified = GETUTCDATE(),
					StepItemID = FSI.StepItemID,
					Label = FSI.StepItemName,
					StepName = FSI.StepItemName
			FROM dbo.FrameworkSteps FS
				 INNER JOIN FrameworkStepItems FSI ON FSI.StepID = FS.StepID
				 INNER JOIN dbo.FrameworksEntityGridMapping FEGM ON FEGM.FrameworkID = @FrameworkID AND FEGM.StepItemID = FSI.StepItemID
				WHERE FS.FrameworkID = @FrameworkID					  
					  AND FSI.StepItemType IN ('entityLinkGrid','datagrid','tableTemplate');				  
			
			INSERT INTO dbo.FrameworksEntityGridMapping (UserCreated,DateCreated ,UserModified,	DateModified, VersionNum,FrameworkID,StepItemID,Label,APIKey,StepName)
				SELECT @UserID,GETUTCDATE(),@UserID,GETUTCDATE(),@VersionNum, @FrameworkID,FSI.StepItemID, FSI.StepItemName,FSI.StepItemKey,FSI.StepItemName
				FROM dbo.FrameworkSteps FS
					 INNER JOIN FrameworkStepItems FSI ON FSI.StepID = FS.StepID
				WHERE FS.FrameworkID = @FrameworkID
					  --AND FS.StepName = 'entitylinks'
					  AND FSI.StepItemType IN ('entityLinkGrid','datagrid','tableTemplate')
					  AND NOT EXISTS(SELECT 1 FROM dbo.FrameworksEntityGridMapping WHERE FrameworkID = @FrameworkID AND StepItemID = FSI.StepItemID)
			
				DELETE FEGM
				FROM dbo.FrameworksEntityGridMapping FEGM
				WHERE FrameworkID = @FrameworkID
					  AND NOT EXISTS (
										SELECT 1
										FROM dbo.FrameworkSteps FS
											 INNER JOIN FrameworkStepItems FSI ON FSI.StepID = FS.StepID
										WHERE FS.FrameworkID = FEGM.FrameworkID										  
											  AND FEGM.StepItemID = FSI.StepItemID
											  AND FSI.StepItemType IN ('entityLinkGrid','datagrid','tableTemplate')											  
								      )

			INSERT INTO dbo.FrameworkAttributesMapping (UserCreated,DateCreated ,UserModified,	DateModified, VersionNum,FrameworkID,APIkey,AttributeName,AttributeType)
				SELECT @UserID,GETUTCDATE(),@UserID,GETUTCDATE(),@VersionNum, @FrameworkID,TblKey.StringValue,FSI.Name,FSI.StringValue
				FROM #TMP_ALLSTEPS FS
					 INNER JOIN #TMP_ALLSTEPS FSI ON FSI.Parent_ID = FS.Element_ID
					 INNER JOIN #TMP_ALLSTEPS TblKey ON TblKey.Parent_ID = FS.Parent_ID
				WHERE FS.NAME='attributes'
					  AND TblKey.NAME='Key'
					  AND NOT EXISTS(SELECT 1 FROM dbo.FrameworkAttributesMapping WHERE FrameworkID = @FrameworkID AND VersionNum = @VersionNum)
 
		INSERT INTO [dbo].FrameworksEntityGridMapping_history
				   (ID,
					FrameworkID,					
					[StepItemID]
				   ,Label
				   ,APIKey				   
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT		ID,
					@FrameworkID,					
					[StepItemID]
				   ,Label
				   ,APIKey
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				    @PeriodIdentifierID    
		FROM dbo.FrameworksEntityGridMapping
		WHERE FrameworkID = @FrameworkID
			  AND VersionNum = @VersionNum

		INSERT INTO [dbo].FrameworkAttributesMapping_history
				   (ID,
					FrameworkID,					
					AttributeType
				   ,AttributeName
				   ,APIKey				   
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT		ID,
					@FrameworkID,					
					AttributeType
				   ,AttributeName
				   ,APIKey
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				    @PeriodIdentifierID    
		FROM dbo.FrameworkAttributesMapping
		WHERE FrameworkID = @FrameworkID
			  AND VersionNum = @VersionNum
		------------------------------------------------------------------------------------------------------------------------
				
		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
			SET @Params = CONCAT('@Name=', CHAR(39),@Name, CHAR(39),',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=1')
			SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39))
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------
		
		COMMIT

		SELECT NULL AS ErrorMessage

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
			DECLARE @Error INT = ERROR_line()

			SET @Params = CONCAT('@Name=', CHAR(39),@Name, CHAR(39),',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=1')
			SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39))
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage,@Error AS Errorline
END CATCH

		--DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS
		 DROP TABLE IF EXISTS #TMP_DATA
		 DROP TABLE IF EXISTS #TMP_DATA_DAY
		 DROP TABLE IF EXISTS #TMP_DATA_DOT 
		 DROP TABLE IF EXISTS #TMP
		 DROP TABLE IF EXISTS #TMP_Lookups
		 --------------------------------------------------------
END