--https://www.red-gate.com/simple-talk/blogs/consuming-hierarchical-json-documents-sql-server-using-openjson/
USE junk
GO
 
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
                    "value": "1-2"
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
	    
 
 SELECT * FROM #TMP_Objects
 --RETURN

	DECLARE @ID INT,		
			@StepID INT,
			@StepName VARCHAR(500) ='ABC',
			@StepItemType VARCHAR(500),		 
			@StepItemName VARCHAR(500),
			@LookupValues VARCHAR(1000),
			@MetaFieldID INT,
			@UserCreated INT = 1,
			@VersionNum INT,
			@StepItemKey VARCHAR(100)

			--SELECT @VersionNum = MAX(VersionNum) FROM dbo.Framework_Metafield_Steps WHERE StepName=@StepName

			--IF @VersionNum IS NULL 
			--	SET @VersionNum = 1
			--ELSE
			--	SET @VersionNum = @VersionNum + 1

	DECLARE @Framework_Metafield TABLE
	(
	ID INT NULL,
	StepID INT NOT NULL,
	StepName VARCHAR(100) NOT NULL,
	StepItemName VARCHAR(100) NOT NULL,
	StepItemType VARCHAR(100) NOT NULL,
	StepItemKey VARCHAR(100) NOT NULL,
	OrderBy INT
	)

	DECLARE @Framework_Attributes TABLE
	(
	ID INT,
	MetaFieldID INT NOT NULL,
	AttributeKey VARCHAR(100) NOT NULL,	
	AttributeValue VARCHAR(100) NOT NULL,
	OrderBy INT
	)

	DECLARE @Framework_Metafield_Lookups TABLE
	(
	ID INT,
	MetaFieldAttributeID INT NULL,
	LookupName VARCHAR(100) NOT NULL,
	LookupValue VARCHAR(100) NOT NULL,
	OrderBy INT
	)

	DECLARE @Framework_Metafield_Steps TABLE
	(
	StepID INT IDENTITY(1,1),
	StepName VARCHAR(500) NOT NULL,
	DateCreated DATETIME2(0),
	UserCreated INT
	)

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
			   			    
		SELECT TOP 1 @VersionNum = FMS.VersionNum + 1
		FROM dbo.Framework_Metafield_Steps FMS
			 INNER JOIN dbo.Framework_Metafield FM ON FM.StepID = FMS.StepID
		WHERE FMS.StepName = @StepName
			  AND FM.StepItemKey = @StepItemKey
		ORDER BY FMS.VersionNum DESC
		
		IF @VersionNum IS NULL
			SET @VersionNum = 1
		SELECT @VersionNum
		--RETURN
		IF NOT EXISTS(SELECT 1 FROM dbo.Framework_Metafield_Steps WHERE StepName = @StepName)
		BEGIN
			INSERT INTO dbo.Framework_Metafield_Steps (StepName,DateCreated,UserCreated,VersionNum)
				SELECT @StepName,GETDATE(),@UserCreated,@VersionNum	
			
			SET @StepID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SELECT @StepID = StepID FROM dbo.Framework_Metafield_Steps WHERE StepName = @StepName

			UPDATE dbo.Framework_Metafield_Steps
				SET VersionNum = @VersionNum
			WHERE StepID = @StepID
		END
				
		IF @StepID IS NOT NULL
		BEGIN

				IF NOT EXISTS(SELECT 1 FROM Framework_Metafield WHERE StepItemKey = @StepItemKey)
				BEGIN
					INSERT INTO dbo.Framework_Metafield (StepID,StepName,StepItemName,StepItemType,StepItemKey,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT  @StepID,
								@StepName,
								@StepItemName,
								@StepItemType,
								@StepItemKey,
								(SELECT SequenceNo FROM #TMP WHERE KeyName ='Label' AND Parent_ID = @ID),
								GETDATE(),@UserCreated,@VersionNum	

					SET @MetaFieldID = SCOPE_IDENTITY()
				END
				ELSE IF NOT EXISTS(SELECT 1 FROM Framework_Metafield WHERE StepItemKey = @StepItemKey AND StepID = @StepID) --KEY MOVED TO A DIFFERENT STEP
						UPDATE dbo.Framework_Metafield
							SET StepID = @StepID
						WHERE StepItemKey = @StepItemKey
				ELSE
					UPDATE dbo.Framework_Metafield
						SET VersionNum = @VersionNum
					WHERE StepItemKey = @StepItemKey

				IF @MetaFieldID IS NULL
					SELECT @MetaFieldID = MetaFieldID
					FROM dbo.Framework_Metafield
					WHERE StepItemKey = @StepItemKey
			
				DELETE FROM #TMP WHERE KeyName IN ('Label','type','key') AND Parent_ID = @ID	

				--SELECT * FROM #TMP 
				--RETURN

				--GET THE STEPITEM ATTRIBUTES	
				MERGE dbo.Framework_Metafield_Attributes FMA
				USING (SELECT @MetaFieldID AS MetaFieldID,StringValue,KeyName,SequenceNo,GETDATE() AS DateCreated,@UserCreated AS UserCreated,@VersionNum AS VersionNum	
							FROM #TMP T
							WHERE Parent_ID = @ID
								 OR
								 ParentName = 'validate'	
						)TAB
				ON FMA.MetaFieldID=@MetaFieldID AND FMA.AttributeKey=TAB.KeyName
				WHEN MATCHED AND AttributeValue <> TAB.StringValue THEN 
						UPDATE SET 
							AttributeValue = TAB.StringValue,
							DateModified = GETDATE(),
							UserModified = '1'								
				WHEN NOT MATCHED BY TARGET 
					THEN INSERT (MetaFieldID,AttributeValue,AttributeKey,OrderBy,DateCreated,UserCreated,VersionNum)
							VALUES (TAB.MetaFieldID,TAB.StringValue,TAB.KeyName,TAB.SequenceNo,TAB.DateCreated,TAB.UserCreated,TAB.VersionNum)
				WHEN NOT MATCHED BY SOURCE 
					THEN DELETE;
						
				--INSERT INTO dbo.Framework_Metafield_Attributes (MetaFieldID,AttributeValue,AttributeKey,OrderBy,DateCreated,UserCreated,VersionNum)
				--	SELECT @MetaFieldID,StringValue,KeyName,SequenceNo,GETDATE(),@UserCreated,@VersionNum	
				--	FROM #TMP T
				--	WHERE Parent_ID = @ID
				--		 OR
				--		 ParentName = 'validate'	
				--	AND NOT EXISTS(SELECT 1 FROM dbo.Framework_Metafield_Attributes WHERE MetaFieldID=@MetaFieldID AND AttributeKey=T.KeyName)

				UPDATE FMA
					SET VersionNum = @VersionNum
				FROM dbo.Framework_Metafield_Attributes FMA
					 INNER JOIN #TMP TAB ON FMA.MetaFieldID=@MetaFieldID AND FMA.AttributeKey=TAB.KeyName
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

					INSERT INTO dbo.Framework_Metafield_Lookups (MetaFieldID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT @MetaFieldID,@LookupValues,@StepItemName,1,GETDATE(),@UserCreated,@VersionNum
					--WHERE NOT EXISTS(SELECT 1 FROM dbo.Framework_Metafield_Lookups WHERE MetaFieldID=@MetaFieldID AND LookupName=@StepItemName)
						
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
					
						INSERT INTO dbo.Framework_Metafield_Lookups (MetaFieldID,LookupName,LookupValue,LookupType,OrderBy,DateCreated,UserCreated,VersionNum)
							SELECT @MetaFieldID,
								  LookupName,
								  LookupValue,
								  LookupType,	 		  
								  Parent_ID,
								  GETDATE(),@UserCreated,@VersionNum
							FROM #TMP_Lookups T
							WHERE NOT EXISTS(SELECT 1 FROM dbo.Framework_Metafield_Lookups WHERE MetaFieldID=@MetaFieldID AND LookupName=T.LookupName)
				END
				ELSE	
					INSERT INTO dbo.Framework_Metafield_Lookups (MetaFieldID,LookupValue,LookupName,OrderBy,DateCreated,UserCreated,VersionNum)
						SELECT @MetaFieldID,StringValue,KeyName,SequenceNo,GETDATE(),@UserCreated,@VersionNum
						FROM #TMP T
						WHERE Parent_ID <> @ID
							 AND KeyName ='value'
						AND NOT EXISTS(SELECT 1 FROM dbo.Framework_Metafield_Lookups WHERE MetaFieldID=@MetaFieldID AND LookupName=T.KeyName)
		
		END	--END OF OUTERMOSET IF -> IF @StepID IS NOT NULL

		DELETE FROM #TMP_Objects WHERE Element_ID = @ID
		--DELETE FROM @Framework_Metafield
		
		DROP TABLE IF EXISTS #TMP
		DROP TABLE IF EXISTS #TMP_Lookups

 END

		
		SELECT * from dbo.Framework_Metafield_Steps
		SELECT * from dbo.Framework_Metafield
		SELECT * from dbo.Framework_Metafield_Attributes
		SELECT * from dbo.Framework_Metafield_Lookups