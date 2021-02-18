--https://www.red-gate.com/simple-talk/blogs/consuming-hierarchical-json-documents-sql-server-using-openjson/
--CreateTables_v1.sql and ParseJSON_v2.sql
USE junk
GO

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
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	 
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

 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =2
 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =20

 --SELECT * FROM #TMP_ALLSTEPS
 --RETURN

 DROP TABLE IF EXISTS #TMP_Objects

 SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS
	   --AND Element_ID<=12 --FILTERING OUT USERCREATED,DATECREATED,SUBMIT ETC.
	   AND Name NOT IN ('userCreated','dateCreated','userModified','dateModified','submit')
	  -- AND NAME IN ('Name','riskCategory1')
	    
 
-- SELECT * FROM #TMP_Objects
 --RETURN
	 	DECLARE @ID INT,		
			@StepID INT,
			@StepName VARCHAR(500), --='XYZ',
			@StepItemType VARCHAR(500),		 
			@StepItemName VARCHAR(500),
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
	 DROP TABLE IF EXISTS TAB_DATA -- REMOVE THIS LATER, NOT REQUIRED

	 DECLARE @DayString VARCHAR(20)='day'
	 DECLARE @SQL_ID VARCHAR(MAX)='ID INT IDENTITY(1,1)'
	 DECLARE @StaticCols VARCHAR(MAX) =	 
	 'UserCreated INT NOT NULL, 
	 DateCreated DATETIME2(0) NOT NULL DEFAULT GETDATE(), 
	 UserModified INT,
	 DateModified DATETIME2(0),
	 VersionNum INT NOT NULL'
	 
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
		SET DataType = CASE WHEN StringValue IN ('textfield','selectboxes','select','textarea','email','URL','phoneNumber','tags','signature','password','button') THEN 'NVARCHAR' 
							WHEN StringValue IN ('number','checkbox','radio') THEN 'INT'
							WHEN StringValue = 'datetime' THEN 'DATETIME' 							
							WHEN StringValue = 'currency' THEN 'FLOAT'
							WHEN StringValue = 'time' THEN 'TIME'
					   END
	
	UPDATE #TMP_DATA
		SET DataTypeLength = CASE WHEN DataType = 'NVARCHAR' THEN '(MAX)'
							 END
		
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

	 DECLARE @DataCols VARCHAR(MAX) 
	 SET @DataCols = --STUFF(
					 (SELECT CONCAT(', [',[Name],'] [', DataType,'] ', DataTypeLength)
					 FROM #TMP_DATA
					 FOR XML PATH('')
					 )
					 --,1,1,'')

	SET @DataCols = CONCAT(',FrameworkID INT',@DataCols)
	PRINT @DataCols

	SET @DataCols = CONCAT(@SQL_ID,@DataCols,CHAR(10),',',@StaticCols)
	SET @SQL = CONCAT(N' CREATE TABLE dbo.', @Name ,'_data',CHAR(10), '(', @DataCols, ') ',CHAR(10))
	PRINT @SQL
	
	EXEC sp_executesql @SQL	

	--CLEANUP THESE ROWS AS THEY ARE NO LONGER NEEDED
	DELETE FROM #TMP_DATA WHERE StringValue = 'selectboxes_DELETE'
	--===========================================================================================================================
	
			
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

	BEGIN TRAN
	
	--INSERT NEW JSONKEY(NAME) IF IT DOES NOT EXIST=====================================================================================		
	IF @IsAvailable IS NULL OR @IsAvailable = 0	
	BEGIN
		SET IDENTITY_INSERT dbo.Frameworks ON;

		INSERT INTO dbo.Frameworks (FrameworkID,Name,FrameworkFile,UserCreated,DateCreated,VersionNum,FullSchemaJSON)
			SELECT  @FrameworkID,
					@Name,	
					@inputJSON,		
					@UserLoginID,
					GETUTCDATE(),
					@VersionNum,
					@FullSchemaJSON

		--SET @FrameworkID = SCOPE_IDENTITY()	
		SET IDENTITY_INSERT dbo.Frameworks OFF;
	END	
	ELSE ---RECORDS ALREADY AVAILABLE FOR PREVIOUS VERSIONS		
		UPDATE dbo.Frameworks
			SET VersionNum = @VersionNum,
				UserModified = 1,
				DateModified = GETUTCDATE()
		WHERE FrameworkID = @FrameworkID --AND Name = @Name
 --==================================================================================================================================
		
 				
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
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
		
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
			SET @TableName = CONCAT(@Name,'_',@TemplateTableName)

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
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
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
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
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

		SELECT @StepID = NULL, @StepItemID = NULL, @IsAvailable = NULL, @SQL = NULL, @TemplateTableName = NULL,
			   @AttributeID = NULL, @LookupID = NULL
		
 END		

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

		DECLARE @Params VARCHAR(MAX)
		DECLARE @ObjectName VARCHAR(100)

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

END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
			SET @Params = CONCAT('@Name=', CHAR(39),@Name, CHAR(39),',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=1')
			SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39))
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
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