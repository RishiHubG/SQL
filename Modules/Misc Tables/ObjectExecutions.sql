 
DROP TABLE  IF EXISTS dbo.ObjectLog

CREATE TABLE dbo.ObjectLog
	(
	ID INT IDENTITY(1,1),	
	ObjectNameWithParam VARCHAR(MAX),
	DateExecuted DATETIME2(3)
	)	