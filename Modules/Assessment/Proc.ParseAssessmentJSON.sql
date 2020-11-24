USE junk
GO
/*
Steps: ASSUMPTION -> STEPS VERSIONING CAN ONLNY BE LIMITED TO INSERT OR DELETE (i.e. A STEP(A TAB) CAN BE ADDED OR REMOVED ONLY)
*/
CREATE OR ALTER PROCEDURE dbo.ParseAssessmentJSON
@RegisterName VARCHAR(500),
@inputJSON VARCHAR(MAX) = NULL,
@UserCreated INT = 100,
@UserModified INT = 200
AS
BEGIN
	SET NOCOUNT ON; 

	DECLARE @ID INT,			
			@VersionNum INT,
			@RegisterID INT,
			@SQL NVARCHAR(MAX)
			
 DROP TABLE IF EXISTS #TMP_Objects
 DROP TABLE IF EXISTS #TMP_Assessments
 DROP TABLE IF EXISTS #TMP_RegisterProperties
 DROP TABLE IF EXISTS #TMP_AssessmentData
 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
 DROP TABLE IF EXISTS #TMP_RegistersPropertiesXref
 CREATE TABLE #TMP_RegisterProperties(RegisterPropertyID INT,RegisterID INT,PropertyName VARCHAR(1000))
 
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
			UPDATE dbo.Registers
			SET VersionNum = @VersionNum,
				UserModified = @UserModified,
				DateModified = GETUTCDATE()
			WHERE RegisterID = @RegisterID
		
			INSERT INTO dbo.RegisterProperties(RegisterID,UserCreated,VersionNum,PropertyName)
				OUTPUT INSERTED.RegisterPropertyID, inserted.RegisterID,INSERTED.PropertyName INTO #TMP_RegisterProperties(RegisterPropertyID,RegisterID,PropertyName)
			SELECT @RegisterID, @UserCreated, @VersionNum,StringValue
			FROM #TMP_Assessments TA
			WHERE NOT EXISTS(SELECT 1 FROM dbo.RegisterProperties WHERE RegisterID = @RegisterID AND PropertyName = TA.KeyName AND VersionNum = @VersionNum) 
			      AND KeyName ='Label'
								
				SELECT RegisterPropertyID,RegisterID,PropertyName,1 AS IsActive
					INTO #TMP_RegistersPropertiesXref
				FROM #TMP_RegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegistersPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
				
				UNION

				--INSERT MISSING PROPERTIES AS WELL: THIS IS TO HANDLE ANY DELETES IN THE CURRENT VERSION
				SELECT RP.RegisterPropertyID,RPX.RegisterID,RPX.PropertyName,0 AS IsActive
				FROM dbo.RegistersPropertiesXref RPX
					 INNER JOIN dbo.RegisterProperties RP ON RP.RegisterID = RPX.RegisterID AND RP.PropertyName = RPX.PropertyName AND RP.VersionNum = RPX.VersionNum
				WHERE NOT EXISTS(SELECT 1 FROM #TMP_RegisterProperties TR WHERE TR.RegisterID = RPX.RegisterID AND TR.PropertyName = RPX.PropertyName)
					  AND RPX.VersionNum = @VersionNum - 1
				 
			INSERT INTO dbo.RegistersPropertiesXref(RegisterPropertyID,RegisterID,UserCreated,VersionNum,PropertyName,IsActive)
				SELECT RegisterPropertyID, RegisterID,@UserCreated,@VersionNum,PropertyName,IsActive
				FROM #TMP_RegistersPropertiesXref --#TMP_RegisterProperties TR
				--WHERE NOT EXISTS(SELECT 1 FROM dbo.RegistersPropertiesXref WHERE RegisterPropertyID= TR.RegisterPropertyID AND RegisterID = @RegisterID AND PropertyName = TR.PropertyName AND VersionNum = @VersionNum) 
								 
			--MAKE THE PROPERTY INACTIVE IN CASE NOT AVAILABLE IN THE LATEST VERSION
			--UPDATE RPX	
			--	SET IsActive = 0
			--FROM dbo.RegistersPropertiesXref RPX
			--WHERE VersionNum = @VersionNum
			--	  AND EXISTS(SELECT 1 FROM RegistersPropertiesXref C WHERE RPX.RegisterID=C.RegisterID AND C.PropertyName = RPX.PropertyName AND C.VersionNum = @VersionNum - 1)	
			
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
	 	
	 	 --DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_Assessments
		 DROP TABLE IF EXISTS #TMP_RegisterProperties
		 DROP TABLE IF EXISTS #TMP_AssessmentData
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS 
		 DROP TABLE IF EXISTS #TMP_RegistersPropertiesXref
		 DROP TABLE IF EXISTS #TMP_RegistersProperties
		 --------------------------------------------------------
END