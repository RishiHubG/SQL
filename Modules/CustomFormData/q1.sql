 use junk
	go	
 /*

	use junk
	go	 

TRUNCATE TABLE Frameworks
TRUNCATE TABLE Frameworks_HISTORY
	
DROP TABLE IF EXISTS TAB_FrameworkLookups
drop table IF EXISTS TAB_FrameworkAttributes
drop table IF EXISTS TAB_FrameworkStepItems
drop table IF EXISTS TAB_FrameworkSteps

  
DROP TABLE IF EXISTS TAB_FrameworkLookups_history
drop table IF EXISTS TAB_FrameworkAttributes_history
drop table IF EXISTS TAB_FrameworkStepItems_history
drop table IF EXISTS TAB_Frameworksteps_history

	SELECT * from dbo.TAB_FrameworksList
	SELECT * from dbo.TAB_FrameworkAttributes_history
	SELECT * FROM Frameworks

 IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME ='TAB_FrameworksList_History')
 SELECT   * FROM TAB_Frameworks_List_History WHERE JSONFileKey = 'TAB' ORDER BY HistoryID DESC

  SELECT * FROM TAB_Framework_Steps_History WHERE FileID = 1 AND StepName = 'General' ORDER BY HistoryID DESC
  	SET IDENTITY_INSERT dbo.[FrameworkAttributes] OFF;
		SET IDENTITY_INSERT dbo.FrameworkLookups OFF;

*/
 EXEC dbo.PARSEJSONdATA 
  @inputJSON =
