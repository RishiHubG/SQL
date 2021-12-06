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