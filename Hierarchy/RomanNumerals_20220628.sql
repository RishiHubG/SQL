/*
RULES:
1. aa - will start from 31,bb from 32 and so on..
2. a - will start from 1,b from 2 and so on..
3. A - will start from 61,B from 62 and so on..
4. AA - will start from 91,BB from 92 and so on..
5. aaa - will start from 121,bbb from 122 and so on..
6. 1A - will start from 151, 1B from 152 and so on..irrespective of the no. of numbers the last will be an alphabet; starting from a=20,b=21..
7. 2A - will start from 181, 2B from 182
8. Roman Numerals: can hard-code, starting from (i)=301, (iii)=302...only up until (xxx)=30=330
9. Fixed strings:
bis	     	402
quat		404
quin		405
sept		407
ter		    403
dec 		410
10. If anything can't be processed then make whole string NULL

Order of evaluation:
1. Check for Number
2. Check for Roman Numerals
3. Check for Everything else
*/
DECLARE @TBL TABLE(NAME VARCHAR(1000))

--SELECT ASCII('d')- ASCII('a') + 1
--SELECT CHAR(97)

DROP TABLE IF EXISTS #TMP

 

--SELECT ASCII('i')- ASCII('a') + 1

INSERT INTO @TBL
--162.5.3.4.26
SELECT 'SA-COMPA2008 71-2008 SEC162(iii)(c)(9)(aa)'
UNION
--75.1.20.1.1
SELECT 'SA-CUSTEA 91-1964 SEC75(1A)(a)(i)'
UNION
--75.1.21.1
SELECT 'SA-CUSTEA 91-1964 SEC75(1B)(a)'
UNION
--75.1.21.2
SELECT 'SA-CUSTEA 91-1964 SEC75(1B)(b)'
UNION
--162.7.2.2.26
SELECT 'SA-COMPA2008 71-2008 SEC162(7)(b)(cfgii)(aa)'
UNION
--162.7.2.2.27
SELECT 'SA-COMPA2008 71-2008 SEC162(7)(b)(ii)(bb)'
UNION
SELECT 'SA-BBBEEA 112-2007 Par6(1)'
UNION
SELECT 'SA-CUSTEA 91-1964 Sec114(1)(v)(ee)'
UNION
SELECT 'SA-MSA 1262-1999 Reg15D(a)(viii)'
UNION
SELECT 'SA-LTIA 1407-2017 Par15A(1)(a)'
--SELECT R_NAME FROM TEST2

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
	 	
		
	 --UPDATE ALL NUMBERS
	 UPDATE T
		SET Num = TRY_PARSE(value AS INT)
	FROM #TMP T
	--WHERE ROWNUM > 1;

	--HANDLING COMBINATION LIKE 15D BEFORE BRACKETS************
	 
	SELECT Name,StrVal,Val,RIGHT(value,1) AS Alphabet,ROWNUM + 1 AS ROWNUM
		INTO #TMP_NumAlpha
	FROM #TMP
	WHERE RowNum = 1
		  AND Num IS NULL;	
	
	--RESETTING THE ROWNUM ORDER
	UPDATE TMP
			SET ROWNUM = ROWNUM + 1
		FROM #TMP TMP
		WHERE EXISTS(SELECT 1 #TMP_NumAlpha WHERE NAME = TMP.NAME)
		      AND ROWNUM > 1;
	
	--UPDATE 15 D TO 15
	UPDATE TMP
		SET value = REPLACE(TMP.value,TNum.Alphabet,'')
	FROM #TMP TMP
		 INNER JOIN #TMP_NumAlpha TNUM ON TNUM.NAME = TMP.NAME
	WHERE TMP.RowNum = 1;

	--INSERT "D" FROM 15D
	INSERT INTO #TMP(Name,StrVal,Val,value,ROWNUM)
		SELECT Name,StrVal,Val,Alphabet,ROWNUM
		FROM #TMP_NumAlpha;		
	--*******************************************************
	  
	--UPDATE ROMAN NUMBERALS
	UPDATE T
		SET Num = TA.KeyValue
	FROM #TMP T
		 INNER JOIN dbo.HirarchyMapping_OM TA ON T.value=TA.KeyName
	WHERE (NUM IS NULL OR NUM = 0)
		  AND TA.KeyType = 'RomanNumerals'

	  --UPDATE EVERYTHING ELSE
	UPDATE T
		SET Num = TA.KeyValue
	FROM #TMP T
		 INNER JOIN dbo.HirarchyMapping_OM TA ON T.value=TA.KeyName
	WHERE (NUM IS NULL OR NUM = 0);		  

--UPDATE THE REMAINING (WHICH HOPEFULLY SHOULD NOW BE ALL NUMBERS)
UPDATE T
	SET Num = TRY_PARSE(value AS INT)
FROM #TMP T
WHERE (NUM IS NULL OR NUM = 0)

--CHECK IF ANY VALUE WAS NULL, IF YES THEN MAKE THE WHOLE STRING NULL
UPDATE TMP	
	SET Num = NULL
 FROM #TMP TMP
 WHERE EXISTS(SELECT 1 FROM #TMP WHERE TMP.StrVal = StrVal AND Num IS NULL)
 
 ALTER TABLE #TMP ADD [NEWNAME] VARCHAR(MAX)
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

DROP TABLE IF EXISTS #TMP_NumAlpha;
