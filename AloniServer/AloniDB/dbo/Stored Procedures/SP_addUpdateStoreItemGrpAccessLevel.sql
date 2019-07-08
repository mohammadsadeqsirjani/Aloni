CREATE PROCEDURE [dbo].[SP_addUpdateStoreItemGrpAccessLevel]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@storeId as bigint,
	@itemGrpList as dbo.LongType READONLY,
	@itemGrpAll as bit,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
declare @_itemGrpList as dbo.LongType;
insert into @_itemGrpList select * from @itemGrpList

begin tran t
	begin try

	if(not exists (select 1 from @_itemGrpList) AND @itemGrpAll = 0)
	begin
	update TB_STORE
	set accessLevel = 0
	where id = @storeId

	delete from TB_STORE_ITEMGRP_ACCESSLEVEL
	where fk_store_id = @storeId
	end
	else if(@itemGrpAll = 0)
	begin
	update TB_STORE
	set accessLevel = 2
	where id = @storeId

	delete from TB_STORE_ITEMGRP_ACCESSLEVEL
	where fk_store_id = @storeId

	declare @grp as bigint;
	declare itemGrp cursor for select id from @_itemGrpList
	open itemGrp
	fetch next from itemGrp into @grp;
	while(@@FETCH_STATUS = 0)
	begin 
	if(not exists (select 1 from TB_STORE_ITEMGRP_ACCESSLEVEL where fk_store_id = @storeId and fk_itemGrp_id = @grp))
	begin
	insert into TB_STORE_ITEMGRP_ACCESSLEVEL (fk_store_id,fk_itemGrp_id) VALUES (@storeId,@grp)
	end
	fetch next from itemGrp into @grp;
	end
	close itemGrp;
	deallocate itemGrp;

	end
	else
	begin
	delete from TB_STORE_ITEMGRP_ACCESSLEVEL
	where fk_store_id = @storeId
	update TB_STORE
	set accessLevel = 1
	where id = @storeId
	end

	commit tran t;
	end try
	begin catch
	rollback tran t;
	set @rMsg = ERROR_MESSAGE();
	goto fail;
	end catch

success:

SET @rCode = 1;

--commit transaction T
--set @rMsg = dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
RETURN 0;

fail:

SET @rCode = 0;

--rollback transaction T
RETURN 0;
GO
