	--DECLARE @inputJSON VARCHAR(MAX)=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}'

	DECLARE @inputJSON VARCHAR(MAX)=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation1","conditionId":"21","value1":"b1","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}'
	
	DROP TABLE IF EXISTS #TMP_ALLSTEPS
	DROP TABLE IF EXISTS #TMP_FiltersData
	DROP TABLE IF EXISTS #TMP_FiltersWithMatchCondition

	SELECT *
			INTO #TMP_ALLSTEPS
	 FROM dbo.HierarchyFromJSON(@inputJSON) 

	 --SELECT * FROM #TMP_ALLSTEPS

	 ;WITH CTE_FiltersData
			AS
			(		
				SELECT T.Element_ID,
					   T.Name AS ColumnName, 
					   T.Parent_ID,	   
					   T.StringValue,
					   T.ValueType
				 FROM #TMP_ALLSTEPS T			  
				 WHERE Name ='filtersData'

				 UNION ALL

				 SELECT T.Element_ID,
					   T.Name, 
					   T.Parent_ID,			   
					   T.StringValue,
					   T.ValueType
				 FROM CTE_FiltersData C
					  INNER JOIN #TMP_ALLSTEPS T ON T.Parent_ID = C.Element_ID
		
			)

			SELECT * 
				INTO #TMP_FiltersData
			FROM CTE_FiltersData --WHERE ValueType ='boolean' AND  StringValue = 'true'

			SELECT * FROM #TMP_FiltersData ORDER BY ELEMENT_ID--WHERE ColumnName IN ('colKey','conditionId','value1','value2') ORDER BY Element_ID

			SELECT Parent_ID,
				   MAX(CASE WHEN ColumnName = 'colKey' THEN StringValue END) AS colKey,
				   MAX(CASE WHEN ColumnName = 'conditionId' THEN StringValue END) AS conditionId,
				   MAX(CASE WHEN ColumnName = 'value1' THEN StringValue END) AS value1,
				   MAX(CASE WHEN ColumnName = 'value2' THEN StringValue END) AS value2,
				   CAST(NULL AS VARCHAR(50)) AS MatchCondition,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType
				INTO #TMP_FiltersWithMatchCondition
			FROM #TMP_FiltersData
			--WHERE StringValue IS NOT NULL
			--	  AND StringValue <> 'all'
			GROUP BY Parent_ID

			DELETE FROM #TMP_FiltersWithMatchCondition
			WHERE colKey IS NULL
				  OR colKey ='all'

			DECLARE @matchCondition VARCHAR(10) = (SELECT CASE WHEN StringValue = -200 THEN 'AND' ELSE 'OR' END FROM #TMP_FiltersData WHERE ColumnName ='matchCondition')
			--SELECT @matchCondition

			UPDATE #TMP_FiltersWithMatchCondition SET MatchCondition = @matchCondition

			SELECT * FROM #TMP_FiltersWithMatchCondition

			--SELECT Parent_ID							
			--FROM #TMP_FiltersData TMP
			--	 CROSS APPLY (
			--					SELECT StringValue
			--					FROM #TMP_FiltersData 
			--					WHERE Parent_ID = TMP.Parent_ID
			--						  AND 
				 
			--				)
			--WHERE ColumnName IN ('colKey','conditionId','value1','value2') 
			--GROUP BY Parent_ID
			 

		DROP TABLE IF EXISTS #TMP_ItemsWithMatchCondition
		
		--THESE ARE CHILD CONDITIONS
		;WITH CTE_ItemsFiltersData
			AS
			(		
				SELECT T.Element_ID,
					   T.ColumnName, 
					   T.Parent_ID,	   
					   T.StringValue,
					   T.ValueType
				 FROM #TMP_FiltersData T			  
				 WHERE ColumnName ='items'

				 UNION ALL

				 SELECT T.Element_ID,
					   T.ColumnName, 
					   T.Parent_ID,			   
					   T.StringValue,
					   T.ValueType
				 FROM CTE_ItemsFiltersData C
					  INNER JOIN #TMP_FiltersData T ON T.Parent_ID = C.Element_ID
		
			)

			--SELECT *				 
			--FROM CTE_ItemsFiltersData 

			SELECT Parent_ID,
				   MAX(CASE WHEN ColumnName = 'colKey' THEN StringValue END) AS colKey,
				   MAX(CASE WHEN ColumnName = 'conditionId' THEN StringValue END) AS conditionId,
				   MAX(CASE WHEN ColumnName = 'value1' THEN StringValue END) AS value1,
				   MAX(CASE WHEN ColumnName = 'value2' THEN StringValue END) AS value2,
				   CAST(NULL AS VARCHAR(50)) AS MatchCondition,
				   CAST(NULL AS INT) AS ItemID,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType
				INTO #TMP_ItemsWithMatchCondition
			FROM CTE_ItemsFiltersData
			--WHERE StringValue IS NOT NULL
			--	  AND StringValue <> 'all'
			GROUP BY Parent_ID

			DELETE FROM #TMP_ItemsWithMatchCondition WHERE colKey IS NULL

			SELECT * FROM #TMP_ItemsWithMatchCondition

			--SELECT * FROM #TMP_FiltersData WHERE Element_ID IN (112,113)
			--SELECT * FROM #TMP_FiltersData WHERE Element_ID IN (88)

			DROP TABLE IF EXISTS #TMP_Items

			SELECT TMC.Parent_ID, 
				   T4.StringValue,
				   CASE WHEN T4.StringValue = -200 THEN 'AND' ELSE 'OR' END AS MatchCondition,
				   T4.Parent_ID AS ItemID,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType
				INTO #TMP_Items
			FROM #TMP_ItemsWithMatchCondition TMC
				 INNER JOIN #TMP_FiltersData T2 ON T2.Element_ID = TMC.Parent_ID
				 INNER JOIN #TMP_FiltersData T3 ON T3.Element_ID = T2.Parent_ID
				 INNER JOIN #TMP_FiltersData T4 ON T4.Parent_ID = T3.Parent_ID
			WHERE T4.ColumnName = 'columnId'

			UPDATE TMP
				SET MatchCondition = TI.MatchCondition,
					ItemID = TI.ItemID					
			FROM #TMP_ItemsWithMatchCondition TMP
				 INNER JOIN #TMP_Items TI ON TI.Parent_ID = TMP.Parent_ID

			UPDATE TMP
				SET OperatorType = FCM.OperatorType					 		
			FROM #TMP_ItemsWithMatchCondition TMP
				 INNER JOIN dbo.Filterconditions_Master FCM ON FCM.FilterTypeID = TMP.conditionId
			
			UPDATE TMP
				SET OperatorType = FCM.OperatorType					 		
			FROM #TMP_FiltersWithMatchCondition TMP
				 INNER JOIN dbo.Filterconditions_Master FCM ON FCM.FilterTypeID = TMP.conditionId
			
			DELETE TMP FROM #TMP_FiltersWithMatchCondition TMP
			WHERE EXISTS(SELECT 1 FROM #TMP_ItemsWithMatchCondition WHERE Parent_ID = TMP.Parent_ID)

			SELECT * FROM #TMP_FiltersWithMatchCondition
			SELECT * FROM #TMP_ItemsWithMatchCondition

			/*ALTERNATE FOR THE ABOVE WOULD BE A RECURSIVE CTE AS BELOW': WE STILL NEED TO APPLY ONE MORE LAST JOIN/FILTER FOR ColumnName = 'columnId' TO REACH THE ABOVE RESULT
			;WITH CTE_ItemsFiltersData
			AS
			(		
				SELECT NULL AS Element_ID,
					   T.Parent_ID,	   
					   CAST(NULL AS VARCHAR(50)) AS StringValue,
					   CAST(NULL AS VARCHAR(50)) AS ColumnName
				 FROM #TMP_ItemsWithMatchCondition T

				 UNION ALL

				 SELECT T.Element_ID,	
						T.Parent_ID,
					   CAST(T.StringValue AS VARCHAR(50)),
					   CAST(T.ColumnName AS VARCHAR(50))
				 FROM CTE_ItemsFiltersData C
					  INNER JOIN #TMP_FiltersData T ON T.Element_ID = C.Parent_ID				
		
			)

			SELECT *				 
			FROM CTE_ItemsFiltersData 
			WHERE ColumnName = 'items'
			*/

			--UPDATE #TMP_ItemsWithMatchCondition
			--	SET MatchCondition