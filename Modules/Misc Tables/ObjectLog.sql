 
DROP TABLE  IF EXISTS dbo.ObjectLog

CREATE TABLE dbo.ObjectLog
	(
	ID INT IDENTITY(1,1),	
	ObjectNameWithParam VARCHAR(MAX),
	UserCreated INT,
	DateExecuted DATETIME2(3)
	)	