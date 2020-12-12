USE [OM_TEST]
GO

/****** Object:  StoredProcedure [dbo].[Calculate_HeightAndDepth_NG]    Script Date: 2020/12/12 1:44:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*==============================================================================================
OBJECT NAME	 :  dbo.Calculate_HeightAndDepth_NG
PURPOSE	     :  
CREATED BY	 :  
CREATION DATE:  

USAGE: EXEC dbo.Calculate_HeightAndDepth_NG @TName = 'SVQuestionTemplateCategory'
	   EXEC dbo.Calculate_HeightAndDepth_NG @TName = 'AUniverse'
	   EXEC dbo.Calculate_HeightAndDepth_NG @TName = 'SVReportingPosition',@ReportingStructureID=160

CHANGE HISTORY:
SNo.   MODIFIED BY		DATE 			DESCRIPTION
1	   RISHI NAYAR		2019-06-24	    UPDATED LOGIC TO CALCULATE HEIGHT & DEPTH
2	   RISHI NAYAR		2019-10-01	    UPDATED LOGIC FOR FETCHING LEAF NODES
3	   RISHI NAYAR		2019-10-15	    1. RENAMED PROCEDURE FROM [Calucalate_HeightAndDepth] TO [Calculate_HeightAndDepth_NG]
										2. ADDED A NEW PARAMETER: @ReportingStructureID, FOR HANDLING ORG CHART; IN THIS CASE @TNAME='SVReportingPosition'
===============================================================================================*/

CREATE PROCEDURE [dbo].[Calculate_HeightAndDepth_NG]
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

/****** Object:  StoredProcedure [dbo].[Calucalate_HeightAndDepth]    Script Date: 2020/12/12 1:44:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================================================
OBJECT NAME	 :  dbo.Calucalate_HeightAndDepth
PURPOSE	     :  
CREATED BY	 :  
CREATION DATE:  

USAGE: EXEC dbo.Calucalate_HeightAndDepth @TName = 'SVQuestionTemplateCategory'

CHANGE HISTORY:
SNo.   MODIFIED BY		DATE 			DESCRIPTION
1	   RISHI NAYAR		2019-06-24	    UPDATED LOGIC TO CALCULATE HEIGHT & DEPTH
===============================================================================================*/

