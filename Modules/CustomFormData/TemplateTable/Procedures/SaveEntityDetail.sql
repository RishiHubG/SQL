USE [agsqa]
GO
/****** Object:  StoredProcedure [dbo].[SaveEntityDetail]    Script Date: 10/24/2021 12:30:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  PROCEDURE [dbo].[SaveEntityDetail](
						@EntitytypeId			INT,						
						@UserLoginID			INT,
						@MethodName				VARCHAR(255),
						@InputJson              NVARCHAR(MAX),
						@EntityId				INT)
AS
BEGIN 

	SET NOCOUNT ON 

	IF(@EntitytypeId = 4) -- Userlist
	BEGIN
		EXEC SaveUserDetail @entityId,@UserloginId,@MethodName,@InputJson
	END
	ELSE IF(@EntitytypeId = 5) -- Role Type List
	BEGIN
		exec SaveRoleType @roleTypeId = @entityId, @UserloginId=@UserLoginID,@MethodName=@MethodName,@InputJson = @InputJson
	END
	ELSE IF (@EntitytypeId = 7) -- Permission scheme list
	BEGIN
		exec SavePermissionSchemeDetails @PermissionSchemeID= @entityId, @UserloginId=@UserLoginID,@MethodName=@MethodName,@InputJson = @InputJson
	END
	ELSE IF (@EntitytypeId = 6) -- User Group list
	BEGIN
		exec SaveUserGroupDetails @UserloginId=@UserLoginID,@usergroupId= @entityId,@MethodName=@MethodName,@InputJson = @InputJson
	END
	ELSE IF (@EntitytypeId = 10)
	BEGIN
		EXEC SaveFrameworkPropertiesJSONData @inputjson,@userloginId,@entityid,@entitytypeid,@methodname
	END
	ELSE IF (@EntitytypeId = 22)
	BEGIN
		EXEC SaveResourcecalendarJSONData @inputjson,@userloginId,@entityid,@entitytypeid,@methodname
	END
	ELSE IF @EntitytypeId = 13 -- Custom Form Data
	BEGIN
		exec SaveTemplateTableData @UserLoginID=@UserLoginID,@Entityid= @Entityid,@MethodName=@MethodName,@InputJson = @InputJson
	END

END


