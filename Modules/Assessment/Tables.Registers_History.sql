USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Registers_history,RegisterProperties_history,RegistersPropertiesXref_history,RegisterPropertyXerf_Data_history

DROP TABLE  IF EXISTS dbo.Registers_history
CREATE TABLE dbo.Registers_history
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
	RegisterID INT,
	Name VARCHAR(500) NOT NULL,
	FrameworkID	INT,
	UniverseID INT,
	AccessControlID	INT,
	WorkFlowACID INT,	
	PropagatedAccessControlID INT,
	PropagatedWFAccessControlID INT,
	HasExtendedProperties BIT,
	CONSTRAINT PK_Registers_history_HistoryID PRIMARY KEY(HistoryID)
	)
		 
GO
	
DROP TABLE  IF EXISTS dbo.RegisterProperties_history
CREATE TABLE dbo.RegisterProperties_history
	(
	HistoryID INT IDENTITY(1,1),
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	PeriodIdentifierID INT NOT NULL,
	OperationType VARCHAR(50),
	UserActionID INT,
	PropertyID INT NOT NULL,
	RegisterID INT NOT NULL,	
	ColumnName VARCHAR(100) NOT NULL,
	CONSTRAINT PK_RegisterProperties_history_HistoryID PRIMARY KEY(HistoryID)
	)

 
GO

DROP TABLE  IF EXISTS dbo.RegistersPropertiesXref_history
CREATE TABLE dbo.RegistersPropertiesXref_history
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
RegisterID INT NOT NULL,
PropertyID INT NOT NULL,
IsRequired BIT,
IsActive BIT, 
PropertyName NVARCHAR(1000),
CONSTRAINT PK_RegistersPropertiesXref_history_HistoryID PRIMARY KEY(HistoryID)
)
 
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

--COLUMNS WILL BE ADDED TO THIS TABLE; NO REMOVAL OF COLUMNS
DROP TABLE  IF EXISTS dbo.RegisterPropertyXerf_Data_history
CREATE TABLE dbo.RegisterPropertyXerf_Data_history
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
RegisterID INT
)
 		 
GO