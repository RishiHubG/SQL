--==========================================================================================	
					
					DECLARE @ID INT = 335
					DROP TABLE IF EXISTS #TMP

					SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
							DATA_TYPE
						INTO #TMP
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'NewAuditFramework_data_history'
					AND COLUMN_NAME NOT IN ('FrameworkID','HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid','PeriodIdentifier','OperationType');

					
					UPDATE #TMP
						SET COL = CONCAT('CAST(',REPLACE(Col,'AS NewValue',' AS NVARCHAR(MAX)) AS NewValue'))
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'LAG',' CAST(LAG')
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');

					UPDATE #TMP
						SET COL = REPLACE(Col,'AS OldValue',' AS NVARCHAR(MAX)) AS OldValue')
					WHERE DATA_TYPE IN('datetime', 'decimal','bigint','int');


					--SELECT * FROM #TMP

						DECLARE @SQL VARCHAR(MAX)
						SET @SQL = 'SELECT ID, COLUMN_NAME,tab.DateModified, DATA_TYPE,tab.OldValue,tab.NewValue
									FROM #TMP
										 CROSS APPLY(SELECT TOP 100 PERCENT DateModified,''<Column_Name>'' AS ColName, <Col> FROM NewAuditFramework_data_history  
																		WHERE ID=<ID> ORDER BY DateModified
													)TAB
									WHERE COLUMN_NAME = tab.ColName
										--AND column_name=''referencenum''
									'
						SET @SQL =  REPLACE(@SQL,'<ID>', @ID)

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

						 CREATE TABLE #TMPHistData(ID INT, Column_Name VARCHAR(500),DateModified datetime2(6),Data_Type VARCHAR(50),OldValue NVARCHAR(MAX),NewValue NVARCHAR(MAX))

						 DECLARE @STR VARCHAR(MAX)
						 SELECT @str = STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 FROM #TMP_SQL

						 PRINT @STR

						 INSERT INTO #TMPHistData(ID,Column_Name,DateModified,Data_Type,OldValue,NewValue)
							EXEC(@str)	
								
								--WHY ARE THERE DUPLICATE ROWS FOR SOME DATES??
								 ;WITH CTE
								 AS
								 (
								   SELECT *, ROW_NUMBER()OVER(PARTITION BY Column_Name,DateModified Order By OldValue) AS RowNum
								   FROM #TMPHistData
								 )
								 SELECT * FROM CTE
			
			 --==========================================================================================

		

			