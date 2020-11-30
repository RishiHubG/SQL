USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Universe_history,UniverseProperties_history,UniversePropertiesXref_history,UniversePropertyXerf_Data_history

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
	FrameworkID	INT,
	--UniverseID INT,
	AccessControlID	INT,
	WorkFlowACID INT,	
	PropagatedAccessControlID INT,
	PropagatedWFAccessControlID INT,
	HasExtendedProperties BIT,
	CONSTRAINT PK_Universe_history_HistoryID PRIMARY KEY(HistoryID)
	)
		 
GO
	
DROP TABLE  IF EXISTS dbo.UniverseProperties_history
CREATE TABLE dbo.UniverseProperties_history
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
	UniversePropertyID INT NOT NULL,
	UniverseID INT NOT NULL,	
	PropertyName VARCHAR(100) NOT NULL,
	JSONType VARCHAR(50) NOT NULL,
	CONSTRAINT PK_UniverseProperties_history_HistoryID PRIMARY KEY(HistoryID)
	)

 
GO

DROP TABLE  IF EXISTS dbo.UniversePropertiesXref_history
CREATE TABLE dbo.UniversePropertiesXref_history
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
UniversePropertiesXrefID INT NOT NULL,
UniverseID INT NOT NULL,
UniversePropertyID INT NOT NULL,
PropertyName NVARCHAR(1000),
IsRequired BIT,
IsActive BIT, 
CONSTRAINT PK_UniversePropertiesXref_history_HistoryID PRIMARY KEY(HistoryID)
)
 
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

--COLUMNS WILL BE ADDED TO THIS TABLE; NO REMOVAL OF COLUMNS
DROP TABLE  IF EXISTS dbo.UniversePropertyXerf_Data_history
CREATE TABLE dbo.UniversePropertyXerf_Data_history
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
UniversePropertyXerf_DataID INT,
UniverseID INT
)
 		 
GO