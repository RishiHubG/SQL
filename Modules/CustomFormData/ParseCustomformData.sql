USE [agsqa]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.ParseCustomformData
CREATION DATE:      2020-11-27
AUTHOR:             Rishi Nayar
DESCRIPTION:		

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[ParseCustomformData]
@Name VARCHAR(100),
@InputJSON VARCHAR(MAX),
@FullSchemaJSON VARCHAR(MAX),
@UserLoginID INT,
@MethodName NVARCHAR(200)=NULL, 
@LogRequest BIT = 1,
@Entitytypeid int,
@Description nvarchar(max),
@Entityid int
AS
BEGIN
BEGIN TRY


	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @UserID INT,
		     @Params VARCHAR(MAX),
			 @ObjectName VARCHAR(100)
	Declare @customformid INT = (select CustomFormID from CustomForms where EntityTypeid = @Entitytypeid)

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     

	IF @UserID IS NOT NULL
	BEGIN

	--BEGIN TRAN

	IF @Entityid = -1
	Begin
		
		Declare @ID INT

		Insert into dbo.CustomFormsInstance (CustomFormID,UserCreated,DateCreated,UserModified,DateModified,VersionNum,FullSchemaJSON,Name,Description,CustomFormsFile)
			select @customformid,@userid,GETUTCDATE(),@userid,GETUTCDATE(),1,@FullSchemaJSON,@Name,@Description,@InputJSON

		SET @ID = SCOPE_IDENTITY()
		
	END
	ELSE
	BEGIN
		
		UPDATE dbo.CustomFormsInstance
			SET FullSchemaJSON = @FullSchemaJSON,
				Name = @Name,
				Description = @Description,
				CustomFormsFile = @InputJSON,
				UserModified = @userid,
				DateModified = GETUTCDATE()
		WHERE ID = @Entityid

	END

		EXEC dbo.ParseTableJSONData @Name = @Name, @Entityid = @Entityid, @UserLoginID = @UserLoginID, @InputJSON = @InputJSON, @FullSchemaJSON = @FullSchemaJSON,
									@FrameworkID = @FrameworkID, @TableID = @ID

	--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		IF @LogRequest = 1
		BEGIN			
			 
				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=',@EntityID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39),',@Name=',CHAR(39),@Name,CHAR(39),',@Description=',CHAR(39),@Description,CHAR(39))
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		--COMMIT

		SELECT NULL AS ErrorMessage
		SELECT @id id

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

				SET @Params = CONCAT('@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@EntityID=',@EntityID,',@EntityTypeID=',@EntityTypeID)
				SET @Params = CONCAT(@Params,',@FullSchemaJSON=',CHAR(39),@FullSchemaJSON,CHAR(39),',@Name=',CHAR(39),@Name,CHAR(39),',@Description=',CHAR(39),@Description,CHAR(39))
				SET @Params = CONCAT(@Params,',@MethodName=',@MethodName,',@LogRequest=',@LogRequest)
			
			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage
				
			SELECT @ErrorMessage AS ErrorMessage
END CATCH

 END