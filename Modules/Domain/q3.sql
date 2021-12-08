DECLARE @inputJSON VARCHAR(MAX) ='{
  "general.name": {
    "label": "Name",
    "labelPosition": "top",
    "placeholder": "",
    "description": "",
    "tooltip": "",
    "prefix": "",
    "suffix": "",
    "widget": {
      "type": "input"
    },
    "inputMask": "",
    "allowMultipleMasks": false,
    "customClass": "",
    "tabindex": "",
    "autocomplete": "",
    "hidden": false,
    "hideLabel": false,
    "showWordCount": false,
    "showCharCount": false,
    "mask": false,
    "autofocus": false,
    "spellcheck": true,
    "disabled": false,
    "tableView": true,
    "modalEdit": false,
    "multiple": false,
    "persistent": true,
    "inputFormat": "plain",
    "protected": false,
    "dbIndex": false,
    "case": "",
    "encrypted": false,
    "redrawOn": "",
    "clearOnHide": true,
    "customDefaultValue": "",
    "calculateValue": "",
    "calculateServer": false,
    "allowCalculateOverride": false,
    "validateOn": "change",
    "validate": {
      "required": false,
      "pattern": "",
      "customMessage": "",
      "custom": "",
      "customPrivate": false,
      "json": "",
      "minLength": "",
      "maxLength": "",
      "strictDateValidation": false,
      "multiple": false,
      "unique": false
    },
    "unique": false,
    "errorLabel": "",
    "key": "name",
    "tags": [],
    "properties": {},
    "conditional": {
      "show": null,
      "when": null,
      "eq": "",
      "json": ""
    },
    "customConditional": "",
    "logic": [],
    "attributes": {},
    "overlay": {
      "style": "",
      "page": "",
      "left": "",
      "top": "",
      "width": "",
      "height": ""
    },
    "type": "textfield",
    "input": true,
    "refreshOn": "",
    "inputType": "text",
    "id": "euwbr4s",
    "defaultValue": ""
  },
  "general.description": {
    "label": "Description",
    "labelPosition": "top",
    "placeholder": "",
    "description": "",
    "tooltip": "",
    "prefix": "",
    "suffix": "",
    "widget": {
      "type": "input"
    },
    "editor": "",
    "autoExpand": false,
    "customClass": "",
    "tabindex": "",
    "autocomplete": "",
    "hidden": false,
    "hideLabel": false,
    "showWordCount": false,
    "showCharCount": false,
    "autofocus": false,
    "spellcheck": true,
    "disabled": false,
    "tableView": true,
    "modalEdit": false,
    "multiple": false,
    "persistent": true,
    "inputFormat": "html",
    "protected": false,
    "dbIndex": false,
    "case": "",
    "encrypted": false,
    "redrawOn": "",
    "clearOnHide": true,
    "customDefaultValue": "",
    "calculateValue": "",
    "calculateServer": false,
    "allowCalculateOverride": false,
    "validateOn": "change",
    "validate": {
      "required": false,
      "pattern": "",
      "customMessage": "",
      "custom": "",
      "customPrivate": false,
      "json": "",
      "minLength": "",
      "maxLength": "",
      "minWords": "",
      "maxWords": "",
      "strictDateValidation": false,
      "multiple": false,
      "unique": false
    },
    "unique": false,
    "errorLabel": "",
    "key": "description",
    "tags": [],
    "properties": {},
    "conditional": {
      "show": null,
      "when": null,
      "eq": "",
      "json": ""
    },
    "customConditional": "",
    "logic": [],
    "fixedSize": true,
    "overlay": {
      "style": "",
      "page": "",
      "left": "",
      "top": "",
      "width": "",
      "height": ""
    },
    "attributes": {},
    "type": "textarea",
    "rows": 3,
    "wysiwyg": false,
    "input": true,
    "refreshOn": "",
    "allowMultipleMasks": false,
    "mask": false,
    "inputType": "text",
    "inputMask": "",
    "id": "eeq0geo",
    "defaultValue": ""
  },
  "attributes.currency": {
    "label": "Currency",
    "labelPosition": "top",
    "widget": "choicesjs",
    "placeholder": "",
    "description": "",
    "tooltip": "",
    "customClass": "",
    "tabindex": "",
    "hidden": false,
    "hideLabel": false,
    "uniqueOptions": false,
    "autofocus": false,
    "disabled": false,
    "tableView": true,
    "modalEdit": false,
    "multiple": false,
    "dataSrc": "values",
    "data": {
      "values": [
        {
          "label": "USD",
          "value": "usd"
        },
        {
          "label": "INR",
          "value": "inr"
        },
        {
          "label": "ZAR",
          "value": "zar"
        }
      ],
      "resource": "",
      "json": "",
      "url": "",
      "custom": ""
    },
    "valueProperty": "",
    "dataType": "",
    "idPath": "id",
    "template": "<span>{{ item.label }}</span>",
    "refreshOn": "",
    "clearOnRefresh": false,
    "searchEnabled": true,
    "selectThreshold": 0.3,
    "readOnlyValue": false,
    "customOptions": {},
    "persistent": true,
    "protected": false,
    "dbIndex": false,
    "encrypted": false,
    "clearOnHide": true,
    "customDefaultValue": "",
    "calculateValue": "",
    "calculateServer": false,
    "allowCalculateOverride": false,
    "validateOn": "change",
    "validate": {
      "required": false,
      "customMessage": "",
      "custom": "",
      "customPrivate": false,
      "json": "",
      "strictDateValidation": false,
      "multiple": false,
      "unique": false
    },
    "unique": false,
    "errorLabel": "",
    "key": "currency",
    "tags": [],
    "properties": {},
    "conditional": {
      "show": null,
      "when": null,
      "eq": "",
      "json": ""
    },
    "customConditional": "",
    "logic": [],
    "attributes": {},
    "overlay": {
      "style": "",
      "page": "",
      "left": "",
      "top": "",
      "width": "",
      "height": ""
    },
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "selectFields": "",
    "searchField": "",
    "minSearch": 0,
    "filter": "",
    "limit": 100,
    "redrawOn": "",
    "input": true,
    "prefix": "",
    "suffix": "",
    "showCharCount": false,
    "showWordCount": false,
    "allowMultipleMasks": false,
    "lazyLoad": true,
    "authenticate": false,
    "searchThreshold": 0.3,
    "fuseOptions": {
      "include": "score",
      "threshold": 0.3
    },
    "id": "e4b1oif",
    "defaultValue": ""
  },
  "attributes.exchangeRate": {
    "label": "Exchange Rate",
    "labelPosition": "top",
    "placeholder": "",
    "description": "",
    "tooltip": "",
    "prefix": "",
    "suffix": "",
    "widget": {
      "type": "input"
    },
    "customClass": "",
    "tabindex": "",
    "autocomplete": "",
    "hidden": false,
    "hideLabel": false,
    "mask": false,
    "autofocus": false,
    "spellcheck": true,
    "disabled": false,
    "tableView": false,
    "modalEdit": false,
    "multiple": false,
    "persistent": true,
    "delimiter": false,
    "requireDecimal": false,
    "inputFormat": "plain",
    "protected": false,
    "dbIndex": false,
    "encrypted": false,
    "redrawOn": "",
    "clearOnHide": true,
    "customDefaultValue": "",
    "calculateValue": "",
    "calculateServer": false,
    "allowCalculateOverride": false,
    "validateOn": "change",
    "validate": {
      "required": false,
      "customMessage": "",
      "custom": "",
      "customPrivate": false,
      "json": "",
      "min": "",
      "max": "",
      "strictDateValidation": false,
      "multiple": false,
      "unique": false,
      "step": "any",
      "integer": ""
    },
    "errorLabel": "",
    "key": "exchangeRate",
    "tags": [],
    "properties": {},
    "conditional": {
      "show": null,
      "when": null,
      "eq": "",
      "json": ""
    },
    "customConditional": "",
    "logic": [],
    "attributes": {},
    "overlay": {
      "style": "",
      "page": "",
      "left": "",
      "top": "",
      "width": "",
      "height": ""
    },
    "type": "number",
    "input": true,
    "unique": false,
    "refreshOn": "",
    "showCharCount": false,
    "showWordCount": false,
    "allowMultipleMasks": false,
    "id": "efs1pol",
    "defaultValue": null
  }
}'

