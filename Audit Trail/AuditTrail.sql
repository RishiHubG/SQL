 USE VKB_NEW
 GO

--==========================================================================================	
					
					DECLARE @ID INT = 1442
					DROP TABLE IF EXISTS #TMP
					
					DECLARE @FrameworkID INT = 6
					DECLARE @TableName VARCHAR(500) = 'NewAuditFramework'
					DECLARE @TableName_StepItems VARCHAR(500) = CONCAT(@TableName,'_FrameworkStepItems');
					DECLARE @TableName_Data VARCHAR(500) = CONCAT(@TableName,'_data_history'); 

					SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
							DATA_TYPE
						INTO #TMP
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = @TableName_Data
					AND COLUMN_NAME NOT IN ('FrameworkID','HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid','PeriodIdentifier','OperationType');

					DECLARE @strDT VARCHAR(500) = 'CONVERT(NVARCHAR(MAX),<ColName>,20)'
					
					UPDATE #TMP
						SET COL = REPLACE(Col,COLUMN_NAME,REPLACE(@strDT,'<ColName>', COLUMN_NAME))
					WHERE DATA_TYPE = 'datetime'
					 
					UPDATE #TMP
						SET COL = CONCAT('CAST(',REPLACE(Col,'AS NewValue',' AS NVARCHAR(MAX)) AS NewValue'))
					WHERE DATA_TYPE IN('decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'LAG',' CAST(LAG')
					WHERE DATA_TYPE IN('decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'AS OldValue',' AS NVARCHAR(MAX)) AS OldValue')
					WHERE DATA_TYPE IN('decimal','bigint','int');

 
						DECLARE @SQL VARCHAR(MAX)
						SET @SQL = 'SELECT ID, COLUMN_NAME,tab.OldHistoryID,tab.NewHistoryID,tab.DateModified, DATA_TYPE,tab.OldValue,tab.NewValue
									FROM #TMP
										 CROSS APPLY(SELECT TOP 100 PERCENT HistoryID AS NewHistoryID,LAG(HISTORYID)OVER(ORDER BY HISTORYID) AS OldHistoryID,
																DateModified,''<Column_Name>'' AS ColName, <Col> FROM <TableName> 
																		WHERE ID=<ID> ORDER BY DateModified
													)TAB
									WHERE COLUMN_NAME = tab.ColName
										--AND column_name=''actualstartDate''
									'
						SET @SQL =  REPLACE(@SQL,'<ID>', @ID)
						SET @SQL =  REPLACE(@SQL,'<TableName>', @TableName_Data)

					DROP TABLE IF EXISTS #TMP_SQL;

					SELECT *,
						REPLACE(
								REPLACE(ColString,'<Column_Name>',COLUMN_NAME),
								'<Col>', Col) AS strSQL
						INTO #TMP_SQL
					FROM #TMP
						 CROSS APPLY(VALUES(@SQL))TAB(ColString);	
						 
						 --SELECT STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 --FROM #TMP_SQL
						 DROP TABLE IF EXISTS #TMPHistData;

						 CREATE TABLE #TMPHistData(ID INT, Column_Name VARCHAR(500),StepItemName VARCHAR(500),OldHistoryID INT,NewHistoryID INT, DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))

						 DECLARE @STR VARCHAR(MAX)
						 SELECT @str = STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 FROM #TMP_SQL

						 PRINT @STR

						 INSERT INTO #TMPHistData(ID,Column_Name,OldHistoryID,NewHistoryID,DateModified,Data_Type,OldValue,NewValue)
							EXEC(@str)	
								
								--DELETE DATA THAT IS NOT REQUIRED
								 DELETE FROM #TMPHistData
								 WHERE OldHistoryID IS NULL --FIRST VALUE OF EACH COLUMN WILL HAVE OldHistoryID AS NULL (DUE TO LAG), DON'T NEED THIS
										 --IGNORE OLDVALUE/NEWVLAUE NULL/EMPTY STRING COMBINATIONS
									    OR ((NULLIF(OldValue,'') IS NULL AND NULLIF(NewValue,'') IS NULL) )
								 
								 --FETCH STEPITEMNAME
								 SET @SQL = CONCAT('UPDATE Hist
														SET StepItemName = StepItems.StepItemName
													FROM #TMPHistData Hist
														 INNER JOIN ',@TableName_StepItems,' StepItems ON StepItems.StepItemKey = Hist.Column_Name
														 WHERE StepItems.FrameworkID = ',@FrameworkID
												 )								
								PRINT @SQL
								EXEC(@SQL)

								/*
								 ;WITH CTE
								 AS
								 (
								   SELECT *--, ROW_NUMBER()OVER(PARTITION BY Column_Name,DateModified Order By OldValue) AS RowNum
								   FROM #TMPHistData
								   /* HANDLED IN THE ABOVE DELETE
								   WHERE OldHistoryID IS NOT NULL --FIRST VALUE OF EACH COLUMN WILL HAVE OldHistoryID AS NULL (DUE TO LAG), DON'T NEED THIS
										 --IGNORE OLDVALUE/NEWVLAUE NULL/EMPTY STRING COMBINATIONS
									     AND NOT (NULLIF(OldValue,'') IS NULL AND NULLIF(NewValue,'') IS NULL) 
									*/
								 )
								 SELECT * FROM CTE
								 WHERE ISNULL(OldValue,-1) <> ISNULL(NewValue,-1)
								 ORDER BY NewHistoryID
								*/

								 SELECT * FROM #TMPHistData
								 WHERE ISNULL(OldValue,-1) <> ISNULL(NewValue,-1)
								 ORDER BY NewHistoryID

			 --==========================================================================================

		

			