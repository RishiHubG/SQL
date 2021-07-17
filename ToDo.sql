SELECT * FROM OBJECTLOG order by id desc

1.
--REGISTER SAVE
SELECT * FROM OBJECTLOG WHERE ID=2376

--REGISTER SAVE
SELECT * FROM OBJECTLOG WHERE ID=2377

--REGISTER SAVE
SELECT * FROM OBJECTLOG WHERE ID=2465

--rollback

ALTER TABLE RegisterPropertiesXref_Data_history DROP COLUMN RegisterPropertyXref_Dataid
ALTER TABLE RegisterPropertiesXref_Data_history ADD RegisterPropertiesXref_DataID INT NOT NULL

2.
Name/ParentID as unique in REgisters
ALTER TABLE [dbo].Registers DROP CONSTRAINT UQ_Registers_Name
ALTER TABLE [dbo].Registers ADD CONSTRAINT UQ_Registers_Name UNIQUE(Name,ParentID)

3.Framework save:
SELECT * FROM OBJECTLOG WHERE ID=2397
Cannot insert the value NULL into column 'UserCreated', table 'agsqa.dbo.RiskLite_data'; column does not allow nulls. INSERT fails.
SELECT * FROM RiskLite_data

4. Add username in accesscontrol, check for both uniservse/register:
SELECT * FROM OBJECTLOG WHERE ID=2402

ALTER TABLE dbo.accesscontrol ADD UserName NVARCHAR(500)

