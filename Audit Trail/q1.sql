USE DEVDB
GO

	SELECT *
	FROM dbo.Frameworks
	WHERE FrameworkID = @EntityID

	SELECT * FROM NewAuditFramework_data WHERE ID=290
	SELECT * FROM NewAuditFramework_data_history ORDER BY DateModified DESC

	SELECT * FROM Frameworks WHERE frameworkid IN (6)

	SELECT * FROM NewAuditFramework_data WHERE ID=290
	SELECT DISTINCT * FROM NewAuditFramework_data_history  WHERE ID=290 and PeriodIdentifier=1 ORDER BY DateModified DESC
