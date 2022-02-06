
DROP TABLE  IF EXISTS dbo.FilterExpression

CREATE TABLE dbo.FilterExpression
(
 ID INT IDENTITY(1,1),
 RegisterID INT,
 InputJSON VARCHAR(MAX),
 FilterExpression  VARCHAR(MAX),
 DateCreated DATETIME2(0)
 )

 	
ALTER TABLE [dbo].FilterExpression ADD CONSTRAINT DF_FilterExpression_DateCreated DEFAULT GETUTCDATE() FOR [DateCreated] 