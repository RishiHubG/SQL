/*
RULES:
1. aa - will start from 26,bb from 27 and so on..
2. a - will start from 1,b from 2 and so on..
3. 1A - will start from 20, 1B from 21 and so on..irrespective of the no. of numbers the last will be an alphabet; starting from a=20,b=21..
4. The 4th extraction point will always be a roman numeral
*/
DECLARE @TBL TABLE(NAME VARCHAR(1000))

--SELECT ASCII('d')- ASCII('a') + 1
--SELECT CHAR(97)

DROP TABLE IF EXISTS #TMP
DROP TABLE IF EXISTS #TBL_DblAlpha
DROP TABLE IF EXISTS #TBL_Alpha
DROP TABLE IF EXISTS #TBL_AlphaNumeric

 
;WITH CTE AS
(
	SELECT 97 AS Num
	UNION ALL
	SELECT Num+1 AS Num
	FROM CTE
	WHERE Num < 123
	 
)

SELECT IDENTITY(INT,26,1) AS ID,
		CONCAT(CHAR(Num),CHAR(Num)) AS Alpha
	INTO #TBL_DblAlpha
FROM CTE
WHERE Num < 123

--SELECT * FROM #TBL_DblAlpha


;WITH CTE AS
(
	SELECT 97 AS Num
	UNION ALL
	SELECT Num+1 AS Num
	FROM CTE
	WHERE Num < 123
	 
)

SELECT IDENTITY(INT,1,1) AS ID,
		CHAR(Num) AS Alpha
	INTO #TBL_Alpha
FROM CTE
WHERE Num < 123

--SELECT * FROM #TBL_Alpha

;WITH CTE AS
(
	SELECT 97 AS Num
	UNION ALL
	SELECT Num+1 AS Num
	FROM CTE
	WHERE Num < 123
	 
)

SELECT IDENTITY(INT,20,1) AS ID,
		CHAR(Num) AS Alpha
	INTO #TBL_AlphaNumeric
FROM CTE
WHERE Num < 123

--SELECT * FROM #TBL_AlphaNumeric

--SELECT ASCII('i')- ASCII('a') + 1

INSERT INTO @TBL
/*
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
SELECT 'SA-COMPA2008 71-2008 SEC162(7)(b)(ii)(aa)'
UNION
--162.7.2.2.27
SELECT 'SA-COMPA2008 71-2008 SEC162(7)(b)(ii)(bb)'
UNION
SELECT 'SA-BBBEEA 112-2007 Par6(1)'
*/
SELECT R_NAME FROM TEST2

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
	 
--UPDATE ROMAN NUMBERALS
UPDATE T
	SET Num = TAB.Number
FROM #TMP T
	 CROSS APPLY dbo.GetNumberFromRomanNumeral(value)TAB
WHERE T.ROWNUM=4

--UPDATE DOUBLE ALPAHABETS
UPDATE T
	SET Num = TA.ID
FROM #TMP T
	 INNER JOIN #TBL_DblAlpha TA ON T.value=TA.Alpha

--UPDATE SINGLE ALPAHABETS
UPDATE T
	SET Num = TA.ID
FROM #TMP T
	 INNER JOIN #TBL_Alpha TA ON T.value=TA.Alpha 

--UPDATE ALPAHANUMERICS
UPDATE T
	SET Num = TA.ID
FROM #TMP T
	 INNER JOIN #TBL_AlphaNumeric TA ON RIGHT(T.value,1)=TA.Alpha 
WHERE T.ROWNUM <> 4
	  AND RIGHT(T.value,1) LIKE '%[a-zA-Z]%'
	  AND LEFT(T.value,1) LIKE '%[0-9]%'
	 
--UPDATE THE REMAINING (WHICH HOPEFULLY SHOULD NOW BE ALL NUMBERS)
UPDATE T
	SET Num = TRY_PARSE(value AS INT)
FROM #TMP T
WHERE Num IS NULL

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

--SELECT * FROM #TMP WHERE NAME =  'SA-BBBEEA 112-2007 Par6(1)'

SELECT DISTINCT Name,
		(SELECT STRING_AGG( ISNULL(Num, NULL), '.')
		FROM #TMP
		WHERE T.NAME=Name		  
		)	 
FROM #TMP T
--WHERE NAME =  'SA-BBBEEA 112-2007 Par6(1)'