USE AGSQA
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetTemplateTableData
CREATION DATE:      2021-10-24
AUTHOR:             Rishi Nayar
DESCRIPTION:		
					
USAGE:
CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.GetTemplateTableData
@EntityID INT,
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL, 
@LogRequest BIT = 1
AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;

	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     

	IF @UserID IS NOT NULL
	BEGIN

	 
	 DECLARE @Params VARCHAR(MAX),
			 @ObjectName VARCHAR(100),
			 @TableName SYSNAME,
		     @SQL NVARCHAR(MAX)

	 SELECT @TableName = CONCAT('[TemplateTable_', [Name],'_data]')		   
	 FROM CustomFormsInstance WHERE ID = @Entityid
	
	 IF @TableName IS NULL
	 BEGIN
		PRINT 'TEMPLATE TABLE NOT FOUND!!'
		RETURN
	 END
	 	 
		SET @SQL = CONCAT('SELECT * FROM ',@TableName)		
		EXEC sp_executesql @SQL		  
  
		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@Entityid=',@Entityid,',@UserLoginID=',@UserLoginID)			
			SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
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
	
		 
			DECLARE @ErrorMessage VARCHAR(MAX)= ERROR_MESSAGE()
			IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

			SET @Params = CONCAT('@Entityid=',@Entityid,',@UserLoginID=',@UserLoginID)			
			SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
			
			SELECT @ErrorMessage AS ErrorMessage
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