EXEC dbo.ParseUniverseJSON  @inputJSON = @inputJSON, @UserLoginID=100,@FullSchemaJSON = @inputJSON

SELECT * FROM Universe
SELECT * FROM UniverseProperties
SELECT * FROM UniversePropertiesXref
SELECT * FROM UniversePropertyXerf_Data
 DELETE FROM  UniversePropertyXerf_Data
 DELETE FROM  UniversePropertiesXref
   DELETE FROM  UniverseProperties
      DELETE FROM  Universe
--ROLLBACK

--select * from AdminForms

--select * from EntityAdminForm
--ALTER TABLE EntityAdminForm ADD VersionNum INT

--UPDATE EntityAdminForm SET VersionNum=0
--ALTER TABLE EntityAdminForm ADD CONSTRAINT UQ_EntityAdminForm_EntityTypeID UNIQUE (EntityTypeID)


--ROLBLACK
SET XACT_ABORT ON
BEGIN TRAN
exec SaveUniverseJSONData @EntityId=-1,@EntitytypeId=2,@ParentEntityID=-1,@ParentEntityTypeID=2,@name=N'1. New Universe1',@description=N'Description',
@InputJSON=N'{"domainpermissiona":[],"attributes":{"currency":"inr","notes":"This is new domain creation","domainowner":"ABC","exchangeRate":7},"permissionList":{"jsonData":{"assigned":[{"username":"IT Auditors","userid":2025,"read":true,"write":true,"cut":true,"copy":true,"delete":true,"administrate":true,"adhoc":true,"export":true,"report":true},{"username":"dussa","userid":2028,"read":true,"report":true,"export":true},{"username":"loginid3","userid":2031,"read":true,"copy":true,"cut":true,"write":true,"modify":true}],"unassigned":[{"username":"admin","userid":1},{"username":"Administrators","userid":2},{"username":"Super Users","userid":2024},{"username":"Operational User","userid":2026},{"username":"Operational User1","userid":2027},{"username":"Gprashanthi","userid":2032},{"username":"New User Group","userid":2033},{"username":"Test","userid":2034},{"username":"Test2","userid":2035},{"username":"agstest10","userid":2036}]}},"domianinherentpermissions":false,"frameworklist":{"a":false,"2":false,"3":false,"4":false,"5":false,"6":false,"7":false,"8":false,"9":false,"10":false,"11":false,"12":false,"13":false,"14":true,"15":true,"16":true,"17":true,"18":false,"19":false,"20":false,"21":false,"22":false,"23":false,"24":false,"25":false,"26":false,"27":false,"28":false,"29":false,"30":false,"31":false,"32":false,"33":false,"34":false,"35":false,"36":false,"37":false,"38":false,"39":false,"40":false,"41":false,"42":false,"43":false,"44":false,"45":false,"46":false,"47":false,"48":false,"49":false,"50":false,"51":false,"52":false,"53":false,"54":false,"55":false,"56":false,"57":false},"contactscontainer":{"domaincontactList":{"jsonData":{"assigned":[{"name":"Prashanthi  ","id":1012,"role":-1,"notify":""},{"name":"Srinath  ","id":1013,"role":-1,"notify":""}],"unassigned":[{"name":"test100  ","id":1014,"role":-1,"notify":""},{"name":"fname mname lname","id":1017,"role":-1,"notify":""},{"name":"Prashanthi Reddy Gadepally","id":1018,"role":-1,"notify":""},{"name":"agstest10  ","id":1019,"role":-1,"notify":""}]}}},"Linkcontainer":{"domainLinks":{"jsonData":{}}}}',
@MethodName=NULL,@UserLoginID=3830

