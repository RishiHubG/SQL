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
@MethodName VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT * 
	FROM dbo.Registers
	WHERE RegisterID = ISNULL(@EntityID,RegisterID)

END