USE JUNK
GO	
--COMMIT
----ROLLBACK
--BEGIN TRAN;
 EXEC dbo.SaveFrameworkJSONData 
 @EntityID=1,
 @UserLoginID=100,
 @inputJSON =
'{
  "general.name": "",
  "general.reference": "",
  "general.description": "",
  "riskDetail.riskProgressForReporting": "",
  "riskDetail.regulatoryComplianceRequirements": 0,
  "riskDetail.riskCategory1": "",
  "riskDetail.riskCategory2": "",
  "riskDetail.riskCategory3": "",
  "riskDetail.causalCategory1": "",
  "riskDetail.causalSubCategory": "",
  "riskDetail.causalDescription1": "",
  "riskDetail.causalSubCategory2": "",
  "riskDetail.causalDescription2": "",
  "riskDetail.causalCategory3": "",
  "riskDetail.causalSubCategory3": "",
  "riskDetail.causalDescription3": "",
  "riskContact.riskOwnerFreeText": "",
  "riskContact.riskCoordinatorFreeText": "",
  "inherentRatings.localCurrency": "",
  "inherentRatings.nonFinancialImpactReputational": "",
  "inherentRatings.nonFinancialImpactBusiness": "",
  "inherentRatings.nonFinancialImpactLicense": "",
  "inherentRatings.likelihoodRationale": "",
  "inherentRatings.financialImpactRationale": "",
  "inherentRatings.nonFinancialImpactRationale": "",
  "inherentRatings.likelihoodImpact": 1,
  "inherentRatings.inherentRatingOverall": "",
  "inherentRatings.whichPartiesAreEffected.reputational": {
    "1": false,
    "": false,
    "investors": false,
    "society": false,
    "shareholders": false,
    "employees": false,
    "suppliers": false
  },
  "inherentRatings.whichPartiesAreEffected.licenseToOperate": {
    "": false
  },
  "inherentRatings.whichPartiesAreEffected.businessContinuity": {
    "": false
  },
  "controls.controlEnvironmentAdequacy": "",
  "controls.controlEnvironmentEffectiveness": "",
  "controls.controlEnvironmentRationale": "",
  "inherentRatings1.rlocalCurrency": "",
  "inherentRatings1.rnonFinancialImpactReputational": "",
  "inherentRatings1.rnonFinancialImpactBusiness": "",
  "inherentRatings1.rnonFinancialImpactLicense": "",
  "inherentRatings1.rlikelihoodRationale": "",
  "inherentRatings1.rfinancialImpactRationale": "",
  "inherentRatings1.rnonFinancialImpactRationale": "",
  "inherentRatings1.rinherentRatingOverall": ""
}'
 
/*
		SELECT * from dbo.Frameworks
		SELECT * from dbo.Frameworks_history
		SELECT * from dbo.FrameworkSteps_history
		SELECT * from dbo.FrameworkStepItems_history
		SELECT * from dbo.FrameworkAttributes_history
		SELECT * from dbo.FrameworkLookups_history

		DROP TABLE TAB_DATA, TAB_DATA_HISTORY
		SELECT * FROM TAB_DATA
		SELECT * FROM TAB_DATA_HISTORY
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