SELECT * FROM UniverseFrameworksXref
SELECT * FROM ContactInst
SELECT * FROM dbo.RoleType

The INSERT statement conflicted with the FOREIGN KEY constraint "RoleType_ContactInst_FK1". 
The conflict occurred in database "agsqa", table "dbo.RoleType", column 'RoleTypeID'.

exec SaveUniverseJSONData @EntityId=212,@EntitytypeId=2,@ParentEntityID=-1,@ParentEntityTypeID=2,
@name=N'1. New 
Universe',@description=N'Description',@InputJSON=N'{"domainpermissiona":[{"userid":1,"username":"IT 
Auditors","read":true,"modify":false,"write":true,"cut":true,"copy":true,"delete":true,"administrate":true,"adhoc":true,"export":true,"report":true},{"userid":1,"username":"dussa","read":true,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"export":true,"report":true},{"userid":1,"username":"loginid3","read":true,"modify":true,"write":true,"cut":true,"copy":true,"delete":false,"administrate":false,"adhoc":false,"export":false,"report":false}],"attributes":{"universeid":212,"exchange 
rate":0,"currency":"inr","notes":"This is new domain creation","domain owner":"","domainowner":"ABC","exchangerate":7},"permissionList":{"jsonData":{"assigned":[{"userid":1,"username":"IT Auditors","read":true,"modify":false,"write":true,"cut":true,"copy":true,"delete":true,"administrate":true,"adhoc":true,"export":true,"report":true},{"userid":1,"username":"dussa","read":true,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"export":true,"report":true},{"userid":1,"username":"loginid3","read":true,"modify":true,"write":true,"cut":true,"copy":true,"delete":false,"administrate":false,"adhoc":false,"export":false,"report":false}],"unassigned":[]}},"domianinherentpermissions":false,"frameworklist":{"1":true,"2":false,"3":false,"4":false,"5":false,"6":true,"7":true,"8":false,"9":false,"10":false,"11":false,"12":false,"13":false,"14":false,"15":false,"16":false,"17":false,"18":false,"19":false,"20":false,"21":false,"22":false,"23":false,"24":false,"25":false,"26":false,"27":false,"28":false,"29":false,"30":false,"31":false,"32":false,"33":false,"34":false,"35":false,"36":true,"37":true,"38":true,"39":true,"40":false,"41":false,"42":false,"43":false,"44":false,"45":false,"46":false,"47":false,"48":false,"49":false,"50":false,"51":false,"52":false,"53":false,"54":false,"55":false,"56":true,"57":true},"contactscontainer":{"domaincontactList":{"jsonData":{"assigned":[{"name":"test100  ","id":1014,"role":"3","notify":""},{"name":"fname mname lname","id":1017,"role":"1","notify":""},{"name":"Prashanthi Reddy Gadepally","id":1018,"role":-1,"notify":""}],"unassigned":[{"name":"Prashanthi  ","id":1012,"role":-1,"notify":""},{"name":"Srinath  ","id":1013,"role":-1,"notify":""},{"name":"agstest10  ","id":1019,"role":-1,"notify":""}]}}},"Linkcontainer":{}}',
@MethodName=NULL,@UserLoginID=3832

SELECT * FROM Filterconditions_Master
SELECT * FROM EntityMetaData
SELECT * FROM Registers WHERE REGISTERID=159 --GET FRAMEWORKID
SELECT * FROM FRAMEWORKS WHERE frameworkid=40-- GET name, THIS IS THE TABLE TO APPLY FILTER ON
SELECT * FROM FRAMEWORKS WHERE frameworkid=1-- GET name, THIS IS THE TABLE TO APPLY FILTER ON

exec SaveCustomViewJSONData 
@inputJSON=N'{"viewName":"Testing Filtesr","EntityTypeId":9,"EntityId":-1,"ParentEntityTypeId":1,"ParentEntityId":40,"viewId":-1,"viewType":1,"filtersData":{"matchCondition":-200,"filters":[{"columnId":"14","colDataType":"textfield","colKey":"contactname","conditionId":"3","items":[],"noOfValuesRequired":1,"value1":"Haz"},{"columnId":"-5","colDataType":"datetime","colKey":"DateCreated","conditionId":"55","value1":"","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"-6","colDataType":"datetime","colKey":"Datemodified","conditionId":"56","value1":"","value2":"","items":[],"noOfValuesRequired":2},{"columnId":"-200","colDataType":"all","colKey":"all","conditionId":-1,"value1":"","value2":"","items":[{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"21","value1":"b","value2":"","items":[],"noOfValuesRequired":1}]},{"columnId":"12","colDataType":"select","colKey":"causalSubCategory","conditionId":"14","value1":"b","value2":"","items":[],"noOfValuesRequired":1},{"columnId":"16","colDataType":"checkbox","colKey":"notify","conditionId":70,"value1":"True","value2":"","items":[]},{"columnId":"13","colDataType":"select","colKey":"levelOfAutomation","conditionId":"12","value1":"b","value2":"","items":[],"noOfValuesRequired":1}],"currentUser":false,"topRecords":"ALL","orderByColumn":"","sortBy":"desc"},"columns":[{"colName":"Component - Weighted Audit Error %","colId":"componentweightedauditerror","isSelected":1,"orderid":1},{"colName":"Component Name","colId":"name","isSelected":1,"orderid":2},{"colName":"Component Weight","colId":"componentweight","isSelected":1,"orderid":3},{"colName":"Overall Weight","colId":"overallweight","isSelected":1,"orderid":4},{"colName":"Test Error","colId":"testerror","isSelected":1,"orderid":5},{"colName":"Total Errors","colId":"totalerrors","isSelected":false,"orderid":6},{"colName":"Total Sample Size","colId":"totalsamplesize","isSelected":1,"orderid":7}]}',
@MethodName=NULL,@UserLoginID=3840

select * from Filterconditions_Master WHERE criteria NOT like '%equals%'
ALTER TABLE Filterconditions_Master ADD OperatorType VARCHAR(50)
SELECT * FROM Filterconditions_Master
UPDATE Filterconditions_Master SET OperatorType ='=' WHERE Criteria='Equals'
UPDATE Filterconditions_Master SET OperatorType ='<>' WHERE Criteria='Not Equals'
UPDATE Filterconditions_Master SET OperatorType ='LIKE ''%<COLVALUE>%''' WHERE Criteria='contains'
UPDATE Filterconditions_Master SET OperatorType ='NOT LIKE ''%<COLVALUE>%''' WHERE Criteria='Does Not Contains'
UPDATE Filterconditions_Master SET OperatorType ='LIKE ''%<COLVALUE>''' WHERE Criteria='Starts With'
UPDATE Filterconditions_Master SET OperatorType ='NOT LIKE ''%<COLVALUE>''' WHERE Criteria='Does Not Start With'
UPDATE Filterconditions_Master SET OperatorType ='LIKE ''<COLVALUE>%''' WHERE Criteria='Ends With'
UPDATE Filterconditions_Master SET OperatorType ='NOT LIKE ''<COLVALUE>%''' WHERE Criteria='Does Not End With'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') = ''''' WHERE Criteria='Is Empty'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') <> '''' ' WHERE Criteria='IS Not Empty'
UPDATE Filterconditions_Master SET OperatorType ='<' WHERE Criteria='Less Than'
UPDATE Filterconditions_Master SET OperatorType ='<=' WHERE Criteria='Less Than Or Equal to'
UPDATE Filterconditions_Master SET OperatorType ='>' WHERE Criteria='Greater Than'
UPDATE Filterconditions_Master SET OperatorType ='>=' WHERE Criteria='Greater Than or Equal to'
UPDATE Filterconditions_Master SET OperatorType ='Between' WHERE Criteria='Between'
UPDATE Filterconditions_Master SET OperatorType ='Not Between' WHERE Criteria='Not Between'
UPDATE Filterconditions_Master SET OperatorType ='1' WHERE Criteria='True'
UPDATE Filterconditions_Master SET OperatorType ='0' WHERE Criteria='False'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') = ''''' WHERE Criteria='Empty'
UPDATE Filterconditions_Master SET OperatorType ='ISNULL(<COLNAME>,'''') <> '''' ' WHERE Criteria='Not Empty'
--UPDATE Filterconditions_Master SET OperatorType ='Equal to Field' WHERE Criteria='ISNULL(<COLNAME>,'''') <> '''' '
