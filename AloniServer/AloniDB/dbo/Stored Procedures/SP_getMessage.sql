CREATE PROCEDURE [dbo].[SP_getMessage]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) ,
	@userId as bigint,
	@spicialUserId as bigint,
	@storeId as bigint
AS
	set nocount on
	set @pageNo = ISNULL(@pageNo,0)
	declare @staffId smallint = [dbo].[Func_GetUserStaffStore](@spicialUserId,@storeId)
	
	select m.* from TB_MESSAGE m with (nolock)  
	where (m.fk_usr_senderUser = @spicialUserId or m.fk_usr_destUserId = @spicialUserId or fk_store_destStoreId = @storeId or fk_staff_destStaffId = @staffId)
		   and m.[message] like case when @search is not null and @search <> '' then '%'+@search+'%' else m.[message] end
	ORDER BY m.saveDateTime desc
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
	
RETURN 0
