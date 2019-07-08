CREATE PROCEDURE [dbo].[SP_opinionpoll_option_AddUpdate]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@sessionId as bigint,

	@storeId as bigint,
	@existingOpinionPoolOptionId as bigint out,
	@title as varchar(max),
	@opinionpollId as bigint,
	@isActive as bit,
	@orderingNo as int,

	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS


if(@title is null or @isActive is null or @opinionpollId is null)
begin
set @rMsg = dbo.func_getSysMsg('AllOfRequiredInputsNotDefined',OBJECT_NAME(@@PROCID),@clientLanguage,'لطفا تمامی اطلاعات الزمی را وارد نمائید.'); 
goto fail;
end

if(@storeId is null)
begin
set @rMsg = dbo.func_getSysMsg('storeIdCannotBeNull',OBJECT_NAME(@@PROCID),@clientLanguage,'storeId Cannot Be Null'); 
goto fail;
end

if(not exists (select 1 from TB_STORE_ITEM_OPINIONPOLL with(nolock) where id = @opinionpollId and fk_store_id = @storeId))
begin
set @rMsg = dbo.func_getSysMsg('invalidOpinionpollIdOrStoreId',OBJECT_NAME(@@PROCID),@clientLanguage,'invalid storeId or opinionpollId'); 
goto fail;
end



if(@existingOpinionPoolOptionId is not null)
begin


UPDATE
oppo
  SET [oppo].[title] = @title
      --,[fk_opinionpoll_id] = @opinionpollId
      ,[oppo].[isActive] = @isActive
      ,[oppo].[orderingNo] = @orderingNo

from
 [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS] as oppo
 join TB_STORE_ITEM_OPINIONPOLL as opp
 on oppo.fk_opinionpoll_id = opp.id
 WHERE oppo.id = @existingOpinionPoolOptionId and opp.id = @opinionpollId and opp.fk_store_id = @storeId
 and (publishDateTime is null or dateadd(MINUTE,[dbo].[func_store_item_opinionpoll_editTimeout](), opp.publishDateTime) > getdate())
 and not exists (select 1 from TB_STORE_ITEM_OPINIONPOLL_OPINIONS as oos
 join TB_STORE_ITEM_OPINIONPOLL_OPTIONS as oo on oos.pk_fk_opinionOption_id = oo.id where oo.fk_opinionpoll_id = @opinionpollId)

  if(@@ROWCOUNT <> 1)
 begin
 set @rMsg = dbo.func_getSysMsg('invalidExistingOpinionPoolOptionId',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان اصلاح این گزینه وجود ندارد');
 goto fail;
 end

end

else
begin

if((select count(1) from [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS] where fk_opinionpoll_id = @opinionpollId) >= 10)
 begin
 set @rMsg = dbo.func_getSysMsg('maximumCntOfOptionsReched',OBJECT_NAME(@@PROCID),@clientLanguage,'تعداد گزینه / سوالات نظرسنجی به حداکثر تعداد مجاز خود رسیده است.');
 goto fail;
 end
 if(exists(select top 1 id from [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS] where fk_opinionpoll_id = @opinionpollId and title = @title and isActive = 1))
 begin
 set @rMsg = dbo.func_getSysMsg('maximumCntOfOptionsReched',OBJECT_NAME(@@PROCID),@clientLanguage,' گزینه وارد شده تکراری است ');
 goto fail;
 end

INSERT INTO [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS]
           ([title]
           ,[fk_opinionpoll_id]
           ,[isActive]
           ,[orderingNo])
     VALUES
           (@title
           ,@opinionpollId
           ,@isActive
           ,@orderingNo);

		   set @existingOpinionPoolOptionId = SCOPE_IDENTITY();

end


success:
--commit tran t1;
SET @rCode = 1;
SET @rMsg = 'success.';
RETURN 0;
fail:
--ROLLBACK TRAN t1;
SET @rCode = 0;
RETURN 0;