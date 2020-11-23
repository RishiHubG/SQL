USE JUNK
GO
 
DROP TABLE  IF EXISTS dbo.EntityImages
CREATE TABLE dbo.EntityImages
	(
	ImageID INT IDENTITY(1,1),
	UserCreated INT NOT NULL,
	DateCreated DATETIME2(0) NOT NULL,
	UserModified INT,
	DateModified DATETIME2(0),
	VersionNum INT NOT NULL,
	EntityTypeID INT,
	EntityID INT,
	[Image] VARCHAR(1000),
	isMaster BIT,
	CONSTRAINT PK_EntityImages_ImageID PRIMARY KEY(ImageID)
	)

