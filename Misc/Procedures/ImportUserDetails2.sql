 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.[ImportUserDetails]
CREATION DATE:      2023-03-30
AUTHOR:             Rishi Nayar
DESCRIPTION:							
USAGE:          	Exec dbo.[ImportUserDetails] 
						@dataJSON=N'{"data":[{"entityType":"4","columnToCompare":"Name","dataToMap":[{"FirstName":"ABC","MiddleName":"DEF","Name":"ABCDEF","JobTitle":"CTO","E_Mail":"ABCDEF@gmail.com"},{"FirstName":"XYZ","MiddleName":"MNO","Name":"ZYZMNO","JobTitle":"DPO","E_Mail":"ZYXMNO@gmail.com"}]},{"entityType":"","columnToCompare":"","dataToMap":[{},{}]}],"fileName":"Contact.xlsx","sheetsDependency":[{"leftSheetIndex":0,"leftColumnName":"","rightSheetIndex":1,"rightColumnName":""}]}',
						@MethodName=NULL,
						@UserLoginID=2913

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ImportUserDetails2]
@DataJSON VARCHAR(MAX),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL, 
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     
	
	IF @UserID IS NOT NULL
	BEGIN

	 
	 DECLARE @Params VARCHAR(MAX),
			 @ObjectName VARCHAR(100),
			 @IsExistingTable BIT = 0,
			 @UTCDATE DATETIME2(3) = GETUTCDATE(),
			 @SQL NVARCHAR(MAX)
	DECLARE @StaticColValues VARCHAR(MAX)
	DECLARE @StaticCols VARCHAR(MAX) =	 'UserCreated, 
										 DateCreated, 
										 UserModified,
										 DateModified'
	
	SET @StaticColValues = CONCAT(@UserID,',',CHAR(39),@UTCDATE,CHAR(39),',',@UserID,',',CHAR(39),@UTCDATE,CHAR(39))
	PRINT @StaticColValues

	DROP TABLE IF EXISTS #TMP_ALLSTEPS 

	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@DataJSON); 

		--SELECT * FROM #TMP_ALLSTEPS;
	 BEGIN TRANSACTION

		--====================================================================================================================
		 --IF columnToCompare EXISTS UPDATE ELSE INSERT INTO TEMPLATETABLE_<apikey>_data PROVIDED entityType":"13","parentEntityId":-1,"parentEntityTypeId":-1
		  
			DECLARE @EntityType INT, @EntityId INT, @ParentEntityId INT, @ParentEntityTypeId INT
			SELECT @EntityType = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'entityType';
			SELECT @ParentEntityId = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'parentEntityId';
			SELECT @ParentEntityTypeId = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'ParentEntityTypeId';

			IF @EntityType = 13 AND @ParentEntityId = -1 AND @ParentEntityTypeId = -1
			BEGIN
				SELECT @EntityId = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'EntityId';
				DECLARE @apiKey NVARCHAR(4000) = (SELECT Apikey FROM dbo.CustomFormsInstance WHERE CustomFormsInstanceID=@EntityId)
				DECLARE @TableName VARCHAR(100) =  CONCAT('TemplateTable_',@apiKey,'_data')
				
				IF @TableName IS NOT NULL
				BEGIN
					DECLARE @columnToCompare VARCHAR(100)
					DECLARE @VersionNum INT
					DECLARE @AdditionalInsertColumns VARCHAR(MAX)= 'versionNum, apiKey'
					DECLARE @AdditionalInsertValues VARCHAR(MAX)

					SELECT @columnToCompare = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'columnToCompare';
					
					SET @SQL = CONCAT(' SELECT @VersionNum = ISNULL(MAX(VersionNum),0) FROM ',@TableName, CHAR(10))
					PRINT @SQL  
					EXEC sp_executesql @SQL, N'@VersionNum INT OUTPUT',@VersionNum OUTPUT;
					--SELECT @VersionNum
					SET @AdditionalInsertValues = CONCAT(@VersionNum + 1,',',CHAR(39),@apiKey,CHAR(39))
					
					IF @VersionNum = 0 SET @VersionNum = 1;

					--LIST OF ALL DATA TO PROCESS FOR INSERT/UPDATE
					SELECT @columnToCompare AS columnToCompare,TMP_Data.*
						INTO #TMP_Data
					FROM #TMP_ALLSTEPS Parent
						 INNER JOIN #TMP_ALLSTEPS Child ON Child.Parent_ID = Parent.Element_ID
						 INNER JOIN #TMP_ALLSTEPS TMP_Data ON TMP_Data.Parent_ID = Child.Element_ID 
					WHERE Parent.Name = 'dataToMap';

					SELECT Parent_ID, Name, StringValue,
						  CONCAT(' WHERE VersionNum = ',@VersionNum,CHAR(10),' AND EXISTS (SELECT 1 FROM ',@TableName, ' WHERE ',Name,'=', CHAR(39), StringValue, CHAR(39),')') AS UpdCheck,
						  CONCAT('WHERE NOT EXISTS (SELECT 1 FROM ',@TableName, ' WHERE ',Name,'=', CHAR(39), StringValue, CHAR(39),')') AS InsertCheck
						INTO #TMP_UpdAndInsertCheck
					FROM #TMP_Data
					WHERE @columnToCompare = Name;

					--BUILD UPDATE COLUMN LIST
					SELECT Parent_ID,
						   STRING_AGG(CONCAT(QUOTENAME(NAME),'=',CHAR(39),StringValue,CHAR(39)),CONCAT(',',CHAR(10))) AS UpdString 
						INTO #TMP_Update
					FROM #TMP_Data
					WHERE columnToCompare <> Name
					GROUP BY Parent_ID;

					--BUILD INSERT COLUMN LIST
					SELECT Parent_ID,
						   STRING_AGG(QUOTENAME(NAME),CONCAT(',',CHAR(10))) AS ColumnList,
						   STRING_AGG(CONCAT(CHAR(39),StringValue,CHAR(39)),CONCAT(',',CHAR(10))) AS ValuesList
						INTO #TMP_Insert
					FROM #TMP_Data					
					GROUP BY Parent_ID;

					--BUILD UPDATE STATEMENTS
					SELECT *,
							 CONCAT('UPDATE TMP ',	@TableName, ' TMP ', CHAR(10),' SET ', UpdString, CHAR(10),UpdCheck)
					FROM #TMP_Update TMP
						 INNER JOIN #TMP_UpdAndInsertCheck TMPCheck ON TMPCheck.Parent_ID = TMP.Parent_ID
					
					--BUILD INSERT STATEMENTS
					SELECT * ,
						 CONCAT('INSERT INTO ',	@TableName, ' (',@StaticCols,',',@AdditionalInsertColumns,',',ColumnList,') SELECT ',@StaticColValues,',',@AdditionalInsertValues,',',ValuesList, CHAR(10),
								InsertCheck
								)
					FROM #TMP_Insert TMP
						 INNER JOIN #TMP_UpdAndInsertCheck TMPCheck ON TMPCheck.Parent_ID = TMP.Parent_ID;

					--SELECT @TableName,@columnToCompare,* FROM #TMP_ALLSTEPS
					--ROLLBACK
					--RETURN
				END

			END				 
		--====================================================================================================================

			SELECT '' AS ErrorMessage

			COMMIT
		

		END		--END OF USER PERMISSION CHECK
		 ELSE IF @UserID IS NULL
			SELECT 'User Session has expired, Please re-login' AS ErrorMessage
END TRY
BEGIN CATCH
	
		IF @@TRANCOUNT = 1 AND XACT_STATE() <> 0
			ROLLBACK;

			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
			DECLARE @Error INT = ERROR_line()

			IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@DataJSON=',CHAR(39),@DataJSON,CHAR(39),',@UserLoginID=',@UserLoginID)
			SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage,@Error AS Errorline
END CATCH

		--DROP TEMP TABLES--------------------------------------
		 DROP TABLE IF EXISTS #TMP_Objects
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS
		 DROP TABLE IF EXISTS #TMP_DATA
		 DROP TABLE IF EXISTS #TMP_DATA_DAY
		 DROP TABLE IF EXISTS #TMP_DATA_DOT 
		 DROP TABLE IF EXISTS #TMP
		 DROP TABLE IF EXISTS #TMP_Lookups
		 --------------------------------------------------------
END
