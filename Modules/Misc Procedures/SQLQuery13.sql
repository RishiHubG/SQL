	CREATE OR ALTER PROC P1
	@A INT=1,
	@B VARCHAR(10)='ABC'
	AS	
	DECLARE @ParamDef NVARCHAR(MAX), @Params NVARCHAR(MAX)
	 
	DROP TABLE IF EXISTS #TMP_Params

	SELECT Name,TYPE_NAME(SYSTEM_TYPE_ID) AS DataType,max_length AS DataTypeLength
		INTO #TMP_Params
	FROM SYS.parameters

	SELECT * FROM #TMP_Params

	SET @ParamDef= STUFF(
	(
	SELECT CONCAT(',',CONCAT(NAME,' ', DataType,' ', CASE WHEN DataType LIKE '%VARCHAR%' THEN CONCAT('(',DataTypeLength,')')  END)) 
	FROM #TMP_Params
	FOR XML PATH('')
	)
	,1,1,'')
	SELECT @ParamDef
	 
	SET @Params= STUFF(
	(
	SELECT CONCAT(',',NAME,'=',Name) 
	FROM #TMP_Params
	FOR XML PATH('')
	)
	,1,1,'')
	--SET @Params=CONCAT(CHAR(39),@Params,CHAR(39))
	SELECT @Params
	 
	DECLARE @SQL NVARCHAR(MAX)= 'SELECT CONCAT('+ STUFF
											(
											(SELECT CONCAT('|',NAME)
											FROM SYS.parameters
											FOR XML PATH('')
											)
											,1,1,'') + ')'
	SELECT @SQL
	SET @SQL=REPLACE(@SQL,'|',',''|'',')
	 
	EXEC SP_EXECUTESQL @SQL,@ParamDef,@a,@b
	--EXEC SP_EXECUTESQL @SQL,@ParamDef,@a,@b
 SELECT * FROM ObjectLog

   