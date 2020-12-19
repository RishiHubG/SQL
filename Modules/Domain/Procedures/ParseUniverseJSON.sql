USE junk
GO
 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseUniverseJSON
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		NOTES:
					1.WE NEED ONLY Label & Type FOR EACH NODE, THESE ARE THE ASSESSMENT PROPERTIES
				    2. PROPERTIES CAN ONLY BE INSERTED/DELETED (NO UPDATES); FOR MARKING OPERATION TYPE=DELETE: WHEN A PROPERTY IS REMOVED THE PROPERTY IS NOT DELETED FROM THE TABLE BUT MARKED AS INACTIVE
					   COLUMN FROM _DATA TABLE IS ALSO NOT REMOVED	
USAGE:             
					DECLARE @inputJSON VARCHAR(MAX) ='{
     
						"name": {
							"label": "Name",
							"tableView": true,
							"validate": {
								"required": true,
								"minLength": 3,
								"maxLength": 500
							},
							"key": "name",
							"properties": {
								"StepName": "General"
							},
							"type": "textfield",
							"input": true
						},
						"description": {
							"label": "Description",
							"autoExpand": false,
							"tableView": true,
							"key": "description",
							"properties": {
								"StepName": "General"
							},
							"type": "textarea",
							"input": true
						},
						"currency": {
							"label": "Currency",
							"widget": "choicesjs",
							"tableView": true,
							"data": {
								"values": [
									{
										"label": "USD",
										"value": "USD"
									},
									{
										"label": "INR",
										"value": "INR"
									},
									{
										"label": "ZAR",
										"value": "ZAR"
									},
									{
										"label": "GBP",
										"value": "GBP"
									}
								]
							},
							"selectThreshold": 0.3,
							"key": "currency",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						},
						"levelOfOperation": {
							"label": "Level of Operation",
							"widget": "choicesjs",
							"tableView": true,
							"data": {
								"values": [
									{
										"label": "Busienss Unit",
										"value": "Busienss Unit"
									},
									{
										"label": "Area",
										"value": "Area"
									},
									{
										"label": "Region",
										"value": "Region"
									},
									{
										"label": "Country",
										"value": "Country"
									},
									{
										"label": "Global",
										"value": "Global"
									}
								]
							},
							"selectThreshold": 0.3,
							"key": "levelOfOperation",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						},
						"assessmentContact": {
							"label": "Assessment Contact",
							"widget": "choicesjs",
							"tableView": true,
							"dataSrc": "custom",
							"data": {
								"values": [
									{
										"label": "",
										"value": ""
									}
								]
							},
							"dataType": "auto",
							"selectThreshold": 0.3,
							"key": "assessmentContact",
							"properties": {
								"StepName": "Assessment Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						}
					}'

					EXEC dbo.ParseUniverseJSON @UniverseName ='ABC',@inputJSON = @inputJSON,@UserCreated = 100,@UserModified=NULL

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.ParseUniverseJSON
@UniverseName VARCHAR(500),
@inputJSON VARCHAR(MAX) = NULL,
@UserCreated INT,
@UserModified INT = NULL
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
	BEGIN TRAN

	DECLARE @ID INT,			
			@VersionNum INT,
			@UniverseID INT,
			@SQL NVARCHAR(MAX),
			@IsDataTypesCompatible BIT = 1
			
 DROP TABLE IF EXISTS #TMP_Objects
 DROP TABLE IF EXISTS #TMP_Assessments
 DROP TABLE IF EXISTS #TMP_NewUniverseProperties
 DROP TABLE IF EXISTS #TMP_AssessmentData
 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
 DROP TABLE IF EXISTS #TMP_UniversePropertiesXref
 CREATE TABLE #TMP_NewUniverseProperties(UniversePropertyID INT,UniverseID INT,PropertyName VARCHAR(1000))
	
	--LIST OF COMPATIBLE DATA TYPES==============================================================
		DECLARE @DataTypes TABLE
		 (
		 JSONType VARCHAR(50),
		 DataType VARCHAR(50),
		 DataTypeLength VARCHAR(50),
		 CompatibleTypes VARCHAR(500)
		 )

		 INSERT INTO @DataTypes (JSONType,DataType,DataTypeLength,CompatibleTypes)
			SELECT 'textfield','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'selectboxes','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'select','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'textarea','NVARCHAR','(MAX)','NVARCHAR' UNION ALL
			SELECT 'number','INT',NULL,'INT,FLOAT,DECIMAL,BIGINT,NVARCHAR' UNION ALL
			SELECT 'datetime','DATETIME',NULL,'DATETIME,DATE' UNION ALL
			SELECT 'date','DATE',NULL,'DATE,DATETIME,'

			--SELECT * FROM @DataTypes
	--===========================================================================================

 SELECT *
		INTO #TMP_ALLSTEPS
 FROM dbo.HierarchyFromJSON(@inputJSON)

  SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType 
	INTO #TMP_Objects
 FROM #TMP_ALLSTEPS
 WHERE ValueType='Object'
	   AND Parent_ID = 0 --ONLY ROOT ELEMENTS	
	   --AND StringValue <> ''
	  
	  -- SELECT * FROM #TMP_Objects

	    --GET ALL THE CHILD ELEMENTS FOR A PARENT
		;WITH CTE
		AS
		(	--PARENT
			SELECT CAST('' AS VARCHAR(50)) ParentName, Element_ID,Parent_ID,SequenceNo,[Name] AS KeyName,StringValue,ValueType,CAST('Object' AS VARCHAR(50)) AS ElementType
			FROM #TMP_Objects
			--WHERE Element_ID = 2
			      

			UNION ALL

			--CHILD ITEMS
			SELECT CAST(C.KeyName as varchar(50)),TMP.Element_ID,TMP.Parent_ID,TMP.SequenceNo,TMP.[Name],TMP.StringValue,TMP.ValueType,CAST('ObjectItems' AS VARCHAR(50)) AS ElementType
			FROM CTE C 
				 INNER JOIN #TMP_ALLSTEPS TMP ON TMP.Parent_ID = C.Element_ID			
			WHERE TMP.Name IN ('label','type')
		)

		SELECT *, 
			  CAST(NULL AS VARCHAR(100)) AS DataType,
			  CAST(NULL AS VARCHAR(100)) AS DataTypeLength,
			  CAST(NULL AS VARCHAR(100)) AS JSONType,
			  CAST(NULL AS VARCHAR(100)) AS CompatibleTypes
			INTO #TMP_Assessments
		FROM CTE
		WHERE ValueType NOT IN ('Object','array')
		
		UPDATE TA
		SET DataType = DT.DataType,
			DataTypeLength = DT.DataTypeLength,
			JSONType = TA.StringValue,
			CompatibleTypes = DT.CompatibleTypes
		FROM #TMP_Assessments TA
			 INNER JOIN @DataTypes DT ON DT.JSONType = TA.StringValue
		WHERE TA.KeyName ='type'
		
		UPDATE TA 
				SET DataType= TA_Type.DataType,
					DataTypeLength= TA_Type.DataTypeLength,
					JSONType = TA_Type.StringValue,
					CompatibleTypes = TA_Type.CompatibleTypes
			FROM #TMP_Assessments TA
			     INNER JOIN #TMP_Assessments TA_Type ON TA.Parent_ID = TA_Type.Parent_ID
			WHERE TA.KeyName ='Label'
			      AND TA_Type.KeyName ='Type'

		--SELECT * FROM #TMP_Assessments
		--RETURN
		SELECT @VersionNum = VersionNum + 1,
			   @UniverseID = UniverseID
		FROM dbo.Universe 
		WHERE Name=@UniverseName
				 
		IF @UniverseID IS NULL
		BEGIN
			SET @VersionNum = 1

			INSERT INTO dbo.Universe(Name,UserCreated,VersionNum)
				SELECT @UniverseName, @UserCreated, @VersionNum

			SET @UniverseID =SCOPE_IDENTITY()
		END
		--ELSE
		--BEGIN
		--	 --POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
		--	EXEC dbo.UpdateUniverseHistoryTables @UniverseID = @UniverseID,@VersionNum = @VersionNum

		--	UPDATE dbo.Universe
		--	SET VersionNum = @VersionNum,
		--		UserModified = @UserModified,
		--		DateModified = GETUTCDATE()
		--	WHERE UniverseID = @UniverseID
	 --  END		
		--SELECT * FROM #TMP_Assessments
		--RETURN

		  --=================================================================================================================================
			IF @VersionNum > 1 
			BEGIN
				
				--CHECK FOR DATA TYPE COMPATIBILITY-----------------------------------------------------------------------------------------------
				DROP TABLE IF EXISTS #TMP_DataTypeMismatch

				SELECT @UniverseID AS UniverseID, @UserCreated AS UserCreated, @VersionNum AS VersionNum,TA.StringValue,TA.JSONType AS New_JSONType,
					  TA.DataType AS New_DataType,RP.JsonType AS Old_JSONType,DT.CompatibleTypes AS Old_CompatibleTypes
					 ,CHARINDEX(TA.DataType,DT.CompatibleTypes,1) AS Flag
					INTO #TMP_DataTypeMismatch
				FROM #TMP_Assessments TA
					INNER JOIN dbo.UniverseProperties RP ON RP.UniverseID = @UniverseID AND RP.PropertyName = TA.StringValue 
					INNER JOIN @DataTypes DT ON DT.JSONType = RP.JSONType
				WHERE TA.KeyName ='Label'
					  AND RP.VersionNum = @VersionNum - 1
					  AND CHARINDEX(TA.DataType,DT.CompatibleTypes,1) = 0
								  				
				IF EXISTS(SELECT 1
							FROM #TMP_DataTypeMismatch
						  )						
				BEGIN
					SELECT * FROM #TMP_DataTypeMismatch;
					THROW 50005, N'Data Type Compatibility Mismatch!!', 16;					
					ROLLBACK
					RETURN
				END
				-------------------------------------------------------------------------------------------------------------------------------------
					
					--IF "Type" FOR A PROPERTY HAS CHANGED
					UPDATE RP
					SET JsonType = TA.JsonType,
						VersionNum = @VersionNum,
						UserModified = @UserModified,
						DateModified = GETUTCDATE()
					FROM dbo.UniverseProperties RP
						 INNER JOIN #TMP_Assessments TA ON UniverseID = @UniverseID AND PropertyName = TA.StringValue
					WHERE RP.UniverseID = @UniverseID
						  AND RP.JSONType <> TA.JSONType
						  AND KeyName ='Label'

				--POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
				EXEC dbo.UpdateUniverseHistoryTables @UniverseID = @UniverseID,@VersionNum = @VersionNum

				UPDATE dbo.Universe
				SET VersionNum = @VersionNum,
					UserModified = @UserModified,
					DateModified = GETUTCDATE()
				WHERE UniverseID = @UniverseID

			END
		--==========================================================================================================================================================
			
			--IF "Type" FOR A PROPERTY HAS CHANGED
			--IF @VersionNum > 1
			--BEGIN

			--	UPDATE RP
			--	SET JsonType = TA.JsonType,
			--		VersionNum = @VersionNum,
			--		UserModified = @UserModified,
			--		DateModified = GETUTCDATE()
			--	FROM dbo.UniverseProperties RP
			--		 INNER JOIN #TMP_Assessments TA ON UniverseID = @UniverseID AND PropertyName = TA.StringValue
			--	WHERE RP.UniverseID = @UniverseID
			--		  AND RP.JSONType <> TA.JSONType
			--		  AND KeyName ='Label'

			--END
			--INSERT NEW PROPERTIES (IF ANY)
			INSERT INTO dbo.UniverseProperties(UniverseID,UserCreated,VersionNum,PropertyName,JSONType)
				OUTPUT INSERTED.UniversePropertyID, inserted.UniverseID,INSERTED.PropertyName INTO #TMP_NewUniverseProperties(UniversePropertyID,UniverseID,PropertyName)
			SELECT @UniverseID, @UserCreated, @VersionNum,StringValue,JSONType
			FROM #TMP_Assessments TA
			WHERE NOT EXISTS(SELECT 1 FROM dbo.UniverseProperties WHERE UniverseID = @UniverseID AND PropertyName = TA.StringValue)-- AND VersionNum = @VersionNum) 
			      AND KeyName ='Label'
			
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.UniverseProperties
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE UniverseID = @UniverseID

			/*
				SELECT UniversePropertyID,UniverseID,PropertyName,1 AS IsActive
					INTO #TMP_UniversePropertiesXref
				FROM #TMP_NewUniverseProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.UniversePropertiesXref WHERE UniversePropertyID= TR.UniversePropertyID AND UniverseID = @UniverseID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
				
				UNION
			*/
				--INSERT MISSING PROPERTIES AS WELL: THIS IS TO HANDLE ANY DELETES IN THE CURRENT VERSION
				SELECT RP.UniversePropertyID,RP.UniverseID,RP.PropertyName,0 AS IsActive
					INTO #TMP_MissingUniverseProperties
				FROM dbo.UniverseProperties RP 
					  INNER JOIN UniversePropertiesXref RPX ON RPX.UniversePropertyID = RP.UniversePropertyID AND RPX.UniverseID=RP.UniverseID
				WHERE NOT EXISTS(SELECT 1 FROM #TMP_Assessments WHERE StringValue = RP.PropertyName AND KeyName ='Label')
					  AND RP.UniverseID = @UniverseID
					   AND RPX.IsActive = 1

				--INSERT BACK A PROPERTY WHICH WAS REMOVED EARLIER
				SELECT RP.UniversePropertyID,RP.UniverseID,RP.PropertyName,1 AS IsActive
					INTO #TMP_ActivateMissingUniverseProperties
				FROM dbo.UniverseProperties RP
					 INNER JOIN UniversePropertiesXref RPX ON RPX.UniversePropertyID = RP.UniversePropertyID AND RPX.UniverseID=RP.UniverseID
				WHERE EXISTS(SELECT 1 FROM #TMP_Assessments TA WHERE TA.StringValue = RP.PropertyName AND KeyName ='Label')
					 AND RP.UniverseID = @UniverseID
					 AND RPX.IsActive = 0	
			
			INSERT INTO dbo.UniversePropertiesXref(UniversePropertyID,UniverseID,UserCreated,VersionNum,PropertyName,IsActive)
				SELECT UniversePropertyID, UniverseID,@UserCreated,@VersionNum,PropertyName,1
				FROM #TMP_NewUniverseProperties --#TMP_NewUniverseProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.UniversePropertiesXref WHERE UniversePropertyID= TR.UniversePropertyID AND UniverseID = @UniverseID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.UniversePropertiesXref
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE UniverseID = @UniverseID

			--INACTIVATE THE PROPERTIES WHICH WERE REMOVED
			UPDATE RPX
			SET IsActive = 0,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.UniversePropertiesXref RPX		
			WHERE UniverseID = @UniverseID
				 AND EXISTS(SELECT 1 FROM #TMP_MissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX.PropertyName AND UniversePropertyID = RPX.UniversePropertyID)
			
			--ACTIVATE THE PROPERTIES WHICH WERE ADDED BACK
			UPDATE RPX
			SET IsActive = 1,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.UniversePropertiesXref RPX		
			WHERE UniverseID = @UniverseID
				 AND EXISTS(SELECT 1 FROM #TMP_ActivateMissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX.PropertyName AND UniversePropertyID = RPX.UniversePropertyID)
				 			
							
			SELECT * INTO #TMP_AssessmentData 
			FROM #TMP_Assessments
			WHERE KeyName ='Label'
			
			--SELECT * FROM #TMP_AssessmentData
			--RETURN

				DECLARE @DataCols VARCHAR(MAX) 
				 SET @DataCols =STUFF(
							 (SELECT CONCAT(', [',TA.StringValue,'] [', TA.DataType,'] ', TA.DataTypeLength)
							 FROM #TMP_AssessmentData TA								  
							  WHERE NOT EXISTS(SELECT 1 FROM sys.columns C WHERE C.Name = TA.StringValue AND C.object_id =OBJECT_ID('UniversePropertyXerf_Data'))
							 FOR XML PATH('')
							 )
							 ,1,1,'')
				PRINT @DataCols	

				IF @DataCols IS NOT NULL
				BEGIN
					SET @SQL = CONCAT(N' ALTER TABLE dbo.UniversePropertyXerf_Data ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					--CREATE _DATA_HISTORY TABLE
					SET @SQL = CONCAT(N' ALTER TABLE dbo.UniversePropertyXerf_Data_history ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					
					--CREATE TRIGGER
					DECLARE @cols VARCHAR(MAX) = ''

					SELECT @cols = CONCAT(@cols,N', [',name,'] ')
					FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.UniversePropertyXerf_Data' , NULL, 1)
					
					SET @cols = STUFF(@cols, 1, 1, N'');
									 

					IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME ='UniversePropertyXerf_Data_Insert')						
						SET @SQL = N'ALTER TRIGGER '
					ELSE
						SET @SQL = N'CREATE TRIGGER '

					SET @SQL = CONCAT(@SQL,N' dbo.UniversePropertyXerf_Data_Insert
									   ON  dbo.UniversePropertyXerf_Data
									   AFTER INSERT
									AS 
									BEGIN
										SET NOCOUNT ON;

										INSERT INTO dbo.UniversePropertyXerf_Data_history(<ColumnList>)
											SELECT <columnList>
											FROM INSERTED
									END;',CHAR(10))
					SET @SQL = REPLACE(@SQL,'<columnList>',@cols)
					PRINT @SQL	
					EXEC sp_executesql @SQL	
				END
		 --RETURN
	 		
			--POPULATE THE HISTORY TABLES FOR THE FIRST VERSION OF DATA (AFTER ALL THE DATA HAS BEEN POPULATED IN THE MAIN TABLES)
			IF @VersionNum = 1 OR EXISTS(SELECT 1 FROM #TMP_NewUniverseProperties)
				EXEC dbo.UpdateUniverseHistoryTables @UniverseID = @UniverseID,@VersionNum = @VersionNum

			--UPDATE OPERATION TYPE IN HISTORY TABLE-------
			IF @VersionNum > 1
			BEGIN

			--UPDATE RPX_Hist
			--	SET OperationType = 'DELETE'				 
			--FROM dbo.UniversePropertiesXref_history RPX_Hist
			--	 INNER JOIN dbo.UniversePropertiesXref RPX ON RPX.UniverseID=RPX_Hist.UniverseID AND RPX.UniversePropertyID=RPX_Hist.UniversePropertyID
			--WHERE RPX_Hist.VersionNum = @VersionNum
			--	  AND Rpx.IsActive = 0
				 
			UPDATE RPX_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.UniversePropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				  AND RPX_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX_Hist.PropertyName AND UniversePropertyID = RPX_Hist.UniversePropertyID)
			
			UPDATE RP_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.UniverseProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RP_Hist.PropertyName AND UniversePropertyID = RP_Hist.UniversePropertyID)


			UPDATE RPX_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.UniversePropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				  AND RPX_Hist.UniverseID = @UniverseID
				  AND (EXISTS(SELECT 1 FROM #TMP_ActivateMissingUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RPX_Hist.PropertyName AND UniversePropertyID = RPX_Hist.UniversePropertyID)
					   OR EXISTS(SELECT 1 FROM #TMP_NewUniverseProperties  WHERE UniverseID=@UniverseID AND PropertyName=RPX_Hist.PropertyName AND UniversePropertyID = RPX_Hist.UniversePropertyID)
					  )
			
			UPDATE RP_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.UniverseProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM #TMP_NewUniverseProperties WHERE UniverseID=@UniverseID AND PropertyName=RP_Hist.PropertyName AND UniversePropertyID = RP_Hist.UniversePropertyID)
				  
		 	UPDATE RP_Hist
				SET OperationType = 'UPDATE'				 
			FROM dbo.UniverseProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.UniverseID = @UniverseID
				  AND EXISTS(SELECT 1 FROM UniverseProperties_history WHERE UniverseID=@UniverseID AND PropertyName=RP_Hist.PropertyName AND UniversePropertyID = RP_Hist.UniversePropertyID
								AND VersionNum = RP_Hist.VersionNum - 1
								AND JSONType <> RP_Hist.JSONType
							)
	
			END
			------------------------------------------------
		
		 COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK
	END CATCH	
	
		--DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_Assessments
		 DROP TABLE IF EXISTS #TMP_NewUniverseProperties
		 DROP TABLE IF EXISTS #TMP_AssessmentData
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
		 DROP TABLE IF EXISTS #TMP_UniversePropertiesXref
		 DROP TABLE IF EXISTS #TMP_UniverseProperties
		 --------------------------------------------------------

		 --INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		DECLARE @Params VARCHAR(MAX)
		SET @Params = CONCAT('@UniverseName=', CHAR(39),@UniverseName, CHAR(39),',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserCreated=',@UserCreated)
		--PRINT @PARAMS
		EXEC dbo.InsertObjectLog @@PROCID,@Params,@UserCreated
		------------------------------------------------------------------------------------------------------------------------------------------
END