SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetUniverseDetails
CREATION DATE:      2020-12-18
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.GetUniverseDetails
@EntityID INT,
@EntityTypeID VARCHAR(100),
@ParentEntityID INT = NULL,
@ParentEntityType VARCHAR(100),
@UserLoginID INT,
@MethodName VARCHAR(100),
@Frameworkid INT = NULL
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE @UserID INT

	EXEC dbo.CheckUserPermission @UserLoginID = @UserLoginID,
								 @MethodName = @MethodName,
								 @UserID = @UserID	OUTPUT							     

	IF @UserID IS NOT NULL
	BEGIN

	DECLARE @AccessControlID INT
	
	SELECT @UserID AS userid,* 
		INTO #TMP_Universe
	FROM dbo.Universe 
	WHERE UniverseID = @EntityID

	SELECT @AccessControlID = AccessControlID
	FROM #TMP_Universe

	SELECT formjson,
		   @EntityTypeID AS entityid,
		   @EntityID AS entityid
	FROM dbo.EntityAdminForm 
	WHERE EntitytypeId = @EntityTypeID		

	--Universe Details
	SELECT @UserID AS userid,* 
	FROM dbo.Universe
	WHERE UniverseID = @EntityID

	--Universe Extended Properties
	SELECT * 	
	FROM dbo.UniverseProperties
	WHERE UniverseID = @EntityID

	--SubEntityCounts-----------------------------------
	DECLARE @SubUniverseCount INT,
		    @RegisterCount INT

	SELECT @SubUniverseCount = COUNT(*) 
	FROM dbo.Universe 
	WHERE ParentID = @EntityID

	SELECT @RegisterCount = COUNT(*) 
	FROM dbo.Registers 
	WHERE UniverseID = @EntityID

	SELECT entitytypeid,
		   0 AS entityid,
		   PluralName AS entityname,
		   CAST(NULL AS INT) AS [count]
		INTO #TMP_SubEntityCounts
	FROM dbo.EntityMetaData

	UPDATE #TMP_SubEntityCounts
		SET [Count] = @SubUniverseCount
	WHERE entityname = 'Sub Universe'

	UPDATE #TMP_SubEntityCounts
		SET [Count] = @RegisterCount
	WHERE entityname = 'Registers'

	SELECT entitytypeid,
		   entityid,
		   entityname.
		   [count]
	FROM #TMP_SubEntityCounts
	----------------------------------------------------	 
	
	--userrights
	SELECT @userid AS userid,ASU.Name AS username,
		   [read],[modify],write,cut,[copy],[delete],administrate,adhoc,export,report,Customised AS iscustomised
	FROM dbo.AccessControlledResource AC
	     INNER JOIN dbo.AUser ASU ON ASU.UserId = AC.UserId
	WHERE asu.UserID = @UserID

	--DomainPermissions
	SELECT @userid AS userid,ASU.Name AS username,
		   [read],[modify],write,cut,[copy],[delete],administrate,adhoc,export,report,Customised AS iscustomised
	FROM dbo.AccessControlledResource AC
	     INNER JOIN dbo.AUser ASU ON ASU.UserId = AC.UserId		
	WHERE AC.AccessControlID = @AccessControlID		  
		  AND AC.Customised = 1

	END		--END OF USER PERMISSION CHECK
	ELSE IF @UserID IS NULL
		SELECT 'User Session has expired, Please re-login' AS ErrorMessage

	
	 --INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		DECLARE @LogRequest BIT = 1

		 IF @LogRequest = 1
		BEGIN		
			DECLARE @vEntityID VARCHAR(20)='NULL'
			DECLARE @vParentEntityID VARCHAR(20)='NULL'
			DECLARE @Params VARCHAR(MAX),
				    @ObjectName VARCHAR(100)

			IF @EntityID IS NOT NULL SET @vEntityID = @EntityID
			IF @ParentEntityID IS NOT NULL SET @vParentEntityID = @ParentEntityID
		 
			SET @Params = CONCAT('@EntityID=',@vEntityID,',@EntityTypeID=',CHAR(39),@EntityTypeID,CHAR(39),',@ParentEntityID=',@vParentEntityID)
			SET @Params = CONCAT(@Params,',@ParentEntityType=', CHAR(39),@ParentEntityType, CHAR(39),',@UserLoginID=',@UserLoginID,',@MethodName=',CHAR(39),@MethodName, CHAR(39))
			SET @Params = CONCAT(@Params,',@LogRequest=1')

			SET @ObjectName = OBJECT_NAME(@@PROCID)

			--PRINT @PARAMS
			EXEC dbo.InsertObjectLog @ObjectName=@ObjectName,
									 @Params = @Params,
									 @UserLoginID = @UserLoginID
		END
		------------------------------------------------------------------------------------------------------------------------------------------

		DROP TABLE IF EXISTS #TMP_Universe
		DROP TABLE IF EXISTS #TMP_SubEntityCounts
END