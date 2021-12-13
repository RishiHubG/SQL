	--DECLARE @inputJSON VARCHAR(MAX)=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}'

	DECLARE @inputJSON VARCHAR(MAX)=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation1","conditionId":"21","value1":"b1","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}'
	SET @inputJSON = '{"viewName":"filterSave","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":34,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"57","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":1,"currentDateSelected2":true,"currentDateSelected1":false,"value2":"2021-12-18","value1":"2021-12-12"},{"columnId":"5","colDataType":"select","colKey":"controlstatus","conditionId":"14","value1":"archive","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"18","value1":"monthly","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"1","colDataType":"textfield","colKey":"name","conditionId":"5","value1":"f","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":"70","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"4","colDataType":"textfield","colKey":"purposeofthecontrol","conditionId":"3","value1":"f","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"19","value1":"manual","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"3","colDataType":"textarea","colKey":"description","conditionId":"42","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]}]}]}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Actual Completion Date","colId":"actualcompletiondate","isSelected":1,"orderid":0},{"colName":"Actual Start Date","colId":"actualstartdate","isSelected":1,"orderid":0},{"colName":"Adhoc Components Approved?","colId":"adhocComponentsApproved","isSelected":1,"orderid":0},{"colName":"Audit Objective","colId":"auditobjective","isSelected":1,"orderid":0},{"colName":"Audit Reference","colId":"auditreference","isSelected":1,"orderid":0},{"colName":"Audit Status","colId":"auditStatus","isSelected":1,"orderid":0},{"colName":"Comments","colId":"comments","isSelected":1,"orderid":0},{"colName":"Comments on Adhoc Components","colId":"commentsOnAdhocComments","isSelected":1,"orderid":0},{"colName":"Date Draft Report Issued","colId":"dateDraftReportIssued","isSelected":1,"orderid":0},{"colName":"Date Final Report Issued","colId":"dateFinalReportIssued","isSelected":1,"orderid":0},{"colName":"Date of Meeting","colId":"dateOfMeeting","isSelected":1,"orderid":0},{"colName":"Executive Summary","colId":"executivesummary","isSelected":1,"orderid":0},{"colName":"Good Practices","colId":"goodPractices","isSelected":1,"orderid":0},{"colName":"High-level description of the overall process","colId":"highleveldescriptionoftheoverallprocess","isSelected":1,"orderid":0},{"colName":"Initial Risk Rating","colId":"initialRiskRating","isSelected":1,"orderid":0},{"colName":"Name of the Manager","colId":"nameOfTheManager","isSelected":1,"orderid":0},{"colName":"Other Audit Objective","colId":"otherauditobjective","isSelected":1,"orderid":0},{"colName":"Period Under Review From","colId":"periodunderreviewfrom","isSelected":1,"orderid":0},{"colName":"Period Under Review To","colId":"periodunderreviewto","isSelected":1,"orderid":0},{"colName":"Planned Completion Date","colId":"plannedcompletiondate","isSelected":1,"orderid":0},{"colName":"Planned Start Date","colId":"plannedstartdate","isSelected":1,"orderid":0},{"colName":"Review Notes","colId":"reviewNotes","isSelected":1,"orderid":0},{"colName":"Scope of Audit","colId":"scopeofaudit","isSelected":1,"orderid":0},{"colName":"Suggested Overall Risk Rating","colId":"suggestedOverallRiskRating","isSelected":1,"orderid":0},{"colName":"Type of Audit","colId":"typeOfAudit","isSelected":1,"orderid":0},{"colName":"Audit Name","colId":"auditname","isSelected":1,"orderid":1}]}'

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
				   CAST(NULL AS VARCHAR(100)) AS OperatorType,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType2
				INTO #TMP_FiltersWithMatchCondition
			FROM #TMP_FiltersData
			--WHERE StringValue IS NOT NULL
			--	  AND StringValue <> 'all'
			GROUP BY Parent_ID

			DELETE FROM #TMP_FiltersWithMatchCondition
			WHERE colKey IS NULL
				  OR colKey IN ('any','all')

			DECLARE @matchCondition VARCHAR(10) = (SELECT CASE WHEN StringValue = -200 THEN 'AND' ELSE 'OR' END FROM #TMP_FiltersData WHERE ColumnName ='matchCondition')
			--SELECT @matchCondition

			UPDATE #TMP_FiltersWithMatchCondition SET MatchCondition = @matchCondition

			--DELETE FROM #TMP_FiltersWithMatchCondition WHERE (colKey IS NULL OR colKey IN ('any','all'))

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
		DROP TABLE IF EXISTS #TMP_CTE_ItemsFiltersData

		--THESE ARE CHILD CONDITIONS
		;WITH CTE_ItemsFiltersData
			AS
			(		
				SELECT T.Element_ID,
					   T.ColumnName, 
					   T.Parent_ID,	   
					   T.StringValue,
					   T.ValueType,
					  CAST(ROW_NUMBER()OVER(PARTITION BY Parent_ID ORDER BY Element_ID) AS VARCHAR(MAX)) AS Path,
					  CAST('' AS VARCHAR(MAX)) AS Parents
				 FROM #TMP_FiltersData T			  
				 WHERE ColumnName ='items'

				 UNION ALL

				 SELECT T.Element_ID,
					   T.ColumnName, 
					   T.Parent_ID,			   
					   T.StringValue,
					   T.ValueType,
					   CAST(CONCAT(C.Path ,'.' , ROW_NUMBER()OVER(PARTITION BY T.Parent_ID ORDER BY T.Element_ID)) AS VARCHAR(MAX)),
					   CAST(CASE WHEN C.Parents = ''
							THEN(CAST(T.Parent_ID AS VARCHAR(MAX)))
							ELSE(C.Parents + '.' + CAST(T.Parent_ID AS VARCHAR(MAX)))
					   END AS VARCHAR(MAX))
				 FROM CTE_ItemsFiltersData C
					  INNER JOIN #TMP_FiltersData T ON T.Parent_ID = C.Element_ID
		
			)

			--SELECT *				 
			--FROM CTE_ItemsFiltersData 

			SELECT DISTINCT *, CAST(NULL AS VARCHAR(50)) AS MatchCondition
				INTO #TMP_CTE_ItemsFiltersData
			FROM CTE_ItemsFiltersData 
			 

			--SELECT * FROM #TMP_CTE_ItemsFiltersData WHERE ColumnName NOT LIKE '%[^0-9]%' ORDER BY Element_ID
			
			--UPDATE THE BOOLEAN CONDITION BETWEEN FILTERS
			UPDATE TMP 
				SET MatchCondition = CASE TF2.StringValue
										WHEN -200 THEN 'AND'
										WHEN -100 THEN 'OR' 
									  END
			FROM #TMP_CTE_ItemsFiltersData TMP
				 INNER JOIN #TMP_FiltersData TF1 ON TF1.Element_ID = TMP.Parent_ID
				 INNER JOIN #TMP_FiltersData TF2 ON TF2.Parent_ID = TF1.Parent_ID
			WHERE TMP.ColumnName NOT LIKE '%[^0-9]%' 
				  AND TF2.ColumnName = 'columnId'
				  AND TF1.ColumnName = 'items'
			
			--SELECT * FROM #TMP_CTE_ItemsFiltersData WHERE ColumnName NOT LIKE '%[^0-9]%' ORDER BY Element_ID
			--RETURN

			--WRITING CROSS TAB/PIVOT QUERY
			SELECT Parent_ID,
				   MAX(CASE WHEN ColumnName = 'colKey' THEN StringValue END) AS colKey,
				   --MAX(CASE WHEN ColumnName = 'columnId' THEN StringValue END) AS columnId,
				   MAX(CASE WHEN ColumnName = 'conditionId' THEN StringValue END) AS conditionId,
				   MAX(CASE WHEN ColumnName = 'value1' THEN StringValue END) AS value1,
				   MAX(CASE WHEN ColumnName = 'value2' THEN StringValue END) AS value2,
				   CAST(NULL AS VARCHAR(50)) AS MatchCondition,
				   CAST(NULL AS INT) AS ItemID,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType,
				   CAST(NULL AS VARCHAR(100)) AS OperatorType2,
				   CAST(NULL AS VARCHAR(50)) AS ParentMatchCondition,
				   CAST(NULL AS VARCHAR(MAX)) AS Path,
				   CAST(NULL AS VARCHAR(MAX)) AS Parents
				INTO #TMP_ItemsWithMatchCondition
			FROM #TMP_CTE_ItemsFiltersData
			--WHERE StringValue IS NOT NULL
			--	  AND StringValue <> 'all'
			GROUP BY Parent_ID

			DELETE FROM #TMP_ItemsWithMatchCondition WHERE (colKey IS NULL OR colKey IN ('any','all'))

			--SELECT @matchCondition = CASE WHEN StringValue = -200 THEN 'AND' ELSE 'OR' END FROM #TMP_FiltersData WHERE ColumnName ='matchCondition'

			--UPDATE #TMP_ItemsWithMatchCondition SET ParentMatchCondition = @matchCondition

			SELECT * FROM #TMP_ItemsWithMatchCondition
			--RETURN
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

			--SELECT * FROM #TMP_Items
			--RETURN
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

			--NEED SINGLE QUOTES FOR DATE OPERATIONS-------------------------------
			UPDATE #TMP_FiltersWithMatchCondition 
				SET value1 = CONCAT(CHAR(39),value1,CHAR(39)),
					value2 = CONCAT(CHAR(39),value2,CHAR(39))
			WHERE OperatorType IN ('Between','Not Between','<','<=','>','>=')			
			------------------------------------------------------------------------
			
			--REPLACE <COLVALUE>,<COLNAME> WITH ACTUAL VALUE--------------------------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'

			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'
			---------------------------------------------------------------------------------------------------------

			--UPDATE FOR OperatorType2 FOR BETWEEN----------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition 
				SET OperatorType2 = 'AND'
			WHERE OperatorType IN ('Between','Not Between')						
			-------------------------------------------------------------------------------

			;WITH CTE 
			AS(
			SELECT *,
				  ROW_NUMBER()OVER(PARTITION BY Element_ID ORDER BY ELEMENT_ID, Path DESC) AS ROWNUM
			FROM #TMP_CTE_ItemsFiltersData
			)

			DELETE FROM CTE WHERE ROWNUM > 1

			UPDATE TMP
				SET Path = CTE.Path,
				    Parents = CTE.Parents
			FROM #TMP_ItemsWithMatchCondition TMP
				 INNER JOIN #TMP_CTE_ItemsFiltersData CTE ON CTE.StringValue = TMP.colKey AND CTE.Parent_ID = TMP.Parent_ID
			WHERE CTE.ColumnName='colKey'		

			SELECT * FROM #TMP_FiltersWithMatchCondition
			SELECT * FROM #TMP_ItemsWithMatchCondition
			--SELECT * FROM #TMP_CTE_ItemsFiltersData WHERE ColumnName='colKey' AND StringValue='controlfrequency' AND Parent_ID=179 ORDER BY Element_ID
		  

			SELECT CONCAT(colKey,CHAR(32),OperatorType,CHAR(32),value1, CHAR(32),OperatorType2,CHAR(32), value2) 
			FROM #TMP_FiltersWithMatchCondition
			
			DROP TABLE IF EXISTS #TMP_FilterItems
			DROP TABLE IF EXISTS #TMP_JoinStmt

			SELECT ItemID, MatchCondition, CONCAT(colKey,CHAR(32),OperatorType,CHAR(32),value1, CHAR(32),OperatorType2,CHAR(32), value2) AS ColName
				INTO #TMP_FilterItems
			FROM #TMP_ItemsWithMatchCondition

			SELECT 
			ItemID,
			STUFF((
			SELECT  CONCAT(' ',MatchCondition,CHAR(10),ColName)
			FROM #TMP_FilterItems 
			WHERE ItemID = TMP.ItemID			
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,1,'') AS JoinString
			--(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'ID') AS ContactID,
			--(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'Role') AS RoleTypeID
			INTO #TMP_JoinStmt	
		FROM #TMP_FilterItems TMP
		GROUP BY ItemID

		--REPLACING THE 1ST AND/OR WITH EMPTY STRING
		UPDATE #TMP_JoinStmt SET JoinString = CONCAT('(',STUFF(JoinString,1,3,''),')')

		SELECT * FROM #TMP_JoinStmt
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