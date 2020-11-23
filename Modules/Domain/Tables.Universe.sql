USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Universe,UniverseProperties,UniverseFrameworkMapping,UniverseFrameworkXref

DROP TABLE  IF EXISTS dbo.Universe
CREATE TABLE dbo.Universe
	(
	UniverseID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
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
	CONSTRAINT PK_Universe_UniverseID PRIMARY KEY(UniverseID)
	)	
	
	ALTER TABLE [dbo].Universe ADD CONSTRAINT DF_Universe_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO


	
--DROP TABLE  IF EXISTS dbo.UniverseProperties
--CREATE TABLE dbo.UniverseProperties
--	(
--	StepID INT IDENTITY(1,1),
--	UserCreated INT NOT NULL,
--	DateCreated DATETIME2(0) NOT NULL,
--	UserModified INT,
--	DateModified DATETIME2(0),
--	VersionNum INT NOT NULL,
--	FrameworkID INT NOT NULL,
--	StepName NVARCHAR(500) NOT NULL,
--	CONSTRAINT PK_FrameworkSteps_StepID PRIMARY KEY(StepID)
--	)	
	
	--ALTER TABLE [dbo].Frameworks ADD CONSTRAINT DF_Frameworks_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
 
DROP TABLE  IF EXISTS dbo.UniverseFrameworkMapping
CREATE TABLE dbo.UniverseFrameworkMapping
(
FrameworkID INT NOT NULL,
UniverseID INT NOT NULL,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
IsActive BIT,
PropertyID INT,
PropertyName NVARCHAR(1000),
CONSTRAINT PK_UniverseFrameworkMapping_FrameworkID_UniverseID PRIMARY KEY(FrameworkID,UniverseID)
)	
	
	ALTER TABLE [dbo].UniverseFrameworkMapping ADD CONSTRAINT DF_UniverseFrameworkMapping_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.UniverseFrameworkXref
CREATE TABLE dbo.UniverseFrameworkXref
(
UniverseFrameworkXrefID INT IDENTITY(1,1),
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
UniverseFrameworkMappingID INT,
ExtendedProperties INT,
CONSTRAINT PK_UniverseFrameworkXref_UniverseFrameworkXrefID PRIMARY KEY(UniverseFrameworkXrefID)
)	
	
	ALTER TABLE [dbo].UniverseFrameworkXref ADD CONSTRAINT DF_UniverseFrameworkXref_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
 