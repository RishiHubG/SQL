/*

RULES:
1. a - will start from 1,b from 2 and so on..
2. aa - will start from 31,bb from 32 and so on..
3. A - will start from 61,B from 62 and so on..
4. AA - will start from 91,BB from 92 and so on..
5. aaa - will start from 121,bbb from 122 and so on..
6. 1A - will start from 151, 1B from 152 and so on..irrespective of the no. of numbers the last will be an alphabet; starting from a=20,b=21..
7. 2A - will start from 181, 2B from 182
8. Roman Numerals: can hard-code, starting from (i)=301, (ii)=302...only up until (xxx)=30=330
9. Fixed strings:
bis	     	402
quat		404
quin		405
sept		407
ter		    403
dec 		410
*/
	
	DECLARE @TBL TABLE(KeyName VARCHAR(100), KeyValue INT, KeyType VARCHAR(100))

		--=====================================================================
		DROP TABLE IF EXISTS #TBL_Alpha

		--a - will start from 1,b from 2 and so on..		
		;WITH CTE AS
		(
			SELECT 97 AS Num
			UNION ALL
			SELECT Num+1 AS Num
			FROM CTE
			WHERE Num < 123
	 
		)

		--SELECT 
		SELECT CHAR(Num) AS Alpha,
			   IDENTITY(INT,1,1) AS ID
			INTO #TBL_Alpha
		FROM CTE
		WHERE Num < 123


			INSERT INTO @TBL(KeyName, KeyValue)
				SELECT Alpha,ID  FROM #TBL_Alpha
		--=====================================================================

		--=====================================================================
			DROP TABLE IF EXISTS #TBL_DblAlpha

		--aa - will start from 31,bb from 32 and so on..		
		;WITH CTE AS
		(
			SELECT 97 AS Num
			UNION ALL
			SELECT Num+1 AS Num
			FROM CTE
			WHERE Num < 123
	 
		)

		SELECT IDENTITY(INT,31,1) AS ID,
				CONCAT(CHAR(Num),CHAR(Num)) AS Alpha
			INTO #TBL_DblAlpha
		FROM CTE
		WHERE Num < 123

			INSERT INTO @TBL(KeyName, KeyValue)
				SELECT Alpha,ID FROM #TBL_DblAlpha
		--=====================================================================
					   
		--=====================================================================
		DROP TABLE IF EXISTS #TBL_CapsAlpha

		-- A - will start from 61,B from 62 and so on..	
		;WITH CTE AS
		(
			SELECT 65 AS Num
			UNION ALL
			SELECT Num+1 AS Num
			FROM CTE
			WHERE Num < 91
	 
		)

		--SELECT 
		SELECT CHAR(Num) AS Alpha,
			   IDENTITY(INT,61,1) AS ID
			INTO #TBL_CapsAlpha
		FROM CTE
		WHERE Num < 91

			INSERT INTO @TBL(KeyName, KeyValue)
				SELECT Alpha,ID  FROM #TBL_CapsAlpha
		--=====================================================================

		--=====================================================================
			   
			DROP TABLE IF EXISTS #TBL_DblCapsAlpha

		--AA - will start from 91,BB from 92 and so on..
		;WITH CTE AS
		(
			SELECT 65 AS Num
			UNION ALL
			SELECT Num+1 AS Num
			FROM CTE
			WHERE Num < 91
	 
		)

		SELECT IDENTITY(INT,91,1) AS ID,
				CONCAT(CHAR(Num),CHAR(Num)) AS Alpha
			INTO #TBL_DblCapsAlpha
		FROM CTE
		WHERE Num < 91

			INSERT INTO @TBL(KeyName, KeyValue)
				SELECT Alpha,ID FROM #TBL_DblCapsAlpha
		--=====================================================================

		--=====================================================================
			DROP TABLE IF EXISTS #TBL_TripleAlpha

		--aaa - will start from 121,bbb from 122 and so on..
		;WITH CTE AS
		(
			SELECT 97 AS Num
			UNION ALL
			SELECT Num+1 AS Num
			FROM CTE
			WHERE Num < 123
	 
		)

		SELECT IDENTITY(INT,121,1) AS ID,
				CONCAT(CHAR(Num),CHAR(Num),CHAR(Num)) AS Alpha
			INTO #TBL_TripleAlpha
		FROM CTE
		WHERE Num < 123

			INSERT INTO @TBL(KeyName, KeyValue)
				SELECT Alpha,ID FROM #TBL_TripleAlpha
		--=====================================================================
				
		
		--=====================================================================
		DROP TABLE IF EXISTS #TBL_NumCaps

		--1A - will start from 151, 1B from 152 and so on
		;WITH CTE AS
		(
			SELECT 65 AS Num
			UNION ALL
			SELECT Num+1 AS Num
			FROM CTE
			WHERE Num < 91
	 
		)

		--SELECT 
		SELECT CONCAT('1',CHAR(Num)) AS Alpha,
			   IDENTITY(INT,151,1) AS ID
			INTO #TBL_NumCaps
		FROM CTE
		WHERE Num < 91

	 


			INSERT INTO @TBL(KeyName, KeyValue)
				SELECT Alpha,ID  FROM #TBL_NumCaps
		--=====================================================================

		--=====================================================================
		DROP TABLE IF EXISTS #TBL_NumCaps2

		--2A - will start from 181, 2B from 182
		;WITH CTE AS
		(
			SELECT 65 AS Num
			UNION ALL
			SELECT Num+1 AS Num
			FROM CTE
			WHERE Num < 91
	 
		)

		--SELECT 
		SELECT CONCAT('2',CHAR(Num)) AS Alpha,
			   IDENTITY(INT,181,1) AS ID
			INTO #TBL_NumCaps2
		FROM CTE
		WHERE Num < 91 


			INSERT INTO @TBL(KeyName, KeyValue)
				SELECT Alpha,ID  FROM #TBL_NumCaps2
		--=====================================================================
					 
		
		--=ROMAN NUMERALS:Roman Numerals: can hard-code, starting from (i)=301, (ii)=302...only up until (xxx)=30=330==================
		 
			INSERT INTO @TBL(KeyName, KeyValue, KeyType)
				SELECT 'i',1, 'RomanNumerals'
				UNION
				SELECT 'ii',2, 'RomanNumerals'
				UNION
				SELECT 'iii',3, 'RomanNumerals'
				UNION
				SELECT 'iv',4, 'RomanNumerals'
				UNION
				SELECT 'v',5, 'RomanNumerals'
				UNION
				SELECT 'vi',6, 'RomanNumerals'
				UNION
				SELECT 'vii',7, 'RomanNumerals'
				UNION
				SELECT 'viii',8, 'RomanNumerals'
				UNION
				SELECT 'ix',9, 'RomanNumerals'
				UNION
				SELECT 'x',10, 'RomanNumerals'
				UNION
				SELECT 'xi',11, 'RomanNumerals'
				UNION
				SELECT 'xii',12, 'RomanNumerals'
				UNION
				SELECT 'xiii',13, 'RomanNumerals'
				UNION
				SELECT 'xiv',14, 'RomanNumerals'
				UNION
				SELECT 'xv',15, 'RomanNumerals'
				UNION
				SELECT 'xvi',16, 'RomanNumerals'
				UNION
				SELECT 'xvii',17, 'RomanNumerals'
				UNION
				SELECT 'xviii',18, 'RomanNumerals'
				UNION
				SELECT 'xix',19, 'RomanNumerals'
				UNION
				SELECT 'xx',20, 'RomanNumerals'
				UNION
				SELECT 'xxi',21 , 'RomanNumerals'
				UNION
				SELECT 'xxii',22, 'RomanNumerals'
				UNION
				SELECT 'xxiii',23, 'RomanNumerals'				 
				UNION
				SELECT 'xxiv',24, 'RomanNumerals'
				UNION
				SELECT 'xxv',25, 'RomanNumerals'
				UNION
				SELECT 'xxvi',26, 'RomanNumerals'
				UNION
				SELECT 'xxvii',27, 'RomanNumerals'
				UNION
				SELECT 'xxviii',28, 'RomanNumerals'
				UNION
				SELECT 'xxix',29, 'RomanNumerals'
				UNION
				SELECT 'xxx',30, 'RomanNumerals'	
				
				UPDATE @TBL SET KeyValue = KeyValue + 300 WHERE KeyType = 'RomanNumerals'
		--=====================================================================

		--====================================================================
		/*		
		Fixed strings:
			bis	     	402
			quat		404
			quin		405
			sept		407
			ter		    403
			dec 		410
		*/
		INSERT INTO @TBL(KeyName, KeyValue)
				SELECT 'bis',402
				UNION
				SELECT 'quat',404
				UNION
				SELECT 'quin',405
				UNION
				SELECT 'sept',407
				UNION
				SELECT 'ter',403
				UNION
				SELECT 'dec',410				 		
		--=====================================================================

		INSERT INTO dbo.HirarchyMapping_OM(KeyName, KeyValue, KeyType)
			SELECT KeyName, KeyValue, KeyType
			FROM @TBL TBL
			WHERE NOT EXISTS(SELECT 1 FROM HirarchyMapping_OM WHERE KeyName = TBL.KeyName AND KeyValue = TBL.KeyValue);

		SELECT * FROM dbo.HirarchyMapping_OM;
