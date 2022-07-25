/*
RULES:
1. Roman Numerals: can hard-code, starting from (i)=301, (iii)=302...only up until (xxx)=30=330
2. Fixed strings:
bis	     	402
quat		404
quin		405
sept		407
ter		    403
dec 		410
 

Order of evaluation:
1. Check for Number
2. Check for Roman Numerals
3. Fixed strings (as above)
4. Single alphabets
*/
DECLARE @TBL TABLE(NAME VARCHAR(1000))

--SELECT ASCII('d')- ASCII('a') + 1
--SELECT CHAR(97)

DROP TABLE IF EXISTS #TMP

 

--SELECT ASCII('i')- ASCII('a') + 1

INSERT INTO @TBL
SELECT 'NAM-FIMA 2017 Sec(1)(1)(as)'
UNION
SELECT 'NAM-FIMA 2017 Sec78(1)(ab)(a)(i)'
--SELECT R_NAME FROM TEST2
DROP TABLE IF EXISTS #TMP_NumAlpha;
--SELECT LEN('ii')

/*
SELECT *,
		--CHARINDEX(CHAR(32),REVERSE(NAME)),		
		RTRIM(LTRIM(RIGHT(NAME,CHARINDEX(CHAR(32),REVERSE(NAME))))) AS StrVal
	INTO #TMP
FROM @TBL

SELECT *,
	   --PATINDEX('%[0-9]%',StrVal),	--START POS. OF A NUMBER	   
	   --SUBSTRING(StrVal,PATINDEX('%[0-9]%',StrVal),LEN(StrVal)),
	   REPLACE(
				REPLACE(
							REPLACE(SUBSTRING(StrVal,PATINDEX('%[0-9]%',StrVal),LEN(StrVal)),')(','.')					
						,'(','.'
					   )
			  ,')','' 
			 )
FROM #TMP
*/

;WITH CTE
AS
(

SELECT *,
		RTRIM(LTRIM(RIGHT(NAME,CHARINDEX(CHAR(32),REVERSE(NAME))))) AS StrVal	
FROM @TBL
), CTE2 AS
(
SELECT *,
	   --PATINDEX('%[0-9]%',StrVal),	--START POS. OF A NUMBER	   
	   --SUBSTRING(StrVal,PATINDEX('%[0-9]%',StrVal),LEN(StrVal)),
	   REPLACE(
				REPLACE(
							REPLACE(SUBSTRING(StrVal,PATINDEX('%[0-9]%',StrVal),LEN(StrVal)),')(','.')					
						,'(','.'
					   )
			  ,')','' 
			 ) AS Val
FROM CTE
)

SELECT *,
		ROW_NUMBER()OVER(PARTITION BY NAME ORDER BY NAME) AS ROWNUM,
		CAST(NULL AS INT) AS Num	
	INTO #TMP
