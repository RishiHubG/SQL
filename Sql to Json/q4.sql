USE JUNK
GO

--https://stackoverflow.com/questions/53767142/sql-to-json-parent-child-relationship
DROP TABLE IF EXISTS tmp
create table tmp ([ID] int, ParentID int, SomeText varchar(50))
insert into tmp values
 (1,  null,'abc'    )
,(2, null,'asd'    )
,(3, 1 ,   'weqweq' )
,(4, 1  ,  'lkjlkje')
,(5, 4   , 'noonwqe')
,(6, 4    ,'wet4t4' )
,(7, 2    ,'wet4t4' )
,(8, 5    ,'5' )
,(9, 3    ,'33' )


	DECLARE @ColumnList VARCHAR(MAX),@strColumnList VARCHAR(MAX),@ColumnListDataType VARCHAR(MAX)
	 DECLARE @SQL VARCHAR(MAX) 

	SELECT @ColumnList = STRING_AGG(CONCAT('T.',Column_Name),',') ,
		  @strColumnList = STRING_AGG(CONCAT(CHAR(39),'"',Column_Name,'":',CHAR(39),',',Column_Name),',') ,
		  @ColumnListDataType = STRING_AGG(CONCAT(Column_Name,CONCAT(' ', DATA_TYPE),CASE WHEN DATA_TYPE IN ('varchar','Nvarchar') THEN CONCAT('(',CHARACTER_MAXIMUM_LENGTH,')') END),',' ) 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'tmp'
	SELECT @ColumnListDataType
	SELECT * FROM   INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'tmp'
	 
DROP TABLE IF EXISTS #TMP;

SET @SQL = CONCAT('CREATE TABLE #TMP(', @ColumnListDataType,')')
EXEC(@SQL)

DECLARE @TBL VARCHAR(100)=CONCAT('TMP', REPLACE(NEWID(),'-',''))


RETURN
 SET @SQL =' 
 DROP TABLE IF EXISTS #TMP;
;WITH CTE
AS(

  select <ColumnList>, 1 AS Level, CAST(ID AS VARCHAR(MAX)) AS [Path]
    from dbo.tmp T
    where ParentID IS NULL

	UNION ALL
	
	select <ColumnList>, C.Level + 1, CAST(CONCAT(C.PATH,''.'',T.ID) AS VARCHAR(MAX))
    from dbo.tmp   T
		INNER JOIN CTE C ON C.ID=T.ParentID
        )

		SELECT *,
				CONCAT(''{'',<strColumnList>,''"}'') AS strNode
				INTO #TMP
		FROM CTE
		ORDER BY [Path];'

		SET @SQL = REPLACE(@SQL,'<ColumnList>',@ColumnList)
		SET @SQL = REPLACE(@SQL,'<strColumnList>',@strColumnList)
		PRINT @SQL
		--RETURN
		EXEC (@SQL)

		RETURN

		--SELECT * FROM #TMP ORDER BY [Path];

		DROP TABLE IF EXISTS #Tmp_Path;
		
		SELECT DISTINCT T1.*,TAB.str AS StrPath
			INTO #Tmp_Path
		FROM #TMP T1
			OUTER APPLY (
							SELECT *,SUBSTRING(T1.Path,1,Level) AS str
							FROM #TMP
							WHERE Path LIKE '%' + SUBSTRING(T1.Path,1,Level) + '%'

						)TAB
			ORDER BY StrPath

			--SELECT * FROM #Tmp_Path WHERE StrPath NOT LIKE '%.' order by StrPath,Path

			DROP TABLE IF EXISTS #TMP_RowNum
			SELECT *,
					ROW_NUMBER()OVER(PARTITION BY StrPath order by StrPath,Path) AS RowNum
				INTO #TMP_RowNum
			FROM #Tmp_Path WHERE StrPath NOT LIKE '%.' 
		 			 
			--SELECT DISTINCT ID,strPath
			--FROM #Tmp_Path
			--WHERE StrPath NOT LIKE '%.'
			--order by StrPath

			DROP TABLE IF EXISTS #TMP_MinCTE,#TMP_MaxCTE

			--OPENING BRACE FOR THE CHILD NODE			
				SELECT TR.StrPath, TR.ID
					INTO #TMP_MinCTE
				FROM #TMP_RowNum TR
					INNER JOIN(
								SELECT StrPath, MIN (RowNum) AS RowNum
								FROM #TMP_RowNum			
								GROUP BY StrPath
							)TAB ON TR.StrPath = TAB.StrPath
				WHERE TR.RowNum = TAB.RowNum AND TR.StrPath = TAB.StrPath
			 

			UPDATE T
				SET strNode = REPLACE(T.strNode,'}',', "Child": [')
			FROM #TMP T				 
				 INNER JOIN #TMP_MinCTE C ON T.ID=C.ID;			  
			
			--CLOSING BRACE FOR THE CHILD NODE		 
				SELECT TR.StrPath, TR.ID
					INTO #TMP_MaxCTE
				FROM #TMP_RowNum TR
					INNER JOIN(
								SELECT StrPath, MAX (RowNum) AS RowNum
								FROM #TMP_RowNum			
								GROUP BY StrPath
							)TAB ON TR.StrPath = TAB.StrPath
				WHERE TR.RowNum = TAB.RowNum AND TR.StrPath = TAB.StrPath;
				
				DROP TABLE IF EXISTS #TMP_Replicate;

				--MAY NEED TO ADD CLOSING BRACE MULTIPLE TIMES AT A NODE TO CLOSE ALL CHILD ELEMENTS
				SELECT ID, COUNT(*) AS NumTimes
					INTO #TMP_Replicate
				FROM #TMP_MaxCTE
				GROUP BY ID

				 UPDATE T
					SET strNode = CONCAT(strNode,REPLICATE(']}',NumTimes),',') --REPLACE(strNode,'}',']')
				FROM #TMP T
					 INNER JOIN #TMP_Replicate C ON T.ID=C.ID;
		
			--FOR THE REMAINING NODES (NOT PART OF MIN/MAX TABLES ABOVE) ADD A COMMA
			UPDATE T
				SET strNode = CONCAT(strNode,',')
			FROM #TMP T
			WHERE NOT EXISTS(SELECT 1 FROM #TMP_MinCTE WHERE ID = T.ID
							UNION
							SELECT 1 FROM #TMP_MaxCTE WHERE ID = T.ID
							)
			
			SELECT * FROM #TMP order by Path

			--REMOVE THE LAST COMMA
			UPDATE T
				SET strNode = SUBSTRING(StrNode,1, LEN(StrNode)-1)
			FROM #TMP T
				WHERE Path = (SELECT MAX(PAth) FROM #TMP);
				

				SELECT  
						CONCAT('[' + STRING_AGG(strNode,'') WITHIN GROUP(ORDER BY Path ) , ']')
				FROM #TMP
				
				--SELECT * FROM #TMP_Replicate
		 