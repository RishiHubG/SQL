USE junk
GO
 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseAssessmentJSON
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

					EXEC dbo.ParseAssessmentJSON @RegisterName ='ABC',@inputJSON = @inputJSON

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.ParseAssessmentJSON
@RegisterName VARCHAR(500),
@inputJSON VARCHAR(MAX) = NULL,
@UserCreated INT = 100,
@UserModified INT = 200
AS
BEGIN
	SET NOCOUNT ON; 
	BEGIN TRY
	BEGIN TRAN

	DECLARE @ID INT,			
			@VersionNum INT,
			@RegisterID INT,
			@SQL NVARCHAR(MAX)
			
 DROP TABLE IF EXISTS #TMP_Objects
 DROP TABLE IF EXISTS #TMP_Assessments
 DROP TABLE IF EXISTS #TMP_NewRegisterProperties
 DROP TABLE IF EXISTS #TMP_AssessmentData
 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
 DROP TABLE IF EXISTS #TMP_RegistersPropertiesXref
 CREATE TABLE #TMP_NewRegisterProperties(RegisterPropertyID INT,RegisterID INT,PropertyName VARCHAR(1000))
 
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
			  CAST(NULL AS VARCHAR(100)) AS DataTypeLength
			INTO #TMP_Assessments
		FROM CTE
		WHERE ValueType NOT IN ('Object','array')
		
		UPDATE #TMP_Assessments
		SET DataType = CASE WHEN StringValue IN ('textfield','selectboxes','select','textarea') THEN 'NVARCHAR' 
							WHEN StringValue = 'number' THEN 'INT'
							WHEN StringValue = 'datetime' THEN 'DATETIME' 
						END
		WHERE KeyName ='type'

		UPDATE #TMP_Assessments
		SET DataTypeLength = CASE WHEN DataType = 'NVARCHAR' THEN '(MAX)'
							 END
		WHERE KeyName ='type'
		
		--SELECT * FROM #TMP_Assessments
		--RETURN
		SELECT @VersionNum = VersionNum + 1,
			   @RegisterID = RegisterID
		FROM dbo.Registers 
		WHERE Name=@RegisterName
				 
		IF @RegisterID IS NULL
		BEGIN
			SET @VersionNum = 1

			INSERT INTO dbo.Registers(Name,UserCreated,VersionNum)
				SELECT @RegisterName, @UserCreated, @VersionNum

			SET @RegisterID =SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			 --POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
			EXEC dbo.UpdateAssessmentHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

			UPDATE dbo.Registers
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE RegisterID = @RegisterID
	   END		
		--SELECT * FROM #TMP_Assessments
			INSERT INTO dbo.RegisterProperties(RegisterID,UserCreated,VersionNum,PropertyName)
				OUTPUT INSERTED.RegisterPropertyID, inserted.RegisterID,INSERTED.PropertyName INTO #TMP_NewRegisterProperties(RegisterPropertyID,RegisterID,PropertyName)
			SELECT @RegisterID, @UserCreated, @VersionNum,StringValue
			FROM #TMP_Assessments TA
			WHERE NOT EXISTS(SELECT 1 FROM dbo.RegisterProperties WHERE RegisterID = @RegisterID AND PropertyName = TA.StringValue)-- AND VersionNum = @VersionNum) 
			      AND KeyName ='Label'
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.RegisterProperties
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE RegisterID = @RegisterID

			/*
				SELECT RegisterPropertyID,RegisterID,PropertyName,1 AS IsActive
					INTO #TMP_RegistersPropertiesXref
				FROM #TMP_NewRegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegistersPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
				
				UNION
			*/
				--INSERT MISSING PROPERTIES AS WELL: THIS IS TO HANDLE ANY DELETES IN THE CURRENT VERSION
				SELECT RP.RegisterPropertyID,RP.RegisterID,RP.PropertyName,0 AS IsActive
					INTO #TMP_MissingRegistersProperties
				FROM dbo.RegisterProperties RP 
				WHERE NOT EXISTS(SELECT 1 FROM #TMP_Assessments WHERE StringValue = RP.PropertyName AND KeyName ='Label')
					  AND RP.RegisterID = @RegisterID

				--INSERT BACK A PROPERTY WHICH WAS REMOVED EARLIER
				SELECT RP.RegisterPropertyID,RP.RegisterID,RP.PropertyName,1 AS IsActive
					INTO #TMP_ActivateMissingRegistersProperties
				FROM dbo.RegisterProperties RP
					 INNER JOIN RegistersPropertiesXref RPX ON RPX.RegisterPropertyID = RP.RegisterPropertyID AND RPX.RegisterID=RP.RegisterID
				WHERE EXISTS(SELECT 1 FROM #TMP_Assessments TA WHERE TA.StringValue = RP.PropertyName AND KeyName ='Label')
					 AND RP.RegisterID = @RegisterID
					 AND RPX.IsActive = 0	
			
			INSERT INTO dbo.RegistersPropertiesXref(RegisterPropertyID,RegisterID,UserCreated,VersionNum,PropertyName,IsActive)
				SELECT RegisterPropertyID, RegisterID,@UserCreated,@VersionNum,PropertyName,1
				FROM #TMP_NewRegisterProperties --#TMP_NewRegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegistersPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.RegistersPropertiesXref
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE RegisterID = @RegisterID

			--INACTIVATE THE PROPERTIES WHICH WERE REMOVED
			UPDATE RPX
			SET IsActive = 0,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.RegistersPropertiesXref RPX		
			WHERE RegisterID = @RegisterID
				 AND EXISTS(SELECT 1 FROM #TMP_MissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX.PropertyName AND RegisterPropertyID = RPX.RegisterPropertyID)
			
			--ACTIVATE THE PROPERTIES WHICH WERE ADDED BACK
			UPDATE RPX
			SET IsActive = 1,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.RegistersPropertiesXref RPX		
			WHERE RegisterID = @RegisterID
				 AND EXISTS(SELECT 1 FROM #TMP_ActivateMissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX.PropertyName AND RegisterPropertyID = RPX.RegisterPropertyID)
				 			
			UPDATE TA 
				SET DataType= TA_Type.DataType,
					DataTypeLength= TA_Type.DataTypeLength
			FROM #TMP_Assessments TA
			     INNER JOIN #TMP_Assessments TA_Type ON TA.Parent_ID = TA_Type.Parent_ID
			WHERE TA.KeyName ='Label'
			      AND TA_Type.KeyName ='Type'
				
			SELECT * INTO #TMP_AssessmentData 
			FROM #TMP_Assessments
			WHERE KeyName ='Label'
			
			--SELECT * FROM #TMP_AssessmentData
			--RETURN

				DECLARE @DataCols VARCHAR(MAX) 
				 SET @DataCols =STUFF(
							 (SELECT CONCAT(', [',TA.StringValue,'] [', TA.DataType,'] ', TA.DataTypeLength)
							 FROM #TMP_AssessmentData TA								  
							  WHERE NOT EXISTS(SELECT 1 FROM sys.columns C WHERE C.Name = TA.StringValue AND C.object_id =OBJECT_ID('RegisterPropertyXerf_Data'))
							 FOR XML PATH('')
							 )
							 ,1,1,'')
				PRINT @DataCols	

				IF @DataCols IS NOT NULL
				BEGIN
					SET @SQL = CONCAT(N' ALTER TABLE dbo.RegisterPropertyXerf_Data ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					--CREATE _DATA_HISTORY TABLE
					SET @SQL = CONCAT(N' ALTER TABLE dbo.RegisterPropertyXerf_Data_history ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					
					--CREATE TRIGGER
					DECLARE @cols VARCHAR(MAX) = ''

					SELECT @cols = CONCAT(@cols,N', [',name,'] ')
					FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.RegisterPropertyXerf_Data' , NULL, 1)
					
					SET @cols = STUFF(@cols, 1, 1, N'');
									 

					IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME ='RegisterPropertyXerf_Data_Insert')						
						SET @SQL = N'ALTER TRIGGER '
					ELSE
						SET @SQL = N'CREATE TRIGGER '

					SET @SQL = CONCAT(@SQL,N' dbo.RegisterPropertyXerf_Data_Insert
									   ON  dbo.RegisterPropertyXerf_Data
									   AFTER INSERT
									AS 
									BEGIN
										SET NOCOUNT ON;

										INSERT INTO dbo.RegisterPropertyXerf_Data_history(<ColumnList>)
											SELECT <columnList>
											FROM INSERTED
									END;',CHAR(10))
					SET @SQL = REPLACE(@SQL,'<columnList>',@cols)
					PRINT @SQL	
					EXEC sp_executesql @SQL	
				END
		 --RETURN
	 		
			--POPULATE THE HISTORY TABLES FOR THE FIRST VERSION OF DATA (AFTER ALL THE DATA HAS BEEN POPULATED IN THE MAIN TABLES)
			IF @VersionNum = 1 OR EXISTS(SELECT 1 FROM #TMP_NewRegisterProperties)
				EXEC dbo.UpdateAssessmentHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

			--UPDATE OPERATION TYPE IN HISTORY TABLE-------
			IF @VersionNum > 1
			BEGIN

			--UPDATE RPX_Hist
			--	SET OperationType = 'DELETE'				 
			--FROM dbo.RegistersPropertiesXref_history RPX_Hist
			--	 INNER JOIN dbo.RegistersPropertiesXref RPX ON RPX.RegisterID=RPX_Hist.RegisterID AND RPX.RegisterPropertyID=RPX_Hist.RegisterPropertyID
			--WHERE RPX_Hist.VersionNum = @VersionNum
			--	  AND Rpx.IsActive = 0
				 
			UPDATE RPX_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.RegistersPropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				AND RPX_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX_Hist.PropertyName AND RegisterPropertyID = RPX_Hist.RegisterPropertyID)
			
			UPDATE RP_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.RegisterProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				AND RP_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM #TMP_MissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RP_Hist.PropertyName AND RegisterPropertyID = RP_Hist.RegisterPropertyID)


			UPDATE RPX_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.RegistersPropertiesXref_history RPX_Hist				 
			WHERE RPX_Hist.VersionNum = @VersionNum		
				AND RPX_Hist.RegisterID = @RegisterID
				  AND (EXISTS(SELECT 1 FROM #TMP_ActivateMissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX_Hist.PropertyName AND RegisterPropertyID = RPX_Hist.RegisterPropertyID)
					   OR EXISTS(SELECT 1 FROM #TMP_NewRegisterProperties  WHERE RegisterID=@RegisterID AND PropertyName=RPX_Hist.PropertyName AND RegisterPropertyID = RPX_Hist.RegisterPropertyID)
					  )
			
			UPDATE RP_Hist
				SET OperationType = 'INSERT'				 
			FROM dbo.RegisterProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				AND RP_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM #TMP_NewRegisterProperties WHERE RegisterID=@RegisterID AND PropertyName=RP_Hist.PropertyName AND RegisterPropertyID = RP_Hist.RegisterPropertyID)
				  
		 	
			END
			------------------------------------------------
		
		 COMMIT
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		IF @@TRANCOUNT > 1 AND XACT_STATE() <> 0
			ROLLBACK
	END CATCH	
	
		--DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_Assessments
		 DROP TABLE IF EXISTS #TMP_NewRegisterProperties
		 DROP TABLE IF EXISTS #TMP_AssessmentData
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
		 DROP TABLE IF EXISTS #TMP_RegistersPropertiesXref
		 DROP TABLE IF EXISTS #TMP_RegistersProperties
		 --------------------------------------------------------

END