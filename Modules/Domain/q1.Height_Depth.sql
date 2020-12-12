 
 DELETE FROM [Universe]


SET IDENTITY_INSERT Universe ON;
INSERT [dbo].[Universe] (UniverseID,[Name],  [ParentID],  [Height], [Depth],UserCreated,VersionNum)

SELECT DISTINCT UniverseID, [Name],  [ParentID],  [Height], [Depth],1,1
FROM [AUniverse]
SET IDENTITY_INSERT Universe OFF;


UPDATE Universe SET Height=0,Depth=0;

SELECT * FROM [Universe] WHERE ParentID IS NULL

EXEC dbo.CalculateHeightAndDepth @TName = 'Universe'

