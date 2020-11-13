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
	   AND Element_ID IN (2,6)-- (2,6),7
	    
 
 --SELECT * FROM #TMP_Objects
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
			@JSONFileKey VARCHAR(100) = 'TAB',
			@SQL NVARCHAR(MAX),
			@FileID INT
	 	
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
	SET @SQL = CONCAT(N' CREATE TABLE dbo.', @JSONFileKey ,'_data',CHAR(10), '(', @DataCols, ') ',CHAR(10))
	PRINT @SQL
	
	EXEC sp_executesql @SQL	
	--===========================================================================================================================

			
	DECLARE @HistTableName SYSNAME = 'Frameworks_List_History'
	SET @SQL = ''
	
	--GET THE FILEID & VERSION NO.: CHECK FOR THE EXISTENCE OF THE JSONKEY		
	SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@HistTableName,''')', CHAR(10))
	SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @FileID = FileID, @VersionNum = VersionNum + 1 FROM ',@HistTableName,' WHERE JSONFileKey = ''', @JSONFileKey,''' ORDER BY HistoryID DESC');	
	PRINT @SQL  
	EXEC sp_executesql @SQL, N'@FileID INT OUTPUT, @VersionNum INT OUTPUT',@FileID OUTPUT, @VersionNum OUTPUT;
	
	--SELECT @VersionNum= MAX(VersionNum) + 1 FROM dbo.Frameworks_List_history WHERE JSONFile = @JSONFileKey
	
	--SELECT @VersionNum
	--RETURN

	--SELECT TOP 1 @VersionNum = VersionNum + 1
	--FROM dbo.Frameworks_List
	--WHERE JSONFileKey = @JSONFileKey		  
	--ORDER BY VersionNum DESC
	
	IF @VersionNum IS NULL
		SET @VersionNum = 1

	--INSERT NEW JSONKEY IF IT DOES NOT EXIST=====================================================================================		
	IF @FileID IS NULL
	BEGIN
		INSERT INTO dbo.Frameworks_List (JSONFileKey,JSONFileText,UserCreated,DateCreated,VersionNum)
			SELECT  @JSONFileKey,	
					@inputJSON,		
					@UserCreated,
					GETDATE(),
					@VersionNum

		SET @FileID = SCOPE_IDENTITY()	
	END	
	ELSE ---RECORDS ALREADY AVAILABLE FOR PREVIOUS VERSIONS		
		UPDATE dbo.Frameworks_List
			SET VersionNum = @VersionNum,
				UserModified = 1,
				DateModified = GETDATE()
		WHERE FileID = @FileID --AND JSONFileKey = @JSONFileKey
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
			   
			    
			   			    
		--SELECT TOP 1 @VersionNum = FMS.VersionNum + 1
		--FROM dbo.Framework_Metafield_Steps FMS
		--	 INNER JOIN dbo.Framework_Metafield FM ON FM.StepID = FMS.StepID
		--WHERE FMS.StepName = @StepName
		--	  AND FM.StepItemKey = @StepItemKey
		--ORDER BY FMS.VersionNum DESC
		
		--IF @VersionNum IS NULL
		--	SET @VersionNum = 1
		--SELECT @VersionNum
		--RETURN
			
	
		--CHECK FOR THE EXISTENCE OF THE STEP======================================================================================================
		SET @HistTableName = CONCAT(@JSONFileKey,'_Framework_Steps_History')
		SET @SQL = ''

		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@HistTableName,''')', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepID = StepID FROM ',@HistTableName,' WHERE FileID = ', @FileID,' AND StepName = ''', @StepName,''' ORDER BY HistoryID DESC');	
		PRINT @SQL  
		EXEC sp_executesql @SQL, N'@StepID INT OUTPUT',@StepID OUTPUT;
		
		IF @StepID IS NULL
		BEGIN
			INSERT INTO dbo.Framework_Steps (FileID,StepName,DateCreated,UserCreated,VersionNum)
				SELECT @FileID,@StepName,GETDATE(),@UserCreated,@VersionNum	
			
			SET @StepID = SCOPE_IDENTITY()
		END
		ELSE
			UPDATE dbo.Framework_Steps
				SET VersionNum = @VersionNum,
					UserModified = 1,
					DateModified = GETDATE()
			WHERE StepID = @StepID
		--===========================================================================================================================================
						
		IF @StepID IS NOT NULL
		BEGIN
				
				--CHECK FOR THE EXISTENCE OF THE STEPITEM======================================================================================================
				SET @HistTableName = CONCAT(@JSONFileKey,'_Framework_StepItems_History')
				SET @SQL = ''

				SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@HistTableName,''')', CHAR(10))
				SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @StepItemID = StepItemID FROM ',@HistTableName,' WHERE StepID = ', @StepID,' AND StepItemKey = ''', @StepItemKey,''' ORDER BY HistoryID DESC');	
				PRINT @SQL  
				EXEC sp_executesql @SQL, N'@StepItemID INT OUTPUT',@StepItemID OUTPUT;
				
				IF @StepItemID IS NULL
				BEGIN
					INSERT INTO dbo.Framework_StepItems (FileID,StepID,StepItemName,StepItemType,StepItemKey,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT  @FileID,
								@StepID,								
								@StepItemName,
								@StepItemType,
								@StepItemKey,
								(SELECT SequenceNo FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
								GETDATE(),@UserCreated,@VersionNum	

					SET @StepItemID = SCOPE_IDENTITY()
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
							DateModified = GETDATE()
					WHERE @StepItemID = StepItemID --StepItemKey = @StepItemKey
			

				--IF @StepItemID IS NULL
				--	SELECT @StepItemID = StepItemID
				--	FROM dbo.Framework_StepItems
				--	WHERE StepItemKey = @StepItemKey
			
				DELETE FROM #TMP WHERE KeyName IN ('Label','type','key') AND Parent_ID = @ID	
								
				--SELECT * FROM #TMP 
				--RETURN				

					--GET THE STEPITEM ATTRIBUTES					 				
					INSERT INTO dbo.Framework_Attributes(FileID,StepItemID,AttributeValue,AttributeKey,OrderBy,DateCreated,UserCreated,VersionNum)							
						SELECT @FileID,@StepItemID,StringValue,KeyName,SequenceNo,GETDATE(),@UserCreated ,@VersionNum
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
					 
				--UPDATE FMA
				--	SET VersionNum = @VersionNum
				--FROM dbo.Framework_Attributes FMA
				--	 INNER JOIN #TMP TAB ON FMA.StepItemID=@StepItemID AND FMA.AttributeKey=TAB.KeyName
				--WHERE TAB.Parent_ID = @ID
				--	  OR
				--	 TAB.ParentName = 'validate'				

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
						--				WHERE FileID = @FileID
						--					  AND StepItemID=@StepItemID 
						--					  AND LookupName=@StepItemName
						--			)
						 INSERT INTO dbo.Framework_Lookups(FileID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
									VALUES (@FileID,@StepItemID,@LookupValues,@StepItemName,1,GETDATE(),@UserCreated,@VersionNum)
						
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
							
						 INSERT INTO dbo.Framework_Lookups(FileID,StepItemID,LookupValue,LookupName,LookupType,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT @FileID,
										   @StepItemID,
										   LookupValue,
										   LookupName,
										   LookupType,	 		  
											Parent_ID,
											GETDATE(),
											@UserCreated,
											@VersionNum	
									FROM #TMP_Lookups T
									--WHERE NOT EXISTS (SELECT 1 
									--					FROM dbo.Framework_Lookups FMA
									--					WHERE FileID = @FileID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.LookupName
									--				)


				END
				ELSE
								INSERT INTO dbo.Framework_Lookups(FileID,StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
									SELECT @FileID,
										   @StepItemID,
										   StringValue,
										   KeyName,
										   SequenceNo,
										   GETDATE(),
										   @UserCreated,
										   @VersionNum
									FROM #TMP T
									WHERE Parent_ID <> @ID
										AND KeyName ='value'
									--AND NOT EXISTS (SELECT 1 
									--					FROM dbo.Framework_Lookups FMA
									--					WHERE FileID = @FileID
									--						  AND StepItemID= @StepItemID 
									--						  AND LookupName= T.KeyName
									--				)

					UPDATE dbo.Framework_Metafield_Lookups SET VersionNum = @VersionNum
		
		END	--END OF OUTERMOST IF -> IF @StepID IS NOT NULL

		DELETE FROM #TMP_Objects WHERE Element_ID = @ID
		--DELETE FROM @Framework_Metafield
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups

		SELECT @StepID = NULL, @StepItemID = NULL

 END

		--SELECT * from dbo.Frameworks_List
		--SELECT * from dbo.Framework_Steps
		--SELECT * from dbo.Framework_StepItems
		--SELECT * from dbo.Framework_Attributes
		--SELECT * from dbo.Framework_Lookups

		--POPULATE TEMPLATE HISTORY TABLES**************************************************************************************
		--DECLARE @CurrentIdentifier INT = (SELECT MAX(VersionNum) + 1 FROM dbo.Frameworks_List_history WHERE JSONFileKey = @JSONFileKey)

		--IF @CurrentIdentifier IS NULL
		--	SET @CurrentIdentifier = 1

		DECLARE @CurrentIdentifier TINYINT = 1
		
		INSERT INTO [dbo].[Frameworks_List_history]
				   (FileID,
					JSONFileKey,
					JSONFileText
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   CurrentIdentifier)
		SELECT     FileID,
				   JSONFileKey,
				   JSONFileText
				  ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   @CurrentIdentifier
		FROM [dbo].[Frameworks_List]

		INSERT INTO [dbo].[Framework_Steps_history]
				   (StepID,
					FileID,
					[StepName]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   CurrentIdentifier)
		SELECT		StepID,
					@FileID,
					[StepName]
				   ,[UserCreated]
				   ,[DateCreated]
				   ,[UserModified]
				   ,[DateModified]
				   ,[VersionNum],
				   @CurrentIdentifier
		FROM dbo.[Framework_Steps]


				INSERT INTO [dbo].[Framework_StepItems_history]
						   (FileID,
							StepItemID,
							[StepID]
						   ,[StepItemName]
						   ,[StepItemType]
						   ,[StepItemKey]
						   ,[OrderBy]
						   ,[UserCreated]
						   ,[DateCreated]
						   ,[UserModified]
						   ,[DateModified]
						   ,[VersionNum],
						   CurrentIdentifier)
				SELECT @FileID,
					   StepItemID,
					  [StepID]
					,[StepItemName]
					,[StepItemType]
					,[StepItemKey]
					,[OrderBy]
					,[UserCreated]
					,[DateCreated]
					,[UserModified]
					,[DateModified]
					,[VersionNum],
					@CurrentIdentifier
				FROM dbo.Framework_StepItems        

 
		INSERT INTO [dbo].[Framework_Attributes_history]
				   (FileID,
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
				   CurrentIdentifier)
		SELECT		@FileID,
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
				   @CurrentIdentifier
		FROM dbo.[Framework_Attributes]

		INSERT INTO [dbo].[Framework_Lookups_history]
				   (FileID,
					ID,
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
				   CurrentIdentifier)
		SELECT		@FileID,
					ID,
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
				   @CurrentIdentifier    
		FROM dbo.Framework_Lookups

		--UPDATE dbo.Frameworks_List_history SET CurrentIdentifier = @VersionNum
		--UPDATE dbo.Framework_Metafield_Steps_history SET CurrentIdentifier = @VersionNum
		--UPDATE dbo.Framework_Metafield_history SET CurrentIdentifier = @VersionNum
		--UPDATE dbo.Framework_Metafield_Attributes_history SET CurrentIdentifier = @VersionNum
		--UPDATE dbo.Framework_Metafield_Lookups_history SET CurrentIdentifier = @VersionNum
		
	--**********************************************************************************************************************************	
		
		PRINT 'ParseJSONData Completed...'
			 
		EXEC dbo.CreateSchemaTables @FileID = @FileID, @VersionNum = @VersionNum

END