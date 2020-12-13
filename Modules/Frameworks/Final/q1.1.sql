 use junk
	go	
 /*
  --type=day: split into 4 columns (day,month,year,full column name)

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

	SELECT * FROM TAB_DATA
	SELECT * from dbo.TAB_FrameworkAttributes_history
	SELECT * FROM Frameworks

 IF EXISTS(SELECT 1 FROM SYS.TABLES WHERE NAME ='TAB_FrameworksList_History')
 SELECT   * FROM TAB_Frameworks_List_History WHERE JSONFileKey = 'TAB' ORDER BY HistoryID DESC

  SELECT * FROM TAB_Framework_Steps_History WHERE FileID = 1 AND StepName = 'General' ORDER BY HistoryID DESC
  	SET IDENTITY_INSERT dbo.[FrameworkAttributes] OFF;
		SET IDENTITY_INSERT dbo.FrameworkLookups OFF;

*/

----CREATE TABLES
--:setvar path "E:\New Company\GitHub\SQL\Modules\Frameworks\Final"
--:r $(path)\Tables.sql
--:r $(path)\Tables.History.sql

----CREATE FUNCTION
--:SETVAR path "E:\New Company\GitHub\SQL\Modules\Frameworks\Final\Function\"
--:r $(path)\HierarchyFromJSON.SQL

--COMMIT
----ROLLBACK
BEGIN TRAN;
 EXEC dbo.ParseFrameworkJSONData
 @Name = 'TAB',
 @UserCreated=100,
  @inputJSON =
