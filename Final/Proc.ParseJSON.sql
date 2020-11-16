--https://www.red-gate.com/simple-talk/blogs/consuming-hierarchical-json-documents-sql-server-using-openjson/
--CreateTables_v1.sql and ParseJSON_v2.sql
USE junk
GO
/*
Steps: ASSUMPTION -> STEPS VERSIONING CAN ONLNY BE LIMITED TO INSERT OR DELETE (i.e. A STEP(A TAB) CAN BE ADDED OR REMOVED ONLY)
*/
CREATE OR ALTER PROCEDURE dbo.ParseJSONData
@inputJSON VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

--EMPTY THE TEMPLATE TABLES----------------------
TRUNCATE TABLE dbo.Framework_Lookups_history
TRUNCATE TABLE dbo.Framework_Attributes_history
TRUNCATE TABLE dbo.Framework_StepItems_history
TRUNCATE TABLE dbo.Framework_Steps_history

TRUNCATE TABLE dbo.Framework_Lookups
TRUNCATE TABLE dbo.Framework_Attributes
TRUNCATE TABLE dbo.Framework_StepItems
TRUNCATE TABLE dbo.Framework_Steps
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
	   AND Element_ID<=12 --FILTERING OUT USERCREATED,DATECREATED,SUBMIT ETC.
	   AND Element_ID IN (2)-- (2,6),7
	    
 
 SELECT * FROM #TMP_Objects
 --RETURN
	 	DECLARE @ID INT,		
			@StepID INT,
			@StepName VARCHAR(500), --='XYZ',
			@StepItemType VARCHAR(500),		 
			@StepItemName VARCHAR(500),
			@LookupValues VARCHAR(1000),
			@StepItemID INT,
			@UserCreated INT = 1,
			@VersionNum INT,
			@StepItemKey VARCHAR(100),
			@Name VARCHAR(100) = 'TAB',
			@SQL NVARCHAR(MAX),
			@FrameworkID INT,
			@IsAvailable BIT,
			@TemplateTableName SYSNAME,
			@Counter INT = 1,
			@AttributeID INT, @LookupID INT
	 	
	--BUILD SCHEMA FOR _DATA TABLE============================================================================================	 
	 DROP TABLE IF EXISTS TAB_DATA -- REMOVE THIS LATER, NOT REQUIRED
	 DECLARE @SQL_ID VARCHAR(MAX)='ID INT IDENTITY(1,1)'
	 DECLARE @StaticCols VARCHAR(MAX) =	 
	 'UserCreated INT NOT NULL, 
	 DateCreated DATETIME2(0) NOT NULL, 
	 UserModified INT,
	 DateModified DATETIME2(0),
	 VersionNum INT NOT NULL'
	 
	 DROP TABLE IF EXISTS #TMP_DATA

	 SELECT TOB.Element_ID, TOB.NAME,TA.StringValue, CAST(NULL AS VARCHAR(50)) AS DataType,
			CAST(NULL AS VARCHAR(50)) AS DataTypeLength
		INTO #TMP_DATA
	 FROM #TMP_Objects TOB
		 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = TOB.Element_ID
	 WHERE TA.Name = 'type'

	 UPDATE #TMP_DATA
		SET DataType = CASE WHEN StringValue IN ('textfield','selectboxes','select','textarea') THEN 'NVARCHAR' 
							WHEN StringValue = 'number' THEN 'INT' 
						END
	
	UPDATE #TMP_DATA
		SET DataTypeLength = CASE WHEN DataType = 'NVARCHAR' THEN '(MAX)'
							 END
			
	-- SELECT * FROM #TMP_DATA

	 DECLARE @DataCols VARCHAR(MAX) 
	 SET @DataCols = --STUFF(
					 (SELECT CONCAT(', [',[Name],'] [', DataType,'] ', DataTypeLength)
					 FROM #TMP_DATA
					 FOR XML PATH('')
					 )
					 --,1,1,'')
	PRINT @DataCols	

	SET @DataCols = CONCAT(@SQL_ID,@DataCols,CHAR(10),',',@StaticCols)
	SET @SQL = CONCAT(N' CREATE TABLE dbo.', @Name ,'_data',CHAR(10), '(', @DataCols, ') ',CHAR(10))
	PRINT @SQL
	
	EXEC sp_executesql @SQL	
	--===========================================================================================================================

			
	DECLARE @TableName SYSNAME = 'dbo.Frameworks_List'
	SET @SQL = ''
	
	--GET THE FrameworkID & VERSION NO.: CHECK FOR THE EXISTENCE OF THE JSONKEY		
		--SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10)) --ASSUSMPTION:Frameworks_List IS ALREADY AVAILABLE
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM ',@TableName,')', CHAR(10))	--ASSUSMPTION:Frameworks_List IS ALREADY AVAILABLE
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
		SET IDENTITY_INSERT dbo.Frameworks_List ON;

		INSERT INTO dbo.Frameworks_List (FrameworkID,Name,FrameworkFile,UserCreated,DateCreated,VersionNum)
			SELECT  @FrameworkID,
					@Name,	
					@inputJSON,		
					@UserCreated,
					GETUTCDATE(),
					@VersionNum

		--SET @FrameworkID = SCOPE_IDENTITY()	
		SET IDENTITY_INSERT dbo.Frameworks_List OFF;
	END	
	ELSE ---RECORDS ALREADY AVAILABLE FOR PREVIOUS VERSIONS		
		UPDATE dbo.Frameworks_List
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
			   @StepName  = (SELECT StringValue FROM #TMP WHERE KeyName ='Parent' AND Parent_ID = @ID)	  
			   			    		
	
		--CHECK FOR THE EXISTENCE OF THE STEP======================================================================================================		
		SELECT @SQL = '', @StepID= NULL,@IsAvailable = NULL
		SET @TemplateTableName = 'Framework_Steps'
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
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = MAX(StepID) + 1 FROM ',@TemplateTableName,CHAR(10));	
		SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = 1, @IsAvailable = NULL;', CHAR(10))
		SET @SQL = CONCAT(@SQL,' END ', CHAR(10))
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@StepID INT OUTPUT,@IsAvailable BIT OUTPUT',@StepID OUTPUT,@IsAvailable OUTPUT;
		
		IF @IsAvailable IS NULL OR @IsAvailable = 0		
		BEGIN			
				SET IDENTITY_INSERT dbo.Framework_Steps ON;
				
				INSERT INTO dbo.Framework_Steps (StepID,FrameworkID,StepName,DateCreated,UserCreated,VersionNum)
					SELECT @StepID,@FrameworkID,@StepName,GETUTCDATE(),@UserCreated,@VersionNum	
			
				--SET @StepID = SCOPE_IDENTITY()
				SET IDENTITY_INSERT dbo.Framework_Steps OFF;
		END
		ELSE
			UPDATE dbo.Framework_Steps
				SET VersionNum = @VersionNum,
					UserModified = 1,
					DateModified = GETUTCDATE()
			WHERE StepID = @StepID			
		--===========================================================================================================================================
		
		INSERT INTO [dbo].[Framework_Steps_history]
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
			SET @TemplateTableName = 'Framework_StepItems'
			SET @TableName = CONCAT(@Name,'_',@TemplateTableName)

			SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
			SET @SQL = CONCAT(@SQL,' BEGIN ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SET @IsAvailable = 1; ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepItemID = StepItemID FROM ',@TableName,' WHERE FrameworkID =',@FrameworkID,' AND StepID = ', @StepID,' AND StepItemKey = ''', @StepItemKey,''' ORDER BY StepItemID DESC;', CHAR(10));	
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
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = MAX(StepItemID) + 1 FROM ',@TemplateTableName,CHAR(10));	
			SET @SQL = CONCAT(@SQL,' ELSE ', CHAR(10))
			SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = 1, @IsAvailable = NULL;', CHAR(10))
			SET @SQL = CONCAT(@SQL,' END ', CHAR(10))			
			PRINT @SQL  
			EXEC sp_executesql @SQL, N'@StepItemID INT OUTPUT,@IsAvailable BIT OUTPUT',@StepItemID OUTPUT,@IsAvailable OUTPUT;
		
		IF @IsAvailable IS NULL OR @IsAvailable = 0
		BEGIN

					SET IDENTITY_INSERT dbo.Framework_StepItems ON;

					INSERT INTO dbo.Framework_StepItems (StepItemID,FrameworkID,StepID,StepItemName,StepItemType,StepItemKey,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT  @StepItemID,
								@FrameworkID,
								@StepID,								
								@StepItemName,
								@StepItemType,
								@StepItemKey,
								(SELECT SequenceNo FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
								GETUTCDATE(),@UserCreated,@VersionNum	

					--SET @StepItemID = SCOPE_IDENTITY()
					SET IDENTITY_INSERT dbo.Framework_StepItems OFF;				
		END
		ELSE IF NOT EXISTS(SELECT 1 FROM Framework_StepItems WHERE StepItemKey = @StepItemKey AND StepID = @StepID) --KEY MOVED TO A DIFFERENT STEP
				UPDATE dbo.Framework_StepItems
					SET StepID = @StepID,
						VersionNum = @VersionNum
				WHERE StepItemKey = @StepItemKey
		ELSE
			UPDATE dbo.Framework_StepItems
				SET VersionNum = @VersionNum,
					UserModified = 1,
					DateModified = GETUTCDATE()
			WHERE @StepItemID = StepItemID --StepItemKey = @StepItemKey
							
				INSERT INTO [dbo].[Framework_StepItems_history]
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
				--	FROM dbo.Framework_StepItems
				--	WHERE StepItemKey = @StepItemKey
			
				DELETE FROM #TMP WHERE KeyName IN ('Label','type','key') AND Parent_ID = @ID	
								
				--SELECT * FROM #TMP 
				--RETURN				
					
		--GET ATTRIBUTE/LOOKUP ID FOR NEW DATA THAT NEEDS TO BE INSERTED
		--================================================================================================================================== 		
		SELECT @SQL = ''
		SET @TemplateTableName = 'Framework_Attributes'
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' SELECT @AttributeID = MAX(AttributeID) + 1 FROM ',@TableName);						
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@AttributeID INT OUTPUT',@AttributeID OUTPUT;

		
		IF @AttributeID IS NULL AND NOT EXISTS(SELECT 1 FROM dbo.Framework_Attributes)
			SET @AttributeID = 0;
		ELSE IF EXISTS(SELECT 1 FROM dbo.Framework_Attributes)
			SELECT @AttributeID  = MAX(AttributeID) + 1 FROM dbo.Framework_Attributes
						
		SELECT @SQL = ''
		SET @TemplateTableName = 'Framework_Lookups'
		SET @TableName = CONCAT(@Name,'_',@TemplateTableName)
		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))	--ASSUSMPTION:Framework TABLE WILL NOT BE AVAILABLE IN THE 1ST VERSION AND CREATED DYNAMICALLY BY THE NEXT PROCEDURE
		SET @SQL = CONCAT(@SQL,' IF EXISTS(SELECT 1 FROM ',@TableName,')', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @LookupID = MAX(LookupID) + 1 FROM ',@TableName);						
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@LookupID INT OUTPUT',@LookupID OUTPUT;
			
		IF @LookupID IS NULL AND NOT EXISTS(SELECT 1 FROM dbo.Framework_Lookups)		
			SET @LookupID = 0;			
		ELSE IF EXISTS(SELECT 1 FROM dbo.Framework_Lookups)		
			SELECT @LookupID  = MAX(LookupID) + 1 FROM dbo.Framework_Lookups
		--==================================================================================================================================
					
					SET IDENTITY_INSERT dbo.[Framework_Attributes] ON;
		
					--GET THE STEPITEM ATTRIBUTES					 				
					INSERT INTO dbo.Framework_Attributes(AttributeID,FrameworkID,StepItemID,AttributeValue,AttributeKey,OrderBy,DateCreated,UserCreated,VersionNum)							
						SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @AttributeID,
							   @FrameworkID,@StepItemID,StringValue,KeyName,SequenceNo,GETUTCDATE(),@UserCreated ,@VersionNum
							FROM #TMP T
							WHERE (Parent_ID = @ID
								 OR
								 ParentName = 'validate'	
								 )
						--AND NOT EXISTS (SELECT 1 
						--				FROM dbo.Framework_Attributes FMA
						--				WHERE FMA.StepItemID=@StepItemID 
						--						AND FMA.AttributeKey=T.KeyName
						--				)
					
					 SET IDENTITY_INSERT dbo.[Framework_Attributes] OFF;
				--UPDATE FMA
				--	SET VersionNum = @VersionNum
				--FROM dbo.Framework_Attributes FMA
				--	 INNER JOIN #TMP TAB ON FMA.StepItemID=@StepItemID AND FMA.AttributeKey=TAB.KeyName
				--WHERE TAB.Parent_ID = @ID
				--	  OR
				--	 TAB.ParentName = 'validate'				

				SET IDENTITY_INSERT dbo.Framework_Lookups ON;

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
						--				FROM dbo.Framework_Lookups FMA
						--				WHERE FrameworkID = @FrameworkID
						--					  AND StepItemID=@StepItemID 
						--					  AND LookupName=@StepItemName
						--			)

						
						 INSERT INTO dbo.Framework_Lookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
							SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
								   @FrameworkID,@StepItemID,@LookupValues,@StepItemName,1,GETUTCDATE(),@UserCreated,@VersionNum						
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
					
						 INSERT INTO dbo.Framework_Lookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,LookupType,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   LookupValue,
										   LookupName,
										   LookupType,	 		  
											Parent_ID,
											GETUTCDATE(),
											@UserCreated,
											@VersionNum	
									FROM #TMP_Lookups T
									--WHERE NOT EXISTS (SELECT 1 
									--					FROM dbo.Framework_Lookups FMA
									--					WHERE FrameworkID = @FrameworkID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.LookupName
									--				)					
							
				END
				ELSE
										
								INSERT INTO dbo.Framework_Lookups(LookupID,FrameworkID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT ROW_NUMBER()OVER(ORDER BY (SELECT NULL)) + @LookupID,
										   @FrameworkID,
										   @StepItemID,
										   StringValue,
										   KeyName,
										   SequenceNo,
										   GETUTCDATE(),
										   @UserCreated,
										   @VersionNum
									FROM #TMP T
									WHERE Parent_ID <> @ID
										AND KeyName ='value'
									--AND NOT EXISTS (SELECT 1 
									--					FROM dbo.Framework_Lookups FMA
									--					WHERE FrameworkID = @FrameworkID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.KeyName
									--				)			
					
					SET IDENTITY_INSERT dbo.Framework_Lookups OFF;
										
					UPDATE dbo.Framework_Metafield_Lookups SET VersionNum = @VersionNum
		
		END	--END OF OUTERMOST IF -> IF @StepID IS NOT NULL

		DELETE FROM #TMP_Objects WHERE Element_ID = @ID
		--DELETE FROM @Framework_Metafield
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups

		SELECT @StepID = NULL, @StepItemID = NULL, @IsAvailable = NULL, @SQL = NULL, @TemplateTableName = NULL,
			   @AttributeID = NULL, @LookupID = NULL
		
 END

		--SELECT * from dbo.Frameworks_List
		--SELECT * from dbo.Framework_Steps
		--SELECT * from dbo.Framework_StepItems
		--SELECT * from dbo.Framework_Attributes
		--SELECT * from dbo.Framework_Lookups

		--POPULATE TEMPLATE HISTORY TABLES**************************************************************************************
		--DECLARE @PeriodIdentifierID INT = (SELECT MAX(VersionNum) + 1 FROM dbo.Frameworks_List_history WHERE Name = @Name)

		--IF @PeriodIdentifierID IS NULL
		--	SET @PeriodIdentifierID = 1

		DECLARE @PeriodIdentifierID TINYINT = 1
		
		UPDATE [dbo].[Frameworks_List_history]
			SET PeriodIdentifierID = 0,
				UserModified = 1,
				DateModified = GETUTCDATE()
		WHERE FrameworkID = @FrameworkID
			  AND VersionNum < @VersionNum

		INSERT INTO [dbo].[Frameworks_List_history]
				   (FrameworkID,
					Name,
					FrameworkFile
				   ,[UserCreated]
				   ,[DateCreated]				   
				   ,[VersionNum],
				   PeriodIdentifierID)
		SELECT  @FrameworkID,
				@Name,	
				@inputJSON,		
				@UserCreated,
				GETUTCDATE(),
				@VersionNum,
				@PeriodIdentifierID
		
		INSERT INTO [dbo].[Framework_Attributes_history]
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
		FROM dbo.[Framework_Attributes]
		ORDER BY [OrderBy]

		
		INSERT INTO [dbo].[Framework_Lookups_history]
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
		FROM dbo.Framework_Lookups
		ORDER BY [OrderBy]

		--UPDATE dbo.Frameworks_List_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Steps_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Attributes_history SET PeriodIdentifierID = @VersionNum
		--UPDATE dbo.Framework_Metafield_Lookups_history SET PeriodIdentifierID = @VersionNum
		
	--**********************************************************************************************************************************	
		
		PRINT 'ParseJSONData Completed...'
			 
		EXEC dbo.CreateSchemaTables @FrameworkID = @FrameworkID, @VersionNum = @VersionNum

END