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