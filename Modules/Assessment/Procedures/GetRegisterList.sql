SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetRegisterList
CREATION DATE:      2020-12-18
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.GetRegisterList @EntityID=NULL,
											@EntityType=NULL,
											@ParentEntityID = NULL,
											@ParentEntityType = NULL,
											@UserCreated=1,
											@MethodName= ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.GetRegisterList
@EntityID INT = NULL,
@EntityType VARCHAR(100) = NULL,
@ParentEntityID INT = NULL,
@ParentEntityType VARCHAR(100) = NULL,
@UserCreated INT,
@MethodName VARCHAR(100),
@LogRequest BIT = 1
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT * 
	FROM dbo.Registers
	WHERE RegisterID = ISNULL(@EntityID,RegisterID)

		--INSERT INTO LOG-------------------------------------------------------------------------------------------------------------------------
		 IF @LogRequest = 1
		BEGIN		
			DECLARE @vEntityID VARCHAR(20)='NULL'
			DECLARE @vParentEntityID VARCHAR(20)='NULL'

			IF @EntityID IS NOT NULL SET @vEntityID = @EntityID
			IF @ParentEntityID IS NOT NULL SET @vParentEntityID = @ParentEntityID

			DECLARE @Params VARCHAR(MAX)
			SET @Params = CONCAT('@EntityID=',@vEntityID,',@EntityType=',CHAR(39),@EntityType,CHAR(39),',@ParentEntityID=',@vParentEntityID)
			SET @Params = CONCAT(@Params,',@ParentEntityType=', CHAR(39),@ParentEntityType, CHAR(39),',@UserCreated=',@UserCreated,',@MethodName=',CHAR(39),@MethodName, CHAR(39))
			SET @Params = CONCAT(@Params,',@LogRequest=1')
			--PRINT @PARAMS
			EXEC dbo.InsertObjectLog @ObjectID=@@PROCID,
									 @Params = @Params,
									 @UserCreated = @UserCreated
		END
		------------------------------------------------------------------------------------------------------------------------------------------
END