--USE Q8.SQL TO INSERT INTO A TABLE TMP

--SELECT * FROM TMP ORDER BY ID

--1.
--GET THE FRAMEWORK/TABLE; GET THE PATH COL. VALUE FOR TYPE=4=ARRAY( THIS WILL HAVE THE HIERARCHY)
--TO FIND ALL CHILD ITEMS OF A PARENT: A PATH VALUE AGAINST A PARENT WILL MATCH THE PREPATH VALUE AGAINST ALL ITS CHILDREN
SELECT * FROM TMP WHERE PrePath='components[0]' AND [Type]=4

DECLARE @Path VARCHAR(100)=(SELECT [Path] FROM TMP WHERE PrePath='components[0]' AND type=4)

--GET ALL STEPS UNDER THE FRAMEWORK
SELECT * FROM TMP WHERE PrePath='components[0].components'
SELECT COUNT(*) FROM TMP WHERE PrePath=@Path

--SELECT * FROM TMP WHERE PrePath=@Path --NO. OF STEPS UNDER A FRAMEWORK;PROCESS THIS ONE BY ONE

DECLARE @StepPath VARCHAR(100)=(SELECT TOP 1 [Path] FROM TMP WHERE PrePath=@Path AND [type]=5 ORDER BY ID)

SELECT @StepPath = REPLACE(@StepPath,'[','\[')
SELECT @StepPath = CONCAT(@StepPath,'%')
SELECT @StepPath = 'components\[0].components\[0]%'

--GET ALL CHILDREN FOR A STEP (THE FIRST RECORD WILL BE STEP ITESELF)
SELECT * FROM dbo.TMP tc WHERE tc.[key]='Label' AND PrePath LIKE @StepPath  ESCAPE '\' ORDER BY ID

--2. USING THE PATH VALUE (components[0].components) FOUND ABOVE, APPLY THIS AS A FILTER IN PREPATH TO GET ITS CHILDREN
--USE THE PATH VALUE TO GET EACH OF THEIR CHILDREN;THIS SHOWS ALL THE DATA FROM TOP TO BOTTOM; ADD A FILTER FOR KEY=LABEL & PROCESS EACH ONE BY ONE
SELECT * FROM TMP WHERE PrePath LIKE 'components\[0].components\[2]%' ESCAPE '\'
SELECT * FROM TMP WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[1]%' ESCAPE '\'

-----------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS TMP_CTE
;WITH CTE
AS(
SELECT PrePath,Path,[key],type,value,hierarchyid
FROM TMP WHERE PrePath='components[0]' AND type=4
UNION ALL
SELECT T.PrePath,T.Path,T.[key],T.type,T.value,T.hierarchyid
FROM TMP T
	 INNER JOIN CTE C ON C.Path = T.pREPATH
--WHERE T.type=4 or T.type=5
)

SELECT IDENTITY(INT,1,1) AS ID,* 
	INTO TMP_CTE
FROM CTE
ORDER BY hierarchyid
-----------------------------------------------------------------------------------------------

---PROCESSING STEPS (ONE BY ONE)-----------------------------------------------------------------------------------------------------------------
SELECT * FROM TMP_CTE ORDER BY hierarchyid


SELECT * FROM TMP WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[0]%' ESCAPE '\'
SELECT * FROM TMP_CTE WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[0]%' ESCAPE '\'

--GET THE FRAMEWORK/TABLE; GET THE PATH COL. VALUE FOR TYPE=4=ARRAY( THIS WILL HAVE THE HIERARCHY)
DECLARE @Path VARCHAR(100)=(SELECT Path FROM TMP_CTE WHERE PrePath='components[0]' AND type=4)
SELECT @Path

--2. USING THE PATH VALUE (components[0].components) FOUND ABOVE, APPLY THIS AS A FILTER IN PREPATH TO GET ITS CHILDREN
--USE THE PATH VALUE TO GET EACH OF THEIR CHILDREN
SELECT * FROM TMP_CTE WHERE PrePath=@Path --NO. OF STEPS

SELECT @Path = CONCAT(@Path,'[1]%') --STEP NO. STARTING FROM 0

SELECT @Path = REPLACE(@Path,'[','\[')
SELECT @Path

--GET ALL CHILDREN FOR A STEP
SELECT * FROM dbo.TMP_CTE tc WHERE tc.[key]='Label' AND PrePath LIKE @Path  ESCAPE '\'
---------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------
DECLARE @Path VARCHAR(100)=(SELECT Path FROM TMP WHERE PrePath='components[0]' AND type=4)
SELECT @Path = path FROM TMP WHERE PrePath='components[0].columns[0]' AND type=5 --AND [KEY]=0 --COMPONENT
	SELECT @Path

DECLARE @Key INT = 0
DECLARE @Label VARCHAR(100)
DECLARE @PrePath VARCHAR(100)
 
--SELECT @Path = [Path] FROM TMP WHERE PrePath=@Path AND type=4 AND [KEY]=@key

WHILE @Path IS NOT NULL
BEGIN		
		
	SELECT @Path = [Path] FROM TMP WHERE PrePath='components[0].columns[0]' AND type=5 AND [KEY]=0 --COMPONENT
	PRINT @Path
	--RETURN
	--RETURN
	IF @Path IS NULL OR @Path = ''
	BEGIN
		SELECT @Path = [Path] FROM TMP WHERE PrePath=@Path AND type=4   ---ARRAY
		RETURN
			
		IF @Path IS NULL
		BEGIN		
			SELECT @Label = [value] FROM TMP WHERE PrePath=@Path AND [key] ='label'
			PRINT @Label
			SET @Key = @key + 1
		END
	END
	
	--SELECT @Path = [Path] FROM TMP WHERE PrePath=@Path AND type=5 AND [KEY]=@key

	IF @Path IS NULL
		BREAK;
		
	PRINT @PATH
	--break;

END
