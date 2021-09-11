--TEMPLATE TABLES FOR HISTORY

DROP TABLE  IF EXISTS dbo.FrameworkLookups_history,FrameworkAttributes_history,Framework_history,FrameworkSteps_history,Frameworks_history


DROP TABLE  IF EXISTS dbo.Frameworks_history
CREATE TABLE dbo.Frameworks_history
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
	FrameworkID INT,
	FullSchemaJSON VARCHAR(MAX),
	[Name] VARCHAR(500) NOT NULL,
	FrameworkFile VARCHAR(MAX) NOT NULL,
	[Namespace]	VARCHAR(100),
	CONSTRAINT PK_Frameworks_history_HistoryID PRIMARY KEY(HistoryID)
	)

	ALTER TABLE [dbo].Frameworks_history ADD CONSTRAINT DF_Frameworks_history_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
	

	
DROP TABLE  IF EXISTS dbo.FrameworkSteps_history
CREATE TABLE dbo.FrameworkSteps_history
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
	StepID INT,
	FrameworkID INT,
	StepName NVARCHAR(500) NOT NULL,	
	CONSTRAINT PK_FrameworkSteps_history_HistoryID PRIMARY KEY(HistoryID)
	)
	ALTER TABLE [dbo].FrameworkSteps_history ADD CONSTRAINT DF_FrameworkSteps_history_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

DROP TABLE  IF EXISTS dbo.FrameworkStepItems_history
CREATE TABLE dbo.FrameworkStepItems_history
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
FrameworkID INT,
StepItemID INT ,
StepID INT NOT NULL,
StepItemName NVARCHAR(100) NOT NULL,
StepItemType NVARCHAR(100) NOT NULL,
StepItemKey NVARCHAR(100) NOT NULL,
OrderBy INT,
CONSTRAINT PK_FrameworkStepItems_history_HistoryID PRIMARY KEY(HistoryID)
)

	ALTER TABLE [dbo].FrameworkStepItems_history ADD CONSTRAINT DF_FrameworkStepItems_history_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
--ALTER TABLE dbo.FrameworkStepItems_history ADD CONSTRAINT FK_FrameworkStepItems_history_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps_history(StepID)


DROP TABLE  IF EXISTS dbo.FrameworkAttributes_history
CREATE TABLE dbo.FrameworkAttributes_history
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
FrameworkID INT,
AttributeID INT,
StepItemID INT NOT NULL,
AttributeKey NVARCHAR(1000) NOT NULL,	
AttributeValue NVARCHAR(MAX) NOT NULL,
OrderBy INT, 
CONSTRAINT PK_FrameworkAttributes_historys_history_HistoryID PRIMARY KEY(HistoryID)
)

	ALTER TABLE [dbo].FrameworkAttributes_history ADD CONSTRAINT DF_FrameworkAttributes_history_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
--ALTER TABLE dbo.FrameworkAttributes_history ADD CONSTRAINT FK_FrameworkAttributes_history_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems_history(StepItemID)

DROP TABLE  IF EXISTS dbo.FrameworkLookups_history
CREATE TABLE dbo.FrameworkLookups_history
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
FrameworkID INT,
LookupID INT,
StepItemID INT NOT NULL,
LookupName NVARCHAR(100) NOT NULL,
LookupValue NVARCHAR(100) NOT NULL,
LookupType NVARCHAR(100) NULL,
OrderBy INT
)

	ALTER TABLE [dbo].FrameworkLookups_history ADD CONSTRAINT DF_FrameworkLookups_history_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
--ALTER TABLE dbo.FrameworkLookups_history ADD CONSTRAINT FK_FrameworkLookups_history_history_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems_history(StepItemID)



DROP TABLE  IF EXISTS dbo.FrameworksEntityGridMapping_history
CREATE TABLE dbo.FrameworksEntityGridMapping_history
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
	ID INT,
	FrameworkID INT,
	StepItemID INT,
	Label NVARCHAR(MAX),
	APIKey  NVARCHAR(MAX)
	)
 
GO

DROP TABLE  IF EXISTS dbo.FrameworkAttributesMapping_history
CREATE TABLE dbo.FrameworkAttributesMapping_history
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
	ID INT,
	FrameworkID INT,	
	APIKey NVARCHAR(MAX),
	AttributeType NVARCHAR(MAX),
	AttributeName NVARCHAR(MAX)
	)
 
GO