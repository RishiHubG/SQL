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
 @UserLoginID=100,
  @inputJSON =
'{
    "general.name": {
        "label": "Name",
        "tableView": true,
        "validate": {
            "required": true
        },
        "key": "name",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "general.referene": {
        "label": "Referene",
        "disabled": true,
        "tableView": true,
        "key": "referene",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "general.description": {
        "label": "Description",
        "autoExpand": false,
        "tableView": true,
        "key": "description",
        "type": "textarea",
        "input": true
    },
    "crmpDetails.highLevelBusinessActivity1": {
        "label": "High Level Business Activity 1",
        "tableView": true,
        "validate": {
            "required": true
        },
        "key": "highLevelBusinessActivity1",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "crmpDetails.highLevelActivity2": {
        "label": "High Level Business Activity 2",
        "tableView": true,
        "key": "highLevelActivity2",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "crmpDetails.highLevelBusinessActivity3": {
        "label": "High Level Business Activity 3",
        "tableView": true,
        "validate": {
            "required": true
        },
        "key": "highLevelBusinessActivity3",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "crmpDetails.businessActivity1": {
        "label": "Business Activity 1",
        "tableView": true,
        "validate": {
            "required": true
        },
        "key": "businessActivity1",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "crmpDetails.businessActivity2": {
        "label": "Business Activity 2",
        "tableView": true,
        "key": "businessActivity2",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "crmpDetails.businessActivity3": {
        "label": "Business Activity 3",
        "tableView": true,
        "key": "businessActivity3",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "crmpDetails.regulatoryRequirementInitiated": {
        "label": "Regulatory Requirement Updated",
        "tableView": false,
        "defaultValue": false,
        "key": "regulatoryRequirementInitiated",
        "type": "checkbox",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "crmpDetails.initiateControlAssessments": {
        "label": "Initiate Control Assessments?",
        "tableView": false,
        "key": "initiateControlAssessments",
        "type": "checkbox",
        "input": true,
        "defaultValue": false
    },
    "businessAssessment.regulatoryRequirementAgreed": {
        "label": "Regulatory Requirement Agreed?",
        "tableView": false,
        "key": "regulatoryRequirementAgreed",
        "type": "checkbox",
        "input": true,
        "defaultValue": false,
        "hideOnChildrenHidden": false
    },
    "businessAssessment.agreedBy": {
        "label": "Agreed By",
        "tableView": true,
        "key": "agreedBy",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "businessAssessment.dateOfAgreement": {
        "label": "Date of Agreement",
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateOfAgreement",
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
    "businessAssessment.notes": {
        "label": "Notes",
        "autoExpand": false,
        "tableView": true,
        "key": "notes",
        "type": "textarea",
        "input": true
    },
    "businessAssessment.businessConfirmationControls": {
        "label": "Business Confirmation Controls",
        "tableView": false,
        "key": "businessConfirmationControls",
        "type": "checkbox",
        "input": true,
        "defaultValue": false,
        "hideOnChildrenHidden": false
    },
    "businessAssessment.validationPerformedBy": {
        "label": "Validation Performed By",
        "tableView": true,
        "key": "validationPerformedBy",
        "type": "textfield",
        "input": true,
        "hideOnChildrenHidden": false
    },
    "businessAssessment.dateOfValidation": {
        "label": "Date of Validation",
        "tableView": false,
        "enableMinDateInput": false,
        "datePicker": {
            "disableWeekends": false,
            "disableWeekdays": false
        },
        "enableMaxDateInput": false,
        "key": "dateOfValidation",
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
    "businessAssessment.businessConfirmationOfControlsNotes": {
        "label": "Business Confirmation Of Controls : Notes:",
        "autoExpand": false,
        "tableView": true,
        "key": "businessConfirmationOfControlsNotes",
        "type": "textarea",
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