CREATE PROCEDURE [dbo].[Calucalate_HeightAndDepth]
	@TName varchar(500) 
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

			SET @SQL =CONCAT('SELECT ',@PKName,', Name,ParentID,Height,Depth FROM ',@TName)

			INSERT INTO #TMP_HeightAndDepth(ID,Name,ParentID,Height,Depth)
				EXEC (@SQL)


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
			 WHERE NOT EXISTS(SELECT 1 FROM #TMP_HeightAndDepth WHERE CHARINDEX(T.LevelPath,LevelPath) > 0 AND ID <> T.ID)
			 AND T.ParentID IS NOT NULL
			 ORDER BY HEIGHT
			
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
			 SELECT *, SUBSTRING(T.LevelPath,1,pos+1) AS LevelPath_ToUpdate
				INTO #TMP_LevelPath_ToUpdate
			 FROM #TMP_LEAFNODES T
				  CROSS APPLY dbo.FindPatternLocation(T.LevelPath,'.')				  
			
			UPDATE T
				SET DEPTH = P.Depth
			FROM #TMP_HeightAndDepth T
				 INNER JOIN #TMP_LevelPath_ToUpdate P ON P.LevelPath_ToUpdate=T.LevelPath
			
			--SELECT * FROM #TMP_HeightAndDepth ORDER BY HEIGHT	
	--============================================================================================================================						
	
					--UPDATE HEIGHT & DEPTH IN THE MAIN TABLE
					SET @SQL =CONCAT('	UPDATE S
											SET Height = T.Height,
												Depth = T.Depth 
										FROM #TMP_HeightAndDepth T
											 INNER JOIN dbo.',@TName,' S ON S.',@PKName,' = T.ID					
									')
					EXEC (@SQL)

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

/****** Object:  StoredProcedure [dbo].[GetHeightandDepthForBusviewByAssessID_NG]    Script Date: 2020/12/12 1:44:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetHeightandDepthForBusviewByAssessID_NG]
							@AssessID		INT 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE 
		@PBusViewID int,
		@height int = 1,
		@depth int = 1,
		@ModifiedDate DATETIME = GETUTCDATE() 
		
	SELECT PBusViewID,Name,ParentID,Height,Depth INTO #APBusview FROM APBusview WHERE assessID	=	@AssessId   

	UPDATE #APBusview SET Height = 0, Depth = 0

	DECLARE @CalculateHeight CURSOR

	SET @CalculateHeight = CURSOR FOR
				select PBusViewID from #APBusview where ParentID is null and Height = 0 and Depth = 0 order by Name

	OPEN @CalculateHeight
	FETCH NEXT FROM @CalculateHeight INTO @PBusViewID
	WHILE @@FETCH_STATUS = 0
	BEGIN

	START:

		UPDATE #APBusview set Height = @height,Depth = @depth where PBusViewID = @PBusViewID
		SET @height = @height+1
		SET @depth = @depth+1
	LOOP:
		IF EXISTS (SELECT 1 FROM #APBusview WHERE ParentID = @PBusViewID and Height = 0 and Depth = 0)
		BEGIN
			SET @PBusViewID = (SELECT TOP 1 PBusViewID from #APBusview WHERE ParentID = @PBusViewID and Height = 0 and Depth = 0 
									ORDER BY Name)
			GOTO Start
		END
		ELSE IF ((SELECT ParentID FROM #APBusview WHERE PBusViewID = @PBusViewID) is not null)
		BEGIN
			SET @PBusViewID = (SELECT ParentID FROM #APBusview WHERE PBusViewID = @PBusViewID)
			GOTO LOOP
		END



		FETCH NEXT FROM @CalculateHeight INTO @PBusViewID
	END
	CLOSE @CalculateHeight

	DEALLOCATE @CalculateHeight 
	---------------------------------------------------------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------------------------------------------------------

	DECLARE @CalculateDepth CURSOR

	SET @CalculateDepth = CURSOR FOR
				select PBusViewID from #APBusview where PBusViewID not in (select distinct isnull(ParentID,0) from #APBusview) 
				order by Height,Depth

	OPEN @CalculateDepth
	FETCH NEXT FROM @CalculateDepth INTO @PBusViewID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		WITH rec_cte as (
		select PBusViewID,ParentID,Depth from #APBusview where PBusViewID = @PBusViewID
		UNION ALL
		SELECT #APBusview.PBusViewID,#APBusview.ParentID,rcte.Depth 
		FROM #APBusview
		inner join rec_cte  as rcte on rcte.ParentID = #APBusview.PBusViewID)
	
		UPDATE #APBusview
		SET #APBusview.Depth = rec_cte.Depth
		FROM #APBusview 
		INNER JOIN rec_cte on rec_cte.PBusViewID = #APBusview.PBusViewID
		FETCH NEXT FROM @CalculateDepth INTO @PBusViewID
	END
	CLOSE @CalculateDepth

	DEALLOCATE @CalculateDepth


	--select * from #APBusview order by Height,Depth
	--select * from APBusview  where assessid=@assessid order by Height,Depth
	BEGIN TRY
		ALTER  TABLE APBusView DISABLE  TRIGGER APBusView_UPDATE

		UPDATE APBusview
		SET APBusview.Height = #APBusview.Height,
			APBusview.Depth = #APBusview.Depth,
			ModifiedDate = GETUTCDATE()
		FROM APBusview
		INNER JOIN #APBusview on #APBusview.PBusViewID = APBusview.PBusViewID

		ALTER  TABLE APBusView ENABLE  TRIGGER APBusView_UPDATE

	END TRY
	BEGIN CATCH 	
		ALTER  TABLE APBusView ENABLE  TRIGGER APBusView_UPDATE
	END CATCH
	DROP TABLE #APBusview

END


GO

/****** Object:  StoredProcedure [dbo].[Validate_HeightAndDepth_NG]    Script Date: 2020/12/12 1:44:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*==============================================================================================
OBJECT NAME	 :  dbo.Validate_HeightAndDepth_NG
PURPOSE	     :  VALIDATES IF THE PARENT DEPTH IN THE PASSED TABLE MATCHES WITH THE HIGHEST DEPTH OF IT'S CHIDLREN
				THERE SHOULD BE ANY EMPTY RESULTSET, IF IT IS NOT THEN THE DEPTH OF RETURNED UNIVERSE HAVE NOT BEEN STAMPED CORRECTLY
CREATED BY	 :  
CREATION DATE:  

USAGE: EXEC dbo.Validate_HeightAndDepth_NG @TName = 'AUniverse'
	   EXEC dbo.Validate_HeightAndDepth_NG @TName = 'SVReportingPosition'
	   EXEC dbo.Validate_HeightAndDepth_NG @TName = 'SVQuestionTemplateCategory'

CHANGE HISTORY:
SNo.   MODIFIED BY		DATE 			DESCRIPTION
===============================================================================================*/

CREATE PROCEDURE [dbo].[Validate_HeightAndDepth_NG]
@TName VARCHAR(100)
AS
BEGIN

	IF @TName = 'AUniverse'
		EXEC dbo.ValidateUniverse_HeightAndDepth_NG		
	ELSE IF @TName = 'SVReportingPosition'	
		EXEC dbo.ValidateSVReportingPosition_HeightAndDepth_NG
	ELSE IF @TName = 'SVQuestionTemplateCategory'	
		EXEC dbo.ValidateSVQuestionTemplateCategory_HeightAndDepth_NG

END
GO

