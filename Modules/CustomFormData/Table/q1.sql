Entitytypeid:
table=12
table template=13

SELECT * FROM CUSTOMFORMS
SELECT * FROM CUSTOMFORMsinstance 

entityid=-1=insert else update

1. DYNAMICALLY CREATE NEW TABLE -> TABLE_NAME/TABLETemplate_NAME - REMOVE SPACE IN TABLE NAME
add new column namespace - put dynamic table name here
2. create new table - table_name_data

table_name_data: additional columns
FrameworkID
EntityID
FullFormJson
4- STANDARD COLUMNS
VersionNum

 
SELECT * FROM TABLE_TableDef_DATA
SELECT * FROM TableColumnMaster_history
SELECT * FROM TableColumnMaster
--ROLLBACK COMMIT
BEGIN TRAN

exec parseCustomFormData @name=N'Table Def',@description=N'Table Des',
@fullSchemaJson=N'{"components":[{"label":"Container","labelPosition":"top","tooltip":"","customClass":"","hidden":false,"hideLabel":true,"disabled":false,"tableView":false,"modalEdit":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"validateOn":"change","errorLabel":"","key":"container","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"container","input":true,"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"refreshOn":"","description":"","tabindex":"","autofocus":false,"widget":null,"allowCalculateOverride":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"components":[{"label":"TableGrid","labelPosition":"top","description":"","tooltip":"","disableAddingRemovingRows":false,"conditionalAddButton":"","reorder":false,"addAnother":"","addAnotherPosition":"bottom","defaultOpen":false,"layoutFixed":false,"enableRowGroups":false,"initEmpty":false,"customClass":"","tabindex":"","hidden":false,"hideLabel":false,"autofocus":false,"disabled":false,"tableView":false,"modalEdit":false,"defaultValue":[{}],"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"minLength":"","maxLength":"","customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"tableGrid","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"datagrid","input":true,"placeholder":"","prefix":"","suffix":"","multiple":false,"refreshOn":"","widget":null,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"components":[{"label":"SNO","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":false,"modalEdit":false,"multiple":false,"persistent":true,"delimiter":false,"requireDecimal":false,"inputFormat":"plain","protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","min":"","max":"","strictDateValidation":false,"multiple":false,"unique":false,"step":"any","integer":""},"errorLabel":"","key":"sno","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"number","input":true,"unique":false,"refreshOn":"","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"id":"e02et500000000","defaultValue":null},{"label":"Checklist Item","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"checklistitem","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ec34bu000000","defaultValue":""},{"label":"Status","labelPosition":"top","widget":"choicesjs","placeholder":"","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"uniqueOptions":false,"autofocus":false,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"dataSrc":"values","data":{"values":[{"label":"Confirm","value":"Confirm"},{"label":"Reject","value":"Reject"}],"resource":"","json":"","url":"","custom":""},"valueProperty":"","dataType":"","idPath":"id","template":"<span>{{ item.label }}</span>","refreshOn":"","clearOnRefresh":false,"searchEnabled":true,"selectThreshold":0.3,"readOnlyValue":false,"customOptions":{},"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"status","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"select","indexeddb":{"filter":{}},"selectFields":"","searchField":"","minSearch":0,"filter":"","limit":100,"redrawOn":"","input":true,"prefix":"","suffix":"","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"lazyLoad":true,"authenticate":false,"searchThreshold":0.3,"fuseOptions":{"include":"score","threshold":0.3},"id":"e6uwrv0000","defaultValue":""},{"label":"Compliance","labelPosition":"top","optionsLabelPosition":"right","description":"","tooltip":"","customClass":"","tabindex":"","inline":true,"hidden":false,"hideLabel":false,"autofocus":false,"disabled":false,"tableView":false,"modalEdit":false,"values":[{"label":"Compliant","value":"Compliant","shortcut":""},{"label":"Non Compliant","value":"Non Compliant","shortcut":""},{"label":"Not Applicable","value":"Not Applicable","shortcut":""}],"dataType":"","persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"errorLabel":"","key":"compliance","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"radio","input":true,"placeholder":"","prefix":"","suffix":"","multiple":false,"unique":false,"refreshOn":"","widget":null,"validateOn":"change","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"inputType":"radio","fieldSet":false,"id":"e5xrqy0","defaultValue":""}],"id":"eijdjqb"}],"id":"e2sk2t"},{"type":"button","label":"Submit","key":"submit","size":"md","block":false,"action":"submit","disableOnInvalid":true,"theme":"primary","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","tableView":false,"modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"leftIcon":"","rightIcon":"","dataGridLabel":true,"id":"eyga1g"}],"display":"form"}',
@InputJSON=N'{
  "container.tableGrid.sno": {
    "label": "SNO",
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
    "key": "sno",
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
    "id": "e02et500000000",
    "defaultValue": null
  },
  "container.tableGrid.checklistitem": {
    "label": "Checklist Item",
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
    "key": "checklistitem",
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
    "id": "ec34bu000000",
    "defaultValue": ""
  },
  "container.tableGrid.status": {
    "label": "Status",
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
          "label": "Confirm",
          "value": "Confirm"
        },
        {
          "label": "Reject",
          "value": "Reject"
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
    "key": "status",
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
    "id": "e6uwrv0000",
    "defaultValue": ""
  },
  "container.tableGrid.compliance": {
    "label": "Compliance",
    "labelPosition": "top",
    "optionsLabelPosition": "right",
    "description": "",
    "tooltip": "",
    "customClass": "",
    "tabindex": "",
    "inline": true,
    "hidden": false,
    "hideLabel": false,
    "autofocus": false,
    "disabled": false,
    "tableView": false,
    "modalEdit": false,
    "values": [
      {
        "label": "Compliant",
        "value": "Compliant",
        "shortcut": ""
      },
      {
        "label": "Non Compliant",
        "value": "Non Compliant",
        "shortcut": ""
      },
      {
        "label": "Not Applicable",
        "value": "Not Applicable",
        "shortcut": ""
      }
    ],
    "dataType": "",
    "persistent": true,
    "protected": false,
    "dbIndex": false,
    "encrypted": false,
    "redrawOn": "",
    "clearOnHide": true,
    "customDefaultValue": "",
    "calculateValue": "",
    "calculateServer": false,
    "allowCalculateOverride": false,
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
    "errorLabel": "",
    "key": "compliance",
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
    "type": "radio",
    "input": true,
    "placeholder": "",
    "prefix": "",
    "suffix": "",
    "multiple": false,
    "unique": false,
    "refreshOn": "",
    "widget": null,
    "validateOn": "change",
    "showCharCount": false,
    "showWordCount": false,
    "allowMultipleMasks": false,
    "inputType": "radio",
    "fieldSet": false,
    "id": "e5xrqy0",
    "defaultValue": ""
  }
}',
@EntityId=-1,@Entitytypeid=12,@UserloginId=3648,@MethodName=NULL

--ROLLBACK

SET XACT_ABORT ON;
BEGIN TRAN;
exec SaveEntityDetail @EntityId=101,@EntitytypeId=13,
@InputJson=N'{"checklist":{"audit":[{"checklistitem":"a","comply":"yes","comments":"test"},{"checklistitem":"b","comply":"yes","comments":"test2"},{"checklistitem":"c","comply":"no","comments":"no comment"}]},"submit":false}',
@MethodName=NULL,@UserLoginID=3723

SELECT * FROM TEMPLATETABLE_template1_data
SELECT * FROM CustomFormsInstance

ALTER TABLE CustomFormsInstance ADD CONSTRAINT UQ_CustomFormsInstance_APIKey UNIQUE(APIKey)


exec GetTemplateTableData @EntityId=101,@MethodName=NULL,@UserLoginID=3723