'{
    "name": {
        "label": "Name",
        "tableView": true,
        "key": "name",
        "properties": {
            "StepName": "General"
        },
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "reference": {
        "label": "Reference",
        "disabled": true,
        "tableView": true,
        "key": "reference",
        "properties": {
            "StepName": "Reference"
        },
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "showTabs": {
        "label": "ShowTabs",
        "tableView": false,
        "key": "showTabs",
        "properties": {
            "StepName": "General"
        },
        "type": "checkbox",
        "input": true,
        "defaultValue": false
    },
    "description": {
        "label": "Description",
        "autoExpand": false,
        "tableView": true,
        "key": "description",
        "properties": {
            "StepName": "General"
        },
        "type": "textarea",
        "input": true
    },
    "engagementType": {
        "label": "Engagement Type",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "Meeting",
                    "value": "meeting"
                },
                {
                    "label": "On-Site visit",
                    "value": "onSiteVisit"
                },
                {
                    "label": "Regulatory Inspectioon",
                    "value": "regulatoryInspectioon"
                },
                {
                    "label": "Information Request",
                    "value": "informationRequest"
                },
                {
                    "label": "Other",
                    "value": "other"
                }
            ]
        },
        "selectThreshold": 0.3,
        "validate": {
            "required": true
        },
        "key": "engagementType",
        "properties": {
            "StepName": "Engagement Details"
        },
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false
    },
    "createdDate": {
        "label": "Created Date",
        "disabled": true,
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "createdDate",
        "properties": {
            "StepName": "Engagement Details"
        },
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
    "engagementStatus": {
        "label": "Engagement Status",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "In Progress",
                    "value": "inProgress"
                },
                {
                    "label": "Closed",
                    "value": "closed"
                },
                {
                    "label": "Archive",
                    "value": "archive"
                }
            ]
        },
        "selectThreshold": 0.3,
        "validate": {
            "required": true
        },
        "key": "engagementStatus",
        "properties": {
            "StepName": "Engagement Details"
        },
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false
    },
    "classificationOfEngagement": {
        "label": "Classification of Engagement",
        "widget": "choicesjs",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "Routine",
                    "value": "routine"
                },
                {
                    "label": "Non Routine",
                    "value": "nonRoutine"
                },
                {
                    "label": "Industry Request",
                    "value": "industryRequest"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "classificationOfEngagement",
        "properties": {
            "StepName": "Engagement Details"
        },
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false
    },
    "engagementOwner": {
        "label": "Engagement Owner",
        "tableView": true,
        "key": "engagementOwner",
        "properties": {
            "StepName": "Engagement Details"
        },
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "externalReferenceNumber": {
        "label": "External Reference Number",
        "tableView": true,
        "key": "externalReferenceNumber",
        "properties": {
            "StepName": "Engagement Details"
        },
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "confenditialDoc": {
        "label": "ConfenditialDoc",
        "tableView": false,
        "defaultValue": false,
        "key": "confenditialDoc",
        "properties": {
            "StepName": "Confidential Documentation"
        },
        "type": "checkbox",
        "input": true
    },
    "container.email": {
        "label": "Email",
        "tableView": true,
        "key": "email",
        "properties": {
            "StepName": "Contacts"
        },
        "type": "email",
        "input": true
    },
    "container.url": {
        "label": "Url",
        "tableView": true,
        "key": "url",
        "properties": {
            "StepName": "Contacts"
        },
        "type": "url",
        "input": true
    },
    "container.phoneNumber": {
        "label": "Phone Number",
        "tableView": true,
        "key": "phoneNumber",
        "properties": {
            "StepName": "Contacts"
        },
        "type": "phoneNumber",
        "input": true
    },
    "container.additionalDetails.smartTag": {
        "label": "SmartTag",
        "tableView": false,
        "key": "smartTag",
        "properties": {
            "StepName": "Contacts"
        },
        "type": "tags",
        "input": true
    },
    "container.additionalDetails.dateTime": {
        "label": "Date / Time",
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateTime",
        "properties": {
            "StepName": "Contacts"
        },
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
        }
    },
    "container.additionalDetails.day": {
        "label": "Day",
        "hideInputLabels": false,
        "inputsLabelPosition": "top",
        "useLocaleSettings": false,
        "tableView": false,
        "fields": {
            "day": {
                "hide": false
            },
            "month": {
                "hide": false
            },
            "year": {
                "hide": false
            }
        },
        "key": "day",
        "properties": {
            "StepName": "Contacts"
        },
        "type": "day",
        "input": true,
        "defaultValue": "00/00/0000"
    },
    "container.signature": {
        "label": "Signature",
        "tableView": false,
        "key": "signature",
        "properties": {
            "StepName": "Contacts"
        },
        "type": "signature",
        "input": true
    },
    "financialImpact": {
        "label": "Financial Impact",
        "mask": false,
        "spellcheck": true,
        "tableView": false,
        "currency": "USD",
        "inputFormat": "plain",
        "validate": {
            "required": true
        },
        "key": "financialImpact",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "currency",
        "input": true,
        "delimiter": true,
        "hideOnChildrenHidden": false
    },
    "likelyhood": {
        "label": "Likelyhood",
        "suffix": "%",
        "mask": false,
        "spellcheck": true,
        "tableView": false,
        "delimiter": false,
        "requireDecimal": false,
        "inputFormat": "plain",
        "validate": {
            "required": true
        },
        "key": "likelyhood",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "number",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "dateTime1": {
        "label": "Date / Time",
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateTime1",
        "properties": {
            "StepName": "Custom Attributes"
        },
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
        }
    },
    "time": {
        "label": "Time",
        "tableView": true,
        "key": "time",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "time",
        "input": true,
        "inputMask": "99:99"
    },
    "rating": {
        "label": "Rating",
        "disabled": true,
        "tableView": true,
        "key": "rating",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "password": {
        "label": "Password",
        "tableView": false,
        "key": "password",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "password",
        "input": true,
        "protected": true
    },
    "yesNo": {
        "label": "I accept the conditins",
        "tableView": false,
        "defaultValue": false,
        "key": "yesNo",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "checkbox",
        "input": true
    },
    "applicableCategories": {
        "label": "Applicable Categories",
        "optionsLabelPosition": "right",
        "tableView": false,
        "defaultValue": {
            "": false,
            "hr": false,
            "finance": false,
            "it": false,
            "development": false
        },
        "values": [
            {
                "label": "HR",
                "value": "hr",
                "shortcut": "H"
            },
            {
                "label": "Finance",
                "value": "finance",
                "shortcut": "F"
            },
            {
                "label": "IT",
                "value": "it",
                "shortcut": "I"
            },
            {
                "label": "Development",
                "value": "development",
                "shortcut": "D"
            }
        ],
        "key": "applicableCategories",
        "properties": {
            "Stepname": "Custom Attributes"
        },
        "type": "selectboxes",
        "input": true,
        "inputType": "checkbox",
        "hideOnChildrenHidden": false
    },
    "rating1": {
        "label": "Rating",
        "tableView": true,
        "data": {
            "values": [
                {
                    "label": "High",
                    "value": "high"
                },
                {
                    "label": "Medium",
                    "value": "medium"
                },
                {
                    "label": "Low",
                    "value": "low"
                }
            ]
        },
        "selectThreshold": 0.3,
        "key": "rating1",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "select",
        "indexeddb": {
            "filter": {}
        },
        "input": true,
        "hideOnChildrenHidden": false
    },
    "button": {
        "label": "Submit",
        "showValidations": false,
        "tableView": false,
        "key": "button",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "button",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "applicableFactor": {
        "label": "Applicable Factor",
        "optionsLabelPosition": "right",
        "inline": false,
        "tableView": false,
        "values": [
            {
                "label": "Agree",
                "value": "agree",
                "shortcut": "A"
            },
            {
                "label": "Disagree",
                "value": "disagree",
                "shortcut": "N"
            }
        ],
        "validate": {
            "required": true
        },
        "key": "applicableFactor",
        "properties": {
            "StepName": "Custom Attributes"
        },
        "type": "radio",
        "input": true,
        "hideOnChildrenHidden": false
    }
}'

/*
		SELECT * from dbo.Frameworks
		SELECT * from dbo.Frameworks_history
		SELECT * from dbo.FrameworkSteps_history
		SELECT * from dbo.FrameworkStepItems_history
		SELECT * from dbo.FrameworkAttributes_history
		SELECT * from dbo.FrameworkLookups_history

		SELECT * FROM TAB_DATA	 
		SELECT * FROM  TAB_FrameworkSteps
		SELECT * FROM  TAB_FrameworkStepItems
		SELECT * FROM TAB_FrameworkAttributes		
		SELECT * FROM TAB_FrameworkLookups
		
	
		SELECT * FROM FrameworkLookups
		SELECT * FROM FrameworkAttributes
		SELECT * FROM  FrameworkStepItems
		SELECT * FROM  FrameworkSteps
		SELECT * FROM  FrameworkSteps_history

		
		SELECT * FROM  TAB_FrameworkSteps_history
		SELECT * FROM  TAB_FrameworkStepItems_history
		SELECT * FROM TAB_FrameworkAttributes_history		
		SELECT * FROM TAB_FrameworkLookups_history

		SELECT * FROM dbo.TAB_Framework_Attributes_history WHERE VersionNum=4
		EXEC dbo.UpdateHistoryOperationType @FrameworkID=1, @TableInitial ='TAB',@VersionNum=4
		
*/
