
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 


/*==============================================================================================
OBJECT NAME	 :  dbo.CalculateHeightAndDepth
PURPOSE	     :  
CREATED BY	 :  
CREATION DATE:  

USAGE: EXEC dbo.CalculateHeightAndDepth @TName = 'Universe'	  

CHANGE HISTORY:
SNo.   MODIFIED BY		DATE 			DESCRIPTION
===============================================================================================*/

CREATE OR ALTER PROCEDURE [dbo].CalculateHeightAndDepth
	@TName varchar(500),
	@ReportingStructureID INT = NULL 
AS
BEGIN
BEGIN TRY

		SET NOCOUNT ON
	
		IF (@TName IS NULL)
			RAISERROR('Please provide a valid table name to execute the procedure logic.',16,1);

			DECLARE @SQL VARCHAR(MAX)
			
			DECLARE	@PKName varchar(500),  @query varchar(max)

			SELECT @PKName = col.name 
			FROM		sys.tables t
					INNER JOIN	sys.indexes i		ON t.object_id = i.object_id
					INNER JOIN	sys.index_columns c ON t.object_id = c.object_id	AND i.index_id = c.index_id
					INNER JOIN	sys.columns col		ON c.object_id = col.object_id	AND c.column_id = col.column_id
			WHERE i.is_primary_key = 1	AND t.name = @TName
			

			--GET HEIGHT===============================================================================================================================
					
			CREATE TABLE #TMP_HeightAndDepth(ID INT, Name VARCHAR(500) COLLATE DATABASE_DEFAULT,ParentID INT,Height INT,Depth INT)
			--CREATE TABLE #TMP(ID INT, Name VARCHAR(500),ParentID INT,Height INT,Depth INT,Lvl INT)

			DECLARE @ID INT=0

			IF @ReportingStructureID IS NULL
			BEGIN
				SET @SQL =CONCAT('SELECT ',@PKName,', Name,ParentID,Height,Depth FROM ',@TName)
				INSERT INTO #TMP_HeightAndDepth(ID,Name,ParentID,Height,Depth)
					EXEC (@SQL)
			END
			ELSE	
				INSERT INTO #TMP_HeightAndDepth(ID,Name,ParentID,Height,Depth)			
					SELECT SVR.ReportingPositionID, P.Name, SVR.ReportsToPositionID AS ParentID, 0, 0
					FROM dbo.SVReportingPosition SVR 
						INNER JOIN dbo.SVPosition P ON P.positionid = SVR.PositionID
					WHERE SVR.ReportingStructureID = @ReportingStructureID

			--SELECT * FROM	#TMP_HeightAndDepth
			UPDATE #TMP_HeightAndDepth SET Height = 0, Depth = 0

		;WITH CTE
		AS(
			SELECT ID,NAME,ParentID, Height, Depth,
			-- Row_Number returns a bigint - max value have 19 digits
			CAST(ROW_NUMBER()OVER(PARTITION BY PARENTID ORDER BY NAME) AS VARCHAR(MAX)) AS Path,
			CAST(ROW_NUMBER()OVER(PARTITION BY PARENTID ORDER BY NAME) AS VARCHAR(MAX)) AS ReversePath
			FROM #TMP_HeightAndDepth WHERE PARENTID IS NULL
			UNION ALL
			SELECT T.ID,T.NAME,T.ParentID, T.Height, T.Depth,
			--CONCAT(C.Path ,'.' , CAST(ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME) AS VARCHAR(MAX))),
			--CONCAT(CAST(ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME) AS VARCHAR(MAX)) ,'.' , C.ReversePath)
			CAST(CONCAT(C.Path ,'.' , ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME)) AS VARCHAR(MAX)),
			CAST(CONCAT(ROW_NUMBER()OVER(PARTITION BY T.PARENTID ORDER BY T.NAME) ,'.' , C.ReversePath) AS VARCHAR(MAX))
			FROM CTE C
				 INNER JOIN #TMP_HeightAndDepth T ON T.ParentID = C.ID
		)

		SELECT *, ROW_NUMBER()OVER(ORDER BY Path) AS ROWNUM
			INTO #TMP
		FROM CTE
		ORDER BY Path

		--SELECT * FROM #TMP

		ALTER TABLE #TMP_HeightAndDepth ADD LevelPath VARCHAR(MAX) COLLATE DATABASE_DEFAULT, ReversePath VARCHAR(MAX) COLLATE DATABASE_DEFAULT, LeafNode VARCHAR(MAX) COLLATE DATABASE_DEFAULT, Path VARCHAR(MAX) COLLATE DATABASE_DEFAULT

		UPDATE T
			SET HEIGHT = TMP.ROWNUM,
				DEPTH = TMP.ROWNUM,
				LevelPath = TMP.Path,
				ReversePath= TMP.ReversePath,
				LeafNode = PARSENAME(TMP.ReversePath,1),
				Path = TMP.Path
		FROM #TMP_HeightAndDepth T
			 INNER JOIN #TMP TMP ON T.ID=TMP.ID
			 		
		UPDATE #TMP_HeightAndDepth
			SET LeafNode = SUBSTRING(Path,1,CHARINDEX('.',Path)-1)	
		WHERE LeafNode IS NULL
			  AND Path IS NOT NULL

		--SELECT * FROM #TMP_HeightAndDepth ORDER BY HEIGHT	
		-- RETURN
		--===========================================================================================================================================================

		--GET DEPTH: STAMP THE DEPTH OF THE LEAF NODE TO ALL ITS PARENTS (UP UNTIL THE ROOT LEVEL)===============================================================================================================================
						
			IF OBJECT_ID('TEMPDB..#TMP_ALLLEAFNODESWITHPARENTS') IS NOT NULL
				DROP TABLE #TMP_ALLLEAFNODESWITHPARENTS
					
			IF OBJECT_ID('TEMPDB..#TMP_LEAFNODES') IS NOT NULL
				DROP TABLE #TMP_LEAFNODES

			 --GET ALL LEAFNODES
			SELECT * 
				INTO #TMP_LEAFNODES
			FROM #TMP_HeightAndDepth T
			WHERE NOT EXISTS(SELECT 1 FROM #TMP_HeightAndDepth WHERE ParentID = T.ID) 
					AND ParentID IS NOT NULL
			 
			 --RETAIN ONE WITH THE HIGHEST DEPTH
			 ;WITH CTE_LeafNodes
			 AS(
				 SELECT *, ROW_NUMBER()OVER(PARTITION BY ParentID,LeafNode ORDER BY Depth DESC) AS RowNum
				 FROM #TMP_LEAFNODES
			 )
			 DELETE FROM CTE_LeafNodes WHERE RowNum > 1
					

			 --THE TOP MOST PARENT'S DEPTH IS THE MAXIMUM HEIGHT AMONGST ALL ITS CHILDREN===================
			 SELECT LeafNode, MAX(Height) AS Depth
				INTO #TMP_ParentDepth
			 FROM #TMP_LEAFNODES 
			 GROUP BY LeafNode
			 
			 UPDATE TMP
			  SET Depth = T.Depth 
			  FROM #TMP_HeightAndDepth TMP
				   INNER JOIN #TMP_ParentDepth T ON T.LeafNode = TMP.LeafNode			  
			  WHERE TMP.ParentID IS NULL
			  --==============================================================================================

			--GET THE DEPTH OF THE REMAINING HIERARCHY: EACH DEPTH IS THE MAXIMUM HEIGHT FROM AMONGST ALL IT'S CHILDREN, IF NO CHILD THEN DEPTH IS SAME AS HEIGHT
			 SELECT *, SUBSTRING(T.LevelPath,1,pos-1) AS LevelPath_ToUpdate
				INTO #TMP_LevelPath_ToUpdate
			 FROM #TMP_LEAFNODES T
				  CROSS APPLY dbo.FindPatternLocation(T.LevelPath,'.')				  
			
			--DELETE THE TOP MOST PARENTS WHICH HAVE ALREADY BEEN STAMPED	
			DELETE T FROM #TMP_LevelPath_ToUpdate T WHERE EXISTS(SELECT 1 FROM #TMP_ParentDepth WHERE LeafNode=T.LevelPath_ToUpdate)

			;WITH CTE
			AS(
				SELECT *, ROW_NUMBER()OVER(PARTITION BY  LevelPath_ToUpdate ORDER BY Depth DESC) AS RowNum
				FROM #TMP_LevelPath_ToUpdate
			  )
			  DELETE FROM CTE WHERE ROWNUM > 1

			UPDATE T
				SET DEPTH = P.Depth
			FROM #TMP_HeightAndDepth T
				 INNER JOIN #TMP_LevelPath_ToUpdate P ON P.LevelPath_ToUpdate=T.LevelPath
			
			--SELECT * FROM #TMP_HeightAndDepth ORDER BY HEIGHT	
		--============================================================================================================================						
	
					--UPDATE HEIGHT & DEPTH IN THE MAIN TABLE
					IF @ReportingStructureID IS NULL
					BEGIN
							SET @SQL =CONCAT('	UPDATE S
													SET Height = T.Height,
														Depth = T.Depth 
												FROM #TMP_HeightAndDepth T
													 INNER JOIN dbo.',@TName,' S ON S.',@PKName,' = T.ID					
											')
							EXEC (@SQL)
					END
					ELSE	
						UPDATE S
							SET Height = T.Height,
								Depth = T.Depth 
						FROM #TMP_HeightAndDepth T
							INNER JOIN dbo.SVReportingPosition S ON S.ReportingPositionID = T.ID
						WHERE S.ReportingStructureID = @ReportingStructureID											
				

			IF OBJECT_ID('TEMPDB..#TMP') IS NOT NULL
				DROP TABLE #TMP

			IF OBJECT_ID('TEMPDB..#LeafNodes') IS NOT NULL
				DROP TABLE #LeafNodes

			IF OBJECT_ID('TEMPDB..#LeafNodesWithDepth') IS NOT NULL
				DROP TABLE #LeafNodesWithDepth

			IF OBJECT_ID('TEMPDB..#TMP_HeightAndDepth') IS NOT NULL
				DROP TABLE #TMP_HeightAndDepth

			IF OBJECT_ID('TEMPDB..#TMP_GroupBy') IS NOT NULL
				DROP TABLE 	#TMP_GroupBy
		
			IF OBJECT_ID('TEMPDB..#TMP_Parents') IS NOT NULL
				DROP TABLE 	#TMP_Parents

END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()

			IF OBJECT_ID('TEMPDB..#TMP') IS NOT NULL
				DROP TABLE #TMP

			IF OBJECT_ID('TEMPDB..#LeafNodes') IS NOT NULL
				DROP TABLE #LeafNodes

			IF OBJECT_ID('TEMPDB..#LeafNodesWithDepth') IS NOT NULL
				DROP TABLE #LeafNodesWithDepth

			IF OBJECT_ID('TEMPDB..#TMP_HeightAndDepth') IS NOT NULL
				DROP TABLE #TMP_HeightAndDepth
		
			IF OBJECT_ID('TEMPDB..#TMP_LevelPath_ToUpdate') IS NOT NULL
				DROP TABLE 	#TMP_LevelPath_ToUpdate


END CATCH

END

GO