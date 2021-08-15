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



--1. drop col. Customised from dbo.AccessControlledResource
ALTER TABLE AccessControlledResource DROP CONSTRAINT DF__AccessCon__Custo__66B53B20
ALTER TABLE AccessControlledResource DROP COLUMN Customised
--USER PERMISSIONS

--PARENT UNI.:
--IF @ParentEntityID=-1,@ParentEntityTypeID=2 THEN PARENTID=NULL
--stamp permissions WITH NEW NODES IN PERMISSONLIST : NEED TO MODIFY SaveUniversePermissions
--XREF_DATA: NOT BEING POPULATED
--ROLLBACK COMMIT
BEGIN TRAN
exec SaveUniverseJSONData @EntityId=-1,@EntitytypeId=2,@ParentEntityID=-1,@ParentEntityTypeID=2,@name=N'rishi domain3',@description=N'rishi test domain',
@InputJSON=N'{"domainpermissiona":[],"attributes":{"currency":"usd","notes":"test","domainowner":"","exchangeRate":150},"permissionList":{"jsonData":{"assigned":[{"username":"admin","userid":1,"read":true,"modify":true,"write":true,"cut":true,"copy":true,"delete":true,"administrate":true,"adhoc":true,"export":true,"report":true},{"username":"loginid3","userid":2031,"read":true,"modify":true}],"unassigned":[{"username":"Administrators","userid":2,"description":"Administrators"},{"username":"Super Users","userid":2024,"description":"Super Users"},{"username":"IT Auditors","userid":2025,"description":"IT Auditors"},{"username":"Operational User","userid":2026,"description":"Operational User"},{"username":"Operational User1","userid":2027,"description":"Operational User1"},{"username":"Gprashanthi","userid":2032,"description":"Gprashanthi"},{"username":"New User Group","userid":2033,"description":"New User Group"}]}},"domianinherentpermissions":false,"workflowpermissions":[{"userUserGroup":"","read":false,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"","stepstepItem":"","stepname":"","stepItemName":{},"view":false}],"WFinheritpermissions":false,"frameworklist":{"1":false,"2":false,"3":false,"4":false,"5":false,"6":false,"7":false,"8":false,"9":false,"10":false,"11":false,"12":false,"13":false,"14":false,"15":false,"16":false,"17":false,"18":false,"19":false,"20":true,"21":true}}',
@MethodName=NULL,@UserLoginID=3432

--CHILD:
--IF @ParentEntityID>0 & @ParentEntityTypeID=2
--ROLLBACK COMMIT
BEGIN TRAN
exec SaveUniverseJSONData @EntityId=-1,@EntitytypeId=2,@ParentEntityID=51,@ParentEntityTypeID=2,@name=N'sub uni 21',@description=N'sub uni 1 desc',
@InputJSON=N'{"domainpermissiona":[],"attributes":{"currency":"usd","notes":"","domainowner":"","exchangeRate":125},"permissionList":{"jsonData":{"assigned":[{"username":"admin","userid":1,"description":"admin","read":true,"modify":true,"cut":true,"write":true,"copy":true,"delete":true,"adhoc":true,"export":true,"report":true,"administrate":true},{"username":"IT Auditors","userid":2025,"description":"IT Auditors","read":true,"modify":true}],"unassigned":[{"username":"Administrators","userid":2,"description":"Administrators"},{"username":"Super Users","userid":2024,"description":"Super Users","selected":false},{"username":"Operational User","userid":2026,"description":"Operational User"},{"username":"Operational User1","userid":2027,"description":"Operational User1"},{"username":"loginid3","userid":2031,"description":"loginid3"},{"username":"Gprashanthi","userid":2032,"description":"Gprashanthi"},{"username":"New User Group","userid":2033,"description":"New User Group"}]}},"domianinherentpermissions":false,"workflowpermissions":[{"userUserGroup":"","read":false,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"","stepstepItem":"","stepname":"","stepItemName":{},"view":false}],"WFinheritpermissions":false,"frameworklist":{"1":false,"2":false,"3":false,"4":false,"5":false,"6":false,"7":false,"8":false,"9":false,"10":false,"11":false,"12":false,"13":false,"14":false,"15":false,"16":false,"17":false,"18":false,"19":false,"20":true,"21":true}}',
@MethodName=NULL,@UserLoginID=3432

--INHERITED:
--stamp permissions of PARENT IF INHERIT IS TRUE
exec SaveUniverseJSONData @EntityId=-1,@EntitytypeId=2,@ParentEntityID=51,@ParentEntityTypeID=2,@name=N'Sub uni 3',@description=N'Sub uni 3 desc',
@InputJSON=N'{"domainpermissiona":[],"attributes":{"currency":"usd","notes":"","domainowner":"","exchangeRate":135},"permissionList":{"jsonData":{"assigned":[],"unassigned":[]}},"domianinherentpermissions":true,"workflowpermissions":[{"userUserGroup":"","read":false,"modify":false,"write":false,"cut":false,"copy":false,"delete":false,"administrate":false,"adhoc":false,"workflowname":"","stepstepItem":"","stepname":"","stepItemName":{},"view":false}],"WFinheritpermissions":false,"frameworklist":{"1":false,"2":false,"3":false,"4":false,"5":false,"6":false,"7":false,"8":false,"9":false,"10":false,"11":false,"12":false,"13":false,"14":false,"15":false,"16":false,"17":false,"18":false,"19":false,"20":true,"21":true}}',
@MethodName=NULL,@UserLoginID=3432

select * from UniversePropertiesXref_Data
select * from UniversePropertiesXref_Data_history

ALTER TABLE dbo.UniversePropertiesXref_Data_history ALTER COLUMN VERSIONNUM INT NULL

exec SP_RENAME 'dbo.UniversePropertiesXref_Data_history.UniversePropertiesXerf_DataID','UniversePropertiesXref_DataID','COLUMN'


exec SP_RENAME 'dbo.UniversePropertiesXref_Data.UniversePropertiesXerf_DataID','UniversePropertiesXref_DataID','COLUMN'

SELECT * FROM AccessControlledResource ORDER BY DateCreated DESC

 