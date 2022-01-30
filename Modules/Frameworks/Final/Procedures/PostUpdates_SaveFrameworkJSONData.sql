 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/***************************************************************************************************
OBJECT NAME:        dbo.PostUpdates_SaveFrameworkJSONData
CREATION DATE:      2022-1-30
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:   

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].PostUpdates_SaveFrameworkJSONData
@FrameworkID INT = NULL,
@UserLoginID INT = NULL,
@EntityID INT = NULL,
@EntityTypeID INT=NULL,
@ParentEntityID INT=NULL,
@ParentEntityTypeID INT=NULL,
@MethodName NVARCHAR(200)=NULL,
@LogRequest BIT = 1,
@TransitionID INT = NULL
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	PRINT 'TEST';
	/*
	IF @EntityID IS NULL
		RAISERROR ('Invalid EntityID',16,1)
		
	DECLARE @UserID INT
		
	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     
	
	IF @UserID IS NOT NULL
	BEGIN

	DECLARE @UTCDATE DATETIME2(3) = GETUTCDATE()
	DECLARE @FixedColumns VARCHAR(1000) 
	DECLARE @SQL NVARCHAR(MAX),	@ColumnNames VARCHAR(MAX), @ColumnValues VARCHAR(MAX)
	DECLARE @PeriodIdentifierID INT = 1,
			@OperationType VARCHAR(50),
			@VersionNum INT,
			--@IsAvailable BIT = 0
			@UpdStr VARCHAR(MAX)

	DECLARE @FrameworkID int = (SELECT frameworkid FROM Registers WHERE registerid = @ParentEntityID)
	DECLARE @TableName VARCHAR(500) 
	
	SELECT @TableName = CONCAT(Name,'_DATA') ,
		   @VersionNum = VersionNum
	FROM dbo.Frameworks 
	WHERE FrameworkID = @FrameworkID

	IF @TableName IS NULL
	BEGIN
		PRINT '_DATA TABLE NOT AVAILABLE!!'
		RETURN
	END

	--SET @SQL = CONCAT(N'IF EXISTS(SELECT 1 FROM dbo.',@TableName,' WHERE FrameworkID = ',@EntityID,') SET @IsAvailable = 1;' )
	--EXEC sp_executesql @SQL,N'@IsAvailable BIT OUTPUT',@IsAvailable OUTPUT

	IF @EntityID = -1
		SET @OperationType ='INSERT'
	ELSE IF @EntityID > 0
	    SET @OperationType ='UPDATE'

	--IF @EntityID = -1
	--BEGIN
	--	SELECT @FrameworkID = 1, @OperationType ='INSERT', @VersionNum = 1
	--END
	--ELSE
	--BEGIN

		--SET @SQL = CONCAT(N'SELECT TOP 1 @VersionNum = MAX(VersionNum)+1 FROM dbo.',@TableName,'_HISTORY WHERE FrameworkID = ',@FrameworkID,' ORDER BY HISTORYID DESC' )
		--EXEC sp_executesql @SQL,N'@VersionNum BIT OUTPUT',@VersionNum OUTPUT

		--SET @SQL = CONCAT('SELECT @VersionNum = VersionNum FROM ',@TableName,' WHERE FrameworkID =', @FrameworkID)		
		--EXEC sp_executesql @SQL,N'@VersionNum INT OUTPUT',@VersionNum OUTPUT

		IF @VersionNum IS NULL	
			SET @VersionNum = 1
		
	--END
		
	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON) 
	

	--EXCLUDE THESE COLUMNS AS THESE WERE HARD-CODED IN PARSE & WILL NOT BE PROCESSED AS PART OF SAVE
		------------------------------------------------------------------------------
		DECLARE @TBL_DELETECOLUMNS TABLE(NAME VARCHAR(100),IsAdminColumn BIT)
		
		--ADD TO THIS LIST ANY COLUMNS WHICH WERE ARE HARD-CODED/EXCLUDED
		--IsAdminColumn = 1 WILL BE POPULATED IN THE STATIC TABLE dbo.Frameworks_ExtendedValues
		INSERT INTO @TBL_DELETECOLUMNS(NAME,IsAdminColumn)
			SELECT 'DateCreated',0
			UNION
			SELECT 'DateModified',0
			UNION
			SELECT 'UserCreated',0
			UNION
			SELECT 'UsermModified',0
			UNION
			SELECT 'referencenum',0
			UNION
			SELECT 'registerReference',0
			UNION
			SELECT 'knowledgebasereference',0
			UNION
			SELECT 'showAdminTab',1
			UNION
			SELECT 'loggedInUserRole',1
			UNION
			SELECT 'loggedInUserGroup',1
			UNION
			SELECT 'isModuleAdmin',1
			UNION
			SELECT 'isSystemAdmin',1
			UNION
			SELECT 'isModuleAdminGroup',1
			UNION
			SELECT 'CurrentStateowner',1
			UNION
			SELECT 'submit',0
			
			--GATHER DATA FOR dbo.Frameworks_ExtendedValues TABLE
			SELECT Parent_ID,
				   MAX(IIF(TMP.Name='showAdminTab',TMP.StringValue,'')) AS showAdminTab,
				   MAX(IIF(TMP.Name='loggedInUserRole',TMP.StringValue,'')) AS loggedInUserRole,
				   MAX(IIF(TMP.Name='loggedInUserGroup',TMP.StringValue,'')) AS loggedInUserGroup,
				   MAX(IIF(TMP.Name='isModuleAdmin',TMP.StringValue,'')) AS isModuleAdmin,
				   MAX(IIF(TMP.Name='CurrentStateowner',TMP.StringValue,'')) AS CurrentStateowner,
				   MAX(IIF(TMP.Name='isSystemAdmin',TMP.StringValue,'')) AS isSystemAdmin,
				   MAX(IIF(TMP.Name='isModuleAdminGroup',TMP.StringValue,'')) AS isModuleAdminGroup				
				INTO #TMP_Frameworks_ExtendedValues
			FROM @TBL_DELETECOLUMNS  TMP_D
				 INNER JOIN #TMP_ALLSTEPS TMP ON TMP.NAME=TMP_D.NAME 
			WHERE TMP_D.IsAdminColumn = 1
				  AND TMP.ValueType ='string'
			GROUP BY Parent_ID

			--DELETE DATA NOT BEING PROESSED
			DELETE TMP FROM #TMP_ALLSTEPS TMP
			WHERE EXISTS(SELECT 1 FROM @TBL_DELETECOLUMNS WHERE NAME=TMP.NAME AND TMP.ValueType ='string')			
		------------------------------------------------------------------------------

	-------------------------------------------------------------------------------------------------
	
	--REPLACE SINGLE QUOTES WITH DOUBLE QUOTES
	UPDATE #TMP_ALLSTEPS SET StringValue = REPLACE(StringValue,'''','''''') WHERE ValueType ='string'

	--SEPARATE OUT CONTACT LIST
	;WITH CTE_ContactList
	AS
	(		
		SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.OBJECT_ID AS ObjectID,			   
			   T.StringValue,
			   1 as Lvl
		 FROM #TMP_ALLSTEPS T			  
		 WHERE Name ='contactList'

		 UNION ALL

		 SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.OBJECT_ID AS ObjectID,			   
			   T.StringValue,
			   C.Lvl+1
		 FROM CTE_ContactList C
			  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
	)

	SELECT *
		INTO #TMP_ContactList
	FROM CTE_ContactList
	
	--REMOVE CONTACT LIST NODE ELEMENTS FROM THE MAIN NODES WE ARE PROCESSING
	DELETE T FROM #TMP_ALLSTEPS T WHERE EXISTS(SELECT 1 FROM #TMP_ContactList WHERE Element_ID = T.Element_ID)

	--SEPARATE OUT ASSIGNED FROM WITHIN CONTACT LIST
	;WITH CTE_AssignedContactList
	AS
	(		
		SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.ObjectID,			   
			   T.StringValue,
			   1 as Lvl
		 FROM #TMP_ContactList T			  
		 WHERE Name ='assigned'

		 UNION ALL

		 SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,
			   T.ObjectID,			   
			   T.StringValue,
			   C.Lvl+1
		 FROM CTE_AssignedContactList C
			  INNER JOIN #TMP_ContactList T ON T.Parent_ID = C.Element_ID
	)
	SELECT * 
		INTO #TMP_AssignedContactList
	FROM CTE_AssignedContactList
	WHERE NOT (Name IS NULL OR Name = 'name' OR Name = 'assigned')

	--SELECT * FROM #TMP_AssignedContactList
	--RETURN
	DECLARE @TBL TABLE(ContactInstID INT, ContactID INT, RoleTypeID INT,Notify BIT)

	INSERT INTO @TBL(ContactInstID,ContactID,RoleTypeID,Notify)
		SELECT  MAX(CASE WHEN Name ='ID'  THEN StringValue END),
				MAX(CASE WHEN Name ='ID'  THEN StringValue END),
				MAX(CASE WHEN Name ='Role' THEN  StringValue END),
				MAX(CASE WHEN Name ='Notify' THEN  StringValue END)
		FROM #TMP_AssignedContactList 			
		GROUP BY Parent_ID
	
		SELECT ContactInstId
			INTO #TBL_REMOVECONTACTS
		FROM dbo.ContactInst C
		WHERE FrameWorkID = @Frameworkid
			  AND EntityTypeID = @EntityTypeID
			  AND EntityID = @EntityID
			  AND NOT EXISTS(SELECT 1 FROM @TBL WHERE ContactID = C.ContactId)
			  AND ContactInstID <> -1
	
		BEGIN TRAN

		--REMOVE CONTACTS NOT PART OF THE CURRENT JSON
		DELETE C FROM dbo.ContactInst C WHERE EXISTS (SELECT 1 FROM #TBL_REMOVECONTACTS WHERE ContactInstId = C.ContactInstId)

		--INSERT NEW CONTACTS
		INSERT INTO dbo.ContactInst(UserCreated,DateCreated,UserModified,DateModified,RoleTypeID,ContactId,Notify,FrameworkId,EntityTypeId,EntityId)
			SELECT @UserID,@UTCDATE,@UserID,@UTCDATE, RoleTypeID,ContactID,Notify,@Frameworkid,@EntityTypeID, @EntityID
			FROM @TBL T
			WHERE ContactInstID = -1 --NOT EXISTS(SELECT 1 FROM dbo.ContactInst WHERE ContactID = T.ContactID AND RoleTypeID =T.RoleTypeID AND FrameworkId = @Frameworkid)
		
		--UPDATE EXISTING CONTACT'S ROLETYPEID
		UPDATE CInst
			SET RoleTypeID = T.RoleTypeID,
				DateModified = @UTCDATE
		FROM dbo.ContactInst CInst
			 INNER JOIN @TBL T ON Cinst.ContactInstId = Cinst.ContactInstId
		WHERE ISNULL(CInst.RoleTypeID,0) <> ISNULL(T.RoleTypeID,0)
		
		--UPDATE EXISTING CONTACT'S Notify
		UPDATE CInst
			SET Notify = T.Notify,
				DateModified = @UTCDATE
		FROM dbo.ContactInst CInst
			 INNER JOIN @TBL T ON Cinst.ContactInstId = Cinst.ContactInstId
		WHERE ISNULL(CInst.Notify,0) <> ISNULL(T.Notify,0)
			
	--ELSE -- TO DO: UPDATE
	--BEGIN
	--END


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
		
		--SELECT * FROM #TMP_ALLSTEPS WHERE Name LIKE 'TemplateKey_%'
		--SELECT * FROM #TMP_ALLSTEPS

   --PROCESS "TEMPLATEKEY_" DATA FOR TABLE/TABLETEMPLATE------------------------------------------------------------------------
	DECLARE @OperationType_TMP VARCHAR(50)
	DECLARE @StaticColValues VARCHAR(MAX)
	DECLARE @StaticCols VARCHAR(MAX) =	 'UserCreated, 
										 DateCreated, 
										 UserModified,
										 DateModified,
										 VersionNum,	 
										 TableInstanceID'

	;WITH CTE_TableOrTableTemplate
	AS
	(		
		SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,			   	   
			   T.StringValue,
			   T.ValueType,
			   1 as Lvl
		 FROM #TMP_ALLSTEPS T
		 WHERE Name LIKE 'TemplateKey_%'

		 UNION ALL

		 SELECT T.Element_ID,
			   T.Name, 
			   T.Parent_ID,			  			   
			   T.StringValue,
			   T.ValueType,
			   C.Lvl+1
		 FROM CTE_TableOrTableTemplate C
			  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
	)
	SELECT * 
		INTO #TMP_TableOrTableTemplate
	FROM CTE_TableOrTableTemplate
	WHERE (ValueType = 'string' OR Name LIKE 'TemplateKey_%')
	
	--INSERT INTO TABLE/TEMPLATETABLE
	IF EXISTS(SELECT 1 FROM #TMP_TableOrTableTemplate)
	BEGIN

			SELECT @APIKey = Name FROM #TMP_TableOrTableTemplate WHERE Lvl = 1
		
			--DELETE THE APIKEY RECORD AFTER APIKEY HAS BEEN EXTRACTED
			DELETE FROM #TMP_TableOrTableTemplate WHERE Lvl = 1

			SET @APIKey =REPLACE(@APIKey,'_','.')
			SET @APIKey =PARSENAME(@APIKey,1)
	
			DECLARE @CustomFormsInstanceID INT, @CustomFormID INT
			DECLARE @TBLNAME VARCHAR(500) = CONCAT('Table_',@APIKey,'_DATA')
			PRINT @TBLNAME
			SELECT @CustomFormsInstanceID = CustomFormsInstanceID,
				   @CustomFormID =  CustomFormID
			FROM dbo.CustomFormsInstance 
			WHERE Apikey = @APIKey

			 IF @CustomFormID = 2
				SET @TBLNAME = CONCAT('Template',@TBLNAME)

			IF NOT EXISTS(SELECT 1 FROM [dbo].[Table_EntityMapping] WHERE [APIKey] = @APIKey)
			BEGIN
				SET @OperationType_TMP = 'INSERT'

				INSERT INTO [dbo].[Table_EntityMapping]
						   ([UserCreated]
						   ,[DateCreated]
						   ,[UserModified]
						   ,[DateModified]
						   ,[VersionNum]
						   ,[TableID]
						   ,[EntityID]
						   ,[FrameworkID]
						   ,[FullSchemaJSON]
						   ,[EntityTypeID]
						   ,[APIKey]
						   )
					 VALUES
						   (@UserLoginID
						   ,@UTCDATE
						   ,@UserLoginID
						   ,@UTCDATE
						   ,@VersionNum
						   ,@CustomFormsInstanceID
						   ,@EntityID
						   ,@Frameworkid
						   ,NULL
						   ,@EntityTypeID
						   ,@APIKey			   
						   )
		
				DECLARE @TableInstanceID INT = SCOPE_IDENTITY()

					INSERT INTO [dbo].[Table_EntityMapping_history]
					   ([UserCreated]
					   ,[DateCreated]
					   ,[UserModified]
					   ,[DateModified]
					   ,[VersionNum]
					   ,[TableID]
					   ,[EntityID]
					   ,[FrameworkID]
					   ,[FullSchemaJSON]
					   ,[EntityTypeID]
					   ,[APIKey],
					   TableInstanceID,
					   OperationType
					   )
				 VALUES
					   (@UserLoginID
					   ,@UTCDATE
					   ,@UserLoginID
					   ,@UTCDATE
					   ,@VersionNum
					   ,@CustomFormsInstanceID
					   ,@EntityID
					   ,@Frameworkid
					   ,NULL
					   ,@EntityTypeID
					   ,@APIKey,
					   @TableInstanceID,
					   @OperationType_TMP
					   )
		
			END

				--SELECT * FROM #TMP_TableOrTableTemplate
		
				--SELECT Parent_ID,STRING_AGG(QUOTENAME(NAME),',')
				--FROM #TMP_TableOrTableTemplate
				--GROUP BY Parent_ID
		
	 		
				IF @OperationType_TMP ='INSERT'
				BEGIN
			
					SET @StaticColValues = CONCAT(@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@VersionNum,',',@EntityID)
					PRINT @StaticColValues

						SELECT 
							Parent_ID,
							STUFF((
									SELECT  CONCAT(', ',QUOTENAME(Name)) 
									FROM #TMP_TableOrTableTemplate 
									WHERE Parent_ID = TMP.Parent_ID
									ORDER BY Element_ID
									FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
									,1,2,'') AS ColumnName
							INTO #TMP_AllCols	
						FROM #TMP_TableOrTableTemplate TMP
						GROUP BY Parent_ID

						 SELECT 
							Parent_ID,
							STUFF((
									SELECT  CONCAT(', ',CHAR(39),StringValue,CHAR(39))
									FROM #TMP_TableOrTableTemplate 
									WHERE Parent_ID = TMP.Parent_ID
									ORDER BY Element_ID
									FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
									,1,2,'') AS StringValue
							INTO #TMP_AllColValues
						FROM #TMP_TableOrTableTemplate TMP
						GROUP BY Parent_ID

	 				SELECT CONCAT('INSERT INTO dbo.<TABLENAME>(',@StaticCols,',',A1.ColumnName,') VALUES (',@StaticColValues,',',A2.StringValue,')') AS InsertString
						INTO #TMP_InsertString
					 FROM #TMP_AllCols A1
						  INNER JOIN #TMP_AllColValues A2 ON A1.Parent_ID = A2.Parent_ID

					SET @SQL = (SELECT STRING_AGG(InsertString,CONCAT(';',CHAR(10))) FROM #TMP_InsertString);
					SET @SQL = REPLACE(@SQL,'<TABLENAME>',@TBLNAME)
					SET @SQL = CONCAT(@SQL,CHAR(10),';SET @EntityID = SCOPE_IDENTITY();')
					PRINT @SQL
					EXEC sp_executesql @SQL					

				END
				ELSE IF @OperationType_TMP ='UPDATE'
				BEGIN	

					DECLARE @UpdStmt VARCHAR(MAX) = CONCAT(' UPDATE <TABLENAME> SET UserModified=', @UserID,', DateModified = GETUTCDATE(),')
					DECLARE @UpdWhereClauseStmt VARCHAR(MAX) = CONCAT(' WHERE TableInstanceID=',@TableInstanceID, CHAR(10), ' AND FrameWorkID=',@FrameworkID)

						SELECT 
							Parent_ID,
							STUFF((
									SELECT  CONCAT(', ', CHAR(10), QUOTENAME(Name),'=''',StringValue,'''')
									FROM #TMP_TableOrTableTemplate 
									WHERE Parent_ID = TMP.Parent_ID
									ORDER BY Element_ID
									FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
									,1,2,'') AS UpdString
							INTO #TMP_UpdateStmt	
						FROM #TMP_TableOrTableTemplate TMP
						GROUP BY Parent_ID
			
					UPDATE #TMP_UpdateStmt 
						SET UpdString = CONCAT(@UpdStmt,UpdString, CHAR(10),@UpdWhereClauseStmt)
			
					UPDATE	#TMP_UpdateStmt 
						SET UpdString = REPLACE(UpdString,'<TABLENAME>',@TBLNAME)
		
					SET @SQL = STUFF
								((SELECT CONCAT(' ', UpdString,'; ', CHAR(10))
								FROM #TMP_UpdateStmt 	
								FOR XML PATH ('')								
								),1,1,'')	
		 
					PRINT @SQL
					EXEC (@SQL)

				END

		END -- END OF INSERT INTO TABLE/TEMPLATETABLE -> IF EXISTS(SELECT 1 FROM #TMP_TableOrTableTemplate) 	
	--------------------------------------------------------------------------------------------------------------------------------------------
		--RETURN
		/*
		 --GET THE SELECTBOXES (THESE WILL HAVE A PARENT OF TYPE "Object")
		 -------------------------------------------------------------------------------------------------------
		DECLARE @TBL TABLE(Name VARCHAR(100))
		INSERT INTO @TBL (Name) VALUES ('Name')--,('Value'),('Description'),('Color')

		 SELECT Element_ID,SequenceNo,Parent_ID,[Object_ID] AS ObjectID,Name,StringValue,ValueType,TAB.MultiKeyName 
			INTO #TMP_Objects
		 FROM #TMP_ALLSTEPS
			  CROSS APPLY (SELECT NAME FROM @TBL) TAB(MultiKeyName)
		 WHERE ValueType='Object'
			   AND Parent_ID = 0 --ONLY ROOT ELEMENTS			   
			   AND Name NOT IN ('userCreated','dateCreated','userModified','dateModified','submit')
			  
			
		SELECT T.Element_ID,T.Name, MAX(TAB.pos) AS Pos,CAST(NULL AS VARCHAR(100)) AS KeyName	    
			INTO #TMP_DATA_MultiKeyName
		 FROM #TMP_Objects T
			  CROSS APPLY dbo.[FindPatternLocation](T.Name,'.')TAB			  
		GROUP BY T.Element_ID,T.Name		

		UPDATE TD
			SET KeyName = SUBSTRING(TD.Name,Pos+1,len(TD.Name))
		FROM #TMP_DATA_MultiKeyName TD 
			 INNER JOIN #TMP_Objects T ON T.Element_ID = TD.Element_ID
		WHERE Pos > 0	

			SELECT DISTINCT TDM.Element_ID,
				   CONCAT(TDM.KeyName,'_',TAB.MultiKeyName) AS ColumnName,
				   STUFF(
							(SELECT CONCAT(', ',TA.[Name])
							FROM #TMP_ALLSTEPS TA
							WHERE TA.Parent_ID =TDM.Element_ID
								  AND TA.StringValue = 'True'
							FOR XML PATH(''))	
						,1,1,''	
						)  AS StringValue
				INTO #TMP_MULTI
			FROM #TMP_DATA_MultiKeyName TDM
				 INNER JOIN #TMP_Objects TAB ON TAB.Element_ID =TDM.Element_ID
				 INNER JOIN #TMP_ALLSTEPS TAS ON TAS.Parent_ID =TDM.Element_ID
			WHERE TAS.StringValue = 'True'
				
		--SELECT * FROM #TMP_DATA_MultiKeyName
		--SELECT * FROM #TMP_Objects
		 -------------------------------------------------------------------------------------------------------
		

		 --BUILD THE COLUMN LIST
		 -------------------------------------------------------------------------------------------------------

		 --FOR SELECTBOXES
		SELECT Element_ID,
		        ColumnName,
			    StringValue			 
			INTO #TMP_INSERT
		FROM #TMP_MULTI

		UNION
				
		SELECT Element_ID,
			   KeyName,
			   StringValue
		FROM #TMP_DATA_KEYNAME
		WHERE Parent_ID = 0
			  AND OBJECTID IS NULL
			  AND StringValue <> ''
		 */
		 
		  SELECT Element_ID,
				Name AS ColumnName,
				CAST(StringValue AS VARCHAR(MAX)) AS StringValue
			INTO #TMP_INSERT
		 FROM #TMP_ALLSTEPS			  
		 WHERE ValueType NOT IN ('Object','array')
			   AND Name NOT IN ('userCreated','dateCreated','userModified','dateModified','submit')		
		

		--CHECK FOR A MULTISELECT Selectboxes--------------------------------------------------------------------------------------------------------
			
			DROP TABLE IF EXISTS #TMP_Multi_Parent, #TMP_Multi_Child

			SELECT TMP.* , Multi.StepItemID
				INTO #TMP_Multi_Parent
			FROM #TMP_ALLSTEPS TMP
				 INNER JOIN dbo.MultiSelect_FrameworkStepItems Multi ON Multi.FrameworkID = @FrameworkID AND TMP.Name = Multi.StepItemKey			
			WHERE TMP.NAME ='multiselect' 
				  AND TMP.ValueType ='object'
				  AND Multi.StepItemType = 'Selectboxes'
			
			SELECT TMP.*, Parent.StepItemID
				INTO #TMP_Multi_Child
			FROM #TMP_ALLSTEPS TMP
				 INNER JOIN #TMP_Multi_Parent Parent ON Parent.Element_ID = TMP.Parent_ID
		
		DECLARE @TBL_FrameworkMultiselectStepItemValues TABLE(ID INT)

		UPDATE #TMP_Multi_Child
		SET StringValue = CASE StringValue 
								WHEN 'true' THEN '1'
								WHEN 'false' THEN '0'
						  END;
		
		--UPDATE FOR EXISTING IN FrameworkMultiselectStepItemValues
		UPDATE FMSI
			SET IsSelected = Child.StringValue
		FROM dbo.FrameworkMultiselectStepItemValues FMSI
			 INNER JOIN #TMP_Multi_Child Child ON Child.StepItemID = FMSI.StepItemID AND Child.Name = FMSI.Name
		WHERE FMSI.FrameworkID=@FrameworkID
			  AND  FMSI.IsSelected <> Child.StringValue;
		
		--INSERT NEW IN FrameworkMultiselectStepItemValues
		INSERT INTO dbo.FrameworkMultiselectStepItemValues(FrameworkID,Entityid,EntityTypeID,StepItemID,Name,IsSelected)
			OUTPUT INSERTED.ID INTO @TBL_FrameworkMultiselectStepItemValues(ID)
		SELECT @FrameworkID, @EntityID, @EntityTypeID, StepItemID, Name, StringValue 
		FROM #TMP_Multi_Child TMP
		WHERE NOT EXISTS(SELECT 1 FROM dbo.FrameworkMultiselectStepItemValues WHERE @FrameworkID=@FrameworkID AND StepItemID = TMP.StepItemID AND Name = TMP.Name
							AND IsSelected = StringValue);
		
		
		DECLARE @Multi_ColumnNames VARCHAR(MAX)

		SET @Multi_ColumnNames = STUFF
							((SELECT CONCAT(', ',Name)
							FROM #TMP_Multi_Child 
							WHERE StringValue = '1'
							ORDER BY Element_ID
							FOR XML PATH ('')							
							),1,1,'');	
		

		--REMOVE THE MULTI ITEMS FROM #TMP_INSERT AS THEY WILL NOW BE INSERTED AS A COMMA SEPARATED LIST FROM @Multi_ColumnNames
		DELETE TMP FROM #TMP_INSERT TMP
		WHERE EXISTS(SELECT 1 FROM #TMP_Multi_Child WHERE Element_ID = TMP.ELEMENT_ID)

		 --SELECT @Multi_ColumnNames
		-- SELECT * FROM #TMP_Multi_Child		
		 --------------------------------------------------------------------------------------------------------------------------------

		--INSERT ANY OTHER AD-HOC/FIXED COLUMNS
		INSERT INTO #TMP_INSERT(ColumnName,StringValue)
			SELECT 'VersionNum',CAST(@VersionNum AS VARCHAR(10))
			UNION
			SELECT 'UserCreated',CAST(@UserLoginID AS VARCHAR(10))
			UNION
			SELECT 'DateCreated', CAST(CONVERT(DATETIME2(3),  @UTCDATE, 120) AS VARCHAR(100))
			UNION
			SELECT 'RegisterID', CAST(@ParentEntityID AS VARCHAR(10))			
			UNION
			SELECT 'Multiselect', CAST(@Multi_ColumnNames AS VARCHAR(10))
			WHERE EXISTS(SELECT 1 FROM #TMP_Multi_Parent) --MAKE SURE MULTISELECT IS PART OF JSON

		--SELECT * FROM #TMP_INSERT				 

		IF @OperationType ='INSERT'
		BEGIN
				--GET REFERENCENUM------------------------------------------
				DECLARE @REFERENCENUM NVARCHAR(500) 
				DECLARE @TBL_RefNum TABLE (REFERENCENUM NVARCHAR(500))

				INSERT INTO @TBL_RefNum(REFERENCENUM)
					EXEC dbo.getreferenceNo @FrameWorkID
		
				SELECT @REFERENCENUM = REFERENCENUM FROM  @TBL_RefNum
				------------------------------------------------------------

				--INSERT ANY OTHER AD-HOC/FIXED COLUMNS
				INSERT INTO #TMP_INSERT(ColumnName,StringValue)			
					SELECT 'ReferenceNum', CAST(@REFERENCENUM AS VARCHAR(10))

	 		SET @ColumnNames = STUFF
									((SELECT CONCAT(', ',QUOTENAME(ColumnName))
									FROM #TMP_INSERT 								
									ORDER BY Element_ID
									FOR XML PATH ('')								
									),1,1,'')
		
			SET @ColumnNames = CONCAT('FrameworkID',',',@ColumnNames)

			SET @ColumnValues = STUFF
									((SELECT CONCAT(', ',CHAR(39),StringValue,CHAR(39))
									FROM #TMP_INSERT 								
									ORDER BY Element_ID
									FOR XML PATH ('')								
									),1,1,'')

			SET @ColumnValues = CONCAT(CHAR(39),@FrameworkID,CHAR(39),',',@ColumnValues)
		END
		ELSE IF @OperationType ='UPDATE'
		BEGIN
			

			SET  @UpdStr = STUFF(
								(
								SELECT CONCAT(', ',QUOTENAME(COLUMNNAME),'=',CHAR(39),StringValue,CHAR(39), CHAR(10))
								FROM #TMP_INSERT
								FOR XML PATH('')
								),
								1,1,'')
				
		END
		--SELECT @ColumnNames,@ColumnValues
		--RETURN
	
		
		IF @OperationType ='INSERT'
		BEGIN
			--SET @FixedColumns = 'UserCreated,DateCreated,UserModified,DateModified'
		 --   DECLARE @FixedColumnValues VARCHAR(MAX) =  CONCAT(
			--												   CHAR(39),@UserLoginID,CHAR(39),',',
			--												   CHAR(39),@UTCDATE,CHAR(39),',',
			--					  							   CHAR(39),@UserLoginID,CHAR(39),',',
			--												   CHAR(39),@UTCDATE,CHAR(39)
			--													)		 
			--SET @ColumnNames = CONCAT(@FixedColumns,',',@ColumnNames)
			--SET @ColumnValues = CONCAT(@FixedColumnValues,',',@ColumnValues)
			SET @SQL = CONCAT('INSERT INTO dbo.',@TableName,'(',@ColumnNames,') VALUES(',@ColumnValues,')')
			SET @SQL = CONCAT(@SQL,CHAR(10),';SET @EntityID = SCOPE_IDENTITY();')
			PRINT @SQL			
			EXEC sp_executesql @SQL,N'@EntityID INT OUTPUT',@EntityID OUTPUT
		END
		ELSE IF @OperationType ='UPDATE'
		BEGIN
			--SET @FixedColumns   = CONCAT('UserModified=',@UserLoginID,',DateModified=',CHAR(39),@UTCDATE,CHAR(39))
			SET @SQL = CONCAT('UPDATE dbo.',@TableName,CHAR(10),' SET ',@UpdStr)
			--SET @SQL = CONCAT(@SQL,',',CHAR(10),@FixedColumns, CHAR(10))
			SET @SQL = CONCAT(@SQL, ' WHERE ID=', @EntityID)
			PRINT @SQL
			EXEC sp_executesql @SQL	
		END		
		
		--UPDATE EntityID in dbo.FrameworkMultiselectStepItemValues-----------------------
		UPDATE FMSI
			SET EntityID = @EntityID
		FROM @TBL_FrameworkMultiselectStepItemValues TMP
			 INNER JOIN dbo.FrameworkMultiselectStepItemValues FMSI ON FMSI.ID = TMP.ID
		-----------------------------------------------------------------------------------

		--UPDATE _HISTORY TABLE-----------------------------------------
		
		DECLARE @HistoryID INT 
		
		SET @SQL = CONCAT(N'SELECT @HistoryID = MAX(HistoryID) FROM dbo.',@TableName,'_history WHERE FrameworkID = ',@FrameworkID)
		EXEC sp_executesql @SQL,N'@HistoryID INT OUTPUT',@HistoryID OUTPUT

		--UPDATE VERSION NO.
		SET @SQL = CONCAT(N'UPDATE dbo.', @TableName,'_history
			SET VersionNum = ',@VersionNum,'
		WHERE HistoryID = ',@HistoryID,';', CHAR(10), CHAR(10))			 

		--RESET PERIODIDENTIFIER FOR EARLIER VERSIONS
		SET @SQL = CONCAT(@SQL, 'UPDATE dbo.', @TableName,'_history
			SET PeriodIdentifier = 0				
		WHERE FrameworkID = ',@FrameworkID,'
			  AND VersionNum < ',@VersionNum,';', CHAR(10), CHAR(10))
		
		--UPDATE OTHER COLUMNS FOR CURRENT VERSION
		SET @SQL = CONCAT(@SQL,' UPDATE dbo.', @TableName,'_history
			SET PeriodIdentifier = ',@PeriodIdentifierID,',
				UserModified = ',@UserLoginID,',
				DateModified = GETUTCDATE(),
				OperationType = ''',@OperationType,'''
		WHERE FrameworkID = ',@FrameworkID,'
			  AND VersionNum = ',@VersionNum,';', CHAR(10), CHAR(10))
		
		--EXEC LongPrint @SQL
		EXEC sp_executesql @SQL

		-- ADD Link
		INSERT INTO EntityChildLinkFramework(UserCreated,DateCreated,LinkType,FromFrameworkId,FromEntityId,ToFrameWorkId,ToEntityid, apikey )
		Select @userid,@Utcdate,2,@SourceframeworkId,@LinkId,@Frameworkid,@EntityID , @apikey

		-----------------------------------------------------------------

		--MANAGE [dbo].[Frameworks_ExtendedValues]-------------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT 1 FROM [dbo].[Frameworks_ExtendedValues] WHERE FrameworkID = @FrameworkID AND EntityID = @EntityID AND RegisterID = @ParentEntityID)
			INSERT INTO [dbo].[Frameworks_ExtendedValues]
								   ([FrameworkID]
								   ,[EntityID]
								   ,[RegisterID]
								   ,[showAdminTab]
								   ,[loggedInUserRole]
								   ,[loggedInUserGroup]
								   ,[isModuleAdmin]
								   ,[isSystemAdmin]
								   ,[isModuleAdminGroup]
								   ,[CurrentStateowner])	
					SELECT @FrameworkID
						  ,@EntityID
						  ,@ParentEntityID
						,[showAdminTab]
						,[loggedInUserRole]
						,[loggedInUserGroup]
						,[isModuleAdmin]
						,[isSystemAdmin]
						,[isModuleAdminGroup]
						,[CurrentStateowner]
					FROM #TMP_Frameworks_ExtendedValues;
		ELSE
		    UPDATE FEV
		   SET [showAdminTab] = TMP.[showAdminTab],
			  [loggedInUserRole] = TMP.[loggedInUserRole],
			  [loggedInUserGroup] = TMP.[loggedInUserGroup],
			  [isModuleAdmin] = TMP.[isModuleAdmin],
			  [isSystemAdmin] = TMP.[isSystemAdmin],
			  [isModuleAdminGroup] = TMP.[isModuleAdminGroup],
			  [CurrentStateowner] = TMP.[CurrentStateowner]
			FROM [dbo].[Frameworks_ExtendedValues] FEV
			     INNER JOIN #TMP_Frameworks_ExtendedValues TMP ON TMP.FrameworkID = FEV.FrameworkID AND TMP.EntityID = FEV.EntityID AND FEV.RegisterID = @ParentEntityID;		 
		----------------------------------------------------------------------------------------------------------------------------------------		

		--PROCESS @SpecialInputJSON--------------------------------------
		IF ISNULL(@SpecialInputJSON,'') <> ''
			EXEC dbo.SaveSpecialInputJSON @SpecialInputJSON = @SpecialInputJSON, @UserLoginID = @UserLoginID, @MethodName = @MethodName, @LogRequest = @LogRequest
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
				
				SET @InputJSON = REPLACE(@InputJSON,'''','''''')
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=',@EntityID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,',@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID,',@Description=',CHAR(39),@Description,CHAR(39))
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			--PRINT @PARAMS
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		COMMIT

		SELECT NULL AS ErrorMessage

		SELECT @Frameworkid AS Frameworkid,@EntityID AS id , @ParentEntityID AS Registerid, @ParentEntityTypeID AS ParentEntityTypeID

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
			*/
END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;
			/*
			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'
				
				DECLARE @vEntityID VARCHAR(10) = @EntityID

				IF @EntityID IS NULL				
					SET @vEntityID = 'NULL'
				
				SET @InputJSON = REPLACE(@InputJSON,'''','''''')
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=',@vEntityID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,',@ParentEntityID=',@ParentEntityID,',@ParentEntityTypeID=',@ParentEntityTypeID,',@Description=',CHAR(39),@Description,CHAR(39))
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
			*/
END CATCH

		--DROP TEMP TABLES--------------------------------------	
		 DROP TABLE IF EXISTS #TMP_INSERT
		 DROP TABLE IF EXISTS #TMP_DATA_KEYNAME
		 DROP TABLE IF EXISTS  #TMP_INSERT
		 DROP TABLE IF EXISTS #TMP_DATA_MultiKeyName
		 DROP TABLE IF EXISTS #TMP_MULTI
		 DROP TABLE IF EXISTS #TMP_Frameworks_ExtendedValues
		 --------------------------------------------------------
END