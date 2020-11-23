USE JUNK
GO

DROP TABLE  IF EXISTS dbo.Registers,RegisterProperties,RegistersPropertiesXref,RegisterPropertyXerf_Data

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
	CONSTRAINT PK_Registers_RegisterID PRIMARY KEY(RegisterID)
	)
		ALTER TABLE [dbo].Registers ADD CONSTRAINT DF_Registers_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
	
--DROP TABLE  IF EXISTS dbo.RegisterProperties
--CREATE TABLE dbo.RegisterProperties
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

	--ALTER TABLE dbo.FrameworkSteps ADD CONSTRAINT FK_FrameworkSteps_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.RegistersPropertiesXref
CREATE TABLE dbo.RegistersPropertiesXref
(
RegisterID INT NOT NULL,
PropertyID INT NOT NULL,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL,
IsRequired BIT,
IsActive BIT, 
PropertyName NVARCHAR(1000),
CONSTRAINT PK_RegistersPropertiesXref_RegisterID_PropertyID PRIMARY KEY(RegisterID,PropertyID)
)
 		ALTER TABLE [dbo].RegistersPropertiesXref ADD CONSTRAINT DF_RegistersPropertiesXref_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

DROP TABLE  IF EXISTS dbo.RegisterPropertyXerf_Data
CREATE TABLE dbo.RegisterPropertyXerf_Data
(
RegisterID INT,
UserCreated INT NOT NULL,
DateCreated DATETIME2(0) NOT NULL,
UserModified INT,
DateModified DATETIME2(0),
VersionNum INT NOT NULL
)
 		ALTER TABLE [dbo].RegisterPropertyXerf_Data ADD CONSTRAINT DF_RegisterPropertyXerf_Data_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO