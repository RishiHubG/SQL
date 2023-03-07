--TEMPLATE TABLES

DROP TABLE  IF EXISTS dbo.FrameworkLookups,FrameworkAttributes,FrameworkStepItems,FrameworkSteps,Frameworks

--Frameworks: COMMON TABLE ACROSS ALL FRAMEWORKS
DROP TABLE  IF EXISTS dbo.Frameworks
CREATE TABLE dbo.Frameworks
	(
	FrameworkID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	FullSchemaJSON VARCHAR(MAX),
	Name VARCHAR(500) NOT NULL,
	FrameworkFile VARCHAR(MAX) NOT NULL,
	[Namespace]	VARCHAR(100),	
	CONSTRAINT PK_Frameworks_ID PRIMARY KEY(FrameworkID)
	)
	
	ALTER TABLE [dbo].Frameworks ADD CONSTRAINT DF_Frameworks_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

	
DROP TABLE  IF EXISTS dbo.FrameworkSteps
CREATE TABLE dbo.FrameworkSteps
	(
	StepID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	FrameworkID INT NOT NULL,
	StepName NVARCHAR(500) NOT NULL,
	CONSTRAINT PK_FrameworkSteps_StepID PRIMARY KEY(StepID),
	CONSTRAINT UQ_FrameworkSteps_StepName UNIQUE(StepName),
	)
	
	
	ALTER TABLE [dbo].FrameworkSteps ADD CONSTRAINT DF_FrameworkSteps_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

	--ALTER TABLE dbo.FrameworkSteps ADD CONSTRAINT FK_FrameworkSteps_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkStepItems
CREATE TABLE dbo.FrameworkStepItems
(
--StepItemID INT IDENTITY(1,1),
StepItemID INT,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
FrameworkID INT,
StepID INT NOT NULL,
StepItemName NVARCHAR(100) NOT NULL,
StepItemType NVARCHAR(100) NOT NULL,
StepItemKey NVARCHAR(100) NOT NULL,
OrderBy INT
--,CONSTRAINT PK_FrameworkStepItems_StepItemID PRIMARY KEY(StepItemID)
)

	
	ALTER TABLE [dbo].FrameworkStepItems ADD CONSTRAINT DF_FrameworkStepItems_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
	ALTER TABLE [dbo].FrameworkStepItems ADD CONSTRAINT UQ_FrameworkStepItems_StepItemKey UNIQUE(StepItemKey)
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkAttributes
CREATE TABLE dbo.FrameworkAttributes
(
AttributeID INT IDENTITY(1,1),
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
FrameworkID INT,
StepItemID INT NOT NULL,
AttributeKey NVARCHAR(1000) NOT NULL,	
AttributeValue NVARCHAR(MAX) NOT NULL,
OrderBy INT,
CONSTRAINT PK_FrameworkAttributes_AttributeID PRIMARY KEY(AttributeID)
)

	
	ALTER TABLE [dbo].FrameworkAttributes ADD CONSTRAINT DF_FrameworkAttributes_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

--ALTER TABLE dbo.FrameworkAttributes ADD CONSTRAINT FK_FrameworkAttributess_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems(StepItemID)
--ALTER TABLE dbo.FrameworkAttributes ADD CONSTRAINT FK_FrameworkAttributes_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkLookups
CREATE TABLE dbo.FrameworkLookups
(
--LookupID INT IDENTITY(1,1),
LookupID INT NOT NULL,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
FrameworkID INT,
StepItemID INT NOT NULL,
LookupName NVARCHAR(845) NOT NULL,
LookupValue NVARCHAR(MAX) NOT NULL,
LookupType NVARCHAR(100) NULL,
Color  NVARCHAR(100) NULL,
MinValue NVARCHAR(100) NULL,
MaxValue NVARCHAR(100) NULL,
OrderBy INT,
StepItemKey NVARCHAR(100) NOT NULL
)

	
	ALTER TABLE [dbo].FrameworkLookups ADD CONSTRAINT DF_FrameworkLookups_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
	--ALTER TABLE [dbo].FrameworkLookups ADD CONSTRAINT UQ_FrameworkLookups_LookupName UNIQUE(FrameworkID,StepItemID,LookupName)
GO

--ALTER TABLE dbo.FrameworkLookups ADD CONSTRAINT FK_FrameworkLookups_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems(StepItemID)
--ALTER TABLE dbo.FrameworkLookups ADD CONSTRAINT FK_FrameworkLookups_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)


DROP TABLE  IF EXISTS dbo.FrameworksEntityGridMapping
CREATE TABLE dbo.FrameworksEntityGridMapping
	(
	ID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NULL,
	FrameworkID INT,
	StepItemID INT,
	Label NVARCHAR(MAX),
	APIKey  NVARCHAR(MAX)
	)
	ALTER TABLE [dbo].FrameworksEntityGridMapping ADD CONSTRAINT DF_FrameworksEntityGridMapping_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

DROP TABLE  IF EXISTS dbo.FrameworkAttributesMapping
CREATE TABLE dbo.FrameworkAttributesMapping
	(
	ID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NULL,
	FrameworkID INT,	
	APIKey NVARCHAR(MAX),
	AttributeType NVARCHAR(MAX),
	AttributeName NVARCHAR(MAX)
	)
	ALTER TABLE [dbo].FrameworkAttributesMapping ADD CONSTRAINT DF_FrameworkAttributesMapping_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO


DROP TABLE IF EXISTS FrameworkMultiSelectStepItemValues
CREATE TABLE dbo.FrameworkMultiSelectStepItemValues
(
ID INT IDENTITY(1,1),
FrameworkID INT NOT NULL,
Entityid INT NOT NULL, 
EntityTypeID INT,
StepItemID  INT NOT NULL,
Name NVARCHAR(500) NOT NULL,
IsSelected BIT NOT NULL
)

GO

DROP TABLE IF EXISTS Frameworks_ExtendedValues
CREATE TABLE dbo.Frameworks_ExtendedValues 
	(FrameworkID INT, EntityID INT, RegisterID INT,showAdminTab NVARCHAR(500),loggedInUserRole NVARCHAR(500),loggedInUserGroup NVARCHAR(500),
	isModuleAdmin NVARCHAR(500),isSystemAdmin NVARCHAR(500),isModuleAdminGroup NVARCHAR(500), CurrentStateowner NVARCHAR(500))

	ALTER TABLE dbo.Frameworks_ExtendedValues ADD CONSTRAINT UQ_Frameworks_ExtendedValues UNIQUE (FrameworkID, EntityID,RegisterID);