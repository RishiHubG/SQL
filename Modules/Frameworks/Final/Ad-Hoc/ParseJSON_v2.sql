--https://www.red-gate.com/simple-talk/blogs/consuming-hierarchical-json-documents-sql-server-using-openjson/
--CreateTables_v1.sql and ParseJSON_v2.sql
USE junk
GO

TRUNCATE TABLE dbo.Framework_Lookups_history
TRUNCATE TABLE dbo.Framework_Attributes_history
TRUNCATE TABLE dbo.Framework_StepItems_history
TRUNCATE TABLE dbo.Framework_Steps_history
TRUNCATE TABLE dbo.Frameworks_List_history

DELETE FROM dbo.Framework_Lookups
DELETE FROM  dbo.Framework_Attributes
DELETE FROM  dbo.Framework_StepItems
DELETE FROM  dbo.Framework_Steps
DELETE FROM  dbo.Frameworks_List
 
DROP TABLE IF EXISTS #TMP_ALLSTEPS

DECLARE @inputJSON VARCHAR(MAX)=
'{
    "name": {
        "label": "Name",
        "tableView": true,
        "validate": {
            "required": true,
            "minLength": 1,
            "maxLength": 500
        },
        "key": "name",
        "type": "textfield",
        "input": false,
        "hideOnChildrenHidden": false
    },
    "reference": {
        "label": "Reference",
        "tableView": true,
        "inputFormat": "html",
        "key": "reference",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "reference1": {
        "label": "Reference",
        "disabled": true,
        "tableView": true,
        "validate": {
            "unique": true
        },
        "unique": true,
        "key": "reference1",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "riskDescription": {
        "label": "Risk Description",
        "tableView": true,
        "inputFormat": "html",
        "key": "riskDescription",
        "type": "textfield",
        "input": true
    },
    "riskCategory1": {
        "label": "Applicable Factor",
        "optionsLabelPosition": "right",
        "tableView": false,
        "defaultValue": {
            "": false,
            "strategic": false,
            "busienss": false,
            "management": false
        },
        "values": [
            {
                "label": "Strategic",
                "value": "strategic",
                "shortcut": ""
            },
            {
                "label": "Busienss",
                "value": "busienss",
                "shortcut": ""
            },
            {
                "label": "Management",
                "value": "management",
                "shortcut": ""
            }
        ],
        "key": "riskCategory1",
        "type": "selectboxes",
        "input": true,
        "inputType": "checkbox",
        "hideOnChildrenHidden": false
    },
    "riskCategory2": {
        "label": "Risk Category 1",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "Nature",
                    "value": "Nature"
                },
                {
                    "label": "Machinery",
                    "value": "machinery"
                },
                {
                    "label": "Legal",
                    "value": "legal"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "riskCategory2",
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false
    },
    "riskCategory3": {
        "label": "Risk Category 2",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "Flood",
                    "value": "flood"
                },
                {
                    "label": "Fire",
                    "value": "fire"
                },
                {
                    "label": "Earthquake",
                    "value": "earthquake"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "riskCategory3",
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false
    },
    "likelyhood": {
        "label": "Likelyhood",
        "mask": false,
        "spellcheck": true,
        "tableView": false,
        "delimiter": false,
        "requireDecimal": false,
        "inputFormat": "plain",
        "validate": {
            "required": true,
            "min": 0,
            "max": 100
        },
        "key": "likelyhood",
        "type": "number",
        "input": true
    },
    "financialImpact": {
        "label": "Financial Impact",
        "mask": false,
        "spellcheck": true,
        "tableView": false,
        "delimiter": true,
        "requireDecimal": true,
        "inputFormat": "plain",
        "key": "financialImpact",
        "type": "number",
        "input": true,
        "decimalLimit": 2
    },
    "inherentRating": {
        "label": "Inherent Rating",
        "tableView": true,
        "calculateValue": "value = data.likelyhood/100 + data.FinancialImpact;",
        "key": "inherentRating",
        "type": "textfield",
        "input": true
    },
    "overallComment": {
        "label": "Overall Comment",
        "autoExpand": false,
        "tableView": true,
        "key": "overallComment",
        "type": "textarea",
        "input": true
    },
    "dateCreated": {
        "label": "Date Created",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateCreated",
        "type": "datetime",
        "input": true,
        "widget": {
            "type": "calendar",
            "displayInTimezone": "viewer",
            "language": "en",
            "useLocaleSettings": false,
            "allowInput": true,
            "mode": "single",
            "enableTime": true,
            "noCalendar": false,
            "format": "yyyy-MM-dd hh:mm a",
            "hourIncrement": 1,
            "minuteIncrement": 1,
            "time_24hr": false,
            "minDate": null,
            "disableWeekends": false,
            "disableWeekdays": false,
            "maxDate": null
        },
        "hideOnChildrenHidden": false
    },
    "userCreated": {
        "label": "User Created",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": true,
        "key": "userCreated",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "dateModified": {
        "label": "Date Modified",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateModified",
        "type": "datetime",
        "input": true,
        "widget": {
            "type": "calendar",
            "displayInTimezone": "viewer",
            "language": "en",
            "useLocaleSettings": false,
            "allowInput": true,
            "mode": "single",
            "enableTime": true,
            "noCalendar": false,
            "format": "yyyy-MM-dd hh:mm a",
            "hourIncrement": 1,
            "minuteIncrement": 1,
            "time_24hr": false,
            "minDate": null,
            "disableWeekends": false,
            "disableWeekdays": false,
            "maxDate": null
        },
        "hideOnChildrenHidden": false
    },
    "userModified": {
        "label": "User Modified",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": true,
        "key": "userModified",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "submit": {
        "type": "button",
        "label": "Submit",
        "key": "submit",
        "disableOnInvalid": true,
        "input": true,
        "tableView": false
    }
}'

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@inputJSON)

 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =2
 --SELECT * FROM #TMP_ALLSTEPS WHERE Parent_ID =20

 --SELECT * FROM #TMP_ALLSTEPS

 DROP TABLE IF EXISTS #TMP_Objects

 SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS
	   AND Element_ID<=12 --FILTERING OUT USERCREATED,DATECREATED,SUBMIT ETC.
	   AND Element_ID IN (2)-- (2,6),7
	    
 
 --SELECT * FROM #TMP_Objects
	 	DECLARE @ID INT,		
			@StepID INT,
			@StepName VARCHAR(500) ='ABC',
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

			
	DECLARE @TableName SYSNAME = CONCAT(@JSONFileKey,'_Frameworks_List')
	SET @SQL = ''
	
	--GET THE FILEID & VERSION NO.: CHECK FOR THE EXISTENCE OF THE JSONKEY		
	SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))
	SET @SQL = CONCAT(@SQL,' SELECT TOP 1 @FileID = FileID, @VersionNum = VersionNum + 1 FROM ',@TableName,' WHERE JSONFileKey = ''', @JSONFileKey,''' ORDER BY FileID DESC');	
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
	ELSE
		UPDATE dbo.Frameworks_List
			SET VersionNum = @VersionNum
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
			   @StepItemKey = (SELECT StringValue FROM #TMP WHERE KeyName ='key' AND Parent_ID = @ID)	
			   			    
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
		SET @TableName = CONCAT(@JSONFileKey,'_Framework_Steps')
		SET @SQL = ''

		SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))
		SET @SQL = CONCAT(@SQL,' SELECT @StepID = StepID FROM ',@TableName,' WHERE FileID = ', @FileID,' AND StepName = ''', @StepName,'''');	
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
				SET VersionNum = @VersionNum
			WHERE StepID = @StepID
		--===========================================================================================================================================
						
		IF @StepID IS NOT NULL
		BEGIN
				
				--CHECK FOR THE EXISTENCE OF THE STEPITEM======================================================================================================
				SET @TableName = CONCAT(@JSONFileKey,'_Framework_StepItems')
				SET @SQL = ''

				SET @SQL = CONCAT(' IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME =''',@TableName,''')', CHAR(10))
				SET @SQL = CONCAT(@SQL,' SELECT @StepItemID = StepItemID FROM ',@TableName,' WHERE StepID = ', @StepID,' AND StepItemKey = ''', @StepItemKey,'''');	
				PRINT @SQL  
				EXEC sp_executesql @SQL, N'@StepItemID INT OUTPUT',@StepItemID OUTPUT;
				
				IF @StepItemID IS NULL
				BEGIN
					INSERT INTO dbo.Framework_StepItems (StepID,StepItemName,StepItemType,StepItemKey,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT  @StepID,								
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
						SET VersionNum = @VersionNum
					WHERE @StepItemID = StepItemID --StepItemKey = @StepItemKey
			

				--IF @StepItemID IS NULL
				--	SELECT @StepItemID = StepItemID
				--	FROM dbo.Framework_StepItems
				--	WHERE StepItemKey = @StepItemKey
			
				DELETE FROM #TMP WHERE KeyName IN ('Label','type','key') AND Parent_ID = @ID	

				--SELECT * FROM #TMP 
				--RETURN				

				--GET THE STEPITEM ATTRIBUTES	
				MERGE dbo.Framework_Attributes FMA
				USING (SELECT @StepItemID AS StepItemID,StringValue,KeyName,SequenceNo,GETDATE() AS DateCreated,@UserCreated AS UserCreated,@VersionNum AS VersionNum	
							FROM #TMP T
							WHERE Parent_ID = @ID
								 OR
								 ParentName = 'validate'	
						)TAB
				ON FMA.StepItemID=@StepItemID AND FMA.AttributeKey=TAB.KeyName
				WHEN MATCHED AND AttributeValue <> TAB.StringValue THEN 
						UPDATE SET 
							AttributeValue = TAB.StringValue,
							DateModified = GETDATE(),
							UserModified = '1'								
				WHEN NOT MATCHED BY TARGET 
					THEN INSERT (StepItemID,AttributeValue,AttributeKey,OrderBy,DateCreated,UserCreated,VersionNum)
							VALUES (TAB.StepItemID,TAB.StringValue,TAB.KeyName,TAB.SequenceNo,TAB.DateCreated,TAB.UserCreated,TAB.VersionNum)
				WHEN NOT MATCHED BY SOURCE AND FMA.StepItemID=@StepItemID
					THEN DELETE;
						
				UPDATE FMA
					SET VersionNum = @VersionNum
				FROM dbo.Framework_Attributes FMA
					 INNER JOIN #TMP TAB ON FMA.StepItemID=@StepItemID AND FMA.AttributeKey=TAB.KeyName
				WHERE TAB.Parent_ID = @ID
					  OR
					 TAB.ParentName = 'validate'				

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

						MERGE INTO dbo.Framework_Lookups FML
						USING (SELECT @StepItemID AS StepItemID,@LookupValues AS LookupValues,@StepItemName AS LookupName,1 AS OrderBy, GETDATE() AS DateCreated,@UserCreated AS UserCreated,@VersionNum AS VersionNum	
							  )TAB
						ON FML.StepItemID=TAB.StepItemID AND FML.LookupName=TAB.LookupName
						WHEN MATCHED AND FML.LookupValue <> TAB.LookupValues THEN 
								UPDATE SET 
									LookupValue = TAB.LookupValues,
									VersionNum = TAB.VersionNum,
									DateModified = GETDATE(),
									UserModified = '1'								
						WHEN NOT MATCHED BY TARGET 
							THEN INSERT (StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
									VALUES (TAB.StepItemID,TAB.LookupValues,TAB.LookupName,TAB.OrderBy,TAB.DateCreated,TAB.UserCreated,TAB.VersionNum)
						WHEN NOT MATCHED BY SOURCE AND FML.StepItemID=@StepItemID
							THEN DELETE;					

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
					
							MERGE INTO dbo.Framework_Lookups FML
							USING (SELECT @StepItemID AS StepItemID,
											  LookupName,
											  LookupValue,
											  LookupType,	 		  
											  Parent_ID,
											  GETDATE() AS DateCreated,
											  @UserCreated AS UserCreated,
											  @VersionNum AS VersionNum	
										FROM #TMP_Lookups
								  )TAB
							ON FML.StepItemID=TAB.StepItemID AND FML.LookupName=TAB.LookupName
							--WHEN MATCHED AND FML.LookupValue <> TAB.LookupValue THEN 
							WHEN MATCHED THEN
									UPDATE SET 
										LookupValue = TAB.LookupValue,
										VersionNum = TAB.VersionNum,
										DateModified = GETDATE(),
										UserModified = '1'								
							WHEN NOT MATCHED BY TARGET 
								THEN INSERT (StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
										VALUES (TAB.StepItemID,TAB.LookupValue,TAB.LookupName,TAB.Parent_ID,TAB.DateCreated,TAB.UserCreated,TAB.VersionNum)
							WHEN NOT MATCHED BY SOURCE AND FML.StepItemID=@StepItemID
								THEN DELETE;
						
				END
				ELSE	
						MERGE INTO dbo.Framework_Lookups FML
						USING (	SELECT @StepItemID AS StepItemID,StringValue AS LookupValue,KeyName,SequenceNo,GETDATE() AS DateCreated,
								  @UserCreated AS UserCreated,
								  @VersionNum AS VersionNum	
								FROM #TMP T
								WHERE Parent_ID <> @ID
										AND KeyName ='value'
							  )TAB
						ON FML.StepItemID=TAB.StepItemID AND FML.LookupName=TAB.KeyName
						--WHEN MATCHED AND FML.LookupValue <> TAB.LookupValue THEN 
						WHEN MATCHED THEN 
								UPDATE SET 
									LookupValue = TAB.LookupValue,
									VersionNum = TAB.VersionNum,
									DateModified = GETDATE(),
									UserModified = '1'								
						WHEN NOT MATCHED BY TARGET 
							THEN INSERT (StepItemID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
									VALUES (TAB.StepItemID,TAB.LookupValue,TAB.KeyName,TAB.SequenceNo,TAB.DateCreated,TAB.UserCreated,TAB.VersionNum)
						WHEN NOT MATCHED BY SOURCE AND FML.StepItemID=@StepItemID
							THEN DELETE;
					
					UPDATE dbo.Framework_Metafield_Lookups SET VersionNum = @VersionNum
		
		END	--END OF OUTERMOST IF -> IF @StepID IS NOT NULL

		DELETE FROM #TMP_Objects WHERE Element_ID = @ID
		--DELETE FROM @Framework_Metafield
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups

		SET @StepItemID = NULL

 END

		SELECT * from dbo.Frameworks_List
		SELECT * from dbo.Framework_Steps
		SELECT * from dbo.Framework_StepItems
		SELECT * from dbo.Framework_Attributes
		SELECT * from dbo.Framework_Lookups

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
						   (StepItemID,
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
				SELECT StepItemID,
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
				   (AttributeID,
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
		SELECT		AttributeID,
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
				   (ID,
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
		SELECT ID,
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

		SELECT * from dbo.Frameworks_List_history
		SELECT * from dbo.Framework_Steps_history
		SELECT * from dbo.Framework_StepItems_history
		SELECT * from dbo.Framework_Attributes_history
		SELECT * from dbo.Framework_Lookups_history
	--**********************************************************************************************************************************	