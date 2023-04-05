 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ImportDataForEntity
CREATION DATE:      2022-12-07
AUTHOR:             Rishi Nayar
DESCRIPTION:							
USAGE:          	Exec dbo.ImportDataForEntity 
						@dataJSON=N'{"data":[{"entityType":"4","columnToCompare":"Name","dataToMap":[{"FirstName":"ABC","MiddleName":"DEF","Name":"ABCDEF","JobTitle":"CTO","E_Mail":"ABCDEF@gmail.com"},{"FirstName":"XYZ","MiddleName":"MNO","Name":"ZYZMNO","JobTitle":"DPO","E_Mail":"ZYXMNO@gmail.com"}]},{"entityType":"","columnToCompare":"","dataToMap":[{},{}]}],"fileName":"Contact.xlsx","sheetsDependency":[{"leftSheetIndex":0,"leftColumnName":"","rightSheetIndex":1,"rightColumnName":""}]}',
						@MethodName=NULL,
						@UserLoginID=2913

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ImportDataForEntity]
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
			 @ObjectName VARCHAR(100) 

	DROP TABLE IF EXISTS #TMP_ALLSTEPS 

	 SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@DataJSON); 
	
	DECLARE @EntityType INT, @EntityId INT, @ParentEntityId INT, @ParentEntityTypeId INT
	SELECT @EntityType = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'entityType';
	SELECT @ParentEntityId = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'parentEntityId';
	SELECT @ParentEntityTypeId = StringValue FROM #TMP_ALLSTEPS WHERE NAME = 'ParentEntityTypeId';

	IF @entityType = 4
	BEGIN
		EXEC dbo.[ImportUserDetails] @DataJSON = @DataJSON, @UserLoginID = @UserLoginID, @MethodName = @MethodName, @LogRequest = @LogRequest
	END
	ELSE IF @EntityType = 13 AND @ParentEntityId = -1 AND @ParentEntityTypeId = -1
	BEGIN
		EXEC dbo.[TableTemplateMetaDataImport] @DataJSON = @DataJSON, @UserLoginID = @UserLoginID, @MethodName = @MethodName, @LogRequest = @LogRequest
	END

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
		 DROP TABLE IF EXISTS #TMP_ALLSTEPS	
		 --------------------------------------------------------
END
