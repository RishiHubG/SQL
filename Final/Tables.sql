--TEMPLATE TABLES
USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Framework_Lookups,Framework_Attributes,Framework_StepItems,Framework_Steps,Frameworks_List

--Frameworks_List: COMMON TABLE ACROSS ALL FRAMEWORKS
DROP TABLE  IF EXISTS dbo.Frameworks_List
CREATE TABLE dbo.Frameworks_List
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
	CONSTRAINT PK_Frameworks_List_ID PRIMARY KEY(FrameworkID)
	)

	
DROP TABLE  IF EXISTS dbo.Framework_Steps
CREATE TABLE dbo.Framework_Steps
	(
	StepID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	FrameworkID INT NOT NULL,
	StepName NVARCHAR(500) NOT NULL,
	CONSTRAINT PK_Framework_Steps_StepID PRIMARY KEY(StepID)
	)

	--ALTER TABLE dbo.Framework_Steps ADD CONSTRAINT FK_Framework_Steps_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks_List(FrameworkID)

DROP TABLE  IF EXISTS dbo.Framework_StepItems
CREATE TABLE dbo.Framework_StepItems
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

--ALTER TABLE dbo.Framework_StepItems ADD CONSTRAINT FK_Framework_StepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.Framework_Steps(StepID)
--ALTER TABLE dbo.Framework_StepItems ADD CONSTRAINT FK_Framework_StepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks_List(FrameworkID)

DROP TABLE  IF EXISTS dbo.Framework_Attributes
CREATE TABLE dbo.Framework_Attributes
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
CONSTRAINT PK_Framework_Attributes_AttributeID PRIMARY KEY(AttributeID)
)

--ALTER TABLE dbo.Framework_Attributes ADD CONSTRAINT FK_Framework_Attributess_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.Framework_StepItems(StepItemID)
--ALTER TABLE dbo.Framework_Attributes ADD CONSTRAINT FK_Framework_Attributes_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks_List(FrameworkID)

DROP TABLE  IF EXISTS dbo.Framework_Lookups
CREATE TABLE dbo.Framework_Lookups
(
ID INT IDENTITY(1,1),
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

--ALTER TABLE dbo.Framework_Lookups ADD CONSTRAINT FK_Framework_Lookups_StepItemID FOREIGN KEY(StepItemID) REFERENCES dbo.Framework_StepItems(StepItemID)
--ALTER TABLE dbo.Framework_Lookups ADD CONSTRAINT FK_Framework_Lookups_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks_List(FrameworkID)