
DECLARE @RootPath VARCHAR(100)=(SELECT [Path] FROM TMP WHERE PrePath='components[0]' AND type=4)

--GET ALL STEPS UNDER THE FRAMEWORK
--SELECT * FROM TMP WHERE PrePath='components[0].components'

DECLARE @TotalSteps TINYINT = (SELECT COUNT(*) FROM TMP WHERE PrePath=@RootPath)
--SELECT @TotalSteps

--SELECT * FROM TMP WHERE PrePath=@RootPath --NO. OF STEPS UNDER A FRAMEWORK;PROCESS THIS ONE BY ONE

DECLARE @StepPath VARCHAR(100)=(SELECT TOP 1 [Path] FROM TMP WHERE PrePath=@RootPath AND [type]=5 ORDER BY ID)

SELECT @StepPath = REPLACE(@StepPath,'[','\[')
SELECT @StepPath = CONCAT(@StepPath,'%')
--SELECT @StepPath = 'components\[0].components\[0]%'


DECLARE @Framework_Metafield TABLE
(
ID INT NOT NULL,
StepName VARCHAR(100) NOT NULL,
StepItemName VARCHAR(100) NOT NULL,
StepItemType VARCHAR(100) NOT NULL,
StepItemKey VARCHAR(100) NOT NULL,
OrderBy INT
)

DECLARE @Metafield_Attributes TABLE
(
ID INT IDENTITY(1,1),
MetaField INT NOT NULL,
AttributeType VARCHAR(100) NOT NULL,
AttributeKey VARCHAR(100) NOT NULL,
OrderBy INT
)

DECLARE @Metafield_Lookups  TABLE
(
ID INT IDENTITY(1,1),
MetaFieldAttributeID INT NOT NULL,
LookupName VARCHAR(100) NOT NULL
)

DROP TABLE IF EXISTS #TMP_STEPS

CREATE TABLE #TMP_STEPS(
	[ID] [int] NOT NULL,
	[key] [varchar](max) NULL,
	[value] [varchar](max) NULL,
	[PreType] [int] NULL,
	[type] [int] NULL,
	[PrePath] [varchar](max) NULL,
	[path] [varchar](max) NULL,
	[hierarchyid] [hierarchyid] NULL
)  


--GET ALL CHILDREN FOR A STEP (THE FIRST RECORD WILL BE STEP ITESELF)
INSERT INTO #TMP_STEPS
(
    ID,
    [key],
    [value],
    PreType,
    type,
    PrePath,
    [path],
    hierarchyid
)
SELECT [ID],
	[key],
	[value],
	[PreType] ,
	[type] ,
	[PrePath] ,
	[path],
	[hierarchyid]  
FROM dbo.TMP tc WHERE tc.[key]='Label' AND PrePath LIKE @StepPath  ESCAPE '\' ORDER BY ID

--SELECT * FROM #TMP_STEPS
 
DECLARE @ID [int] ,
	@key [varchar](max) ,
	@value [varchar](max) ,
	@PreType [int] ,
	@type [int] ,
	@PrePath [varchar](max) ,
	@Path [varchar](max) ,
	@hierarchyid [hierarchyid],
	@I INT = 1,
	@StepName VARCHAR(100)

 WHILE EXISTS(SELECT 1 FROM #TMP_STEPS)
 BEGIN
		
		SELECT @ID = MIN(ID) FROM #TMP_STEPS
		SELECT @PrePath = PrePath,
			   @value = [value]
		FROM #TMP_STEPS WHERE ID = @ID
		
		IF @I = 1
			SET @StepName = @value
		
		PRINT @PrePath


		DELETE FROM #TMP_STEPS WHERE ID = @ID
		SET @I = 2

 END