SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/***************************************************************************************************
OBJECT NAME:        dbo.SaveFrameworkJSONData
CREATION DATE:      2022-02-06
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveFilterExpression @inputJSON = ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[SaveFilterExpression]
@InputJSON VARCHAR(MAX),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL,
@LogRequest BIT
AS
BEGIN
BEGIN TRY
	
	DECLARE @UserID INT
		
	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     
	
	IF @UserID IS NOT NULL
	BEGIN

	DECLARE @FrameworkID INT, @ParentEntityId INT, @ParentEntityTypeId INT, @TblName VARCHAR(MAX)
	DECLARE @RoleSQL VARCHAR(MAX) = 'EXISTS (SELECT 1 FROM dbo.RoleType RT INNER JOIN dbo.ContactInst CI ON CI.RoleTypeID = RT.RoleTypeID WHERE RT.name'	
	DECLARE @RegisterSQL VARCHAR(MAX) = 'EXISTS (SELECT 1 FROM dbo.Registers WHERE Name'
	DECLARE @UniverseSQL VARCHAR(MAX) = 'EXISTS (SELECT 1 FROM dbo.Universe WHERE Name'

	SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON) 

	-- SELECT * FROM #TMP_ALLSTEPS

	 SELECT @ParentEntityId = StringValue FROM #TMP_ALLSTEPS  WHERE NAME = 'ParentEntityId'
	 SELECT @ParentEntityTypeId = StringValue FROM #TMP_ALLSTEPS  WHERE NAME = 'ParentEntityTypeId'
	 
	 IF @ParentEntityTypeId = 3 --REGISTER
		SELECT @FrameworkID = FrameWorkID FROM dbo.Registers WHERE RegisterID = @ParentEntityId
	ELSE IF @ParentEntityTypeId = 1 --FRAMEWORK
		SET @FrameworkID = @ParentEntityId

	SELECT @TblName = Name FROM dbo.Frameworks WHERE FrameworkID = @FrameworkID

	IF @TblName IS NOT NULL
		SET @TblName = CONCAT('dbo.',@TblName,'_data')
	ELSE
		Raiserror('Table Not Found!',16,1);

	--SELECT @TblName
	 --RETURN

	 ;WITH CTE_FiltersData
			AS
			(		
				SELECT T.Element_ID,
					   T.Name AS ColumnName, 
					   T.Parent_ID,	   
					   T.StringValue,
					   T.ValueType
				 FROM #TMP_ALLSTEPS T			  
				 WHERE Name ='filtersData'

				 UNION ALL

				 SELECT T.Element_ID,
					   T.Name, 
					   T.Parent_ID,			   
					   T.StringValue,
					   T.ValueType
				 FROM CTE_FiltersData C
					  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
		
			)

			SELECT * 
				INTO #TMP_FiltersData
			FROM CTE_FiltersData --WHERE ValueType ='boolean' AND  StringValue = 'true'

			--SELECT * FROM #TMP_FiltersData ORDER BY ELEMENT_ID--WHERE ColumnName IN ('colKey','conditionId','value1','value2') ORDER BY Element_ID

			SELECT Parent_ID,
				   MAX(CASE WHEN ColumnName = 'colKey' THEN StringValue END) AS colKey,
				   MAX(CASE WHEN ColumnName = 'conditionId' THEN StringValue END) AS conditionId,
				   MAX(CASE WHEN ColumnName = 'value1' THEN StringValue END) AS value1,
				   MAX(CASE WHEN ColumnName = 'value2' THEN StringValue END) AS value2,
				   CAST(NULL AS VARCHAR(50)) AS MatchCondition,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType2
				INTO #TMP_FiltersWithMatchCondition
			FROM #TMP_FiltersData
			--WHERE StringValue IS NOT NULL
			--	  AND StringValue <> 'all'
			GROUP BY Parent_ID

			DELETE FROM #TMP_FiltersWithMatchCondition
			WHERE colKey IS NULL
				  OR colKey IN ('any','all')

			DECLARE @matchCondition VARCHAR(10) = (SELECT CASE WHEN StringValue = -200 THEN 'AND' ELSE 'OR' END FROM #TMP_FiltersData WHERE ColumnName ='matchCondition')
			--SELECT @matchCondition

			UPDATE #TMP_FiltersWithMatchCondition SET MatchCondition = @matchCondition
					 
			--DELETE FROM #TMP_FiltersWithMatchCondition WHERE (colKey IS NULL OR colKey IN ('any','all'))

			--SELECT * FROM #TMP_FiltersWithMatchCondition

			--SELECT Parent_ID							
			--FROM #TMP_FiltersData TMP
			--	 CROSS APPLY (
			--					SELECT StringValue
			--					FROM #TMP_FiltersData 
			--					WHERE Parent_ID = TMP.Parent_ID
			--						  AND 
				 
			--				)
			--WHERE ColumnName IN ('colKey','conditionId','value1','value2') 
			--GROUP BY Parent_ID
			 

		DROP TABLE IF EXISTS #TMP_ItemsWithMatchCondition
		DROP TABLE IF EXISTS #TMP_CTE_ItemsFiltersData

		--THESE ARE CHILD CONDITIONS
		;WITH CTE_ItemsFiltersData
			AS
			(		
				SELECT T.Element_ID,
					   T.ColumnName, 
					   T.Parent_ID,	   
					   T.StringValue,
					   T.ValueType,
					  --CAST(ROW_NUMBER()OVER(PARTITION BY Parent_ID ORDER BY Element_ID) AS VARCHAR(MAX)) AS Path,
					  CAST('' AS VARCHAR(MAX)) AS Parents
				 FROM #TMP_FiltersData T			  
				 WHERE ColumnName ='items'

				 UNION ALL

				 SELECT T.Element_ID,
					   T.ColumnName, 
					   T.Parent_ID,			   
					   T.StringValue,
					   T.ValueType,
					  -- CAST(CONCAT(C.Path ,'.' , ROW_NUMBER()OVER(PARTITION BY T.Parent_ID ORDER BY T.Element_ID)) AS VARCHAR(MAX)),
					   CAST(CASE WHEN C.Parents = ''
							THEN(CAST(T.Parent_ID AS VARCHAR(MAX)))
							ELSE(C.Parents + '.' + CAST(T.Parent_ID AS VARCHAR(MAX)))
					   END AS VARCHAR(MAX))
				 FROM CTE_ItemsFiltersData C
					  INNER JOIN #TMP_FiltersData T ON T.Parent_ID = C.Element_ID
		
			)

			--SELECT *				 
			--FROM CTE_ItemsFiltersData ORDER BY Element_ID
			--RETURN
			SELECT DISTINCT *, CAST(NULL AS VARCHAR(50)) AS MatchCondition
				INTO #TMP_CTE_ItemsFiltersData
			FROM CTE_ItemsFiltersData 
			 

			--SELECT * FROM #TMP_CTE_ItemsFiltersData WHERE ColumnName NOT LIKE '%[^0-9]%' ORDER BY Element_ID
			
			--UPDATE THE BOOLEAN CONDITION BETWEEN FILTERS
			UPDATE TMP 
				SET MatchCondition = CASE TF2.StringValue
										WHEN -200 THEN 'AND'
										WHEN -100 THEN 'OR' 
									  END
			FROM #TMP_CTE_ItemsFiltersData TMP
				 INNER JOIN #TMP_FiltersData TF1 ON TF1.Element_ID = TMP.Parent_ID
				 INNER JOIN #TMP_FiltersData TF2 ON TF2.Parent_ID = TF1.Parent_ID
			WHERE TMP.ColumnName NOT LIKE '%[^0-9]%' 
				  AND TF2.ColumnName = 'columnId'
				  AND TF1.ColumnName = 'items'
			
			--SELECT * FROM #TMP_CTE_ItemsFiltersData WHERE ColumnName NOT LIKE '%[^0-9]%' ORDER BY Element_ID
			--RETURN

			--WRITING CROSS TAB/PIVOT QUERY
			SELECT Parent_ID,
				   MAX(CASE WHEN ColumnName = 'colKey' THEN StringValue END) AS colKey,
				   --MAX(CASE WHEN ColumnName = 'columnId' THEN StringValue END) AS columnId,
				   MAX(CASE WHEN ColumnName = 'conditionId' THEN StringValue END) AS conditionId,
				   MAX(CASE WHEN ColumnName = 'value1' THEN StringValue END) AS value1,
				   MAX(CASE WHEN ColumnName = 'value2' THEN StringValue END) AS value2,
				   CAST(NULL AS VARCHAR(50)) AS MatchCondition,
				   CAST(NULL AS INT) AS ItemID,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType2,
				   CAST(NULL AS VARCHAR(50)) AS ParentMatchCondition,
				   --CAST(NULL AS VARCHAR(MAX)) AS Path,
				   CAST(NULL AS VARCHAR(MAX)) AS Parents
				INTO #TMP_ItemsWithMatchCondition
			FROM #TMP_CTE_ItemsFiltersData
			--WHERE StringValue IS NOT NULL
			--	  AND StringValue <> 'all'
			GROUP BY Parent_ID

			DELETE FROM #TMP_ItemsWithMatchCondition WHERE (colKey IS NULL OR colKey IN ('any','all'))

			--SELECT @matchCondition = CASE WHEN StringValue = -200 THEN 'AND' ELSE 'OR' END FROM #TMP_FiltersData WHERE ColumnName ='matchCondition'

			--UPDATE #TMP_ItemsWithMatchCondition SET ParentMatchCondition = @matchCondition

			--SELECT * FROM #TMP_ItemsWithMatchCondition
			--RETURN
			--SELECT * FROM #TMP_FiltersData WHERE Element_ID IN (112,113)
			--SELECT * FROM #TMP_FiltersData WHERE Element_ID IN (88)

			DROP TABLE IF EXISTS #TMP_Items

			SELECT TMC.Parent_ID, 
				   T4.StringValue,
				   CASE WHEN T4.StringValue = -200 THEN 'AND' ELSE 'OR' END AS MatchCondition,
				   T4.Parent_ID AS ItemID,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType
				INTO #TMP_Items
			FROM #TMP_ItemsWithMatchCondition TMC
				 INNER JOIN #TMP_FiltersData T2 ON T2.Element_ID = TMC.Parent_ID
				 INNER JOIN #TMP_FiltersData T3 ON T3.Element_ID = T2.Parent_ID
				 INNER JOIN #TMP_FiltersData T4 ON T4.Parent_ID = T3.Parent_ID
			WHERE T4.ColumnName = 'columnId'

			--SELECT * FROM #TMP_Items
			--RETURN
			UPDATE TMP
				SET MatchCondition = TI.MatchCondition,
					ItemID = TI.ItemID					
			FROM #TMP_ItemsWithMatchCondition TMP
				 INNER JOIN #TMP_Items TI ON TI.Parent_ID = TMP.Parent_ID

			UPDATE TMP
				SET OperatorType = FCM.OperatorType					 		
			FROM #TMP_ItemsWithMatchCondition TMP
				 INNER JOIN dbo.Filterconditions_Master FCM ON FCM.FilterTypeID = TMP.conditionId
			WHERE FCM.Active = 1

			UPDATE TMP
				SET OperatorType = FCM.OperatorType					 		
			FROM #TMP_FiltersWithMatchCondition TMP
				 INNER JOIN dbo.Filterconditions_Master FCM ON FCM.FilterTypeID = TMP.conditionId
			WHERE FCM.Active = 1

			DELETE TMP FROM #TMP_FiltersWithMatchCondition TMP
			WHERE EXISTS(SELECT 1 FROM #TMP_ItemsWithMatchCondition WHERE Parent_ID = TMP.Parent_ID)

			--NEED SINGLE QUOTES FOR DATE OPERATIONS-------------------------------
			--UPDATE #TMP_FiltersWithMatchCondition 
			--	SET value1 = CONCAT(CHAR(39),value1,CHAR(39)),
			--		value2 = CASE WHEN ISNULL(value2,'')<>'' THEN CONCAT(CHAR(39),value2,CHAR(39)) ELSE value2 END
			--WHERE OperatorType IN ('Between','Not Between','<','<=','>','>=')			
			------------------------------------------------------------------------
			
			--REPLACE <COLVALUE>,<COLNAME> WITH ACTUAL VALUE--------------------------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			---------------------------------------------------------------------------------------------------------

			--UPDATE FOR OperatorType2 FOR BETWEEN----------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition 
				SET OperatorType2 = 'AND'
			WHERE OperatorType IN ('Between','Not Between')						
			-------------------------------------------------------------------------------
			
			--;WITH CTE 
			--AS(
			--SELECT *,
			--	  ROW_NUMBER()OVER(PARTITION BY Element_ID ORDER BY ELEMENT_ID, Path DESC) AS ROWNUM
			--FROM #TMP_CTE_ItemsFiltersData
			--)

			--DELETE FROM CTE WHERE ROWNUM > 1

			UPDATE TMP
				SET Parents = CTE.Parents
					--Path = CTE.Path
			FROM #TMP_ItemsWithMatchCondition TMP
				 INNER JOIN #TMP_CTE_ItemsFiltersData CTE ON CTE.StringValue = TMP.colKey AND CTE.Parent_ID = TMP.Parent_ID
			WHERE CTE.ColumnName='colKey'		

			--MAKING colKey EMPTY IN CASE COLUMN IS USED WITHIN OPERATOR EX. ISNULL(COLUMN,1)
			UPDATE #TMP_FiltersWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'

			--UPDATE FOR OperatorType2 FOR BETWEEN----------------------------------------
			UPDATE #TMP_ItemsWithMatchCondition 
				SET OperatorType2 = 'AND'
			WHERE OperatorType IN ('Between','Not Between')						
			-------------------------------------------------------------------------------
			
			--SELECT * FROM #TMP_FiltersWithMatchCondition
			--IF ItemID(THIS IS THE IMMEDIATE PARENTID OF THE ELEMENT) IS ALSO PART OF "PARENTS" THEN THOSE ELEMENTS ARE PART OF THE SAME HIERARCHY
			--SELECT * FROM #TMP_ItemsWithMatchCondition
			--RETURN
			--SELECT * FROM #TMP_CTE_ItemsFiltersData WHERE ColumnName='colKey' AND StringValue='controlfrequency' AND Parent_ID=179 ORDER BY Element_ID
		  

			--SELECT CONCAT(colKey,CHAR(32),OperatorType,CHAR(32),value1, CHAR(32),OperatorType2,CHAR(32), value2) 
			--FROM #TMP_FiltersWithMatchCondition
		
			--SINGLE QUOTES FOR STRING--------------------------------------------------------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition SET value1 = CONCAT(CHAR(39),value1, CHAR(39)) WHERE ISNULL(value1,'')!='' --value1 LIKE '%[^0-9]%'
			UPDATE #TMP_FiltersWithMatchCondition SET value2 = CONCAT(CHAR(39),value2, CHAR(39)) WHERE ISNULL(value2,'')!='' --value2 LIKE '%[^0-9]%'

			UPDATE #TMP_ItemsWithMatchCondition SET value1 = CONCAT(CHAR(39),value1, CHAR(39)) WHERE ISNULL(value1,'')!='' --value1 LIKE '%[^0-9]%'
			UPDATE #TMP_ItemsWithMatchCondition SET value2 = CONCAT(CHAR(39),value2, CHAR(39)) WHERE ISNULL(value2,'')!='' --value2 LIKE '%[^0-9]%'
			--UPDATE #TMP_FiltersWithMatchCondition
			--	SET value1 = CONCAT(CHAR(39),value1,CHAR(39)),
			--		value2 = CASE WHEN ISNULL(value2,'') <> ''  THEN CONCAT(CHAR(39),value2,CHAR(39)) ELSE value2 END
			--WHERE colKey LIKE '%Date%' --IN (('Between','Not Between','>','>=',,'<','<=')
			
			--UPDATE #TMP_ItemsWithMatchCondition
			--	SET value1 = CONCAT(CHAR(39),value1,CHAR(39)),
			--		value2 = CASE WHEN ISNULL(value2,'') <> ''  THEN CONCAT(CHAR(39),value2,CHAR(39)) ELSE value2 END
			--WHERE colKey LIKE '%Date%' --IN (('Between','Not Between','>','>=',,'<','<=')			
			-----------------------------------------------------------------------------------------------------------------
		
			DROP TABLE IF EXISTS #TMP_FilterItems
			DROP TABLE IF EXISTS #TMP_JoinStmt

			--CONDITIONS FOR Role,Register,Universe============================================================
			UPDATE #TMP_ItemsWithMatchCondition
				SET ColKey = REPLACE(ColKey,'Role', @RoleSQL),
					OperatorType = CONCAT(OperatorType,')') -- ADDING THE LAST BRACKET FOR EXISTS CLAUSE
			WHERE ColKey = 'Role'

			UPDATE #TMP_ItemsWithMatchCondition
				SET ColKey = REPLACE(ColKey,'Universe', @UniverseSQL),
					OperatorType = CONCAT(OperatorType,')') -- ADDING THE LAST BRACKET FOR EXISTS CLAUSE
			WHERE ColKey = 'Universe'

			UPDATE #TMP_ItemsWithMatchCondition
				SET ColKey = REPLACE(ColKey,'Register', @RegisterSQL),
					OperatorType = CONCAT(OperatorType,')') -- ADDING THE LAST BRACKET FOR EXISTS CLAUSE
			WHERE ColKey = 'Register'

			UPDATE #TMP_FiltersWithMatchCondition
				SET ColKey = REPLACE(ColKey,'Role', @RoleSQL),
					OperatorType = CONCAT(OperatorType,')') -- ADDING THE LAST BRACKET FOR EXISTS CLAUSE
			WHERE ColKey = 'Role'

			UPDATE #TMP_FiltersWithMatchCondition
				SET ColKey = REPLACE(ColKey,'Universe', @UniverseSQL),
					OperatorType = CONCAT(OperatorType,')') -- ADDING THE LAST BRACKET FOR EXISTS CLAUSE
			WHERE ColKey = 'Universe'

			UPDATE #TMP_FiltersWithMatchCondition
				SET ColKey = REPLACE(ColKey,'Register', @RegisterSQL),
					OperatorType = CONCAT(OperatorType,')') -- ADDING THE LAST BRACKET FOR EXISTS CLAUSE
			WHERE ColKey = 'Register'
			--=====================================================================================================

			SELECT ItemID, MatchCondition, CONCAT(colKey,CHAR(32),OperatorType,CHAR(32),value1, CHAR(32),OperatorType2,CHAR(32), value2) AS ColName, 
				   Parents
				INTO #TMP_FilterItems
			FROM #TMP_ItemsWithMatchCondition			

			
			--SELECT * FROM #TMP_ItemsWithMatchCondition
			--RETURN
			SELECT 
			ItemID,
			STUFF((
			SELECT  CONCAT(' ',MatchCondition,CHAR(10),ColName)
			FROM #TMP_FilterItems 
			WHERE ItemID = TMP.ItemID			
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,1,'') AS JoinString,
			MAX(Parents) AS Parents,
			MAX(MatchCondition) AS MatchCondition
			--(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'ID') AS ContactID,
			--(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'Role') AS RoleTypeID
			INTO #TMP_JoinStmt	
		FROM #TMP_FilterItems TMP
		GROUP BY ItemID

		--REPLACING THE 1ST AND/OR WITH EMPTY STRING
		UPDATE #TMP_JoinStmt SET JoinString = CONCAT('(',STUFF(JoinString,1,3,''),')')

		ALTER TABLE #TMP_JoinStmt ADD JoinCondition VARCHAR(50),GroupID INT

		--IF ItemID(THIS IS THE IMMEDIATE PARENTID OF THE ELEMENT) IS ALSO PART OF "PARENTS" THEN THOSE ELEMENTS ARE PART OF THE SAME HIERARCHY
		UPDATE TMP
			SET GroupID = ISNULL(TAB.ItemID,TMP.ItemID),
				JoinCondition = ISNULL(TAB.MatchCondition,TMP.MatchCondition)
		FROM #TMP_JoinStmt TMP
			 OUTER APPLY (	
							SELECT ItemID, MatchCondition
							FROM #TMP_JoinStmt
							WHERE TMP.Parents LIKE CONCAT('%',ItemID,'%')								   
						 )TAB

		--SELECT * FROM #TMP_JoinStmt

		DROP TABLE IF EXISTS #TMP_FinalItemsJoin
		DROP TABLE IF EXISTS #TMP_FinalFiltersWithMatchConditionJoin

		--CONCATENATE NON-CHILD FILTERS
		SELECT 	DISTINCT		
			STUFF((
			--SELECT  CONCAT(' (',colKey,CHAR(10),OperatorType,CHAR(10),')')
			SELECT CONCAT(' (',colKey,CHAR(32),OperatorType,CHAR(32),value1, CHAR(32),OperatorType2,CHAR(32), value2,')')
			FROM #TMP_FiltersWithMatchCondition 
			WHERE TMP.Parent_ID = Parent_ID
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,1,'') AS JoinString
			INTO #TMP_FinalFiltersWithMatchConditionJoin
		FROM #TMP_FiltersWithMatchCondition TMP	
		
		--SELECT * FROM #TMP_FinalFiltersWithMatchConditionJoin

		--GET GROUPS WITH MORE THAN 1 RECORD, SO AS TO CLUB THEM TOGETHER
		SELECT 
			GroupID,
			STUFF((
			SELECT  CONCAT(' ',JoinCondition,CHAR(10),JoinString,CHAR(10))
			FROM #TMP_JoinStmt 
			WHERE GroupID = TMP.GroupID			
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,1,'') AS JoinString
			INTO #TMP_FinalItemsJoin
		FROM #TMP_JoinStmt TMP
		GROUP BY GroupID
		HAVING COUNT(*)>1

		--REPLACING THE 1ST AND/OR WITH EMPTY STRING
		UPDATE #TMP_FinalItemsJoin SET JoinString = CONCAT('(',STUFF(JoinString,1,3,''),')')

		--SELECT STRING_AGG(JoinString,@matchCondition)
		--FROM
		--(

		DROP TABLE IF EXISTS #TMP

		--CLUB TOGETHER ALL FILTER CONDITIONS
		SELECT 1 AS NUM, JoinString		
			INTO #TMP
		FROM #TMP_FinalFiltersWithMatchConditionJoin
		UNION
		SELECT 2 AS NUM,JoinString
		FROM #TMP_JoinStmt TMP --#TMP_FiltersWithMatchCondition
		WHERE NOT EXISTS(SELECT 1 FROM #TMP_FinalItemsJoin WHERE GroupID = TMP.GroupID)		
		UNION
		SELECT 3,JoinString FROM #TMP_FinalItemsJoin		 
		ORDER BY NUM
		
		ALTER TABLE #TMP ADD ID INT IDENTITY(1,1) PRIMARY KEY

		--SELECT * FROM #TMP

		SET @matchCondition =  CONCAT(' ',@matchCondition,' ')
		
		DECLARE @QueryCondition VARCHAR(MAX),@SQL VARCHAR(MAX)

		SELECT @QueryCondition = STRING_AGG(JoinString,@matchCondition)
		FROM #TMP
		
		--PRINT @QueryCondition

		SET @SQL = CONCAT('SELECT * FROM ',@TblName,' WHERE ',CHAR(10),@QueryCondition)
		PRINT @SQL

		--EXEC(@SQL)

		IF @TblName IS NOT NULL
		BEGIN
			IF EXISTS(SELECT 1 FROM sys.dm_exec_describe_first_result_set(@SQL,NULL, 0) WHERE error_message IS NOT NULL)
				Raiserror('Error in Filter Query!',16,1);
		ELSE			
			INSERT INTO dbo.FilterExpression (RegisterID, InputJSON, FilterExpression)
				SELECT @ParentEntityId,@InputJSON, @SQL;
		 END

	--DROP TEMP TABLES---------------------------------------------
		DROP TABLE IF EXISTS #TMP_ALLSTEPS
		DROP TABLE IF EXISTS #TMP_FiltersData
		DROP TABLE IF EXISTS #TMP_FiltersWithMatchCondition
		DROP TABLE IF EXISTS #TMP_JoinStmt
		DROP TABLE IF EXISTS #TMP_FinalItemsJoin
		DROP TABLE IF EXISTS #TMP_FinalFiltersWithMatchConditionJoin
	----------------------------------------------------------------

	
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
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=')
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			--PRINT @PARAMS
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------
				
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

				SET @InputJSON = REPLACE(@InputJSON,'''','''''')
				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=')
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
END CATCH

END		 