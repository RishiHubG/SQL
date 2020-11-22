--TEMPLATE TABLES
USE JUNK
GO

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
	Name VARCHAR(500) NOT NULL,
	FrameworkFile VARCHAR(MAX) NOT NULL,
	[Namespace]	VARCHAR(100),	
	CONSTRAINT PK_Frameworks_ID PRIMARY KEY(FrameworkID)
	)

	
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
	CONSTRAINT PK_FrameworkSteps_StepID PRIMARY KEY(StepID)
	)

	--ALTER TABLE dbo.FrameworkSteps ADD CONSTRAINT FK_FrameworkSteps_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkStepItems
CREATE TABLE dbo.FrameworkStepItems
(
StepItemID INT IDENTITY(1,1),
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
OrderBy INT,
CONSTRAINT PK_Framework_Metafield_StepItemID PRIMARY KEY(StepItemID)
)

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
AttributeKey NVARCHAR(100) NOT NULL,	
AttributeValue NVARCHAR(100) NOT NULL,
OrderBy INT,
CONSTRAINT PK_FrameworkAttributes_AttributeID PRIMARY KEY(AttributeID)
)

--ALTER TABLE dbo.FrameworkAttributes ADD CONSTRAINT FK_FrameworkAttributess_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems(StepItemID)
--ALTER TABLE dbo.FrameworkAttributes ADD CONSTRAINT FK_FrameworkAttributes_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.FrameworkLookups
CREATE TABLE dbo.FrameworkLookups
(
LookupID INT IDENTITY(1,1),
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
FrameworkID INT,
StepItemID INT NOT NULL,
LookupName NVARCHAR(100) NOT NULL,
LookupValue NVARCHAR(100) NOT NULL,
LookupType NVARCHAR(100) NULL,
OrderBy INT
)

--ALTER TABLE dbo.FrameworkLookups ADD CONSTRAINT FK_FrameworkLookups_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.FrameworkStepItems(StepItemID)
--ALTER TABLE dbo.FrameworkLookups ADD CONSTRAINT FK_FrameworkLookups_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)