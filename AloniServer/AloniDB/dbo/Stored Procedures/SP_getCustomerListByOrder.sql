CREATE PROCEDURE [dbo].[SP_getCustomerListByOrder]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20),
	@storeId as bigint,
	@rMsg as nvarchar(500) out
AS
	SET NOCOUNT ON
	set @pageNo = ISNULL(@pageNo,0)
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
	begin
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'شما مجاز به انجام این عملیات نمی باشید.')
		return
	end	
	select u.id,fname + ' '+isnull(lname,'') name,mobile,d.completeLink,thumbcompeleteLink
    from TB_USR U left join TB_DOCUMENT_USR DU on u.id = DU.pk_fk_usr_id left join TB_DOCUMENT D on DU.pk_fk_document_id = d.id
	where u.id  in 
	(
		select u.id
		from TB_ORDER O  
		inner join  TB_USR U on o.fk_usr_customerId = u.id
		where o.fk_store_storeId = @storeId and u.fk_status_id = 25 and o.fk_usr_customerId 
		not in (select t.pk_fk_usr_cstmrId from TB_STORE_CUSTOMER T where T.pk_fk_store_id = @storeId)
	)
	and
	(u.lname like case when @search is not null and @search <> '' then '%'+@search+'%' else u.lname end or u.fname like case when @search is not null and @search <> '' then '%'+@search+'%' else u.fname end or u.mobile like case when @search is not null and @search <> '' then '%'+@search+'%' else u.mobile end)
	order by u.id
	OFFSET(@pageNo * 10) rows
	fetch next 10 rows only

RETURN 0
