USE DEVDB
GO

	SELECT *
	FROM dbo.Frameworks
	WHERE FrameworkID = 335

	SELECT * FROM EntityMetaData

	SELECT * FROM NewAuditFramework_data WHERE ID=335
	SELECT * FROM NewAuditFramework_data_history  WHERE ID=335 ORDER BY DateModified 

	SELECT * FROM Frameworks WHERE frameworkid IN (335)

	SELECT * FROM NewAuditFramework_data WHERE ID=330
	SELECT * FROM NewAuditFramework_FrameworkStepItems
 
	--IF @ParentEntityTypeID = 3
	DECLARE @FrameworkID int = (SELECT frameworkid FROM Registers WHERE registerid = @ParentEntityID)
	DECLARE @TableName VARCHAR(500) 

	SELECT @TableName = CONCAT(Name,'_DATA') ,
		   @VersionNum = VersionNum
	FROM dbo.Frameworks 
	WHERE FrameworkID = @FrameworkID

	SELECT * FROM ContactInst

	ALTER TABLE ContactInst_history ADD  [EntityTypeId] INT, [EntityId] INT

SELECT HistoryID,
		LAG(NAME)OVER(ORDER BY HISTORYID) AS [OldValue.Name],
		name AS NewValue_Name		
FROM NewAuditFramework_data_history  
WHERE ID=335 ORDER BY DateModified 

SELECT CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS [OldValue]', CHAR(10)),*
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NewAuditFramework_data_history'
AND COLUMN_NAME NOT IN ('HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid')

DROP TABLE IF EXISTS #TMP

SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
		DATA_TYPE
	INTO #TMP
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NewAuditFramework_data_history'
AND COLUMN_NAME NOT IN ('HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid');

UPDATE #TMP
	SET COL = CONCAT('CAST(',REPLACE(Col,'AS NewValue',' AS NVARCHAR(MAX)) AS NewValue'))
WHERE DATA_TYPE IN('datetime', 'decimal');

UPDATE #TMP
	SET COL = REPLACE(Col,'LAG',' CAST(LAG')
WHERE DATA_TYPE IN('datetime', 'decimal');

UPDATE #TMP
	SET COL = REPLACE(Col,'AS OldValue',' AS NVARCHAR(MAX)) AS OldValue')
WHERE DATA_TYPE IN('datetime', 'decimal');

SELECT * FROM #TMP

				DECLARE @str VARCHAR(MAX)	
				SET	@str = 			 
						STUFF((
						SELECT  CONCAT(', ',Col, CHAR(10))
						FROM #TMP									 
						ORDER BY ID
						FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
						,1,2,'') 
						
				--PRINT @str
				
				SET @Str = CONCAT('SELECT ', @Str, 'FROM NewAuditFramework_data_history  
												    WHERE ID=335 ORDER BY DateModified '
								  )
				PRINT @str

				EXEC(@Str)
				
				SELECT ID, COLUMN_NAME,
					   tab.DateModified,
					   DATA_TYPE,
					   tab.OldValue,
					   tab.NewValue
				FROM #TMP
					 CROSS APPLY(SELECT TOP 100 PERCENT DateModified,'referencenum' AS ColName, referencenum AS NewValue, LAG(referencenum)OVER(ORDER BY HISTORYID) AS [OldValue]  FROM NewAuditFramework_data_history  
												    WHERE ID=335 ORDER BY DateModified  )TAB
				WHERE COLUMN_NAME = tab.ColName
				ORDER BY ID


				--==========================================================================================	
					
					DECLARE @ID INT = 335
					DROP TABLE IF EXISTS #TMP

					SELECT IDENTITY(INT,1,1) AS ID, COLUMN_NAME, CONCAT(COLUMN_NAME,' AS NewValue, LAG(',COLUMN_NAME,')OVER(ORDER BY HISTORYID) AS OldValue', CHAR(10)) AS Col,
							DATA_TYPE
						INTO #TMP
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'NewAuditFramework_data_history'
					AND COLUMN_NAME NOT IN ('HistoryID','ID','UserCreated','DateCreated','UserModified','DateModified','VersionNum','registerid');

					
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

						 DECLARE @STR VARCHAR(MAX)
						 SELECT @str = STRING_AGG(strSQL, CONCAT( CHAR(10),' UNION ', CHAR(10), CHAR(10)))
						 FROM #TMP_SQL

						 PRINT @STR

						 EXEC(@str)
			
			 --==========================================================================================
			   