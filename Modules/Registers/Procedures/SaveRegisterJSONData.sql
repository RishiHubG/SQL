
/****** Object:  StoredProcedure [dbo].[SaveregisterJSONData]    Script Date: 06/06/2021 11:00:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 
/***************************************************************************************************
OBJECT NAME:        dbo.SaveRegisterJSONData
CREATION DATE:      2021-02-20
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveRegisterJSONData   @UserLoginID=100,
													@inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[SaveRegisterJSONData]
@InputJSON VARCHAR(MAX),
@UserLoginID INT,
@EntityID INT,
@EntityTypeID INT=NULL,
@ParentEntityID INT=NULL,
@ParentEntityTypeID INT=NULL,
@MethodName NVARCHAR(2000) = NULL,
@Name NVARCHAR(MAX) = NULL,
@Description NVARCHAR(MAX) = NULL,
@LogRequest BIT = 1,
@FrameworkID INT
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON; 

	IF @EntityTypeID <> 3 OR @ParentEntityTypeid NOT IN (2,3)
	BEGIN
		PRINT 'UNAUTHORIZED ACCESS!!!!'
		RETURN
	END	

	DECLARE @UserID INT

	IF @EntityID = -1 AND EXISTS (SELECT 1 FROM dbo.Registers WHERE NAME = @Name AND parentid = @ParentEntityID)
	BEGIN
		PRINT 'VIOLATION OF UNIQUE KEY; REGISTER ALREADY EXISTS!!'
		RETURN
	END

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     
	
	BEGIN TRAN

	IF @UserID IS NOT NULL
	BEGIN	

			DECLARE @RegisterID INT,
					@UniverseID INT,
					@PeriodIdentifierID INT = 1,
					@OperationType VARCHAR(50),
					@VersionNum INT,			
					@AccessControlID INT,
					@WorkflowID INT,
					@CurrentDate DATETIME2(3) =  GETUTCDATE()
			DECLARE @SQL NVARCHAR(MAX),	@ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX)

			IF @EntityID = -1 AND @ParentEntityID IS NULL
			BEGIN
					SELECT @OperationType ='INSERT'
			
					---GENERATE ACCESSCONTROL & WF ID
					EXEC dbo.[GetNewAccessControllId] @UserLoginid, @MethodName, @EntityTypeID, @AccessControlId OUTPUT
					EXEC dbo.[GetNewAccessControllId] @UserLoginid, @MethodName, @EntityTypeID, @WorkflowID OUTPUT				

					INSERT INTO dbo.Registers([Name],[Description],AccessControlId,WorkFlowACID,UserCreated,DateCreated,DateModified,frameworkid)
						SELECT @Name, @Description,@AccessControlId,@WorkflowID,@UserLoginID,@CurrentDate,@CurrentDate,@FrameworkId
		
					SET @RegisterID = SCOPE_IDENTITY()

					--EXEC [dbo].[CalculateUniverseHeightAndDepth]
			END
			ELSE IF @EntityID = -1 AND @ParentEntityID IS NOT NULL
			BEGIN
					SELECT @OperationType ='INSERT'
					
					IF @ParentEntityTypeID = 2
						SET @UniverseID = @ParentEntityID
					IF @ParentEntityTypeID = 3
						SELECT @UniverseID = UniverseID
						FROM dbo.Registers
						WHERE RegisterID = @ParentEntityID

					---GENERATE ACCESSCONTROL & WF ID
					EXEC dbo.[GetNewAccessControllId] @UserLoginid, @MethodName, @EntityTypeID, @AccessControlId OUTPUT
					EXEC dbo.[GetNewAccessControllId] @UserLoginid, @MethodName, @EntityTypeID, @WorkflowID OUTPUT

					INSERT INTO dbo.Registers([Name],[Description],ParentID,ParentEntityTypeID,UniverseID,AccessControlId,WorkFlowACID,UserCreated,DateCreated,DateModified,frameworkid)
						SELECT @Name, @Description,@ParentEntityID,@ParentEntityTypeID,@UniverseID, @AccessControlId,@WorkflowID,@UserLoginID,@CurrentDate,@CurrentDate,@FrameworkId
		
					SET @RegisterID = SCOPE_IDENTITY()

					--EXEC [dbo].[CalculateUniverseHeightAndDepth]
			END
			ELSE IF @EntityID > 0
			BEGIN		
	
				SELECT @OperationType ='UPDATE',
					   @RegisterID = @EntityID

					SELECT @AccessControlID = accesscontrolid FROM  dbo.Registers WHERE RegisterID = @RegisterID
					SELECT @WorkflowID = WorkFlowACID FROM  dbo.Registers WHERE RegisterID = @RegisterID	
					
					UPDATE Registers
					SET name = @Name
					,Description =  @Description
					,frameworkid = @FrameworkId
					WHERE registerid = @EntityID
			END
	
			 SELECT *
					INTO #TMP_ALLSTEPS
			 FROM dbo.HierarchyFromJSON(@inputJSON) 
	
			--SELECT * FROM #TMP_ALLSTEPS

				--RETURN

		--CONTACT LIST--------------------------------------------------------------------------------------------------------------------
		;WITH CTE 
		AS
		(
			SELECT Element_ID, Name,Parent_ID,StringValue,OBJECT_ID AS ObjectID
			FROM #TMP_ALLSTEPS
			WHERE Name = 'contactscontainer'
				  AND Parent_ID = 0

			UNION ALL

			SELECT TA.Element_ID, TA.Name,TA.Parent_ID,TA.StringValue,TA.OBJECT_ID AS ObjectID
			FROM CTE C
				 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = C.Element_ID			
		),
		CTE_Assigned AS	--FETCH ALL PERMISSIONS UNDER ""ASSIGNED"" NODE
		(
			SELECT Element_ID, Name,Parent_ID,StringValue,ObjectID
			FROM CTE
			WHERE Name = 'Assigned'

			UNION ALL

			SELECT TA.Element_ID, TA.Name,TA.Parent_ID,TA.StringValue,TA.OBJECT_ID AS ObjectID
			FROM CTE_Assigned C
				 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = C.Element_ID
		
		)

		SELECT * 
			INTO #TMP_AssignedPermissions
		FROM CTE_Assigned
		
		DELETE FROM #TMP_AssignedPermissions WHERE Name = 'Assigned' OR Name IS NULL OR ObjectID IS NOT NULL
		--SELECT * FROM #TMP_AssignedPermissions
		 DROP TABLE IF EXISTS #TMP
		
		SELECT TD.Element_ID,
			   TD.Name AS ColumnName,
			   TD.StringValue,
			   TD.Parent_ID AS ParentID
			INTO #TMP
		FROM #TMP_AssignedPermissions TD
		 

		--BUILD THE UPDATE STATEMENTS-------------------------------------------------------------------------------------------------------
		DECLARE @UpdStmt VARCHAR(MAX) = CONCAT('IF EXISTS(SELECT 1 FROM dbo.ContactInst WHERE EntityID = <EntityID> AND ContactID=<ContactID> AND RoleTypeID=<RoleTypeID>)',CHAR(10),
												' UPDATE dbo.ContactInst SET UserModified=', @UserID,', DateModified = GETUTCDATE(),')
		DECLARE @UpdWhereClauseStmt VARCHAR(MAX) = CONCAT(' WHERE EntityID=',@RegisterID, CHAR(10), ' AND ContactID=<ContactID>', CHAR(10), ' AND RoleTypeID=<RoleTypeID>')
		
		 SELECT 
			ParentID,
			STUFF((
			SELECT  CONCAT(', ',CHAR(10),
								CASE WHEN ColumnName = 'id' THEN '[ContactID]' 
								     WHEN ColumnName = 'role' THEN '[RoleTypeID]' 
								ELSE QUOTENAME(ColumnName) END,'=''',							 
							  StringValue
							,'''')
			FROM #TMP 
			WHERE ParentID = TMP.ParentID
			AND ColumnName <> 'name'
			ORDER BY Element_ID
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,2,'') AS UpdString,
			(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'ID') AS ContactID,
			(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'Role') AS RoleTypeID
			INTO #TMP_UpdateStmt	
		FROM #TMP TMP
		GROUP BY ParentID
		
		UPDATE #TMP_UpdateStmt 
			SET UpdString = CONCAT(@UpdStmt,UpdString, CHAR(10),@UpdWhereClauseStmt)

		UPDATE	TMP 
			SET UpdString =  REPLACE(REPLACE( REPLACE(UpdString,'<EntityID>',@RegisterID),'<ContactID>',ContactID),'<RoleTypeID>',RoleTypeID)
		FROM #TMP_UpdateStmt TMP
			 
		SET @SQL = STUFF
					((SELECT CONCAT(' ', UpdString,'; ', CHAR(10))
					FROM #TMP_UpdateStmt 					 	
					FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
					,1,1,'')	
		 
		PRINT @SQL
		EXEC (@SQL)
		--UPDATE STATEMENTS ENDS HERE--------------------------------------------------------------------------------------------------------
 

		---BUILD INSERT------------------------------
		--BUILD THE COLUMNS
		SELECT 
			ParentID,
			STUFF((
			SELECT  CONCAT(', ',
								CASE WHEN ColumnName = 'id' THEN '[ContactID]' 
									 WHEN ColumnName = 'role' THEN '[RoleTypeID]' 	
								ELSE QUOTENAME(ColumnName) END
						  )
			FROM #TMP 
			WHERE ParentID = TMP.ParentID
				  AND ColumnName <> 'name'
			ORDER BY Element_ID
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,2,'') AS ColumnNames
		 INTO #TMP_Columns
		FROM #TMP TMP
		GROUP BY ParentID
		 
		--BUILD THE COLUMN VALUES
		SELECT 
			ParentID,
			STUFF((
			SELECT CONCAT(', ',CHAR(39),							  
							  StringValue,	
							  CHAR(39))
			FROM #TMP T
			WHERE ParentID = TMP.ParentID
				  AND ColumnName <> 'name'
			ORDER BY Element_ID
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,2,'') AS ColumnValues,
			(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'ID') AS ContactID,
			(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'Role') AS RoleTypeID
			INTO #TMP_ColumnValues
		FROM #TMP TMP
		GROUP BY ParentID
	 
		DECLARE @FixedColumns VARCHAR(1000) = 'UserCreated,DateCreated,UserModified,DateModified,EntityID,EntityTypeID,FrameWorkID'
		DECLARE @FixedColumnValues VARCHAR(1000) =  CONCAT(
									   CHAR(39),@UserLoginID,CHAR(39),',',
									   CHAR(39),@CurrentDate,CHAR(39),',',
								  	   CHAR(39),@UserLoginID,CHAR(39),',',
									   CHAR(39),@CurrentDate,CHAR(39),',',
									   @RegisterID,',', @EntityTypeID,',-1'
									   )		 
			
		--BUILD THE INSERT
		SELECT Cols.ParentID,			  
			  CONCAT('IF NOT EXISTS(SELECT 1 FROM dbo.ContactInst WHERE EntityID = <EntityID> AND ContactID=<ContactID> AND RoleTypeID = <RoleTypeID>)',CHAR(10),
					  'INSERT INTO dbo.ContactInst (',ColumnNames,',',@FixedColumns, ')',
					  'VALUES (', ColumnValues,',',@FixedColumnValues,')'		
				     ) AS TableInsert,
				Val.ContactID,
				Val.RoleTypeID
			INTO #TMP_ContactInst
		FROM #TMP_Columns Cols
			 INNER JOIN #TMP_ColumnValues Val ON VAL.ParentID = Cols.ParentID			 
		 
		UPDATE #TMP_ContactInst
			SET TableInsert = REPLACE(REPLACE( REPLACE(TableInsert,'<EntityID>',@RegisterID),'<ContactID>',ContactID),'<RoleTypeID>',RoleTypeID)

		SET @SQL = STUFF
					((SELECT CONCAT(' ', TableInsert,'; ', CHAR(10))
					FROM #TMP_ContactInst 	
					FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
					,1,1,'')	
		 
		PRINT @SQL
		EXEC (@SQL)
		---INSERT ENDS HERE--------------------------
		
		--CONTACT LIST ENDS HERE--------------------------------------------------------------------------------------------------------------------------------


				;WITH CTE
				AS
				(
				SELECT T.Element_ID,
					   T.Name, 
					   T.Parent_ID,
					   T.OBJECT_ID AS ObjectID,
					   TAB.pos,
					   T.StringValue,	
					   CAST(NULL AS VARCHAR(500)) AS KeyName,			   
						ROW_NUMBER()OVER(PARTITION BY T.Element_ID,T.Name ORDER BY TAB.pos DESC) AS RowNum
				 FROM #TMP_ALLSTEPS T
					  OUTER APPLY dbo.[FindPatternLocation](T.Name,'.')TAB	 
				 WHERE Parent_ID = 0
				)
		
				SELECT *
					INTO #TMP_DATA_KEYNAME
				FROM CTE
				WHERE RowNum = 1

				UPDATE #TMP_DATA_KEYNAME
					SET KeyName = SUBSTRING(Name,Pos+1,len(Name))
				WHERE Pos > 0

				--UPDATE T
				--	SET StringValue = TA.StringValue
				--FROM #TMP_DATA_KEYNAME T
				--	 INNER JOIN #TMP_ALLSTEPS TA ON T.Element_ID = TA.Element_ID
				--WHERE TA.Pos > 0

				--SELECT * FROM #TMP_DATA_KEYNAME
				--RETURN
				--SELECT * FROM #TMP_ALLSTEPS

				 --BUILD THE COLUMN LIST
				 -------------------------------------------------------------------------------------------------------
				
				SELECT TA.Element_ID,
					   TA.Name AS ColumnName,
					   TA.StringValue
					INTO #TMP_INSERT
				FROM #TMP_DATA_KEYNAME TD
					 INNER JOIN #TMP_ALLSTEPS TA ON TA.Parent_ID = TD.ObjectID
				WHERE TD.Name ='attributes'			  

				--INSERT ANY OTHER AD-HOC/FIXED COLUMNS
				--INSERT INTO #TMP_INSERT(ColumnName,StringValue)
				--	--SELECT 'VersionNum',@VersionNum
				--	--UNION
					--SELECT 'UserCreated',@UserLoginID
			

						 --SELECT * FROM #TMP_INSERT
					   --RETURN			

 				IF @EntityID = -1
				BEGIN
	 				SET @ColumnNames = STUFF
											((SELECT CONCAT(', ',QUOTENAME(ColumnName))
											FROM #TMP_INSERT 								
											ORDER BY Element_ID
											FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
											,1,1,'')
					
						
						DECLARE @HistoryColumns VARCHAR(MAX) = 'RegisterPropertiesXref_DataID,RegisterID,UserCreated,DateCreated ,UserModified, Datemodified'
						
					
					IF @ColumnNames IS NOT NULL
					BEGIN
						SET @ColumnNames = CONCAT('RegisterID,UserCreated,',@ColumnNames)
						SET @HistoryColumns = CONCAT(@HistoryColumns,',',@ColumnNames)
					END
					ELSE
					BEGIN
						SET @ColumnNames = 'RegisterID,UserCreated'
					END

					SET @ColumnValues = STUFF
											((SELECT CONCAT(', ',CHAR(39),StringValue,CHAR(39))
											FROM #TMP_INSERT 								
											ORDER BY Element_ID
											FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
											,1,1,'')

					IF @ColumnValues IS NOT NULL
						SET @ColumnValues = CONCAT(CHAR(39),@RegisterID,CHAR(39),',',CHAR(39),@UserLoginID,CHAR(39),',',@ColumnValues)
					ELSE
						SET @ColumnValues = CONCAT(CHAR(39),@RegisterID,CHAR(39),',',CHAR(39),@UserLoginID,CHAR(39))
				END
				ELSE
				BEGIN
					DECLARE @UpdStr VARCHAR(MAX)

					SET  @UpdStr = STUFF(
										(
										SELECT CONCAT(', ',QUOTENAME(COLUMNNAME),'=',CHAR(39),StringValue,CHAR(39), CHAR(10))
										FROM #TMP_INSERT
										FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)'),
										1,1,'')
				
				END
			

				--UPDATE TRIGGER FOR ANY NEW COLUMNS/REMOVAL OF EXISTING COLUMNS---------------------
					IF EXISTS(SELECT 1 FROM SYS.triggers WHERE NAME ='RegisterPropertiesXref_Data_Insert')						
						SET @SQL = N'ALTER TRIGGER '
					ELSE
						SET @SQL = N'CREATE TRIGGER '

					SET @SQL = CONCAT(@SQL,N' dbo.RegisterPropertiesXref_Data_Insert
									   ON  dbo.RegisterPropertiesXref_Data
									   AFTER INSERT, UPDATE
									AS 
									BEGIN
										SET NOCOUNT ON;

										IF EXISTS(SELECT 1 FROM INSERTED) AND  NOT EXISTS(SELECT 1 FROM DELETED) --INSERT
											INSERT INTO dbo.RegisterPropertiesXref_Data_history(<ColumnList>)
												SELECT <columnList>
												FROM INSERTED
										ELSE IF EXISTS(SELECT 1 FROM INSERTED) AND  EXISTS(SELECT 1 FROM DELETED) --UPDATE
											INSERT INTO dbo.RegisterPropertiesXref_Data_history(<ColumnList>)
												SELECT <columnList>
												FROM DELETED
									END;',CHAR(10))
					SET @SQL = REPLACE(@SQL,'<columnList>',@HistoryColumns)
					PRINT @SQL	
					EXEC sp_executesql @SQL	
				--END: TRIGGER------------------------------------------------------------------------
			
				IF @EntityID = -1
				BEGIN
					SET @SQL = CONCAT('INSERT INTO dbo.RegisterPropertiesXref_Data','(',@ColumnNames,') VALUES(',@ColumnValues,')')
					PRINT @SQL
				END
				ELSE	--UPDATE
				BEGIN
					SET @SQL = CONCAT('UPDATE dbo.RegisterPropertiesXref_Data',CHAR(10),' SET ',@UpdStr)
					SET @SQL = CONCAT(@SQL, ' WHERE RegisterID=', @RegisterID)
					PRINT @SQL
				END
			
				-- RETURN
				EXEC sp_executesql @SQL	
				
				--CALL DOMAIN PERMISSIONS HERE
				EXEC dbo.SaveRegisterPermissions @InputJSON = @InputJSON,
												 @UserLoginID=@UserLoginID,
												 @MethodName = @MethodName,
												 @AccessControlID = @AccessControlID
												 
				--UPDATE _HISTORY TABLE-----------------------------------------
			
				--DECLARE @HistoryID INT = (SELECT MAX(HistoryID) FROM dbo.RegisterPropertiesXref_Data_history WHERE RegisterID = @RegisterID)
				
				----UPDATE VERSION NO.
				--UPDATE dbo.RegisterPropertiesXref_Data_history
				--	SET VersionNum = @VersionNum
				--WHERE HistoryID = @HistoryID			 

				----RESET PERIODIDENTIFIER FOR EARLIER VERSIONS
				--UPDATE dbo.RegisterPropertiesXref_Data_history
				--	SET PeriodIdentifierID = 0,
				--		UserModified = @UserLoginID,
				--		DateModified = GETUTCDATE()
				--WHERE RegisterID = @RegisterID
				--	  AND VersionNum < @VersionNum
		
				----UPDATE OTHER COLUMNS FOR CURRENT VERSION
				--UPDATE dbo.RegisterPropertiesXref_Data_history
				--	SET PeriodIdentifierID = @PeriodIdentifierID,
				--		UserModified = @UserLoginID,
				--		DateModified = GETUTCDATE(),
				--		OperationType = @OperationType
				--WHERE RegisterID = @RegisterID
				--	  AND VersionNum = @VersionNum
				-----------------------------------------------------------------

				DECLARE @Params VARCHAR(MAX)
				DECLARE @ObjectName VARCHAR(100)

				--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
				IF @LogRequest = 1
				BEGIN			
				
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

						SET @Params = CONCAT('@EntityID=',@EntityID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=',@LogRequest,',@EntityTypeID=',@EntityTypeID)
						SET @Params = CONCAT(@Params,',@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID,',@FrameworkID=',@FrameworkID)
						SET @Params = CONCAT(@Params,',@name=',CHAR(39),@Name,CHAR(39),',@MethodName=',@MethodName)
					--PRINT @PARAMS
			
					SET @ObjectName = OBJECT_NAME(@@PROCID)

					EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
											 @Params = @Params,
											 @UserLoginID = @UserLoginID
				END
				------------------------------------------------------------------------------------------------------------------------------------------

				COMMIT
		
				--DROP TEMP TABLES--------------------------------------	
				 DROP TABLE IF EXISTS #TMP_INSERT
				 DROP TABLE IF EXISTS #TMP_DATA_KEYNAME		 
				 --------------------------------------------------------

				 SELECT NULL AS ErrorMessage
				 SELECT @RegisterID AS id

		 END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage

END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()

				 IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'
			 

						SET @Params = CONCAT('@EntityID=',@EntityID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=',@LogRequest,',@EntityTypeID=',@EntityTypeID)
						SET @Params = CONCAT(@Params,',@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID,',@FrameworkID=',@FrameworkID)
						SET @Params = CONCAT(@Params,',@name=',CHAR(39),@Name,CHAR(39),',@MethodName=',@MethodName)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
END CATCH
END



