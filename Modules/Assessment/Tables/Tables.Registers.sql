USE JUNK
GO

DROP TABLE  IF EXISTS RegistersPropertiesXref,RegisterPropertyXerf_Data,RegisterProperties,dbo.Registers

DROP TABLE  IF EXISTS dbo.Registers
CREATE TABLE dbo.Registers
	(	
	RegisterID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	Name VARCHAR(500) NOT NULL,
	FrameworkID	INT,
	UniverseID INT,
	AccessControlID	INT,
	WorkFlowACID INT,	
	PropagatedAccessControlID INT,
	PropagatedWFAccessControlID INT,
	HasExtendedProperties BIT,
	CONSTRAINT PK_Registers_RegisterID PRIMARY KEY(RegisterID),
	CONSTRAINT UQ_Registers_Name UNIQUE(Name),
	)
		ALTER TABLE [dbo].Registers ADD CONSTRAINT DF_Registers_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
	
DROP TABLE  IF EXISTS dbo.RegisterProperties
CREATE TABLE dbo.RegisterProperties
	(
	RegisterPropertyID INT IDENTITY(1,1) NOT NULL,
	RegisterID INT NOT NULL,	
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	PropertyName VARCHAR(100) NOT NULL,
	CONSTRAINT PK_RegisterProperties_RegisterPropertyID PRIMARY KEY(RegisterPropertyID)
	)

	ALTER TABLE dbo.RegisterProperties ADD CONSTRAINT FK_RegisterProperties_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
	ALTER TABLE [dbo].Registers ADD CONSTRAINT FK_RegisterProperties_RegisterID FOREIGN KEY(RegisterID) REFERENCES dbo.Registers(RegisterID)
GO

DROP TABLE  IF EXISTS dbo.RegistersPropertiesXref
CREATE TABLE dbo.RegistersPropertiesXref
(
RegistersPropertiesXrefID INT IDENTITY(1,1),
RegisterPropertyID INT NOT NULL,
RegisterID INT NOT NULL,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
PropertyName NVARCHAR(1000),
IsRequired BIT,
IsActive BIT, 
CONSTRAINT PK_RegistersPropertiesXref_RegisterID_RegisterPropertyID PRIMARY KEY(RegistersPropertiesXrefID,RegisterPropertyID,RegisterID)
)
 		ALTER TABLE [dbo].RegistersPropertiesXref ADD CONSTRAINT DF_RegistersPropertiesXref_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
		ALTER TABLE [dbo].RegistersPropertiesXref ADD CONSTRAINT FK_RegistersPropertiesXref_RegisterID FOREIGN KEY(RegisterID) REFERENCES dbo.Registers(RegisterID)
		ALTER TABLE [dbo].RegistersPropertiesXref ADD CONSTRAINT FK_RegistersPropertiesXref_RegisterPropertyID FOREIGN KEY(RegisterPropertyID) REFERENCES dbo.RegisterProperties(RegisterPropertyID)
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

--COLUMNS WILL BE ADDED TO THIS TABLE; NO REMOVAL OF COLUMNS
DROP TABLE  IF EXISTS dbo.RegisterPropertyXerf_Data
CREATE TABLE dbo.RegisterPropertyXerf_Data
(
RegisterPropertyXerf_DataID INT IDENTITY(1,1),
RegisterID INT ,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
CONSTRAINT PK_RegisterPropertyXerf_Data_RegisterID PRIMARY KEY(RegisterID)
)
 		ALTER TABLE [dbo].RegisterPropertyXerf_Data ADD CONSTRAINT DF_RegisterPropertyXerf_Data_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
		ALTER TABLE [dbo].RegisterPropertyXerf_Data ADD CONSTRAINT FK_RegisterPropertyXerf_Data_RegisterID FOREIGN KEY(RegisterID) REFERENCES dbo.Registers(RegisterID)
GO