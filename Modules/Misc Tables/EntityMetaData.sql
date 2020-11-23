USE JUNK
GO
/*
USE [junk]
GO

SELECT CONCAT('INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (',
			[AGSID],',',0,','''
           ,[Name],''',',''''
           ,[PluralName],''',',''''
           ,[ChildName],''',',''''
           ,[ChildPluralName],''')'
		   )
FROM T1            

*/ 
DROP TABLE  IF EXISTS dbo.EntityMetaData
CREATE TABLE dbo.EntityMetaData
	(
	AGSID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),	
	Name VARCHAR(1000),
	PluralName VARCHAR(1000),
	ChildName VARCHAR(1000),
	ChildPluralName	VARCHAR(1000),
	IsActive BIT,
	CONSTRAINT PK_EntityMetaData_AGSID PRIMARY KEY(AGSID)	
	)

ALTER TABLE [dbo].EntityMetaData ADD CONSTRAINT DF_EntityMetaData_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 
GO
	

	SET IDENTITY_INSERT EntityMetaData ON;

	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (0,0,'Framework','Frameworks','Framework','Frameworks')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (1,0,'Universe','Universe','Sub Universe','Sub Universe')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (2,0,'Register','Register','Registers','Sub Registers')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (3,0,'Entity','Entitys','Entity','Entity')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (4,0,'User','Users','User','User')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (5,0,'User Group','User Groups','User Group','User Group')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (6,0,'BaseCalendar','BaseCalendars','BaseCalendar','BaseCalendar')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (7,0,'PermissionScheme','PermissionSchemes','PermissionScheme','PermissionScheme')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (8,0,'Landing Page','Landing Pages','Landing Page','Landing Page')
	INSERT INTO dbo.EntityMetaData(AGSID,UserCreated,Name,PluralName,ChildName,ChildPluralName) VALUES (9,0,'ShortCut','ShortCuts','ShortCut','ShortCut')
		
	SET IDENTITY_INSERT EntityMetaData OFF;

	SELECT * FROM EntityMetaData	
	
 