'{
    "name": {
        "label": "Name",
        "tableView": true,
        "validate": {
            "required": true,
            "minLength": 1,
            "maxLength": 500
        },
        "key": "name",
        "type": "textfield",
        "input": false,
        "hideOnChildrenHidden": false,
		"parent": "General"
    },
    "reference": {
        "label": "Reference",
        "tableView": true,
        "inputFormat": "html",
        "key": "reference",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false,
		"parent": "General"
    },
    "reference1": {
        "label": "Reference",
        "disabled": true,
        "tableView": true,
        "validate": {
            "unique": true
        },
        "unique": true,
        "key": "reference1",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false,
		"parent": "General"
    },
    "riskDescription": {
        "label": "Risk Description",
        "tableView": true,
        "inputFormat": "html",
        "key": "riskDescription",
        "type": "textfield",
        "input": true,
		"parent": "Details"
    },
    "riskCategory1": {
        "label": "Applicable Factor",
        "optionsLabelPosition": "right",
        "tableView": true,
        "defaultValue": {
            "": false,
            "strategic": false,
            "busienss": false,
            "management": false
        },
        "values": [
            {
                "label": "Strategic",
                "value": "strategic",
                "shortcut": ""
            },
            {
                "label": "Busienss",
                "value": "busienss",
                "shortcut": ""
            },
            {
                "label": "Management",
                "value": "management",
                "shortcut": ""
            }
        ],
        "key": "riskCategory1",
        "type": "selectboxes",
        "input": true,
        "inputType": "checkbox",
        "hideOnChildrenHidden": true,
		"parent": "Details"
    },
    "riskCategory2": {
        "label": "Risk Category 1",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "Nature",
                    "value": "Nature"
                },
                {
                    "label": "Machinery",
                    "value": "machinery"
                },
                {
                    "label": "Legal",
                    "value": "legal"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "riskCategory2",
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false,
		"parent": "Details"
    },
    "riskCategory3": {
        "label": "Risk Category 2",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "Flood",
                    "value": "flood"
                },
                {
                    "label": "Fire",
                    "value": "fire"
                },
                {
                    "label": "Earthquake",
                    "value": "earthquake"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "riskCategory3",
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false,
		"parent": "Details"
    },
    "likelyhood": {
        "label": "Likelyhood",
        "mask": false,
        "spellcheck": true,
        "tableView": false,
        "delimiter": false,
        "requireDecimal": false,
        "inputFormat": "plain",
        "validate": {
            "required": true,
            "min": 0,
            "max": 100
        },
        "key": "likelyhood",
        "type": "number",
        "input": true,
		"parent": "Ratings"
    },
    "financialImpact": {
        "label": "Financial Impact",
        "mask": false,
        "spellcheck": true,
        "tableView": false,
        "delimiter": true,
        "requireDecimal": true,
        "inputFormat": "plain",
        "key": "financialImpact",
        "type": "number",
        "input": true,
        "decimalLimit": 2,
		"parent": "Ratings"
    },
    "inherentRating": {
        "label": "Inherent Rating",
        "tableView": true,
        "calculateValue": "value = data.likelyhood/100 + data.FinancialImpact;",
        "key": "inherentRating",
        "type": "textfield",
        "input": true,
		"parent": "Ratings"
    },
    "overallComment": {
        "label": "Overall Comment",
        "autoExpand": false,
        "tableView": true,
        "key": "overallComment",
        "type": "textarea",
        "input": true,
		"parent": "Summary"
    },
    "dateCreated": {
        "label": "Date Created",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateCreated",
        "type": "datetime",
        "input": true,
        "widget": {
            "type": "calendar",
            "displayInTimezone": "viewer",
            "language": "en",
            "useLocaleSettings": false,
            "allowInput": true,
            "mode": "single",
            "enableTime": true,
            "noCalendar": false,
            "format": "yyyy-MM-dd hh:mm a",
            "hourIncrement": 1,
            "minuteIncrement": 1,
            "time_24hr": false,
            "minDate": null,
            "disableWeekends": false,
            "disableWeekdays": false,
            "maxDate": null
        },
        "hideOnChildrenHidden": false
    },
    "userCreated": {
        "label": "User Created",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": true,
        "key": "userCreated",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "dateModified": {
        "label": "Date Modified",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateModified",
        "type": "datetime",
        "input": true,
        "widget": {
            "type": "calendar",
            "displayInTimezone": "viewer",
            "language": "en",
            "useLocaleSettings": false,
            "allowInput": true,
            "mode": "single",
            "enableTime": true,
            "noCalendar": false,
            "format": "yyyy-MM-dd hh:mm a",
            "hourIncrement": 1,
            "minuteIncrement": 1,
            "time_24hr": false,
            "minDate": null,
            "disableWeekends": false,
            "disableWeekdays": false,
            "maxDate": null
        },
        "hideOnChildrenHidden": false
    },
    "userModified": {
        "label": "User Modified",
        "labelPosition": "left-left",
        "disabled": true,
        "tableView": true,
        "key": "userModified",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "submit": {
        "type": "button",
        "label": "Submit",
        "key": "submit",
        "disableOnInvalid": true,
        "input": true,
        "tableView": false
    }
}'

/*
		SELECT * from dbo.Frameworks
		SELECT * from dbo.Frameworks_history
		SELECT * from dbo.FrameworkSteps_history
		SELECT * from dbo.FrameworkStepItems_history
		SELECT * from dbo.FrameworkAttributes_history
		SELECT * from dbo.FrameworkLookups_history

		 
		SELECT * FROM  TAB_FrameworkSteps
		SELECT * FROM  TAB_FrameworkStepItems
		SELECT * FROM TAB_FrameworkAttributes		
		SELECT * FROM TAB_FrameworkLookups
		

		--SELECT * FROM FrameworkLookups
		--SELECT * FROM FrameworkAttributes
		--SELECT * FROM  FrameworkStepItems
		--SELECT * FROM  FrameworkSteps
		--SELECT * FROM  FrameworkSteps_history

		
		SELECT * FROM  TAB_FrameworkSteps_history
		SELECT * FROM  TAB_FrameworkStepItems_history
		SELECT * FROM TAB_FrameworkAttributes_history		
		SELECT * FROM TAB_FrameworkLookups_history

		SELECT * FROM dbo.TAB_Framework_Attributes_history WHERE VersionNum=4
		EXEC dbo.UpdateHistoryOperationType @FrameworkID=1, @TableInitial ='TAB',@VersionNum=4
		
		SELECT * FROM TestControls_DATA
		SELECT * FROM TestControls_data_history
		SP_tABLES '%TESTCONTROLS%'
*/


SELECT * FROM Table_TableEntityMapping  -- SINGLE TYPE


SELECT * FROM TableColumnMaster


EXEC dbo.ParseCustomformData @InputJSON='{"checkList.dataGrid":{"label":"Data Grid","labelPosition":"top","description":"","tooltip":"","disableAddingRemovingRows":false,"conditionalAddButton":"","reorder":false,"addAnother":"","addAnotherPosition":"bottom","defaultOpen":false,"layoutFixed":false,"enableRowGroups":false,"initEmpty":false,"customClass":"","tabindex":"","hidden":false,"hideLabel":false,"autofocus":false,"disabled":false,"tableView":false,"modalEdit":false,"defaultValue":[{}],"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"minLength":"","maxLength":"","customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"dataGrid","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"datagrid","input":true,"placeholder":"","prefix":"","suffix":"","multiple":false,"refreshOn":"","widget":null,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"components":[{"label":"Text Field","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"textField","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ebb5txi000","defaultValue":null},{"label":"Yes/No","labelPosition":"top","widget":"choicesjs","placeholder":"","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"uniqueOptions":false,"autofocus":false,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"dataSrc":"values","data":{"values":[{"label":"Yes","value":"Yes"},{"label":"No","value":"No"}],"resource":"","json":"","url":"","custom":""},"valueProperty":"","dataType":"","idPath":"id","template":"<span>{{ item.label }}</span>","refreshOn":"","clearOnRefresh":false,"searchEnabled":true,"selectThreshold":0.3,"readOnlyValue":false,"customOptions":{},"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"yesNo","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"select","indexeddb":{"filter":{}},"selectFields":"","searchField":"","minSearch":0,"filter":"","limit":100,"redrawOn":"","input":true,"prefix":"","suffix":"","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"lazyLoad":true,"authenticate":false,"searchThreshold":0.3,"fuseOptions":{"include":"score","threshold":0.3},"id":"ehzr960","defaultValue":""}],"id":"ekpns7v"},"checkList.dataGrid.textField":{"label":"Text Field","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"textField","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ebb5txi000","defaultValue":null},"checkList.dataGrid.yesNo":{"label":"Yes/No","labelPosition":"top","widget":"choicesjs","placeholder":"","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"uniqueOptions":false,"autofocus":false,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"dataSrc":"values","data":{"values":[{"label":"Yes","value":"Yes"},{"label":"No","value":"No"}],"resource":"","json":"","url":"","custom":""},"valueProperty":"","dataType":"","idPath":"id","template":"<span>{{ item.label }}</span>","refreshOn":"","clearOnRefresh":false,"searchEnabled":true,"selectThreshold":0.3,"readOnlyValue":false,"customOptions":{},"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"yesNo","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"select","indexeddb":{"filter":{}},"selectFields":"","searchField":"","minSearch":0,"filter":"","limit":100,"redrawOn":"","input":true,"prefix":"","suffix":"","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"lazyLoad":true,"authenticate":false,"searchThreshold":0.3,"fuseOptions":{"include":"score","threshold":0.3},"id":"ehzr960","defaultValue":""}}',@UserLoginID=3688,@EntityID=98,@EntityTypeID=12,@FullSchemaJSON='{"components":[{"label":"Check List","labelPosition":"top","tooltip":"","customClass":"","hidden":false,"hideLabel":true,"disabled":false,"tableView":false,"modalEdit":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"validateOn":"change","errorLabel":"","key":"checkList","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"container","input":true,"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"refreshOn":"","description":"","tabindex":"","autofocus":false,"widget":null,"allowCalculateOverride":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"components":[{"label":"Data Grid","labelPosition":"top","description":"","tooltip":"","disableAddingRemovingRows":false,"conditionalAddButton":"","reorder":false,"addAnother":"","addAnotherPosition":"bottom","defaultOpen":false,"layoutFixed":false,"enableRowGroups":false,"initEmpty":false,"customClass":"","tabindex":"","hidden":false,"hideLabel":false,"autofocus":false,"disabled":false,"tableView":false,"modalEdit":false,"defaultValue":[{}],"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"minLength":"","maxLength":"","customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"dataGrid","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"datagrid","input":true,"placeholder":"","prefix":"","suffix":"","multiple":false,"refreshOn":"","widget":null,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"components":[{"label":"Text Field","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"textField","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ebb5txi000","defaultValue":null},{"label":"Yes/No","labelPosition":"top","widget":"choicesjs","placeholder":"","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"uniqueOptions":false,"autofocus":false,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"dataSrc":"values","data":{"values":[{"label":"Yes","value":"Yes"},{"label":"No","value":"No"}],"resource":"","json":"","url":"","custom":""},"valueProperty":"","dataType":"","idPath":"id","template":"<span>{{ item.label }}</span>","refreshOn":"","clearOnRefresh":false,"searchEnabled":true,"selectThreshold":0.3,"readOnlyValue":false,"customOptions":{},"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"yesNo","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"select","indexeddb":{"filter":{}},"selectFields":"","searchField":"","minSearch":0,"filter":"","limit":100,"redrawOn":"","input":true,"prefix":"","suffix":"","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"lazyLoad":true,"authenticate":false,"searchThreshold":0.3,"fuseOptions":{"include":"score","threshold":0.3},"id":"ehzr960","defaultValue":""}],"id":"ekpns7v"}],"id":"etj4zwe"},{"type":"button","label":"Submit","key":"submit","size":"md","block":false,"action":"submit","disableOnInvalid":true,"theme":"primary","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","tableView":false,"modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"leftIcon":"","rightIcon":"","dataGridLabel":true,"id":"ef7u3xi"}],"display":"form"}',
@Name='Check List Table',@Description='Check List Table',
@MethodName=NULL,@LogRequest=1

--TO DO:
-------------------------
SELECT * FROM TableColumnMaster --Add New Col. CustomFormsInstanceID=CustomFormsInstance.ID
SELECT * FROM CustomFormsInstance	--RENAME ID= CustomFormsInstanceID
SELECT * FROM [dbo].[Table_EntityMapping] -- ADD NEW COL. TableInstanceID
--NEW RECORD TO BE INSERTED INTO [dbo].[Table_EntityMapping] VIA SAVE FRAMEWORK PROC.;SEARCH FOR KEY IN JSON: APIKey;
--USING THIS APIKEY GO TO CUSTOMFORMINSTANCE GET ID=tableid;CHECK THE NAME COLUMN AND _DATA WILL BE OF THIS NAME
--customFormID=1=table;2=templateTablE-> THIS WILL GIVE THE _DATA
--INSERT NEW RECORD IN _dATA TABLE -> IF RECORD NOT AVAILABLE IN TABLE/TEMPLATE TABLE ELSE UPDATE
SELECT * FROM TemplateTableColumnMaster --Add New Col. CustomFormsInstanceID=CustomFormsInstance.ID
SAVE TEMPLATE TABLE: ENTITYTYPEID=13,ENTITYID=101-> MAKE TableInstanceID=0;FRAMEWORKID=null
TEMPLATETABLE_TABLENAME_DATA-> REMOVE FULLSCHEMAJSON COL.;FRAMEWORKID=NULL
ALTER TABLE TableColumnMaster ADD CustomFormsInstanceID INT
ALTER TABLE TableColumnMaster_history ADD CustomFormsInstanceID INT
ALTER TABLE TemplateTableColumnMaster ADD CustomFormsInstanceID INT
ALTER TABLE TemplateTableColumnMaster_history ADD CustomFormsInstanceID INT
ALTER TABLE [dbo].[Table_EntityMapping] ADD TableInstanceID INT IDENTITY(1,1)
ALTER TABLE [dbo].[Table_EntityMapping] ADD CONSTRAINT PK_Table_EntityMapping_TableInstanceID PRIMARY KEY(TableInstanceID)
EXEC sp_rename 'dbo.CustomFormsInstance.ID', 'CustomFormsInstanceID', 'COLUMN';
ALTER TABLE dbo.TableColumnMaster ADD CONSTRAINT FK_TableColumnMaster_CustomFormsInstanceID FOREIGN KEY(CustomFormsInstanceID) REFERENCES dbo.CustomFormsInstance(CustomFormsInstanceID)
ALTER TABLE dbo.TemplateTableColumnMaster ADD CONSTRAINT FK_TemplateTableColumnMaster_CustomFormsInstanceID FOREIGN KEY(CustomFormsInstanceID) REFERENCES dbo.CustomFormsInstance(CustomFormsInstanceID)

-------------------------

SELECT * FROM EntityMetaData WHERE EntityTypeId IN (12,13)


SELECT * FROM ObjectLog WHERE ID=22899

--ROLLBACK
SET XACT_ABORT ON;
BEGIN TRAN
EXEC dbo.SaveFrameworkJSONData 
@InputJSON='{"general":{},"auditdetails":{"name":"aafa","auditreference":"adfa","scopeofaudit":"adfa","typeOfAudit":"Other audit","auditStatus":"In reporting (Auditor)","auditobjective":"adfa","otherauditobjective":"","plannedstartdate":"","actualstartdate":"","periodunderreviewfrom":"","plannedcompletiondate":"","actualcompletiondate":"","periodunderreviewto":"","comments":"","TemplateKey_checklist":{"audit":[{"checklistitem":"b","comply":"yes","comments":"ada"},{"checklistitem":"b","comply":"yes","comments":"ada"},{"checklistitem":"a","comply":"no","comments":"afda"},{"checklistitem":"c","comply":"yes","comments":"adfafa"}]},"submit":false},"entitylinks":{"riskandaontrols":{"jsonData":{"a":1}},"auditplans":{"jsonData":{"a":1}},"components":{"jsonData":{"a":1}},"auditrating":{"selectVal":"#b7e0b7"}},"managerDetails":{"nameOfTheManager":"adfaf","dateOfMeeting":"2021-11-03T00:00:00+05:30","reviewNotes":""},"systemdescription":{"highleveldescriptionoftheoverallprocess":"adfa","adhocComponentsApproved":"adfafa","commentsOnAdhocComments":"adfaa"},"auditreporting":{"dateDraftReportIssued":"","dateFinalReportIssued":"","initialRiskRating":"","suggestedOverallRiskRating":"","executivesummary":"","goodPractices":""},"auditDetails":{"allcomponents":[{}]}}',
@UserLoginID=3739,@EntityID=-1,@EntityTypeID=9,@ParentEntityID=173,@ParentEntityTypeID=3,@Name='',@Description='',@MethodName=NULL,@LogRequest=1

 
SELECT * FROM dbo.CustomFormsInstance
SELECT * FROM dbo.TableColumnMaster -- Add Reference to the Table
SELECT * FROM dbo.TemplateTable_TableTemplate1_data -- Table as a part of Parse


--Table : TEmplate Data: --> 

Framwork -- Table

SELECT * FROM dbo.Table_EntityMapping WITH (NOLOCK)-- Tableinstanceid

SELECT * FROM dbo.Table_EntityMapping_history WITH (NOLOCK)
SELECT * FROM dbo.TemplateTable_TableTemplate1_data

