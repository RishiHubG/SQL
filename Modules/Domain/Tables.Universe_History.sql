USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Universe_history,UniverseProperties_history,UniverseFrameworkMapping_history,UniverseFrameworkXref_history

DROP TABLE  IF EXISTS dbo.Universe_history
CREATE TABLE dbo.Universe_history
	(
	HistoryID INT IDENTITY(1,1),	
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	PeriodIdentifierID INT NOT NULL,
	OperationType VARCHAR(50),
	UserActionID INT,
	UniverseID INT,
	Name VARCHAR(500) NOT NULL,
	AccessControlID	INT,
	ParentID INT,
	Height INT,
	Depth INT,
	WorkFlowACID INT,
	PropagatedUniverseID INT,
	PropagatedWFID INT,
	PropagatedAccessControlID INT,
	PropagatedWFAccessControlID INT,
	CONSTRAINT PK_Universe_history_HistoryID PRIMARY KEY(HistoryID)
	)	
	
	 
GO

	
--DROP TABLE  IF EXISTS dbo.UniverseProperties_history
--CREATE TABLE dbo.UniverseProperties_history
--	(
--HistoryID INT IDENTITY(1,1),
--	StepID INT IDENTITY(1,1),
--	UserCreated INT NOT NULL,
--	DateCreated DATETIME2(0) NOT NULL,
--	UserModified INT,
--	DateModified DATETIME2(0),
--	VersionNum INT NOT NULL,
--	FrameworkID INT NOT NULL,
--	StepName NVARCHAR(500) NOT NULL,
--	CONSTRAINT PK_FrameworkSteps_StepID PRIMARY KEY(HistoryID)
--	)	
	
	 
GO
 
DROP TABLE  IF EXISTS dbo.UniverseFrameworkMapping_history
CREATE TABLE dbo.UniverseFrameworkMapping_history
(
HistoryID INT IDENTITY(1,1),
FrameworkID INT NOT NULL,
UniverseID INT NOT NULL,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
PeriodIdentifierID INT NOT NULL,
OperationType VARCHAR(50),
UserActionID INT,
IsActive BIT,
PropertyID INT,
PropertyName NVARCHAR(1000),
CONSTRAINT PK_UniverseFrameworkMapping_history_HistoryID PRIMARY KEY(HistoryID)
)	
	
	 
GO


DROP TABLE  IF EXISTS dbo.UniverseFrameworkXref_history
CREATE TABLE dbo.UniverseFrameworkXref_history
(
HistoryID INT IDENTITY(1,1),
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
PeriodIdentifierID INT NOT NULL,
OperationType VARCHAR(50),
UserActionID INT,
UniverseFrameworkXrefID INT,
UniverseFrameworkMappingID INT,
ExtendedProperties INT,
CONSTRAINT PK_UniverseFrameworkXref_history_HistoryID PRIMARY KEY(HistoryID)
)	
	
	 