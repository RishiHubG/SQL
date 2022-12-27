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

	DROP TABLE TAB_DATA
	SELECT * FROM TAB_DATA
	SELECT * FROM TAB_data_history
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
--BEGIN TRAN;
 EXEC dbo.ParseFrameworkJSONData
 @Name = 'TAB',
 @UserLoginID=100,
 @FullSchemaJSON = '{
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
  "general.reference": {
    "label": "Reference",
    "disabled": true,
    "tableView": true,
    "key": "reference",
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
  "riskDetail.riskProgressForReporting": {
    "label": "Risk Progress for Reporting",
    "autoExpand": false,
    "tableView": true,
    "validate": {
      "required": true
    },
    "key": "riskProgressForReporting",
    "type": "textarea",
    "input": true
  },
  "riskDetail.regulatoryComplianceRequirements": {
    "label": "Regulatory / Compliance Requirements:",
    "tableView": false,
    "key": "regulatoryComplianceRequirements",
    "type": "checkbox",
    "input": true,
    "defaultValue": false
  },
  "riskDetail.riskCategory1": {
    "label": "Risk Category 1",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Business",
          "value": "business"
        },
        {
          "label": "Conduct",
          "value": "conduct"
        },
        {
          "label": "Credit",
          "value": "credit"
        },
        {
          "label": "External",
          "value": "external"
        },
        {
          "label": "Insurance",
          "value": "insurance"
        },
        {
          "label": "Liquidity",
          "value": "liquidity"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "riskCategory1",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.riskCategory2": {
    "label": "Risk Category 2",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Maintenance",
          "value": "maintenance"
        },
        {
          "label": "Project",
          "value": "project"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "riskCategory2",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.riskCategory3": {
    "label": "Risk Category 3",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Not Applicable",
          "value": "notApplicable"
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
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalCategory1": {
    "label": "Causal Category 1",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "People",
          "value": "people"
        },
        {
          "label": "Process",
          "value": "process"
        },
        {
          "label": "System",
          "value": "system"
        },
        {
          "label": "Internal",
          "value": "internal"
        },
        {
          "label": "External",
          "value": "external"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "causalCategory1",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalSubCategory": {
    "label": "Causal Sub-Category 1",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "causalSubCategory",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalDescription1": {
    "label": "Causal Description 1",
    "autoExpand": false,
    "tableView": true,
    "key": "causalDescription1",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalCategory2": {
    "label": "Causal Category 2",
    "widget": "choicesjs",
    "hidden": true,
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "People",
          "value": "people"
        },
        {
          "label": "Process",
          "value": "process"
        },
        {
          "label": "System",
          "value": "system"
        },
        {
          "label": "Internal",
          "value": "internal"
        },
        {
          "label": "External",
          "value": "external"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalCategory2",
    "customConditional": "show=(data.riskDetail.causalCategory1 !== \"\")",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalSubCategory2": {
    "label": "Causal Sub-Category 2",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalSubCategory2",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalDescription2": {
    "label": "Causal Description 2",
    "autoExpand": false,
    "tableView": true,
    "key": "causalDescription2",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalCategory3": {
    "label": "Causal Category 3",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "People",
          "value": "people"
        },
        {
          "label": "Proces",
          "value": "proces"
        },
        {
          "label": "System",
          "value": "system"
        },
        {
          "label": "Internal",
          "value": "internal"
        },
        {
          "label": "External",
          "value": "external"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalCategory3",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalSubCategory3": {
    "label": "Causal Sub-Category 3",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalSubCategory3",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalDescription3": {
    "label": "Causal Description 3",
    "autoExpand": false,
    "tableView": true,
    "key": "causalDescription3",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskContact.riskOwnerFreeText": {
    "label": "Risk Owner (Free Text)",
    "tableView": true,
    "key": "riskOwnerFreeText",
    "type": "textfield",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskContact.riskCoordinatorFreeText": {
    "label": "Risk Coordinator (Free Text)",
    "tableView": true,
    "key": "riskCoordinatorFreeText",
    "type": "textfield",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.likelyhood": {
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
    "type": "number",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.localCurrency": {
    "label": "Local Currency",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "TZX - Tanzanian Shilling",
          "value": "1"
        },
        {
          "label": "USD - US Dollar",
          "value": "2"
        },
        {
          "label": "RWF - Rwandan Franc",
          "value": "3"
        },
        {
          "label": "ZAR - South African Rand",
          "value": "4"
        },
        {
          "label": "KES - Kenya Shillings",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "localCurrency",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.financialExposureLocalCurrency": {
    "label": "Financial Exposure (Local Currency)",
    "mask": false,
    "spellcheck": true,
    "tableView": false,
    "delimiter": true,
    "requireDecimal": true,
    "inputFormat": "plain",
    "validate": {
      "required": true
    },
    "key": "financialExposureLocalCurrency",
    "type": "number",
    "input": true,
    "decimalLimit": 2,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactReputational": {
    "label": "Non Financial Impact (Reputational)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Insignificatn",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "nonFinancialImpactReputational",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactBusiness": {
    "label": "Non Financial Impact (Business)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "nonFinancialImpactBusiness",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactLicense": {
    "label": "Non Financial Impact (License)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "nonFinancialImpactLicense",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.likelihoodRationale": {
    "label": "Likelihood Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "likelihoodRationale",
    "logic": [
      {
        "name": "Likelihood-Dependency",
        "trigger": {
          "type": "javascript",
          "javascript": "result=(data.inherentRatings.likelyhood>0)"
        },
        "actions": [
          {
            "name": "Likelyhood Rationale Mandatory",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.financialImpactRationale": {
    "label": "Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "financialImpactRationale",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactRationale": {
    "label": "Non Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "nonFinancialImpactRationale",
    "logic": [
      {
        "name": "Mandator - Non Financial Rationale",
        "trigger": {
          "type": "javascript",
          "javascript": "result = (data.inherentRatings.nonFinancialImpactReputational > 0||data.inherentRatings.nonFinancialImpactBusiness >0||data.inherentRatings.nonFinancialImpactLicense > 0)"
        },
        "actions": [
          {
            "name": "Mandatory Non financial Rationale",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.likelihoodImpact": {
    "label": "LikelihoodImpact",
    "mask": false,
    "spellcheck": true,
    "disabled": true,
    "tableView": false,
    "delimiter": false,
    "requireDecimal": false,
    "inputFormat": "plain",
    "calculateValue": "value=data.inherentRatings.likelyhood*data.inherentRatings.financialExposureLocalCurrency;",
    "key": "likelihoodImpact",
    "type": "number",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.inherentRatingOverall": {
    "label": "Inherent Rating Overall",
    "disabled": true,
    "tableView": true,
    "calculateValue": "var matrix = [[0,10, 0, 2000, 25], [0, 10, 2001, 4000, 27], [0, 10, 4001, 6000, 29], [0, 10, 6001, 99999, 30]];\nvar x=data.inherentRatings.likelyhood,\n    y=data.inherentRatings.financialExposureLocalCurrency;\nmatrix.forEach(function (t, idx) {\n var xMin = t[0],xMax = t[1],yMin=t[2],yMax=t[3];\n console.log(t,xMin,xMax,yMin,yMax,t[4],x,y);\n if((x>=xMin && x <=xMax) && (y>=yMin && y<=yMax)) { \n value = t[4]; \n return;\n }\n});",
    "key": "inherentRatingOverall",
    "type": "textfield",
    "input": true
  },
  "inherentRatings.whichPartiesElementsAreImpacted": {
    "label": "Which parties/elements are impacted?",
    "hideLabel": true,
    "disabled": true,
    "tableView": true,
    "key": "whichPartiesElementsAreImpacted",
    "type": "textfield",
    "input": true,
    "defaultValue": "Which parties/elements are impacted?"
  },
  "inherentRatings.whichPartiesAreEffected.reputational": {
    "label": "Reputational",
    "optionsLabelPosition": "right",
    "tableView": true,
    "defaultValue": {
      "1": false,
      "": false,
      "investors": false,
      "society": false,
      "shareholders": false,
      "employees": false,
      "suppliers": false
    },
    "values": [
      {
        "label": "Customer",
        "value": "1",
        "shortcut": ""
      },
      {
        "label": "Investors",
        "value": "investors",
        "shortcut": ""
      },
      {
        "label": "Society",
        "value": "society",
        "shortcut": ""
      },
      {
        "label": "Shareholders",
        "value": "shareholders",
        "shortcut": ""
      },
      {
        "label": "Employees",
        "value": "employees",
        "shortcut": ""
      },
      {
        "label": "Suppliers",
        "value": "suppliers",
        "shortcut": ""
      }
    ],
    "key": "reputational",
    "type": "selectboxes",
    "input": true,
    "inputType": "checkbox",
    "hideOnChildrenHidden": false
  },
  "inherentRatings.whichPartiesAreEffected.licenseToOperate": {
    "label": "License to Operate",
    "optionsLabelPosition": "right",
    "tableView": false,
    "values": [
      {
        "label": "Regulators",
        "value": "1",
        "shortcut": ""
      },
      {
        "label": "Governmnet",
        "value": "2",
        "shortcut": ""
      },
      {
        "label": "Legal",
        "value": "3",
        "shortcut": ""
      }
    ],
    "key": "licenseToOperate",
    "type": "selectboxes",
    "input": true,
    "inputType": "checkbox",
    "defaultValue": {
      "": false
    },
    "hideOnChildrenHidden": false
  },
  "inherentRatings.whichPartiesAreEffected.businessContinuity": {
    "label": "Business Continuity",
    "optionsLabelPosition": "right",
    "tableView": false,
    "values": [
      {
        "label": "Staff",
        "value": "1",
        "shortcut": ""
      },
      {
        "label": "IT",
        "value": "2",
        "shortcut": ""
      },
      {
        "label": "System",
        "value": "3",
        "shortcut": ""
      },
      {
        "label": "Customer",
        "value": "4",
        "shortcut": ""
      },
      {
        "label": "Reporting",
        "value": "5",
        "shortcut": ""
      },
      {
        "label": "MI",
        "value": "6",
        "shortcut": ""
      }
    ],
    "key": "businessContinuity",
    "type": "selectboxes",
    "input": true,
    "inputType": "checkbox",
    "defaultValue": {
      "": false
    },
    "hideOnChildrenHidden": false
  },
  "controls.controlEnvironmentAdequacy": {
    "label": "Control Environment Adequacy?",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Adequate",
          "value": "adequate"
        },
        {
          "label": "In Adequate",
          "value": "inAdequate"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "controlEnvironmentAdequacy",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true
  },
  "controls.controlEnvironmentEffectiveness": {
    "label": "Control Environment Effectiveness",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "controlEnvironmentEffectiveness",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true
  },
  "controls.controlEnvironmentRationale": {
    "label": "Control Environment Rationale",
    "autoExpand": false,
    "tableView": true,
    "validate": {
      "required": true
    },
    "key": "controlEnvironmentRationale",
    "type": "textarea",
    "input": true
  },
  "inherentRatings1.rlikelyhood": {
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
    "key": "rlikelyhood",
    "type": "number",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rlocalCurrency": {
    "label": "Local Currency",
    "widget": "choicesjs",
    "disabled": true,
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "TZX - Tanzanian Shilling",
          "value": "1"
        },
        {
          "label": "USD - US Dollar",
          "value": "2"
        },
        {
          "label": "RWF - Rwandan Franc",
          "value": "3"
        },
        {
          "label": "ZAR - South African Rand",
          "value": "4"
        },
        {
          "label": "KES - Kenya Shillings",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "rlocalCurrency",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rfinancialExposureLocalCurrency": {
    "label": "rFinancial Exposure (Local Currency)",
    "mask": false,
    "spellcheck": true,
    "tableView": false,
    "delimiter": true,
    "requireDecimal": true,
    "inputFormat": "plain",
    "validate": {
      "required": true
    },
    "key": "rfinancialExposureLocalCurrency",
    "type": "number",
    "decimalLimit": 2,
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactReputational": {
    "label": "Non Financial Impact (Reputational)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Insignificatn",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "rnonFinancialImpactReputational",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactBusiness": {
    "label": "Non Financial Impact (Business)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "rnonFinancialImpactBusiness",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactLicense": {
    "label": "Non Financial Impact (License)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "rnonFinancialImpactLicense",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rlikelihoodRationale": {
    "label": "Likelihood Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "rlikelihoodRationale",
    "logic": [
      {
        "name": "Likelihood-Dependency",
        "trigger": {
          "type": "javascript",
          "javascript": "result=(data.inherentRatings.likelyhood>0)"
        },
        "actions": [
          {
            "name": "Likelyhood Rationale Mandatory",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rfinancialImpactRationale": {
    "label": "Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "rfinancialImpactRationale",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactRationale": {
    "label": "Non Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "rnonFinancialImpactRationale",
    "logic": [
      {
        "name": "Mandator - Non Financial Rationale",
        "trigger": {
          "type": "javascript",
          "javascript": "result = (data.inherentRatings.nonFinancialImpactReputational > 0||data.inherentRatings.nonFinancialImpactBusiness >0||data.inherentRatings.nonFinancialImpactLicense > 0)"
        },
        "actions": [
          {
            "name": "Mandatory Non financial Rationale",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rinherentRatingOverall": {
    "label": "Inherent Rating Overall",
    "disabled": true,
    "tableView": true,
    "key": "rinherentRatingOverall",
    "type": "textfield",
    "input": true
  }
}'
,
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
  "general.reference": {
    "label": "Reference",
    "disabled": true,
    "tableView": true,
    "key": "reference",
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
  "riskDetail.riskProgressForReporting": {
    "label": "Risk Progress for Reporting",
    "autoExpand": false,
    "tableView": true,
    "validate": {
      "required": true
    },
    "key": "riskProgressForReporting",
    "type": "textarea",
    "input": true
  },
  "riskDetail.regulatoryComplianceRequirements": {
    "label": "Regulatory / Compliance Requirements:",
    "tableView": false,
    "key": "regulatoryComplianceRequirements",
    "type": "checkbox",
    "input": true,
    "defaultValue": false
  },
  "riskDetail.riskCategory1": {
    "label": "Risk Category 1",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Business",
          "value": "business"
        },
        {
          "label": "Conduct",
          "value": "conduct"
        },
        {
          "label": "Credit",
          "value": "credit"
        },
        {
          "label": "External",
          "value": "external"
        },
        {
          "label": "Insurance",
          "value": "insurance"
        },
        {
          "label": "Liquidity",
          "value": "liquidity"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "riskCategory1",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.riskCategory2": {
    "label": "Risk Category 2",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Maintenance",
          "value": "maintenance"
        },
        {
          "label": "Project",
          "value": "project"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "riskCategory2",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.riskCategory3": {
    "label": "Risk Category 3",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Not Applicable",
          "value": "notApplicable"
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
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalCategory1": {
    "label": "Causal Category 1",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "People",
          "value": "people"
        },
        {
          "label": "Process",
          "value": "process"
        },
        {
          "label": "System",
          "value": "system"
        },
        {
          "label": "Internal",
          "value": "internal"
        },
        {
          "label": "External",
          "value": "external"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "causalCategory1",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalSubCategory": {
    "label": "Causal Sub-Category 1",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "causalSubCategory",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalDescription1": {
    "label": "Causal Description 1",
    "autoExpand": false,
    "tableView": true,
    "key": "causalDescription1",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalCategory2": {
    "label": "Causal Category 2",
    "widget": "choicesjs",
    "hidden": true,
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "People",
          "value": "people"
        },
        {
          "label": "Process",
          "value": "process"
        },
        {
          "label": "System",
          "value": "system"
        },
        {
          "label": "Internal",
          "value": "internal"
        },
        {
          "label": "External",
          "value": "external"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalCategory2",
    "customConditional": "show=(data.riskDetail.causalCategory1 !== \"\")",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalSubCategory2": {
    "label": "Causal Sub-Category 2",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalSubCategory2",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalDescription2": {
    "label": "Causal Description 2",
    "autoExpand": false,
    "tableView": true,
    "key": "causalDescription2",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalCategory3": {
    "label": "Causal Category 3",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "People",
          "value": "people"
        },
        {
          "label": "Proces",
          "value": "proces"
        },
        {
          "label": "System",
          "value": "system"
        },
        {
          "label": "Internal",
          "value": "internal"
        },
        {
          "label": "External",
          "value": "external"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalCategory3",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalSubCategory3": {
    "label": "Causal Sub-Category 3",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "causalSubCategory3",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskDetail.causalDescription3": {
    "label": "Causal Description 3",
    "autoExpand": false,
    "tableView": true,
    "key": "causalDescription3",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskContact.riskOwnerFreeText": {
    "label": "Risk Owner (Free Text)",
    "tableView": true,
    "key": "riskOwnerFreeText",
    "type": "textfield",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "riskContact.riskCoordinatorFreeText": {
    "label": "Risk Coordinator (Free Text)",
    "tableView": true,
    "key": "riskCoordinatorFreeText",
    "type": "textfield",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.likelyhood": {
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
    "type": "number",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.localCurrency": {
    "label": "Local Currency",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "TZX - Tanzanian Shilling",
          "value": "1"
        },
        {
          "label": "USD - US Dollar",
          "value": "2"
        },
        {
          "label": "RWF - Rwandan Franc",
          "value": "3"
        },
        {
          "label": "ZAR - South African Rand",
          "value": "4"
        },
        {
          "label": "KES - Kenya Shillings",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "localCurrency",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.financialExposureLocalCurrency": {
    "label": "Financial Exposure (Local Currency)",
    "mask": false,
    "spellcheck": true,
    "tableView": false,
    "delimiter": true,
    "requireDecimal": true,
    "inputFormat": "plain",
    "validate": {
      "required": true
    },
    "key": "financialExposureLocalCurrency",
    "type": "number",
    "input": true,
    "decimalLimit": 2,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactReputational": {
    "label": "Non Financial Impact (Reputational)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Insignificatn",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "nonFinancialImpactReputational",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactBusiness": {
    "label": "Non Financial Impact (Business)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "nonFinancialImpactBusiness",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactLicense": {
    "label": "Non Financial Impact (License)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "nonFinancialImpactLicense",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.likelihoodRationale": {
    "label": "Likelihood Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "likelihoodRationale",
    "logic": [
      {
        "name": "Likelihood-Dependency",
        "trigger": {
          "type": "javascript",
          "javascript": "result=(data.inherentRatings.likelyhood>0)"
        },
        "actions": [
          {
            "name": "Likelyhood Rationale Mandatory",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.financialImpactRationale": {
    "label": "Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "financialImpactRationale",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.nonFinancialImpactRationale": {
    "label": "Non Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "nonFinancialImpactRationale",
    "logic": [
      {
        "name": "Mandator - Non Financial Rationale",
        "trigger": {
          "type": "javascript",
          "javascript": "result = (data.inherentRatings.nonFinancialImpactReputational > 0||data.inherentRatings.nonFinancialImpactBusiness >0||data.inherentRatings.nonFinancialImpactLicense > 0)"
        },
        "actions": [
          {
            "name": "Mandatory Non financial Rationale",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.likelihoodImpact": {
    "label": "LikelihoodImpact",
    "mask": false,
    "spellcheck": true,
    "disabled": true,
    "tableView": false,
    "delimiter": false,
    "requireDecimal": false,
    "inputFormat": "plain",
    "calculateValue": "value=data.inherentRatings.likelyhood*data.inherentRatings.financialExposureLocalCurrency;",
    "key": "likelihoodImpact",
    "type": "number",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings.inherentRatingOverall": {
    "label": "Inherent Rating Overall",
    "disabled": true,
    "tableView": true,
    "calculateValue": "var matrix = [[0,10, 0, 2000, 25], [0, 10, 2001, 4000, 27], [0, 10, 4001, 6000, 29], [0, 10, 6001, 99999, 30]];\nvar x=data.inherentRatings.likelyhood,\n    y=data.inherentRatings.financialExposureLocalCurrency;\nmatrix.forEach(function (t, idx) {\n var xMin = t[0],xMax = t[1],yMin=t[2],yMax=t[3];\n console.log(t,xMin,xMax,yMin,yMax,t[4],x,y);\n if((x>=xMin && x <=xMax) && (y>=yMin && y<=yMax)) { \n value = t[4]; \n return;\n }\n});",
    "key": "inherentRatingOverall",
    "type": "textfield",
    "input": true
  },
  "inherentRatings.whichPartiesElementsAreImpacted": {
    "label": "Which parties/elements are impacted?",
    "hideLabel": true,
    "disabled": true,
    "tableView": true,
    "key": "whichPartiesElementsAreImpacted",
    "type": "textfield",
    "input": true,
    "defaultValue": "Which parties/elements are impacted?"
  },
  "inherentRatings.whichPartiesAreEffected.reputational": {
    "label": "Reputational",
    "optionsLabelPosition": "right",
    "tableView": true,
    "defaultValue": {
      "1": false,
      "": false,
      "investors": false,
      "society": false,
      "shareholders": false,
      "employees": false,
      "suppliers": false
    },
    "values": [
      {
        "label": "Customer",
        "value": "1",
        "shortcut": ""
      },
      {
        "label": "Investors",
        "value": "investors",
        "shortcut": ""
      },
      {
        "label": "Society",
        "value": "society",
        "shortcut": ""
      },
      {
        "label": "Shareholders",
        "value": "shareholders",
        "shortcut": ""
      },
      {
        "label": "Employees",
        "value": "employees",
        "shortcut": ""
      },
      {
        "label": "Suppliers",
        "value": "suppliers",
        "shortcut": ""
      }
    ],
    "key": "reputational",
    "type": "selectboxes",
    "input": true,
    "inputType": "checkbox",
    "hideOnChildrenHidden": false
  },
  "inherentRatings.whichPartiesAreEffected.licenseToOperate": {
    "label": "License to Operate",
    "optionsLabelPosition": "right",
    "tableView": false,
    "values": [
      {
        "label": "Regulators",
        "value": "1",
        "shortcut": ""
      },
      {
        "label": "Governmnet",
        "value": "2",
        "shortcut": ""
      },
      {
        "label": "Legal",
        "value": "3",
        "shortcut": ""
      }
    ],
    "key": "licenseToOperate",
    "type": "selectboxes",
    "input": true,
    "inputType": "checkbox",
    "defaultValue": {
      "": false
    },
    "hideOnChildrenHidden": false
  },
  "inherentRatings.whichPartiesAreEffected.businessContinuity": {
    "label": "Business Continuity",
    "optionsLabelPosition": "right",
    "tableView": false,
    "values": [
      {
        "label": "Staff",
        "value": "1",
        "shortcut": ""
      },
      {
        "label": "IT",
        "value": "2",
        "shortcut": ""
      },
      {
        "label": "System",
        "value": "3",
        "shortcut": ""
      },
      {
        "label": "Customer",
        "value": "4",
        "shortcut": ""
      },
      {
        "label": "Reporting",
        "value": "5",
        "shortcut": ""
      },
      {
        "label": "MI",
        "value": "6",
        "shortcut": ""
      }
    ],
    "key": "businessContinuity",
    "type": "selectboxes",
    "input": true,
    "inputType": "checkbox",
    "defaultValue": {
      "": false
    },
    "hideOnChildrenHidden": false
  },
  "controls.controlEnvironmentAdequacy": {
    "label": "Control Environment Adequacy?",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Adequate",
          "value": "adequate"
        },
        {
          "label": "In Adequate",
          "value": "inAdequate"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "controlEnvironmentAdequacy",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true
  },
  "controls.controlEnvironmentEffectiveness": {
    "label": "Control Environment Effectiveness",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "",
          "value": ""
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "controlEnvironmentEffectiveness",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true
  },
  "controls.controlEnvironmentRationale": {
    "label": "Control Environment Rationale",
    "autoExpand": false,
    "tableView": true,
    "validate": {
      "required": true
    },
    "key": "controlEnvironmentRationale",
    "type": "textarea",
    "input": true
  },
  "inherentRatings1.rlikelyhood": {
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
    "key": "rlikelyhood",
    "type": "number",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rlocalCurrency": {
    "label": "Local Currency",
    "widget": "choicesjs",
    "disabled": true,
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "TZX - Tanzanian Shilling",
          "value": "1"
        },
        {
          "label": "USD - US Dollar",
          "value": "2"
        },
        {
          "label": "RWF - Rwandan Franc",
          "value": "3"
        },
        {
          "label": "ZAR - South African Rand",
          "value": "4"
        },
        {
          "label": "KES - Kenya Shillings",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "validate": {
      "required": true
    },
    "key": "rlocalCurrency",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rfinancialExposureLocalCurrency": {
    "label": "rFinancial Exposure (Local Currency)",
    "mask": false,
    "spellcheck": true,
    "tableView": false,
    "delimiter": true,
    "requireDecimal": true,
    "inputFormat": "plain",
    "validate": {
      "required": true
    },
    "key": "rfinancialExposureLocalCurrency",
    "type": "number",
    "decimalLimit": 2,
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactReputational": {
    "label": "Non Financial Impact (Reputational)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Insignificatn",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "rnonFinancialImpactReputational",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactBusiness": {
    "label": "Non Financial Impact (Business)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "rnonFinancialImpactBusiness",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactLicense": {
    "label": "Non Financial Impact (License)",
    "widget": "choicesjs",
    "tableView": true,
    "data": {
      "values": [
        {
          "label": "Significant",
          "value": "1"
        },
        {
          "label": "Major",
          "value": "2"
        },
        {
          "label": "Moderate",
          "value": "3"
        },
        {
          "label": "Minor",
          "value": "4"
        },
        {
          "label": "Low",
          "value": "5"
        }
      ]
    },
    "selectThreshold": 0.3,
    "key": "rnonFinancialImpactLicense",
    "type": "select",
    "indexeddb": {
      "filter": {}
    },
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rlikelihoodRationale": {
    "label": "Likelihood Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "rlikelihoodRationale",
    "logic": [
      {
        "name": "Likelihood-Dependency",
        "trigger": {
          "type": "javascript",
          "javascript": "result=(data.inherentRatings.likelyhood>0)"
        },
        "actions": [
          {
            "name": "Likelyhood Rationale Mandatory",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rfinancialImpactRationale": {
    "label": "Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "rfinancialImpactRationale",
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rnonFinancialImpactRationale": {
    "label": "Non Financial Impact Rationale",
    "autoExpand": false,
    "tableView": true,
    "key": "rnonFinancialImpactRationale",
    "logic": [
      {
        "name": "Mandator - Non Financial Rationale",
        "trigger": {
          "type": "javascript",
          "javascript": "result = (data.inherentRatings.nonFinancialImpactReputational > 0||data.inherentRatings.nonFinancialImpactBusiness >0||data.inherentRatings.nonFinancialImpactLicense > 0)"
        },
        "actions": [
          {
            "name": "Mandatory Non financial Rationale",
            "type": "property",
            "property": {
              "label": "Required",
              "value": "validate.required",
              "type": "boolean"
            },
            "state": true
          }
        ]
      }
    ],
    "type": "textarea",
    "input": true,
    "hideOnChildrenHidden": false
  },
  "inherentRatings1.rinherentRatingOverall": {
    "label": "Inherent Rating Overall",
    "disabled": true,
    "tableView": true,
    "key": "rinherentRatingOverall",
    "type": "textfield",
    "input": true
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
--DROP TABLE TAB_DATA

/*
IF "type": "selectboxes", THEN CREATED 4 ADDITIONAL COLUMNS IN _DATA:
reputational_Name
reputational_Value
reputational_Description
reputational_Color
*/
SET XACT_ABORT ON
--rollback
--BEGIN TRAN;
EXEC p1 --dbo.ParseFrameworkJSONData 
@Name='BWEAudit',
@InputJSON='{"auditContainer.name":{"label":"Audit Name","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"name","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"e2ow9g","defaultValue":"","hideOnChildrenHidden":false},"auditContainer.referencenum":{"label":"Audit Reference","disabled":true,"tableView":true,"key":"referencenum","type":"textfield","input":true,"hideOnChildrenHidden":false,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e7bgm0h","width":3},"auditContainer.auditStatus":{"label":"Audit Status","labelPosition":"top","widget":"choicesjs","placeholder":"","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"uniqueOptions":false,"autofocus":false,"disabled":true,"tableView":true,"modalEdit":false,"multiple":false,"dataSrc":"values","data":{"values":[{"label":"Initiate","value":"Initiate"},{"label":"Audit Under Process","value":"Audit Under Process"},{"label":"Submitted for Review","value":"Submitted for Review"},{"label":"Audit Closed","value":"Audit Closed"},{"label":"Revert to Auditor","value":"Revert to Auditor"}],"resource":"","json":"","url":"","custom":""},"valueProperty":"","dataType":"","idPath":"id","template":"<span>{{ item.label }}</span>","refreshOn":"","clearOnRefresh":false,"searchEnabled":true,"selectThreshold":0.3,"readOnlyValue":false,"customOptions":{},"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"auditStatus","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page" :"","left":"","top":"","width":"","height":""},"type":"select","indexeddb":{"filter":{}},"selectFields":"","searchField":"","minSearch":0,"filter":"","limit":100,"redrawOn":"","input":true,"hideOnChildrenHidden":false,"width":3,"prefix":"","suffix":"","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"lazyLoad":true,"authenticate":false,"searchThreshold":0.3,"fuseOptions":{"include":"score","threshold":0.3},"id":"eqjiyg","defaultValue":""},"auditContainer.planStartDate":{"label":"Plan Start Date","allowInput":false,"format":"yyyy-MM-dd","tableView":false,"enableMinDateInput":false,"datePicker":{"disableWeekends":false,"disableWeekdays":false,"showWeeks":true,"startingDay":0,"initDate":"","minMode":"day","maxMode":"year","yearRows":4,"yearColumns":5,"minDate":null,"maxDate":null},"enableMaxDateInput":false,"enableTime":false,"key":"planStartDate","type":"datetime","input":true,"widget":{"type":"calendar","displayInTimezone":"viewer","locale":"en","useLocaleSettings":false,"allowInput":false,"mode":"single","enableTime":false,"noCalendar":false,"format":"yyyy-MM-dd","hourIncrement":1,"minuteIncrement":1,"time_24hr":false,"minDate":null,"disableWeekends":false,"disableWeekdays":false,"maxDate":null},"hideOnChildrenHidden":false,"width":3,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":"","protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"useLocaleSettings":false,"enableDate":true,"defaultDate":"","displayInTimezone":"viewer","timezone":"","datepickerMode":"day","timePicker":{"hourStep":1,"minuteStep":1,"showMeridian":true,"readonlyInput":false,"mousewheel":true,"arrowkeys":true},"customOptions":{},"id":"eewgs68"},"auditContainer.planEndDate":{"label":"Plan End Date","allowInput":false,"format":"yyyy-MM-dd","tableView":false,"enableMinDateInput":false,"datePicker":{"disableWeekends":false,"disableWeekdays":false,"showWeeks":true,"startingDay":0,"initDate":"","minMode":"day","maxMode":"year","yearRows":4,"yearColumns":5,"minDate":null,"maxDate":null},"enableMaxDateInput":false,"enableTime":false,"key":"planEndDate","type":"datetime","input":true,"widget":{"type":"calendar","displayInTimezone":"viewer","locale":"en","useLocaleSettings":false,"allowInput":false,"mode":"single","enableTime":false,"noCalendar":false,"format":"yyyy-MM-dd","hourIncrement":1,"minuteIncrement":1,"time_24hr":false,"minDate":null,"disableWeekends":false,"disableWeekdays":false,"maxDate":null},"hideOnChildrenHidden":false,"width":3,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":"","protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCou nt":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"useLocaleSettings":false,"enableDate":true,"defaultDate":"","displayInTimezone":"viewer","timezone":"","datepickerMode":"day","timePicker":{"hourStep":1,"minuteStep":1,"showMeridian":true,"readonlyInput":false,"mousewheel":true,"arrowkeys":true},"customOptions":{},"id":"efduxxl"},"auditContainer.sectionNumer":{"label":"Section Numer","disabled":true,"tableView":true,"key":"sectionNumer","type":"textfield","input":true,"hideOnChildrenHidden":false,"width":6,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e09rwrb"},"auditContainer.controlObjective":{"label":"Control Objective","autoExpand":false,"disabled":true,"tableView":true,"key":"controlObjective","type":"textarea","input":true,"hideOnChildrenHidden":false,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":"","minWords":"","maxWords":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"html","inputMask":"","spellcheck":true,"rows":3,"wysiwyg":false,"editor":"","fixedSize":true,"id":"et8vwhe"},"auditContainer.scope":{"label":"Scope","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":true,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"scope","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type ":"textfield","input":true,"hideOnChildrenHidden":false,"refreshOn":"","inputType":"text","id":"eqog5q","defaultValue":""},"auditContainer.risk":{"label":"Risk","autoExpand":false,"disabled":true,"tableView":true,"key":"risk","type":"textarea","input":true,"hideOnChildrenHidden":false,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":"","minWords":"","maxWords":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"html","inputMask":"","spellcheck":true,"rows":3,"wysiwyg":false,"editor":"","fixedSize":true,"id":"euyztsc"},"auditContainer.auditFindings1":{"label":"Audit Findings ","customGridKey":"auditlevelfindings","entityId":"","entityTypeId":"","frameworkId":"","pentityId":"","pentityTypeId":"","labelPosition":"top","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"autofocus":false,"disabled":false,"tableView":false,"modalEdit":false,"multiple":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"auditFindings1","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":null,"when":null,"eq":""},"logic":[{"name":"on Load","trigger":{"type":"javascript","javascript":"result= true;"},"actions":[{"name":"populateIds","type":"mergeComponentSchema","schemaDefinition":"schema = {frameworkId:data.frameworkId, entityId:data.entityId,entityTypeId:data.entityTypeId,pentityId:data.pentityId, pentityTypeId:data.pentityTypeId }"}]}],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"queryGrid","input":true,"placeholder":"","prefix":"","suffix":"","refreshOn":"","widget":null,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"id":"eyyya1","defaultValue":null},"leadershipandculture.leadershipandculture":{"label":"LeadershipandCulture","tableView":true,"key":"leadershipandculture","type":"textfield","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultiple Masks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"eocsej9"},"sheqCompliance.sheqCompliance1":{"label":"SHEQ Compliance","tableView":true,"key":"sheqCompliance1","type":"textfield","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e828ct"},"riskManagement.riskManagement1":{"label":"Risk Management","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"riskManagement1","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ec7b8n8","defaultValue":""},"healthandHygiene.healthandHygiene1":{"label":"Health and Hygiene","tableView":true,"key":"healthandHygiene1","type":"textfield","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e1wak5w"},"fireDefense.fireDefense1":{"label":"Fire Defense","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden ":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"fireDefense1","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ec8x8vm","defaultValue":""}}',
@UserLoginID=20,@LogRequest=1,
@FullSchemaJSON='{"components":[{"title":"Audit Details","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"page1","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":null,"when":null,"eq":""},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"Audit","tabindex":"","components":[{"title":"Audit Details","theme":"info","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"collapsible":false,"key":"auditDetails","type":"panel","label":"Panel","input":false,"tableView":false,"components":[{"label":"Audit Container","tableView":false,"key":"auditContainer","type":"container","input":true,"components":[{"title":"Audit Details","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"auditDetails","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":null,"when":null,"eq":""},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"Panel","tabindex":"","input":false,"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","tableView":false,"labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"components":[{"label":"Audit Name","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":fal se,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"name","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"e2ow9g","defaultValue":"","hideOnChildrenHidden":false},{"label":"Columns","columns":[{"components":[{"label":"Audit Reference","disabled":true,"tableView":true,"key":"referencenum","type":"textfield","input":true,"hideOnChildrenHidden":false,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e7bgm0h","width":3},{"label":"Audit Status","labelPosition":"top","widget":"choicesjs","placeholder":"","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"uniqueOptions":false,"autofocus":false,"disabled":true,"tableView":true,"modalEdit":false,"multiple":false,"dataSrc":"values","data":{"values":[{"label":"Initiate","value":"Initiate"},{"label":"Audit Under Process","value":"Audit Under Process"},{"label":"Submitted for Review","value":"Submitted for Review"},{"label":"Audit Closed","value":"Audit Closed"},{"label":"Revert to Auditor","value":"Revert to Auditor"}],"resource":"","json":"","url":"","custom":""},"valueProperty":"","dataType":"","idPath":"id","template":"<span>{{ item.label }}</span>","refreshOn":"","clearOnRefresh":false,"searchEnabled":true,"selectThreshold":0.3,"readOnlyValue":false,"customOptions":{},"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"auditStatus","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"select","indexeddb":{"filter":{}},"selectFields":"","searchField":"","minSearch":0,"filter":"","limit":100,"redrawOn":"","input":true,"hideOnChildrenHidden":false,"width":3,"prefix":"","suffix":"","showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"lazyLoad":true,"authenticate":false,"searchThreshold":0.3,"fuseOptions":{"include":"score","threshold":0.3},"id":"eqjiyg","defaultValue":""}],"width":6,"offset":0,"push":0,"pull":0,"size":"md"},{"components":[{"label":"Plan Start Date","allowInput":false,"format":"yyyy-MM-dd","tableView":false,"enableMinDateInput":false,"datePicker":{"disableWeekends":false,"disableWeekdays":false,"showWeeks":true,"startingDay":0,"initDate":"","minMode":"day","maxMode":"year","yearRows":4,"yearColumns":5,"minDate":null,"maxDate":null},"enableMaxDateInput":fals e,"enableTime":false,"key":"planStartDate","type":"datetime","input":true,"widget":{"type":"calendar","displayInTimezone":"viewer","locale":"en","useLocaleSettings":false,"allowInput":false,"mode":"single","enableTime":false,"noCalendar":false,"format":"yyyy-MM-dd","hourIncrement":1,"minuteIncrement":1,"time_24hr":false,"minDate":null,"disableWeekends":false,"disableWeekdays":false,"maxDate":null},"hideOnChildrenHidden":false,"width":3,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":"","protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"useLocaleSettings":false,"enableDate":true,"defaultDate":"","displayInTimezone":"viewer","timezone":"","datepickerMode":"day","timePicker":{"hourStep":1,"minuteStep":1,"showMeridian":true,"readonlyInput":false,"mousewheel":true,"arrowkeys":true},"customOptions":{},"id":"eewgs68"},{"label":"Plan End Date","allowInput":false,"format":"yyyy-MM-dd","tableView":false,"enableMinDateInput":false,"datePicker":{"disableWeekends":false,"disableWeekdays":false,"showWeeks":true,"startingDay":0,"initDate":"","minMode":"day","maxMode":"year","yearRows":4,"yearColumns":5,"minDate":null,"maxDate":null},"enableMaxDateInput":false,"enableTime":false,"key":"planEndDate","type":"datetime","input":true,"widget":{"type":"calendar","displayInTimezone":"viewer","locale":"en","useLocaleSettings":false,"allowInput":false,"mode":"single","enableTime":false,"noCalendar":false,"format":"yyyy-MM-dd","hourIncrement":1,"minuteIncrement":1,"time_24hr":false,"minDate":null,"disableWeekends":false,"disableWeekdays":false,"maxDate":null},"hideOnChildrenHidden":false,"width":3,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":"","protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"useLocaleSettings":false,"enableDate":true,"defaultDate":"","displayInTimezone":"viewer","timezone":"","datepickerMode":"day","timePicker":{"hourStep":1,"minuteStep":1,"showMeridian":true,"readonlyInput":false,"mousewheel":true,"arrowkeys":true},"customOptions":{},"id":"efduxxl"}],"size":"md","width":6,"offset":0,"push":0,"pull":0}],"autoAdjust":true,"hideOnChildrenHidden":false,"customClass":"","hidden":false,"hideLabel":false,"modalEdit":false,"key":"columns1","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"columns","input":false,"tableView":false,"placeholder":"","prefix":"","suffix":"","multiple":false,"defau ltValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","tooltip":"","tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"id":"ekgtgz"}],"id":"euj9jl"},{"title":"Audit Scope/Objective/Risk","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"auditScopeOjectiveRisk","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":null,"when":null,"eq":""},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"Audit Scope/Ojective/Risk","tabindex":"","input":false,"tableView":false,"components":[{"label":"Columns","columns":[{"components":[{"label":"Section Numer","disabled":true,"tableView":true,"key":"sectionNumer","type":"textfield","input":true,"hideOnChildrenHidden":false,"width":6,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e09rwrb"},{"label":"Control Objective","autoExpand":false,"disabled":true,"tableView":true,"key":"controlObjective","type":"textarea","input":true,"hideOnChildrenHidden":false,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":"","minWords":"","maxWords":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"html","inputMask":"","spellcheck":true,"rows":3,"wysiwyg":false,"editor":"","fixedSize":true,"id":"et8vwhe"}],"width":6,"offset":0,"push":0,"pull":0,"size":"md"},{"components":[{"label":"Scope","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":fals e,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":true,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"scope","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"hideOnChildrenHidden":false,"refreshOn":"","inputType":"text","id":"eqog5q","defaultValue":""},{"label":"Risk","autoExpand":false,"disabled":true,"tableView":true,"key":"risk","type":"textarea","input":true,"hideOnChildrenHidden":false,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":"","minWords":"","maxWords":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"html","inputMask":"","spellcheck":true,"rows":3,"wysiwyg":false,"editor":"","fixedSize":true,"id":"euyztsc"}],"width":6,"offset":0,"push":0,"pull":0,"size":"md"}],"key":"columns2","type":"columns","input":false,"tableView":false,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"hidden":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"tree":false,"autoAdjust":false,"hideOnChildrenHidden":false,"id":"eoaskyj"}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":fa lse,"tree":false,"id":"ebkthtp"},{"title":"Audit Findings","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"auditFindings","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":null,"when":null,"eq":""},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"Panel","tabindex":"","input":false,"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","tableView":false,"labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"components":[{"label":"Audit Findings ","customGridKey":"auditlevelfindings","entityId":"","entityTypeId":"","frameworkId":"","pentityId":"","pentityTypeId":"","labelPosition":"top","description":"","tooltip":"","customClass":"","tabindex":"","hidden":false,"hideLabel":false,"autofocus":false,"disabled":false,"tableView":false,"modalEdit":false,"multiple":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"auditFindings1","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":null,"when":null,"eq":""},"logic":[{"name":"on Load","trigger":{"type":"javascript","javascript":"result= true;"},"actions":[{"name":"populateIds","type":"mergeComponentSchema","schemaDefinition":"schema = {frameworkId:data.frameworkId, entityId:data.entityId,entityTypeId:data.entityTypeId,pentityId:data.pentityId, pentityTypeId:data.pentityTypeId }"}]}],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"queryGrid","input":true,"placeholder":"","prefix":"","suffix":"","refreshOn":"","widget":null,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"id":"eyyya1","defaultValue":null}],"id":"eqrh8p6"}],"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":true,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"tree":true,"id":"ey8vm3"}],"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"hidden":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip": "","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"tree":false,"breadcrumb":"default","id":"e6g06vl"}],"input":false,"tableView":false,"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"id":"eguvm3"},{"title":"Leadership and Culture","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"page3","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":true,"when":"scope","eq":"Leadership and Culture"},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"Leadership and Culture","tabindex":"","input":false,"tableView":false,"components":[{"label":"Leadership and Culture","labelPosition":"top","tooltip":"","customClass":"","hidden":false,"hideLabel":true,"disabled":false,"tableView":false,"modalEdit":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"validateOn":"change","errorLabel":"","key":"leadershipandculture","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{"TemplateKey":"LeadershipandCulture"},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"container","input":true,"components":[{"label":"LeadershipandCulture","tableView":true,"key":"leadershipandculture","type":"textfield","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"eocsej9"}],"placeholder":"","prefix":"","su ffix":"","multiple":false,"defaultValue":null,"refreshOn":"","description":"","tabindex":"","autofocus":false,"widget":null,"allowCalculateOverride":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"id":"e34kitf"}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"id":"e9enkin"},{"title":"SHEQ Compliance","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"page7","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":true,"when":"auditContainer.scope","eq":"SHEQ Compliance"},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"SHEQ Compliance","tabindex":"","input":false,"tableView":false,"components":[{"label":"SHEQ Compliance","tableView":false,"key":"sheqCompliance","attributes":{"TemplateKey":"SHEQCompliance"},"type":"container","input":true,"components":[{"label":"SHEQ Compliance","tableView":true,"key":"sheqCompliance1","type":"textfield","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e828ct"}],"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":true,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"tree":true,"id":"eqs597"}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultVa lue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"id":"elhf8er"},{"title":"Risk Management","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"page7","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":true,"when":"auditContainer.scope","eq":"SHEQ Compliance"},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"SHEQ Compliance","tabindex":"","input":false,"tableView":false,"components":[{"label":"Risk Management","labelPosition":"top","tooltip":"","customClass":"","hidden":false,"hideLabel":true,"disabled":false,"tableView":false,"modalEdit":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"validateOn":"change","errorLabel":"","key":"riskManagement","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{"TemplateKey":"RiskManagement"},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"container","input":true,"components":[{"label":"Risk Management","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"riskManagement1","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ec7b8n8","defaultValue":""}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"refreshOn":"","description":"","tabindex":"","autofocus":false,"widget":null,"allowCalculateOverride":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"id":"ef8wm0u"}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks ":false,"tree":false,"id":"eod1ap"},{"title":"Health and Hygiene","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"page7","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":true,"when":"auditContainer.scope","eq":"SHEQ Compliance"},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"Risk Management","tabindex":"","input":false,"tableView":false,"components":[{"label":"Health and Hygiene","labelPosition":"top","tooltip":"","customClass":"","hidden":false,"hideLabel":true,"disabled":false,"tableView":false,"modalEdit":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"validateOn":"change","errorLabel":"","key":"healthandHygiene","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{"TemplateKey":"HealthandHygiene"},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"container","input":true,"components":[{"label":"Health and Hygiene","tableView":true,"key":"healthandHygiene1","type":"textfield","input":true,"placeholder":"","prefix":"","customClass":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":true,"hidden":false,"clearOnHide":true,"refreshOn":"","redrawOn":"","modalEdit":false,"labelPosition":"top","description":"","errorLabel":"","tooltip":"","hideLabel":false,"tabindex":"","disabled":false,"autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":{"type":"input"},"attributes":{},"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false,"minLength":"","maxLength":"","pattern":""},"conditional":{"show":null,"when":null,"eq":""},"overlay":{"style":"","left":"","top":"","width":"","height":""},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"properties":{},"allowMultipleMasks":false,"mask":false,"inputType":"text","inputFormat":"plain","inputMask":"","spellcheck":true,"id":"e1wak5w"}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"refreshOn":"","description":"","tabindex":"","autofocus":false,"widget":null,"allowCalculateOverride":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"id":"e4c5elt"}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"id":"e4y1qg"},{"title":"Fire Defense","theme":"info","breadcrumb":"default","breadcrumbClickable":true,"buttonSettings":{"previous":true,"cancel":true,"next":true},"tooltip":"","customClass":"","collapsible":false,"hidden":false,"hideLabel":false,"disabled":false,"modalEdit":false,"key":"page7","tags":[],"properties":{},"customConditional":"","conditional":{"json":"","show":true,"when":"auditContainer.sco pe","eq":"SHEQ Compliance"},"nextPage":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"panel","label":"Health and Hygiene","tabindex":"","input":false,"tableView":false,"components":[{"label":"Fire Defense","labelPosition":"top","tooltip":"","customClass":"","hidden":false,"hideLabel":true,"disabled":false,"tableView":false,"modalEdit":false,"persistent":true,"protected":false,"dbIndex":false,"encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"validate":{"required":false,"customMessage":"","custom":"","customPrivate":false,"json":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"validateOn":"change","errorLabel":"","key":"fireDefense","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{"TemplateKey":"FireDefense"},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"container","input":true,"components":[{"label":"Fire Defense","labelPosition":"top","placeholder":"","description":"","tooltip":"","prefix":"","suffix":"","widget":{"type":"input"},"inputMask":"","allowMultipleMasks":false,"customClass":"","tabindex":"","autocomplete":"","hidden":false,"hideLabel":false,"showWordCount":false,"showCharCount":false,"mask":false,"autofocus":false,"spellcheck":true,"disabled":false,"tableView":true,"modalEdit":false,"multiple":false,"persistent":true,"inputFormat":"plain","protected":false,"dbIndex":false,"case":"","encrypted":false,"redrawOn":"","clearOnHide":true,"customDefaultValue":"","calculateValue":"","calculateServer":false,"allowCalculateOverride":false,"validateOn":"change","validate":{"required":false,"pattern":"","customMessage":"","custom":"","customPrivate":false,"json":"","minLength":"","maxLength":"","strictDateValidation":false,"multiple":false,"unique":false},"unique":false,"errorLabel":"","key":"fireDefense1","tags":[],"properties":{},"conditional":{"show":null,"when":null,"eq":"","json":""},"customConditional":"","logic":[],"attributes":{},"overlay":{"style":"","page":"","left":"","top":"","width":"","height":""},"type":"textfield","input":true,"refreshOn":"","inputType":"text","id":"ec8x8vm","defaultValue":""}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"refreshOn":"","description":"","tabindex":"","autofocus":false,"widget":null,"allowCalculateOverride":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":true,"id":"emx7fws"}],"placeholder":"","prefix":"","suffix":"","multiple":false,"defaultValue":null,"protected":false,"unique":false,"persistent":false,"clearOnHide":false,"refreshOn":"","redrawOn":"","labelPosition":"top","description":"","errorLabel":"","autofocus":false,"dbIndex":false,"customDefaultValue":"","calculateValue":"","calculateServer":false,"widget":null,"validateOn":"change","validate":{"required":false,"custom":"","customPrivate":false,"strictDateValidation":false,"multiple":false,"unique":false},"allowCalculateOverride":false,"encrypted":false,"showCharCount":false,"showWordCount":false,"allowMultipleMasks":false,"tree":false,"id":"elkfsnbt"}],"display":"wizard","isBuilder":true}' 

--rollback

SELECT * FROM USERLOGIN WHERE Active=1