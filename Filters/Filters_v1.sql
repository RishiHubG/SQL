	USE AGSQA
	GO
	--DECLARE @inputJSON VARCHAR(MAX)=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}'

	DECLARE @inputJSON VARCHAR(MAX)=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation1","conditionId":"21","value1":"b1","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}'
	--SET @inputJSON = '{"viewName":"filterSave","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":34,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"57","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":1,"currentDateSelected2":true,"currentDateSelected1":false,"value2":"2021-12-18","value1":"2021-12-12"},{"columnId":"5","colDataType":"select","colKey":"controlstatus","conditionId":"14","value1":"archive","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"18","value1":"monthly","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"1","colDataType":"textfield","colKey":"name","conditionId":"5","value1":"f","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":"70","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"4","colDataType":"textfield","colKey":"purposeofthecontrol","conditionId":"3","value1":"f","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"19","value1":"manual","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"3","colDataType":"textarea","colKey":"description","conditionId":"42","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]}]}]}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Actual Completion Date","colId":"actualcompletiondate","isSelected":1,"orderid":0},{"colName":"Actual Start Date","colId":"actualstartdate","isSelected":1,"orderid":0},{"colName":"Adhoc Components Approved?","colId":"adhocComponentsApproved","isSelected":1,"orderid":0},{"colName":"Audit Objective","colId":"auditobjective","isSelected":1,"orderid":0},{"colName":"Audit Reference","colId":"auditreference","isSelected":1,"orderid":0},{"colName":"Audit Status","colId":"auditStatus","isSelected":1,"orderid":0},{"colName":"Comments","colId":"comments","isSelected":1,"orderid":0},{"colName":"Comments on Adhoc Components","colId":"commentsOnAdhocComments","isSelected":1,"orderid":0},{"colName":"Date Draft Report Issued","colId":"dateDraftReportIssued","isSelected":1,"orderid":0},{"colName":"Date Final Report Issued","colId":"dateFinalReportIssued","isSelected":1,"orderid":0},{"colName":"Date of Meeting","colId":"dateOfMeeting","isSelected":1,"orderid":0},{"colName":"Executive Summary","colId":"executivesummary","isSelected":1,"orderid":0},{"colName":"Good Practices","colId":"goodPractices","isSelected":1,"orderid":0},{"colName":"High-level description of the overall process","colId":"highleveldescriptionoftheoverallprocess","isSelected":1,"orderid":0},{"colName":"Initial Risk Rating","colId":"initialRiskRating","isSelected":1,"orderid":0},{"colName":"Name of the Manager","colId":"nameOfTheManager","isSelected":1,"orderid":0},{"colName":"Other Audit Objective","colId":"otherauditobjective","isSelected":1,"orderid":0},{"colName":"Period Under Review From","colId":"periodunderreviewfrom","isSelected":1,"orderid":0},{"colName":"Period Under Review To","colId":"periodunderreviewto","isSelected":1,"orderid":0},{"colName":"Planned Completion Date","colId":"plannedcompletiondate","isSelected":1,"orderid":0},{"colName":"Planned Start Date","colId":"plannedstartdate","isSelected":1,"orderid":0},{"colName":"Review Notes","colId":"reviewNotes","isSelected":1,"orderid":0},{"colName":"Scope of Audit","colId":"scopeofaudit","isSelected":1,"orderid":0},{"colName":"Suggested Overall Risk Rating","colId":"suggestedOverallRiskRating","isSelected":1,"orderid":0},{"colName":"Type of Audit","colId":"typeOfAudit","isSelected":1,"orderid":0},{"colName":"Audit Name","colId":"auditname","isSelected":1,"orderid":1}]}';
	SET @inputJSON = '{"viewName":"Check Filter","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":3,"ParentEntityId":196,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"11","colDataType":"select","colKey":"causalctegory","conditionId":"12","items":[{"columnId":-1,"colDataType":"","colKey":"","conditionId":-1,"value1":"","value2":"","items":[]}],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"13","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"9","colDataType":"select","colKey":"controlLevel","conditionId":"14","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"8","colDataType":"select","colKey":"controlType","conditionId":"12","value1":"policyControl","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"22","colDataType":"select","colKey":"controlEffectiveness","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"11","colDataType":"select","colKey":"causalctegory","conditionId":"14","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"22","colDataType":"select","colKey":"controlEffectiveness","conditionId":"12","value1":"ineffective","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"3","colDataType":"textarea","colKey":"description","conditionId":"36","value1":"bb","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"12","value1":"weekly","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"10","colDataType":"select","colKey":"controlCategory","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]}]}]},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":"88","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"56","value1":"2021-12-01","value2":"2021-12-16","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"54","value1":"2021-12-04","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":1},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"4","value1":"b","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"4","colDataType":"textfield","colKey":"purposeofthecontrol","conditionId":"1","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"26","colDataType":"textfield","colKey":"loggedinusergroup","conditionId":"1","value1":"b","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"15","colDataType":"textfield","colKey":"contactrole","conditionId":"2","value1":"c","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]}]},{"columnId":"2","colDataType":"textfield","colKey":"reference","conditionId":"3","value1":"1","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"18","colDataType":"select","colKey":"controlEffectivenessOwner","conditionId":"21","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"7","colDataType":"checkbox","colKey":"addressingregulatoryrequirement","conditionId":"88","value1":"t","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}],"currentUser":false,"topRecords":"ALL","orderByColumn":"-2","sortBy":"desc"},"columns":[]}';
	--SET @inputJSON = '{"viewName":"Filterview2","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":3,"ParentEntityId":196,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":"-100","filters":[{"columnId":"11","colDataType":"select","colKey":"causalctegory","conditionId":"12","items":[{"columnId":-1,"colDataType":"","colKey":"","conditionId":-1,"value1":"","value2":"","items":[]}],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"13","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"9","colDataType":"select","colKey":"controlLevel","conditionId":"14","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"8","colDataType":"select","colKey":"controlType","conditionId":"12","value1":"policyControl","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"22","colDataType":"select","colKey":"controlEffectiveness","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"11","colDataType":"select","colKey":"causalctegory","conditionId":"14","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"22","colDataType":"select","colKey":"controlEffectiveness","conditionId":"12","value1":"ineffective","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"3","colDataType":"textarea","colKey":"description","conditionId":"36","value1":"bb","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"12","value1":"weekly","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"10","colDataType":"select","colKey":"controlCategory","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]}]}]},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":"88","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"56","value1":"2021-12-01","value2":"2021-12-16","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"54","value1":"2021-12-04","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":1},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"4","value1":"b","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"4","colDataType":"textfield","colKey":"purposeofthecontrol","conditionId":"1","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"26","colDataType":"textfield","colKey":"loggedinusergroup","conditionId":"1","value1":"b","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"15","colDataType":"textfield","colKey":"contactrole","conditionId":"2","value1":"c","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]},{"columnId":"3","colDataType":"textarea","colKey":"description","conditionId":"42","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]},{"columnId":"2","colDataType":"textfield","colKey":"reference","conditionId":"3","value1":"1","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"18","colDataType":"select","colKey":"controlEffectivenessOwner","conditionId":"21","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"7","colDataType":"checkbox","colKey":"addressingregulatoryrequirement","conditionId":"88","value1":"t","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}],"currentUser":false,"topRecords":"ALL","orderByColumn":"-2","sortBy":"desc"},"columns":[]}',@MethodName=NULL,@UserLoginID=3866exec SaveCustomViewJSONData @inputJSON=N'{"viewName":"Filterview2","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":3,"ParentEntityId":196,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":"-100","filters":[{"columnId":"11","colDataType":"select","colKey":"causalctegory","conditionId":"12","items":[{"columnId":-1,"colDataType":"","colKey":"","conditionId":-1,"value1":"","value2":"","items":[]}],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"13","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"9","colDataType":"select","colKey":"controlLevel","conditionId":"14","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"8","colDataType":"select","colKey":"controlType","conditionId":"12","value1":"policyControl","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"22","colDataType":"select","colKey":"controlEffectiveness","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"11","colDataType":"select","colKey":"causalctegory","conditionId":"14","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"22","colDataType":"select","colKey":"controlEffectiveness","conditionId":"12","value1":"ineffective","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"3","colDataType":"textarea","colKey":"description","conditionId":"36","value1":"bb","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"19","colDataType":"select","colKey":"controlfrequency","conditionId":"12","value1":"weekly","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"10","colDataType":"select","colKey":"controlCategory","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]}]}]},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":"88","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"56","value1":"2021-12-01","value2":"2021-12-16","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"54","value1":"2021-12-04","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":1},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"4","value1":"b","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"4","colDataType":"textfield","colKey":"purposeofthecontrol","conditionId":"1","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"26","colDataType":"textfield","colKey":"loggedinusergroup","conditionId":"1","value1":"b","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"15","colDataType":"textfield","colKey":"contactrole","conditionId":"2","value1":"c","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]},{"columnId":"3","colDataType":"textarea","colKey":"description","conditionId":"42","value1":"a","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}]},{"columnId":"2","colDataType":"textfield","colKey":"reference","conditionId":"3","value1":"1","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"18","colDataType":"select","colKey":"controlEffectivenessOwner","conditionId":"21","value1":"","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"7","colDataType":"checkbox","colKey":"addressingregulatoryrequirement","conditionId":"88","value1":"t","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null}],"currentUser":false,"topRecords":"ALL","orderByColumn":"-2","sortBy":"desc"},"columns":[]}'
	SET @inputJSON = '{"EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":38,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":"-100","filters":[{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-99,"items":[{"columnId":"1","colDataType":"textfield","colKey":"name","conditionId":"3","value1":"abc","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"3","colDataType":"number","colKey":"componentweight","conditionId":"64","value1":"10","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"8","colDataType":"select","colKey":"controlsOperatingEffectively","conditionId":"12","value1":"No","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-99,"value1":"","value2":"","items":[{"columnId":"5","colDataType":"number","colKey":"overallweight","conditionId":"62","value1":"5","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"7","colDataType":"number","colKey":"testerror","conditionId":"63","value1":"0","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"13","colDataType":"number","colKey":"totalsamplesize","conditionId":"66","value1":"1","value2":"100","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":null}],"noOfValuesRequired":0,"daysRequired":0,"currentDateRequired":0}],"noOfValuesRequired":0,"daysRequired":0,"currentDateRequired":0,"value1":"","value2":""},{"columnId":"21","colDataType":"textarea","colKey":"objective","conditionId":"36","value1":"under","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"10","colDataType":"textarea","colKey":"objective","conditionId":"36","value1":"New","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"21","colDataType":"textarea","colKey":"objective","conditionId":"38","value1":"Billing","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"1","colDataType":"textfield","colKey":"name","conditionId":"5","value1":"Errors","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-99,"value1":"","value2":"","items":[{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"54","value1":"2021-11-30","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"2021-11-29","value2":"2021-12-15","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":1},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-99,"value1":"","value2":"","items":[{"columnId":"7","colDataType":"number","colKey":"testerror","conditionId":"64","value1":"1","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"4","colDataType":"number","colKey":"totalerrors","conditionId":"64","value1":"10","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"2","colDataType":"number","colKey":"totalsamplesize","conditionId":"62","value1":"100","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"-100","colDataType":"any","colKey":"any","conditionId":-99,"value1":"","value2":"","items":[{"columnId":"12","colDataType":"textfield","colKey":"name","conditionId":"4","value1":"rrr","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"2","colDataType":"number","colKey":"totalsamplesize","conditionId":"65","value1":"50","value2":"","items":[],"noOfValuesRequired":1,"daysRequired":null,"currentDateRequired":null},{"columnId":"7","colDataType":"number","colKey":"testerror","conditionId":"67","value1":"8","value2":"30","items":[],"noOfValuesRequired":2,"daysRequired":null,"currentDateRequired":null}],"noOfValuesRequired":0,"daysRequired":0,"currentDateRequired":0}],"noOfValuesRequired":0,"daysRequired":0,"currentDateRequired":0}],"noOfValuesRequired":0,"daysRequired":0,"currentDateRequired":0}],"currentUser":true,"topRecords":"150","orderByColumn":"1","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":0},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":0},{"colName":"Controls Operating Effectively?","colId":"controlsOperatingEffectively","isSelected":1,"orderid":0},{"colName":"Objective","colId":"objective","isSelected":1,"orderid":0},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":0},{"colName":"Risk Assessment","colId":"riskAssessment","isSelected":1,"orderid":0},{"colName":"Sub Component Name","colId":"name","isSelected":1,"orderid":0},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":0},{"colName":"Total Errors","colId":"totalerrors","isSelected":1,"orderid":0},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":0}]}'

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
					  --CAST(ROW_NUMBER()OVER(PARTITION BY Parent_ID ORDER BY Element_ID) AS VARCHAR(MAX)) AS Path,
					  CAST('' AS VARCHAR(MAX)) AS Parents
				 FROM #TMP_FiltersData T			  
				 WHERE ColumnName ='items'

				 UNION ALL

				 SELECT T.Element_ID,
					   T.ColumnName, 
					   T.Parent_ID,			   
					   T.StringValue,
					   T.ValueType,
					  -- CAST(CONCAT(C.Path ,'.' , ROW_NUMBER()OVER(PARTITION BY T.Parent_ID ORDER BY T.Element_ID)) AS VARCHAR(MAX)),
					   CAST(CASE WHEN C.Parents = ''
							THEN(CAST(T.Parent_ID AS VARCHAR(MAX)))
							ELSE(C.Parents + '.' + CAST(T.Parent_ID AS VARCHAR(MAX)))
					   END AS VARCHAR(MAX))
				 FROM CTE_ItemsFiltersData C
					  INNER JOIN #TMP_FiltersData T ON T.Parent_ID = C.Element_ID
		
			)

			--SELECT *				 
			--FROM CTE_ItemsFiltersData ORDER BY Element_ID
			--RETURN
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
				   --CAST(NULL AS VARCHAR(MAX)) AS Path,
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
					value2 = CASE WHEN ISNULL(value2,'')<>'' THEN CONCAT(CHAR(39),value2,CHAR(39)) ELSE value2 END
			WHERE OperatorType IN ('Between','Not Between','<','<=','>','>=')			
			------------------------------------------------------------------------
			
			--REPLACE <COLVALUE>,<COLNAME> WITH ACTUAL VALUE--------------------------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			--UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'
			
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLVALUE>',value1),value1='' WHERE OperatorType LIKE '%<COLVALUE>%'
			--UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'			
			---------------------------------------------------------------------------------------------------------

			--UPDATE FOR OperatorType2 FOR BETWEEN----------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition 
				SET OperatorType2 = 'AND'
			WHERE OperatorType IN ('Between','Not Between')						
			-------------------------------------------------------------------------------
			
			--;WITH CTE 
			--AS(
			--SELECT *,
			--	  ROW_NUMBER()OVER(PARTITION BY Element_ID ORDER BY ELEMENT_ID, Path DESC) AS ROWNUM
			--FROM #TMP_CTE_ItemsFiltersData
			--)

			--DELETE FROM CTE WHERE ROWNUM > 1

			UPDATE TMP
				SET Parents = CTE.Parents
					--Path = CTE.Path
			FROM #TMP_ItemsWithMatchCondition TMP
				 INNER JOIN #TMP_CTE_ItemsFiltersData CTE ON CTE.StringValue = TMP.colKey AND CTE.Parent_ID = TMP.Parent_ID
			WHERE CTE.ColumnName='colKey'		

			--MAKING colKey EMPTY IN CASE COLUMN IS USED WITHIN OPERATOR EX. ISNULL(COLUMN,1)
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'
			UPDATE #TMP_ItemsWithMatchCondition SET OperatorType =REPLACE(OperatorType,'<COLNAME>',colKey),colKey='' WHERE OperatorType LIKE '%<COLNAME>%'

			--UPDATE FOR OperatorType2 FOR BETWEEN----------------------------------------
			UPDATE #TMP_ItemsWithMatchCondition 
				SET OperatorType2 = 'AND'
			WHERE OperatorType IN ('Between','Not Between')						
			-------------------------------------------------------------------------------

			SELECT * FROM #TMP_FiltersWithMatchCondition
			--IF ItemID(THIS IS THE IMMEDIATE PARENTID OF THE ELEMENT) IS ALSO PART OF "PARENTS" THEN THOSE ELEMENTS ARE PART OF THE SAME HIERARCHY
			SELECT * FROM #TMP_ItemsWithMatchCondition
			--RETURN
			--SELECT * FROM #TMP_CTE_ItemsFiltersData WHERE ColumnName='colKey' AND StringValue='controlfrequency' AND Parent_ID=179 ORDER BY Element_ID
		  

			--SELECT CONCAT(colKey,CHAR(32),OperatorType,CHAR(32),value1, CHAR(32),OperatorType2,CHAR(32), value2) 
			--FROM #TMP_FiltersWithMatchCondition
		
			--SINGLE QUOTES FOR DATES--------------------------------------------------------------------------------------
			UPDATE #TMP_FiltersWithMatchCondition
				SET value1 = CONCAT(CHAR(39),value1,CHAR(39)),
					value2 = CASE WHEN ISNULL(value2,'') <> ''  THEN CONCAT(CHAR(39),value2,CHAR(39)) ELSE value2 END
			WHERE colKey LIKE '%Date%' --IN (('Between','Not Between','>','>=',,'<','<=')
			
			UPDATE #TMP_ItemsWithMatchCondition
				SET value1 = CONCAT(CHAR(39),value1,CHAR(39)),
					value2 = CASE WHEN ISNULL(value2,'') <> ''  THEN CONCAT(CHAR(39),value2,CHAR(39)) ELSE value2 END
			WHERE colKey LIKE '%Date%' --IN (('Between','Not Between','>','>=',,'<','<=')			
			-----------------------------------------------------------------------------------------------------------------

			DROP TABLE IF EXISTS #TMP_FilterItems
			DROP TABLE IF EXISTS #TMP_JoinStmt

			SELECT ItemID, MatchCondition, CONCAT(colKey,CHAR(32),OperatorType,CHAR(32),value1, CHAR(32),OperatorType2,CHAR(32), value2) AS ColName, 
				   Parents
				INTO #TMP_FilterItems
			FROM #TMP_ItemsWithMatchCondition			

			
			--SELECT * FROM #TMP_ItemsWithMatchCondition
			--RETURN
			SELECT 
			ItemID,
			STUFF((
			SELECT  CONCAT(' ',MatchCondition,CHAR(10),ColName)
			FROM #TMP_FilterItems 
			WHERE ItemID = TMP.ItemID			
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,1,'') AS JoinString,
			MAX(Parents) AS Parents,
			MAX(MatchCondition) AS MatchCondition
			--(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'ID') AS ContactID,
			--(SELECT MAX(StringValue) FROM #TMP WHERE ParentID = TMP.ParentID AND ColumnName = 'Role') AS RoleTypeID
			INTO #TMP_JoinStmt	
		FROM #TMP_FilterItems TMP
		GROUP BY ItemID

		--REPLACING THE 1ST AND/OR WITH EMPTY STRING
		UPDATE #TMP_JoinStmt SET JoinString = CONCAT('(',STUFF(JoinString,1,3,''),')')

		ALTER TABLE #TMP_JoinStmt ADD JoinCondition VARCHAR(50),GroupID INT

		--IF ItemID(THIS IS THE IMMEDIATE PARENTID OF THE ELEMENT) IS ALSO PART OF "PARENTS" THEN THOSE ELEMENTS ARE PART OF THE SAME HIERARCHY
		UPDATE TMP
			SET GroupID = ISNULL(TAB.ItemID,TMP.ItemID),
				JoinCondition = ISNULL(TAB.MatchCondition,TMP.MatchCondition)
		FROM #TMP_JoinStmt TMP
			 OUTER APPLY (	
							SELECT ItemID, MatchCondition
							FROM #TMP_JoinStmt
							WHERE TMP.Parents LIKE CONCAT('%',ItemID,'%')								   
						 )TAB

		SELECT * FROM #TMP_JoinStmt

		DROP TABLE IF EXISTS #TMP_FinalItemsJoin

		SELECT 
			GroupID,
			STUFF((
			SELECT  CONCAT(' ',JoinCondition,CHAR(10),JoinString,CHAR(10))
			FROM #TMP_JoinStmt 
			WHERE GroupID = TMP.GroupID			
			FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)')
			,1,1,'') AS JoinString
			INTO #TMP_FinalItemsJoin
		FROM #TMP_JoinStmt TMP
		GROUP BY GroupID
		HAVING COUNT(*)>1

		--REPLACING THE 1ST AND/OR WITH EMPTY STRING
		UPDATE #TMP_FinalItemsJoin SET JoinString = CONCAT('(',STUFF(JoinString,1,3,''),')')

		--SELECT STRING_AGG(JoinString,@matchCondition)
		--FROM
		--(

		DROP TABLE IF EXISTS #TMP

		--CLUB TOGETHER ALL FILTER CONDITIONS
		SELECT 1 AS NUM,JoinString
			INTO #TMP
		FROM #TMP_JoinStmt --#TMP_FiltersWithMatchCondition
		UNION
		SELECT 2,JoinString FROM #TMP_FinalItemsJoin		 
		ORDER BY NUM
		--)TAB
		
		ALTER TABLE #TMP ADD ID INT IDENTITY(1,1) PRIMARY KEY

		SELECT * FROM #TMP

		SET @matchCondition =  CONCAT(' ',@matchCondition,' ')
		
		SELECT STRING_AGG(JoinString,@matchCondition) AS QueryCondition
		FROM #TMP
		

		--(

		

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