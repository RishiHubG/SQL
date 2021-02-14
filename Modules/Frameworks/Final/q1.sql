USE JUNK
GO	
--COMMIT
----ROLLBACK
--BEGIN TRAN;
 EXEC dbo.SaveFrameworkJSONData 
 @FrameworkID=1,
 @UserLoginID=100,
 @inputJSON =
'{
  "controls.controlEnvironmentAdequacy": "",
  "controls.controlEnvironmentEffectiveness": "",
  "controls.controlEnvironmentRationale": "",
  "general.description": "",
  "general.name": "gfs",
  "general.reference": "",
  "inherentRatings1.ResidualRatingOverall": "",
  "inherentRatings1.RfinancialImpactRationale": "",
  "inherentRatings1.RlikelihoodRationale": "",
  "inherentRatings1.RlocalCurrency": "",
  "inherentRatings1.RnonFinancialImpactBusiness": "",
  "inherentRatings1.RnonFinancialImpactReputational": "",
  "inherentRatings1.rnonFinancialImpactLicense": "",
  "inherentRatings1.rnonFinancialImpactRationale": "",
  "inherentRatings.financialImpactRationale": "",
  "inherentRatings.inherentRatingOverall": "",
  "inherentRatings.likelihoodImpact": 1,
  "inherentRatings.likelihoodRationale": "",
  "inherentRatings.localCurrency": "",
  "inherentRatings.nonFinancialImpactBusiness": "",
  "inherentRatings.nonFinancialImpactLicense": "",
  "inherentRatings.nonFinancialImpactRationale": "",
  "inherentRatings.nonFinancialImpactReputational": "",
  
  "inherentRatings.whichPartiesAreEffected.businessContinuity": {
    "test": true
  },
  "inherentRatings.whichPartiesAreEffected.licenseToOperate": {
    "": false
  },
  "inherentRatings.whichPartiesAreEffected.reputational": {
    "investors1": false,
    "investors2": true,
    "investors": false,
    "society": false,
    "shareholders": true,
    "employees": false,
    "suppliers": true
  }, 
  "riskContact.riskCoordinatorFreeText": "",
  "riskContact.riskOwnerFreeText": "",
  "riskDetail.causalCategory1": "",
  "riskDetail.causalCategory3": "",
  "riskDetail.causalDescription1": "",
  "riskDetail.causalDescription2": "",
  "riskDetail.causalDescription3": "",
  "riskDetail.causalSubCategory": "",
  "riskDetail.causalSubCategory2": "",
  "riskDetail.causalSubCategory3": "",
  "riskDetail.regulatoryComplianceRequirements": 0,
  "riskDetail.riskCategory1": "",
  "riskDetail.riskCategory2": "",
  "riskDetail.riskCategory3": "",
  "riskDetail.riskProgressForReporting": ""
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

		SELECT * FROM ObjectLog
		
*/
/*
IF "type": "selectboxes", THEN CREATED 4 ADDITIONAL COLUMNS IN _DATA:
reputational_Name
reputational_Value
reputational_Description
reputational_Color
*/