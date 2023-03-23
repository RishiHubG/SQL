USE [ClientDemo_Dev]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************************************
OBJECT NAME:        dbo.SaveUserAccessControlledResource
CREATION DATE:      2023-03-21
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.SaveUserAccessControlledResource   @UserLoginID=100,
																@inputJSON=  ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[SaveUserAccessControlledResource]
@InputJSON VARCHAR(MAX),
@UserLoginID INT,
@EntityID INT,
@UserType VARCHAR(50),
@MethodName NVARCHAR(2000) = NULL,
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
						
		CREATE TABLE #TMP_UserAccessControlledResource(
			[AccessControlID] [int] NOT NULL,			
			[UserId] [int] NOT NULL,
			[Rights] [int] NOT NULL,
			--[Customised] [bit] NOT NULL,
			[Read] [bit] NOT NULL,
			[Modify] [bit] NOT NULL,
			[Write] [bit] NOT NULL,
			[Administrate] [bit] NOT NULL,
			[Cut] [bit] NOT NULL,
			[Copy] [bit] NOT NULL,
			[Export] [bit] NOT NULL,
			[Delete] [bit] NOT NULL,
			[Report] [bit] NOT NULL,
			[Adhoc] [bit] NOT NULL,
			[UpdateContact] [bit] NOT NULL,
			[ALL] [bit] NOT NULL,
			[username] [nvarchar](500) NULL
		)

			DECLARE @CurrentDate DATETIME2(3) =  GETUTCDATE()
			 
			 SELECT *
					INTO #TMP_ALLSTEPS
			 FROM dbo.HierarchyFromJSON(@inputJSON) 
			
			DECLARE @TBL TABLE(ID INT)

			IF @UserType = 'UserGroup'
			BEGIN

			   --EXTRACT ALL USERID's FOR THE UG 
			   INSERT INTO @TBL(ID)
				   SELECT StringValue
						--INTO #TMP_UserIDs
				   FROM #TMP_ALLSTEPS TMP
				   WHERE NAME = 'userid' 
						 AND EXISTS(SELECT 1 FROM #TMP_ALLSTEPS 
								WHERE NAME = 'INGROUP' 
									  AND StringValue = '1'
									  AND Parent_ID = TMP.Parent_ID								  
								);
				
				--BUILD UG-USER MAPPING
				SELECT * 
					INTO #TMP_UserAccessControlledResource_UG
				FROM dbo.AccessControlledResource 
					 CROSS APPLY @TBL TAB
				WHERE UserID = @EntityID

				UPDATE #TMP_UserAccessControlledResource_UG SET UserId = ID;

				INSERT INTO #TMP_UserAccessControlledResource
								   ([AccessControlID]								    
								   ,[UserId]
								   ,[Rights]								    
								   ,[Read]
								   ,[Modify]
								   ,[Write]
								   ,[Administrate]
								   ,[Cut]
								   ,[Copy]
								   ,[Export]
								   ,[Delete]
								   ,[Report]
								   ,[Adhoc]
								   ,[UpdateContact]
								   ,[ALL]
								   ,[username])
				SELECT [AccessControlID]								    
								   ,[UserId]
								   ,[Rights]								   
								   ,[Read]
								   ,[Modify]
								   ,[Write]
								   ,[Administrate]
								   ,[Cut]
								   ,[Copy]
								   ,[Export]
								   ,[Delete]
								   ,[Report]
								   ,[Adhoc]
								   ,[UpdateContact]
								   ,[ALL]
								   ,[username]
				FROM #TMP_UserAccessControlledResource_UG;

			END
			ELSE IF @UserType = 'User'
			BEGIN

				--EXTRACT ALL UG FOR THE USER
				 INSERT INTO @TBL(ID)
				   SELECT StringValue					 
				   FROM #TMP_ALLSTEPS TMP
				   WHERE NAME = 'groupid' 
						 AND EXISTS(SELECT 1 FROM #TMP_ALLSTEPS 
								WHERE NAME = 'INGROUP' 
									  AND StringValue = 'True'
									  AND Parent_ID = TMP.Parent_ID
								  
								);
				
				--BUILD UG-USER MAPPING
				SELECT *, @EntityID AS ID
					INTO #TMP_UserAccessControlledResource_User
				FROM dbo.AccessControlledResource ACR					
				WHERE EXISTS(SELECT 1 FROM @TBL WHERE ACR.UserID = ID)
				
				UPDATE #TMP_UserAccessControlledResource_User SET UserId = ID;

				INSERT INTO #TMP_UserAccessControlledResource
								   ([AccessControlID]								    
								   ,[UserId]
								   ,[Rights]								    
								   ,[Read]
								   ,[Modify]
								   ,[Write]
								   ,[Administrate]
								   ,[Cut]
								   ,[Copy]
								   ,[Export]
								   ,[Delete]
								   ,[Report]
								   ,[Adhoc]
								   ,[UpdateContact]
								   ,[ALL]
								   ,[username])
				SELECT [AccessControlID]								    
								   ,[UserId]
								   ,[Rights]								   
								   ,[Read]
								   ,[Modify]
								   ,[Write]
								   ,[Administrate]
								   ,[Cut]
								   ,[Copy]
								   ,[Export]
								   ,[Delete]
								   ,[Report]
								   ,[Adhoc]
								   ,[UpdateContact]
								   ,[ALL]
								   ,[username]
				FROM #TMP_UserAccessControlledResource_User;

			END			
				

				--SELECT * FROM #TMP_UserAccessControlledResource

				BEGIN TRAN;

				--REMOVE FROM UserAccessControlledResource IF NOT FOUND IN JSON
				DELETE UACR 
				FROM [dbo].[UserAccessControlledResource] UACR
				WHERE NOT EXISTS(SELECT 1 FROM #TMP_UserAccessControlledResource TMP WHERE UACR.AccessControlID =  TMP.AccessControlID AND UACR.UserId = TMP.UserId)

				--INSERT NEW DATA
				INSERT INTO [dbo].[UserAccessControlledResource]
								   ([AccessControlID]
								   ,[UserCreated]
								   ,[DateCreated]
								   ,[UserModified]
								   ,[DateModified]
								   ,[UserId]
								   ,[Rights]
								   ,[Customised]
								   ,[Read]
								   ,[Modify]
								   ,[Write]
								   ,[Administrate]
								   ,[Cut]
								   ,[Copy]
								   ,[Export]
								   ,[Delete]
								   ,[Report]
								   ,[Adhoc]
								   ,[UpdateContact]
								   ,[ALL]
								   ,[username])
				SELECT [AccessControlID]
								   ,@UserLoginID
								   ,@CurrentDate
								   ,@UserLoginID
								   ,@CurrentDate
								   ,[UserId]
								   ,[Rights]
								   ,0 AS [Customised]
								   ,[Read]
								   ,[Modify]
								   ,[Write]
								   ,[Administrate]
								   ,[Cut]
								   ,[Copy]
								   ,[Export]
								   ,[Delete]
								   ,[Report]
								   ,[Adhoc]
								   ,[UpdateContact]
								   ,[ALL]
								   ,[username]
				FROM #TMP_UserAccessControlledResource TMP
				WHERE NOT EXISTS(SELECT 1 FROM [dbo].[UserAccessControlledResource] WHERE AccessControlID =  TMP.AccessControlID AND UserId = TMP.UserId);

				--UPDATE EXISTING
				UPDATE UACR
				   SET [AccessControlID] = TMP.AccessControlID
					  ,[UserCreated] = @UserLoginID
					  ,[DateCreated] = @CurrentDate
					  ,[UserModified] = @UserLoginID
					  ,[DateModified] = @CurrentDate
					  ,[UserId] = TMP.UserId
					  ,[Rights] = TMP.Rights					
					  ,[Read] = TMP.[Read]
					  ,[Modify] = TMP.[Modify]
					  ,[Write] = TMP.[Write]
					  ,[Administrate] = TMP.Administrate
					  ,[Cut] = TMP.Cut
					  ,[Copy] = TMP.[Copy]
					  ,[Export] = TMP.Export
					  ,[Delete] = TMP.[Delete]
					  ,[Report] = TMP.[Report]
					  ,[Adhoc] = TMP.[Adhoc]
					  ,[UpdateContact] = TMP.[UpdateContact]
					  ,[ALL] = TMP.[ALL]
					  ,[username] = TMP.[username] 
				FROM [dbo].[UserAccessControlledResource] UACR
					  INNER JOIN #TMP_UserAccessControlledResource TMP ON TMP.AccessControlID = UACR.AccessControlID AND TMP.UserId = UACR.UserId
				WHERE UACR.Customised = 0;

				COMMIT				 

				DECLARE @Params VARCHAR(MAX)
				DECLARE @ObjectName VARCHAR(100)

				--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
				IF @LogRequest = 1
				BEGIN			

				IF @MethodName IS NOT NULL
					SET @MethodName= CONCAT(CHAR(39),@MethodName,CHAR(39))
				ELSE
					SET @MethodName = 'NULL'

						SET @Params = CONCAT('@EntityID=',@EntityID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=',@LogRequest,',@UserType=',CHAR(39),@UserType,CHAR(39))
						SET @Params = CONCAT(@Params,',@MethodName=',@MethodName)
					--PRINT @PARAMS

					SET @ObjectName = OBJECT_NAME(@@PROCID)

					EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
											 @Params = @Params,
											 @UserLoginID = @UserLoginID
				END
				------------------------------------------------------------------------------------------------------------------------------------------

				--DROP TEMP TABLES--------------------------------------	
				 DROP TABLE IF EXISTS #TMP_UserAccessControlledResource			 	 
				 --------------------------------------------------------

				-- SELECT NULL AS ErrorMessage
				

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


						SET @Params = CONCAT('@EntityID=',@EntityID,',@InputJSON=',CHAR(39),@InputJSON,CHAR(39),',@UserLoginID=',@UserLoginID,',@LogRequest=',@LogRequest,',@UserType=',CHAR(39),@UserType,CHAR(39))
						SET @Params = CONCAT(@Params,',@MethodName=',@MethodName)

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID,
									 @ErrorMessage = @ErrorMessage

			SELECT @ErrorMessage AS ErrorMessage
END CATCH
END