FROM CTE2
	 CROSS APPLY STRING_SPLIT(Val, '.')TAB;
	 		
			
	 --1. UPDATE ALL NUMBERS
	 UPDATE T
		SET Num = TRY_PARSE(value AS INT)
	FROM #TMP T
	--WHERE ROWNUM > 1;	 
	  
	--2. UPDATE ROMAN NUMBERALS
	UPDATE T
		SET Num = TA.KeyValue
	FROM #TMP T
		 INNER JOIN dbo.HirarchyMapping_OM TA ON T.value=TA.KeyName
	WHERE (NUM IS NULL OR NUM = 0)
		  AND TA.KeyType = 'RomanNumerals'
	
	--3. UPDATE FIXED STRINGS
	UPDATE T
		SET Num = TA.KeyValue
	FROM #TMP T
		 INNER JOIN dbo.HirarchyMapping_OM TA ON T.value=TA.KeyName
	WHERE (NUM IS NULL OR NUM = 0)
		  AND TA.KeyType = 'FixedStrings'
		
	--4. UPDATE EVERYTHING ELSE: IF A SINGLE ALPHABET IS FOUND
	UPDATE T
		SET Num = TA.KeyValue
	FROM #TMP T
		 INNER JOIN dbo.HirarchyMapping_OM TA ON T.value=TA.KeyName
	WHERE (NUM IS NULL OR NUM = 0)
	      AND TA.KeyType = 'SingleAlphabets';		  
	
	--GENERATE SEQUENCE OF NO.S
	;WITH e1(n) AS
	(
		SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 
		--UNION ALL  SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
		--SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
	), -- 10
	e2(n) AS (SELECT 1 FROM e1 CROSS JOIN e1 AS b) -- 10*10
	
	SELECT TMP.*,SUBSTRING(TMP.value,TAB2.RowNum,1) AS Alphabet
		INTO #TMP_SingleAlpha
	FROM #TMP TMP
		OUTER APPLY(
					 SELECT RowNum
					 FROM
					 (
						  SELECT TOP 100 PERCENT RowNum = ROW_NUMBER() OVER (ORDER BY n) FROM e2 
						  ORDER BY n
					  )A
					  WHERE LEN(TMP.value) > = A.RowNum 
				)TAB2
	WHERE TMP.Num IS NULL;		  
	
	UPDATE T
		SET Num = TA.KeyValue
	FROM #TMP_SingleAlpha T
		 INNER JOIN dbo.HirarchyMapping_OM TA ON T.Alphabet=TA.KeyName		
	WHERE (T.NUM IS NULL OR T.NUM = 0)
	      AND TA.KeyType = 'SingleAlphabets';
	
	--REMOVE THE STRINGS PROCESSED ABOVE FROM #TMP
	DELETE TMP FROM #TMP TMP WHERE Num IS NULL
	AND EXISTS(SELECT 1 FROM #TMP_SingleAlpha WHERE StrVal = TMP.StrVal AND value = TMP.value);

	--ADD BACK THE ONES WHICH WERE SPLIT INTO SINGLE ALPHABETS
	INSERT INTO #TMP(Name,StrVal,Val,value,RowNum,Num)
		SELECT Name,StrVal,Val,Alphabet,RowNum,Num
		FROM #TMP_SingleAlpha;

	--UPDATE THE REMAINING (WHICH HOPEFULLY SHOULD NOW BE ALL NUMBERS)
	--UPDATE T
	--	SET Num = TRY_PARSE(value AS INT)
	--FROM #TMP T
	--WHERE (NUM IS NULL OR NUM = 0)

	--CHECK IF ANY VALUE WAS NULL, IF YES THEN MAKE THE WHOLE STRING NULL
	UPDATE TMP	
		SET Num = NULL
	 FROM #TMP TMP
	 WHERE EXISTS(SELECT 1 FROM #TMP WHERE TMP.StrVal = StrVal AND Num IS NULL)
 
	 --ALTER TABLE #TMP_SingleAlpha ADD [NEWNAME] VARCHAR(MAX)
	 CREATE NONCLUSTERED INDEX IDX ON #TMP(NAME)INCLUDE(NUM)
 
--UPDATE T  
--SET newname = (SELECT STRING_AGG( ISNULL(Num, ' '), '.')
--		FROM #TMP
--		WHERE T.NAME=Name)
--FROM #TMP T
--WHERE NAME =  'SA-BBBEEA 112-2007 Par6(1)'


--SELECT Name,
--		(SELECT STRING_AGG( ISNULL(Num, NULL), '.')
--		FROM #TMP
--		WHERE T.NAME=Name	
 
--		)	 
--FROM #TMP T

SELECT DISTINCT Name,
	  STUFF(
		(SELECT IIF(Num IS NOT NULL, CONCAT('.',Num),NULL)
		FROM #TMP
		WHERE T.NAME=Name
		ORDER BY ROWNUM
		FOR XML PATH('')
		)
		,1,1,''
	  )	
FROM #TMP T;

DROP TABLE IF EXISTS #TMP_NumAlpha, #TMP_SingleAlpha, #TMP;
