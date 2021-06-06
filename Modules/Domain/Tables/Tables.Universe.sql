

DROP TABLE  IF EXISTS UniversePropertiesXref,UniversePropertyXerf_Data,UniverseProperties,dbo.Universe

DROP TABLE  IF EXISTS dbo.Universe
CREATE TABLE dbo.Universe
	(	
	UniverseID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NULL,
	--FullSchemaJSON VARCHAR(MAX),
	Name VARCHAR(500) NOT NULL,	
	Description VARCHAR(MAX) NULL,
	FrameworkID	INT,
	ParentID INT NULL,
	Height INT NULL,
	Depth INT NULL,
	--UniverseID INT,
	AccessControlID	INT,
	ParentAccessControlID INT,
	WorkFlowACID INT,
	IsInherited BIT,
	PropagatedAccessControlID INT,
	PropagatedWFAccessControlID INT,
	HasExtendedProperties BIT,
	CONSTRAINT PK_Universe_UniverseID PRIMARY KEY(UniverseID),
	CONSTRAINT UQ_Universe_Name UNIQUE(Name,ParentID),
	)
		ALTER TABLE [dbo].Universe ADD CONSTRAINT DF_Universe_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 		
GO
	
DROP TABLE  IF EXISTS dbo.UniverseProperties
CREATE TABLE dbo.UniverseProperties
	(
	UniversePropertyID INT IDENTITY(1,1) NOT NULL,
	UniverseID INT NOT NULL,	
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	PropertyName VARCHAR(100) NOT NULL,
	JSONType VARCHAR(50) NOT NULL,
	CONSTRAINT PK_UniverseProperties_UniversePropertyID PRIMARY KEY(UniversePropertyID)
	)

	ALTER TABLE dbo.UniverseProperties ADD CONSTRAINT FK_UniverseProperties_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 			
	ALTER TABLE [dbo].UniverseProperties ADD CONSTRAINT FK_UniverseProperties_UniverseID FOREIGN KEY(UniverseID) REFERENCES dbo.EntityAdminForm(EntityTypeID)
GO
	
GO

DROP TABLE  IF EXISTS dbo.UniversePropertiesXref
CREATE TABLE dbo.UniversePropertiesXref
(
UniversePropertiesXrefID INT IDENTITY(1,1),
UniversePropertyID INT NOT NULL,
UniverseID INT NOT NULL,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
PropertyName NVARCHAR(1000),
IsRequired BIT,
IsActive BIT, 
CONSTRAINT PK_UniversePropertiesXref_UniverseID_UniversePropertyID PRIMARY KEY(UniversePropertiesXrefID,UniversePropertyID,UniverseID)
)
 		ALTER TABLE [dbo].UniversePropertiesXref ADD CONSTRAINT DF_UniversePropertiesXref_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
		ALTER TABLE [dbo].Universe ADD CONSTRAINT FK_UniversePropertiesXref_UniverseID FOREIGN KEY(UniverseID) REFERENCES dbo.EntityAdminForm(EntityTypeID)
		ALTER TABLE [dbo].UniversePropertiesXref ADD CONSTRAINT FK_UniversePropertiesXref_UniversePropertyID FOREIGN KEY(UniversePropertyID) REFERENCES dbo.UniverseProperties(UniversePropertyID)
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

--COLUMNS WILL BE ADDED TO THIS TABLE; NO REMOVAL OF COLUMNS
DROP TABLE  IF EXISTS dbo.UniversePropertyXerf_Data
CREATE TABLE dbo.UniversePropertyXerf_Data
(
UniversePropertyXerf_DataID INT IDENTITY(1,1),
UniverseID INT ,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
CONSTRAINT PK_UniversePropertyXerf_Data_UniversePropertyXerf_DataID PRIMARY KEY(UniversePropertyXerf_DataID)
)
 		ALTER TABLE [dbo].UniversePropertyXerf_Data ADD CONSTRAINT DF_UniversePropertyXerf_Data_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
		ALTER TABLE [dbo].UniversePropertyXerf_Data ADD CONSTRAINT FK_UniversePropertyXerf_Data_UniverseID FOREIGN KEY(UniverseID) REFERENCES dbo.Universe(UniverseID)
GO