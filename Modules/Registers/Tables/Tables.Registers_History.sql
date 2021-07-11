

DROP TABLE  IF EXISTS dbo.Registers_history,RegisterProperties_history,RegisterPropertiesXref_history,RegisterPropertyXref_Data_history

DROP TABLE  IF EXISTS dbo.Registers_history
CREATE TABLE dbo.Registers_history
	(
	historyid INT IDENTITY(1,1),	
	usercreated INT NOT NULL,
	datecreated DATETIME2(0) NOT NULL,
	usermodified INT,
	datemodified DATETIME2(0),
	versionnum INT NULL,
	periodidentifierid INT NOT NULL,
	operationtype NVARCHAR(50),
	useractionid INT,
	registerid INT,
	fullschemajson NVARCHAR(MAX),
	name NVARCHAR(500) NOT NULL,
	description NVARCHAR(MAX) NULL,
	frameworkid	INT,
	parentid INT NULL,
	height INT NULL,
	depth INT NULL,
	universeid INT,
	accesscontrolid	INT,
	parentaccesscontrolid INT,
	workflowacid INT,
	isinherited BIT,
	propagatedaccesscontrolid INT,
	propagatedwfaccesscontrolid INT,
	hasextendedproperties BIT,
	CONSTRAINT PK_Registers_history_HistoryID PRIMARY KEY(HistoryID)
	)
		 
GO
	
DROP TABLE  IF EXISTS dbo.RegisterProperties_history
CREATE TABLE dbo.RegisterProperties_history
	(
	historyid INT IDENTITY(1,1),
	usercreated INT NOT NULL,
	datecreated DATETIME2(0) NOT NULL,
	usermodified INT,
	datemodified DATETIME2(0),
	versionnum INT NULL,
	periodidentifierid INT NOT NULL,
	operationtype NVARCHAR(50),
	useractionid INT,
	registerpropertyid INT NOT NULL,
	registerid INT NOT NULL,	
	propertyname NVARCHAR(MAX) NOT NULL,
	apikeyname NVARCHAR(MAX) NOT NULL,
	jsontype NVARCHAR(50) NOT NULL,
	CONSTRAINT PK_RegisterProperties_history_HistoryID PRIMARY KEY(HistoryID)
	)

 
GO

DROP TABLE  IF EXISTS dbo.RegisterPropertiesXref_history
CREATE TABLE dbo.RegisterPropertiesXref_history
(
historyid INT IDENTITY(1,1),
usercreated INT NOT NULL,
datecreated DATETIME2(0) NOT NULL,
usermodified INT,
datemodified DATETIME2(0),
versionnum INT NULL,
periodidentifierid INT NOT NULL,
operationtype NVARCHAR(50),
useractionid INT,
registerpropertiesxrefid INT NOT NULL,
registerid INT NOT NULL,
registerpropertyid INT NOT NULL,
propertyname NVARCHAR(MAX) NOT NULL,
apikeyname NVARCHAR(MAX) NOT NULL,
isrequired BIT,
isactive BIT, 
CONSTRAINT PK_RegisterPropertiesXref_history_HistoryID PRIMARY KEY(HistoryID)
)
 
GO

--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_StepID FOREIGN KEY(StepID) REFERENCES dbo.FrameworkSteps(StepID)
--ALTER TABLE dbo.FrameworkStepItems ADD CONSTRAINT FK_FrameworkStepItems_FrameworkID FOREIGN KEY(FrameworkID) REFERENCES dbo.Frameworks(FrameworkID)

--COLUMNS WILL BE ADDED TO THIS TABLE; NO REMOVAL OF COLUMNS
DROP TABLE  IF EXISTS dbo.RegisterPropertiesXref_Data_history
CREATE TABLE dbo.RegisterPropertiesXref_Data_history
(
historyid INT IDENTITY(1,1),
usercreated INT NOT NULL,
datecreated DATETIME2(0) NOT NULL,
usermodified INT,
datemodified DATETIME2(0),
versionnum INT NULL,
periodidentifierid INT NULL,
operationtype NVARCHAR(50),
useractionid INT,
RegisterPropertiesXref_DataID INT NOT NULL,
registerid INT
)
 		 
GO