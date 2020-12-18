SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
OBJECT NAME:        dbo.GetFrameworkList
CREATION DATE:      2020-12-18
AUTHOR:             Rishi Nayar
DESCRIPTION:		
USAGE:          	EXEC dbo.GetFrameworkList @EntityID=NULL,
											@EntityType=NULL,
											@ParentEntityID = NULL,
											@ParentEntityType = NULL,
											@UserCreated=1,
											@MethodName= ''

CHANGE HISTORY:
SNo.	Modification Date		Modified By				Comments
*****************************************************************************************************/

CREATE OR ALTER PROCEDURE dbo.GetFrameworkList
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
	FROM dbo.Frameworks
	WHERE FrameworkID = ISNULL(@EntityID,FrameworkID)

END