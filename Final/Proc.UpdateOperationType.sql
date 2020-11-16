--ASSUMPTION: SCRIPT WILL RUN ONLY IF VERSIONNUM > 1
USE JUNK
GO

CREATE OR ALTER PROCEDURE dbo.UpdateHistoryOperationType
@FrameworkID INT,
@TableInitial VARCHAR(100),
@VersionNum INT
AS
BEGIN
	SET NOCOUNT ON;
		
		/*
		DECLARE @TBL_List TABLE(ID INT IDENTITY(1,1),TemplateTableName VARCHAR(500),KeyColName VARCHAR(100), NewTableName VARCHAR(500),ParentTableName VARCHAR(500),ConstraintSQL VARCHAR(MAX),TableType VARCHAR(100))

		INSERT INTO @TBL_List(TemplateTableName,KeyColName,ParentTableName,TableType,ConstraintSQL)
		VALUES	('Framework_Lookups','LookupValue','Framework_StepItems','Lookups','ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemsID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]) '),
			('Framework_Attributes','AttributeKey','Framework_StepItems','Attributes','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID); ALTER TABLE [dbo].[<TABLENAME>] ADD CONSTRAINT [FK_<TABLENAME>_StepItemID] FOREIGN KEY ( [StepItemID] ) REFERENCES [dbo].[<ParentTableName>] ([StepItemID]); '),		
			('Framework_StepItems','StepItemKey','Framework_Steps','StepItems','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepItemID  PRIMARY KEY(StepItemID) ;ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT [FK_<TABLENAME>_StepID] FOREIGN KEY ( [StepID] ) REFERENCES [dbo].[<ParentTableName>] ([StepID]) '),
			('Framework_Steps','StepName','','','ALTER TABLE [dbo].<TABLENAME> ADD CONSTRAINT PK_<TABLENAME>_StepID PRIMARY KEY(StepID)')
		DROP TABLE IF EXISTS #TBL_OperationTypeList
		SELECT IDENTITY(INT,1,1) AS ID,TemplateTableName,KeyColName,TableType INTO #TBL_OperationTypeList FROM @TBL_List WHERE TableType <> ''
		*/

		IF @VersionNum > 1
		BEGIN
	
				DROP TABLE IF EXISTS #TMP_OperationType
				CREATE TABLE #TMP_OperationType(HistoryTableName VARCHAR(100),CommonID INT,KeyColName VARCHAR(100),ModuleName VARCHAR(50),KeyName VARCHAR(100),OldValue VARCHAR(MAX),NewValue VARCHAR(MAX),OperationType VARCHAR(50))

				DECLARE @ID INT,@TemplateTableName VARCHAR(100),@TableType VARCHAR(100),@KeyColName VARCHAR(100)
				DECLARE @PrevVersionNum INT = @VersionNum - 1, @Query NVARCHAR(MAX), @HistTableSuffix VARCHAR(50)='_history'
				DECLARE @cols VARCHAR(MAX)='',@HistoryTableName VARCHAR(500),@KeyName VARCHAR(500),@SelectCols VARCHAR(MAX),@CommonID INT

				SET @TableInitial = CONCAT('dbo.',@TableInitial)

				WHILE EXISTS(SELECT 1 FROM #TBL_OperationTypeList)
				BEGIN
		
						SELECT @ID = MIN(ID) FROM #TBL_OperationTypeList

						SELECT @TemplateTableName = TemplateTableName,
							   @KeyColName = KeyColName,
							   @TableType = TableType
						FROM #TBL_OperationTypeList 
						WHERE ID = @ID		 

						SET @HistoryTableName = CONCAT(@TableInitial,'_',@TemplateTableName,@HistTableSuffix)

						DROP TABLE IF EXISTS #TMP_Items
						CREATE TABLE #TMP_Items(CommonID INT,KeyName VARCHAR(100),KeyValue VARCHAR(1000),VersionNum INT)
		
						IF @TableType = 'StepItems'		
							SET @Query = CONCAT('SELECT CommonID,KeyName,KeyValue,VersionNum			
													FROM
													(
													SELECT DISTINCT Curr.StepItemID AS CommonID, Curr.StepItemKey AS KeyName,Curr.StepItemName AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_Framework_StepItems_history Curr
														 INNER JOIN ',@TableInitial,'_Framework_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr.StepID 
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,')
													      AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''		
													)TAB'
												)		
						ELSE IF @TableType = 'Attributes'
							SET @Query = CONCAT('	SELECT CommonID,KeyName,KeyValue,VersionNum			
													FROM
													(
													SELECT DISTINCT Curr.StepItemID AS CommonID, Curr.AttributeKey AS KeyName,Curr.AttributeValue AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_Framework_Attributes_history Curr	
														 INNER JOIN ',@TableInitial,'_Framework_StepItems_history Curr_Met ON Curr_Met.StepItemID = Curr.StepItemID	
														 INNER JOIN ',@TableInitial,'_Framework_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID 
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,') 
														  AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''		
													)TAB' 
												)
							ELSE IF @TableType = 'Lookups'
							SET @Query = CONCAT('SELECT CommonID,KeyName,KeyValue,VersionNum			
													FROM
													(
													SELECT DISTINCT Curr.StepItemID AS CommonID, Curr.LookupValue AS KeyName,Curr.LookupName AS KeyValue,Curr.VersionNum
													FROM ',@TableInitial,'_Framework_Lookups_history Curr	
														 INNER JOIN ',@TableInitial,'_Framework_StepItems_history Curr_Met ON Curr_Met.StepItemID = Curr.StepItemID	
														 INNER JOIN ',@TableInitial,'_Framework_Steps_history Curr_Steps ON Curr_Steps.StepID = Curr_Met.StepID	 
													WHERE Curr.VersionNum IN (',@PrevVersionNum,',',@VersionNum,') 
														  AND ISNULL(Curr.OperationType,''1'') <> ''DELETE''
													)TAB' 
											  )
			
							PRINT @Query

							INSERT INTO #TMP_Items(CommonID,KeyName,KeyValue,VersionNum)	
								EXEC (@Query)

						INSERT INTO #TMP_OperationType(HistoryTableName,CommonID,KeyColName,ModuleName,KeyName,OldValue,NewValue,OperationType)
							SELECT @HistoryTableName,
								   CommonID,	
								   @KeyColName,
								   @TableType AS ModuleName,
								   KeyName,
								   MAX(CASE WHEN VersionNum = @PrevVersionNum THEN KeyValue END) AS OldValue,
								   MAX(CASE WHEN VersionNum = @VersionNum THEN KeyValue END) AS NewValue,
								   CAST(NULL AS VARCHAR(50)) AS OperationType
							FROM #TMP_Items
							GROUP BY CommonID, KeyName

						--SELECT * FROM #TMP_Items
						--SELECT * FROM #TMP_OperationType
						--RETURN

						UPDATE #TMP_OperationType
							SET OperationType = 'UPDATE'
						WHERE ModuleName = @TableType
							  AND OldValue <> NewValue
							  AND OldValue IS NOT NULL

						UPDATE #TMP_OperationType
							SET OperationType = 'DELETE'
						WHERE ModuleName = @TableType	
							  AND NewValue IS NULL						  
							  AND OldValue IS NOT NULL							  

						UPDATE #TMP_OperationType
							SET OperationType = 'INSERT'
						WHERE ModuleName = @TableType
							  AND NewValue IS NOT NULL
							  AND OldValue IS NULL
						
						DELETE FROM #TBL_OperationTypeList WHERE ID = @ID
						DELETE FROM #TMP_Items				
						SELECT @Query = NULL,@HistoryTableName = NULL
						
					END		--END OF -> WHILE LOOP

					SELECT * FROM #TMP_OperationType

					--SELECT CONCAT('INSERT INTO ',HistoryTableName,'(UserCreated,DateCreated,VersionNum,PeriodIdentifierID,OperationType,FrameworkID,StepItemID,AttributeKey)',CHAR(10),
					--					' SELECT 1,','''',GETUTCDATE(),'''',',',@VersionNum,',1,''DELETE'',',@FrameworkID,',',CommonID,',''',KeyName,''';'								
					--			)
					--FROM #TMP_OperationType
					--WHERE OperationType ='DELETE'
					--	  AND HistoryTableName LIKE '%Framework_Attributes_History%'
					
					--SELECT CONCAT('INSERT INTO ',HistoryTableName,'(UserCreated,DateCreated,VersionNum,PeriodIdentifierID,OperationType,FrameworkID,StepItemID,StepID,StepItemName)',CHAR(10),
					--					' SELECT 1,','''',GETUTCDATE(),'''',',',@VersionNum,',1,''DELETE'',',@FrameworkID,',',CommonID,',<StepID>,''',KeyName,''';'								
					--			 )
					--FROM #TMP_OperationType T						 
					--WHERE OperationType ='DELETE'
					--	  AND HistoryTableName LIKE '%Framework_StepItems_History%'
					
					--PROCESS DELETES=============================================================================================================
					
					DROP TABLE IF EXISTS #TMP_DELETES

					SELECT IDENTITY(INT,1,1) AS ID, * INTO #TMP_DELETES FROM #TMP_OperationType WHERE OperationType ='DELETE'
					--SELECT * FROM #TMP_DELETES
					WHILE EXISTS(SELECT 1 FROM #TMP_DELETES)
					BEGIN
						
						SELECT @ID = MIN(ID) FROM #TMP_DELETES

						SELECT @HistoryTableName = HistoryTableName,
							   @KeyColName = KeyColName,
							   @KeyName = KeyName,
							   @CommonID = CommonID
						FROM #TMP_DELETES 
						WHERE ID = @ID	
						
						SELECT @cols = CONCAT(@cols,N', ', name , ' ')
						FROM sys.dm_exec_describe_first_result_set(CONCAT(N'SELECT * FROM ', @HistoryTableName) , NULL, 1)
						WHERE NAME <> 'HistoryID';

						SET @cols = STUFF(@cols, 1, 1, N'');						  
							
							IF @cols <> ''
							BEGIN
								SET @SelectCols = @cols
								SET @SelectCols = REPLACE(@SelectCols,'OperationType','''DELETE''')
								SET @SelectCols = REPLACE(@SelectCols,'VersionNum',@VersionNum)
								SET @SelectCols = REPLACE(@SelectCols,'PeriodIdentifierID','1')
								SET @Query = CONCAT('INSERT INTO ',@HistoryTableName,'(',@cols,')', CHAR(10))
								SET @Query = CONCAT(@Query,' SELECT ',@SelectCols,' FROM ',@HistoryTableName, CHAR(10))
								SET @Query = CONCAT(@Query, ' WHERE FrameworkID=',@FrameworkID,' AND VersionNum=',@VersionNum - 1, ' AND ',@KeyColName,'=''',@KeyName,''' AND StepItemID = ', @CommonID, ';')
								PRINT @Query
								EXEC sp_executesql @Query 
							END

							SET @cols = ''
							DELETE FROM #TMP_DELETES WHERE ID = @ID				
							SET @Query = NULL	

					END
					--==========================================================================================================================================================
					
					--AS DELETES HAVE ALREADY BEEN PROCESSED BY ABOVE SNIPPET
					DELETE FROM #TMP_OperationType WHERE OperationType ='DELETE'				
					
					--UPDATE THE OPERATION TYPE FLAG IN HISTORY TABLE
					SET @Query = STUFF(
										(SELECT CONCAT('; ','UPDATE ',HistoryTableName,' SET OperationType=''',OperationType, ''' WHERE FrameworkID = ',@FrameworkID,' AND VersionNum=',@VersionNum,' AND ',KeyColName,'=''',KeyName,''' AND StepItemID = ', CommonID, ';', CHAR(10))
										FROM #TMP_OperationType
										WHERE OperationType IS NOT NULL 
										FOR XML PATH('')
										),1,1,''
									  )
	
					PRINT @Query
					IF @Query IS NOT NULL
						EXEC (@Query)
			
				   DROP TABLE IF EXISTS #TMP_OperationType

		END	--IF @VersionNum > 1

END
 