 

/****** Object:  StoredProcedure [dbo].[ParseregisterJSON]    Script Date: 06/06/2021 10:59:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************************************
OBJECT NAME:        dbo.ParseregisterJSON
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		NOTES:
					1.WE NEED ONLY Label & Type FOR EACH NODE, THESE ARE THE register PROPERTIES
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
								"StepName": "register Attributes"
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
								"StepName": "register Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						},
						"registerContact": {
							"label": "register Contact",
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
							"key": "registerContact",
							"properties": {
								"StepName": "register Attributes"
							},
							"type": "select",
							"indexeddb": {
								"filter": {}
							},
							"input": true
						}
					}'

					EXEC dbo.ParseregisterJSON @RegisterName ='ABC',@inputJSON = @inputJSON,@UserLoginID = 100,@UserModified=NULL

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ParseRegisterJSON]
@inputJSON VARCHAR(MAX),
@FullSchemaJSON VARCHAR(MAX),
@UserLoginID INT,
@UserModified INT = NULL,
@MethodName NVARCHAR(2000) = NULL,
@LogRequest BIT = 1
AS
BEGIN
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;
	BEGIN TRY
	
	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     

	IF @UserID IS NOT NULL
	BEGIN

	DECLARE @ID INT,			
			@VersionNum INT,
			@RegisterID INT,
			@SQL NVARCHAR(MAX),
			@IsDataTypesCompatible BIT = 1,
			@Params VARCHAR(MAX),
			@ObjectName VARCHAR(100)
			
 DROP TABLE IF EXISTS #TMP_Objects
 DROP TABLE IF EXISTS #TMP_registers
 DROP TABLE IF EXISTS #TMP_NewRegisterProperties
 DROP TABLE IF EXISTS #TMP_registerData
 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
 DROP TABLE IF EXISTS #TMP_RegisterPropertiesXref
 CREATE TABLE #TMP_NewRegisterProperties(RegisterPropertyID INT,RegisterID INT,PropertyName VARCHAR(1000))
	
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
			INTO #TMP_registers
		FROM CTE
		WHERE ValueType NOT IN ('Object','array')
		
		UPDATE TA
		SET DataType = DT.DataType,
			DataTypeLength = DT.DataTypeLength,
			JSONType = TA.StringValue,
			CompatibleTypes = DT.CompatibleTypes
		FROM #TMP_registers TA
			 INNER JOIN @DataTypes DT ON DT.JSONType = TA.StringValue
		WHERE TA.KeyName ='type'
		
		UPDATE TA 
				SET DataType= TA_Type.DataType,
					DataTypeLength= TA_Type.DataTypeLength,
					JSONType = TA_Type.StringValue,
					CompatibleTypes = TA_Type.CompatibleTypes
			FROM #TMP_registers TA
			     INNER JOIN #TMP_registers TA_Type ON TA.Parent_ID = TA_Type.Parent_ID
			WHERE TA.KeyName ='Label'
			      AND TA_Type.KeyName ='Type'

		--SELECT * FROM #TMP_registers
		--RETURN
		--SELECT @VersionNum = VersionNum + 1,
		--	   @RegisterID = RegisterID
		--FROM dbo.Registers 
		--WHERE Name=@RegisterName

		SET @RegisterID = 3

		SELECT @VersionNum = VersionNum + 1			    
		FROM EntityAdminForm
		WHERE EntitytypeId = @RegisterID		

	BEGIN TRAN

		--IF @RegisterID IS NULL
		--BEGIN
		--	SET @VersionNum = 1

		--	INSERT INTO dbo.Registers(Name,UserCreated,VersionNum,FullSchemaJSON)
		--		SELECT @RegisterName, @UserLoginID, @VersionNum,@FullSchemaJSON

		--	SET @RegisterID =SCOPE_IDENTITY()
		--END
		--ELSE
		--BEGIN
		--	 --POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
		--	EXEC dbo.UpdateregisterHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

		--	UPDATE dbo.Registers
		--	SET VersionNum = @VersionNum,
		--		UserModified = @UserModified,
		--		DateModified = GETUTCDATE()
		--	WHERE RegisterID = @RegisterID
	 --  END		
		--SELECT * FROM #TMP_registers
		--RETURN

		  --=================================================================================================================================
			IF @VersionNum > 1 
			BEGIN
				
				--CHECK FOR DATA TYPE COMPATIBILITY-----------------------------------------------------------------------------------------------
				DROP TABLE IF EXISTS #TMP_DataTypeMismatch

				SELECT @RegisterID AS RegisterID, @UserLoginID AS UserCreated, @VersionNum AS VersionNum,TA.StringValue,TA.JSONType AS New_JSONType,
					  TA.DataType AS New_DataType,RP.JsonType AS Old_JSONType,DT.CompatibleTypes AS Old_CompatibleTypes
					 ,CHARINDEX(TA.DataType,DT.CompatibleTypes,1) AS Flag
					INTO #TMP_DataTypeMismatch
				FROM #TMP_registers TA
					INNER JOIN dbo.RegisterProperties RP ON RP.RegisterID = @RegisterID AND RP.PropertyName = TA.StringValue 
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
					FROM dbo.RegisterProperties RP
						 INNER JOIN #TMP_registers TA ON RegisterID = @RegisterID AND PropertyName = TA.StringValue
					WHERE RP.RegisterID = @RegisterID
						  AND RP.JSONType <> TA.JSONType
						  AND KeyName ='Label'

				--POPULATE THE HISTORY TABLES PRIOR TO ANY OPERATION
				EXEC dbo.UpdateregisterHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

				UPDATE dbo.Registers
				SET VersionNum = @VersionNum,
					UserModified = @UserModified,
					DateModified = GETUTCDATE()
				WHERE RegisterID = @RegisterID

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
			--	FROM dbo.RegisterProperties RP
			--		 INNER JOIN #TMP_registers TA ON RegisterID = @RegisterID AND PropertyName = TA.StringValue
			--	WHERE RP.RegisterID = @RegisterID
			--		  AND RP.JSONType <> TA.JSONType
			--		  AND KeyName ='Label'

			--END
			--INSERT NEW PROPERTIES (IF ANY)
			INSERT INTO dbo.RegisterProperties(RegisterID,UserCreated,VersionNum,PropertyName,JSONType)
				OUTPUT INSERTED.RegisterPropertyID, inserted.RegisterID,INSERTED.PropertyName INTO #TMP_NewRegisterProperties(RegisterPropertyID,RegisterID,PropertyName)
			SELECT @RegisterID, @UserLoginID, @VersionNum,StringValue,JSONType
			FROM #TMP_registers TA
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
					INTO #TMP_RegisterPropertiesXref
				FROM #TMP_NewRegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegisterPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
				
				UNION
			*/
				--INSERT MISSING PROPERTIES AS WELL: THIS IS TO HANDLE ANY DELETES IN THE CURRENT VERSION
				SELECT RP.RegisterPropertyID,RP.RegisterID,RP.PropertyName,0 AS IsActive
					INTO #TMP_MissingRegistersProperties
				FROM dbo.RegisterProperties RP 
					  INNER JOIN RegisterPropertiesXref RPX ON RPX.RegisterPropertyID = RP.RegisterPropertyID AND RPX.RegisterID=RP.RegisterID
				WHERE NOT EXISTS(SELECT 1 FROM #TMP_registers WHERE StringValue = RP.PropertyName AND KeyName ='Label')
					  AND RP.RegisterID = @RegisterID
					   AND RPX.IsActive = 1

				--INSERT BACK A PROPERTY WHICH WAS REMOVED EARLIER
				SELECT RP.RegisterPropertyID,RP.RegisterID,RP.PropertyName,1 AS IsActive
					INTO #TMP_ActivateMissingRegistersProperties
				FROM dbo.RegisterProperties RP
					 INNER JOIN RegisterPropertiesXref RPX ON RPX.RegisterPropertyID = RP.RegisterPropertyID AND RPX.RegisterID=RP.RegisterID
				WHERE EXISTS(SELECT 1 FROM #TMP_registers TA WHERE TA.StringValue = RP.PropertyName AND KeyName ='Label')
					 AND RP.RegisterID = @RegisterID
					 AND RPX.IsActive = 0	
			
			INSERT INTO dbo.RegisterPropertiesXref(RegisterPropertyID,RegisterID,UserCreated,VersionNum,PropertyName,IsActive)
				SELECT RegisterPropertyID, RegisterID,@UserLoginID,@VersionNum,PropertyName,1
				FROM #TMP_NewRegisterProperties --#TMP_NewRegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegisterPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
			
			--UPDATE WITH CURRENT VERSION NO.
			UPDATE dbo.RegisterPropertiesXref
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE RegisterID = @RegisterID

			--INACTIVATE THE PROPERTIES WHICH WERE REMOVED
			UPDATE RPX
			SET IsActive = 0,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.RegisterPropertiesXref RPX		
			WHERE RegisterID = @RegisterID
				 AND EXISTS(SELECT 1 FROM #TMP_MissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX.PropertyName AND RegisterPropertyID = RPX.RegisterPropertyID)
			
			--ACTIVATE THE PROPERTIES WHICH WERE ADDED BACK
			UPDATE RPX
			SET IsActive = 1,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			FROM dbo.RegisterPropertiesXref RPX		
			WHERE RegisterID = @RegisterID
				 AND EXISTS(SELECT 1 FROM #TMP_ActivateMissingRegistersProperties WHERE RegisterID=@RegisterID AND PropertyName=RPX.PropertyName AND RegisterPropertyID = RPX.RegisterPropertyID)
				 			
							
			SELECT * INTO #TMP_registerData 
			FROM #TMP_registers
			WHERE KeyName ='Label'
			
			--SELECT * FROM #TMP_registerData
			--RETURN

				DECLARE @DataCols VARCHAR(MAX) 
				 SET @DataCols =STUFF(
							 (SELECT CONCAT(', [',TA.StringValue,'] [', TA.DataType,'] ', TA.DataTypeLength)
							 FROM #TMP_registerData TA								  
							  WHERE NOT EXISTS(SELECT 1 FROM sys.columns C WHERE C.Name = TA.StringValue AND C.object_id =OBJECT_ID('RegisterPropertyXref_Data'))
							 FOR XML PATH('')
							 )
							 ,1,1,'')
				PRINT @DataCols	

				IF @DataCols IS NOT NULL
				BEGIN
					SET @SQL = CONCAT(N' ALTER TABLE dbo.RegisterPropertyXref_Data ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					--CREATE _DATA_HISTORY TABLE
					SET @SQL = CONCAT(N' ALTER TABLE dbo.RegisterPropertyXref_Data_history ADD', CHAR(10), @DataCols, ' NULL ',CHAR(10))
					PRINT @SQL	
					EXEC sp_executesql @SQL	

					
					--CREATE TRIGGER
					DECLARE @cols VARCHAR(MAX) = ''

					SELECT @cols = CONCAT(@cols,N', [',name,'] ')
					FROM sys.dm_exec_describe_first_result_set(N'SELECT * FROM dbo.RegisterPropertyXref_Data' , NULL, 1)
					
					SET @cols = STUFF(@cols, 1, 1, N'');
									 

					IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME ='RegisterPropertyXref_Data_Insert')						
						SET @SQL = N'ALTER TRIGGER '
					ELSE
						SET @SQL = N'CREATE TRIGGER '

					SET @SQL = CONCAT(@SQL,N' dbo.RegisterPropertyXref_Data_Insert
									   ON  dbo.RegisterPropertyXref_Data
									   AFTER INSERT, UPDATE
									AS 
									BEGIN
										SET NOCOUNT ON;

										IF EXISTS(SELECT 1 FROM INSERTED) AND  NOT EXISTS(SELECT 1 FROM DELETED) --INSERT
											INSERT INTO dbo.RegisterPropertyXref_Data_history(<ColumnList>)
												SELECT <columnList>
												FROM INSERTED
										ELSE IF EXISTS(SELECT 1 FROM INSERTED) AND  EXISTS(SELECT 1 FROM DELETED) --UPDATE
											INSERT INTO dbo.RegisterPropertyXref_Data_history(<ColumnList>)
												SELECT <columnList>
												FROM DELETED
									END;',CHAR(10))
					SET @SQL = REPLACE(@SQL,'<columnList>',@cols)
					PRINT @SQL	
					EXEC sp_executesql @SQL	
				END
		 --RETURN
	 		
			--POPULATE THE HISTORY TABLES FOR THE FIRST VERSION OF DATA (AFTER ALL THE DATA HAS BEEN POPULATED IN THE MAIN TABLES)
			IF @VersionNum = 1 OR EXISTS(SELECT 1 FROM #TMP_NewRegisterProperties)
				EXEC dbo.UpdateregisterHistoryTables @RegisterID = @RegisterID,@VersionNum = @VersionNum

			--UPDATE OPERATION TYPE IN HISTORY TABLE-------
			IF @VersionNum > 1
			BEGIN

			--UPDATE RPX_Hist
			--	SET OperationType = 'DELETE'				 
			--FROM dbo.RegisterPropertiesXref_history RPX_Hist
			--	 INNER JOIN dbo.RegisterPropertiesXref RPX ON RPX.RegisterID=RPX_Hist.RegisterID AND RPX.RegisterPropertyID=RPX_Hist.RegisterPropertyID
			--WHERE RPX_Hist.VersionNum = @VersionNum
			--	  AND Rpx.IsActive = 0
				 
			UPDATE RPX_Hist
				SET OperationType = 'DELETE'				 
			FROM dbo.RegisterPropertiesXref_history RPX_Hist				 
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
			FROM dbo.RegisterPropertiesXref_history RPX_Hist				 
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
				  
		 	UPDATE RP_Hist
				SET OperationType = 'UPDATE'				 
			FROM dbo.RegisterProperties_history RP_Hist				 
			WHERE RP_Hist.VersionNum = @VersionNum		
				  AND RP_Hist.RegisterID = @RegisterID
				  AND EXISTS(SELECT 1 FROM RegisterProperties_history WHERE RegisterID=@RegisterID AND PropertyName=RP_Hist.PropertyName AND RegisterPropertyID = RP_Hist.RegisterPropertyID
								AND VersionNum = RP_Hist.VersionNum - 1
								AND JSONType <> RP_Hist.JSONType
							)
	
			END
			------------------------------------------------		

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN
			 
			SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=1')
			SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39))

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			--PRINT @PARAMS
			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		UPDATE dbo.EntityAdminForm
			SET VersionNum = @VersionNum,
			DateModified = GETUTCDATE(),
			FormJson = @FullSchemaJSON
		WHERE EntitytypeId = @RegisterID

		 COMMIT
		 
		 SELECT NULL AS ErrorMessage
	
	END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage

	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
			SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=1')
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
		 DROP TABLE IF EXISTS #TMP_registers
		 DROP TABLE IF EXISTS #TMP_NewRegisterProperties
		 DROP TABLE IF EXISTS #TMP_registerData
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
		 DROP TABLE IF EXISTS #TMP_RegisterPropertiesXref
		 DROP TABLE IF EXISTS #TMP_RegistersProperties
		 --------------------------------------------------------

END
GO


