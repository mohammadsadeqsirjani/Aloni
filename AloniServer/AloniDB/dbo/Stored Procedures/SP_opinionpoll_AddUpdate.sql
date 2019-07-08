CREATE PROCEDURE [dbo].[SP_opinionpoll_AddUpdate]
@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@sessionId as bigint,
	@storeId as bigint,
	@itemId as bigint,
	@title as varchar(max),
	@itemGrpTitle_override as varchar(150),
	@itemPicId_override as uniqueidentifier,
	@startDateTime as datetime,
	@endDateTime as datetime,
	@resultIsPublic as bit,
	@isActive as bit,
	@publish as bit,
	@existingOpinionPollId as bigint out,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
	
AS

if(@appId <> 1)
begin
set @rMsg = 'forbidden operation';
goto fail;
end



declare @item_title as varchar(150),@itemGrp_title as varchar(150),@itemPicId as uniqueidentifier;


if(@startDateTime >  @endDateTime)
begin
set @rMsg = dbo.func_getSysMsg('incorrectStartAndDateTime',OBJECT_NAME(@@PROCID),@clientLanguage,'زمان شروع و پایان نظرسنجی صحیح نمی باشد.'); 
goto fail;
end
--select 
--@item_title = ISNULL(i_trn.title,i.title)
----@itemGrp_title 

--from
--TB_STORE_ITEM_QTY as siq with(nolock)
--join
--TB_ITEM as i with(nolock)
--on siq.pk_fk_item_id = i.id
--join
--TB_TYP_ITEM_GRP as ig with(nolock)
--on i.fk_itemGrp_id = ig.id
--left join TB_ITEM_TRANSLATIONS as i_trn with(nolock)
--on i.id = i_trn.id and i_trn.lan = @clientLanguage
--left join TB_TYP_ITEM_GRP_TRANSLATIONS as ig_trn with(nolock)
--on ig.id = ig_trn.id and ig_trn.lan = @clientLanguage
--left join TB_DOCUMENT_ITEM as di with(nolock)
--on siq.pk_fk_item_id = di.pk_fk_item_id and di.isDefault = 1
--where siq.pk_fk_store_id = @storeId
--and
--siq.pk_fk_item_id = @itemId;

if(@sessionId is null or @isActive is null or @publish is null or @resultIsPublic is null or @startDateTime is null or @endDateTime is null or @title is null)
begin
set @rMsg = dbo.func_getSysMsg('AllOfRequiredInputsNotDefined',OBJECT_NAME(@@PROCID),@clientLanguage,'لطفا تمامی اطلاعات الزمی را وارد نمائید.'); 
goto fail;
end


if(not exists( select 1 from TB_STORE_ITEM_QTY as siq with(nolock) join TB_ITEM as i with(nolock) on siq.pk_fk_item_id = i.id where siq.pk_fk_store_id = @storeId and siq.pk_fk_item_id = @itemId))
begin
set @rMsg = dbo.func_getSysMsg('invalidItem',OBJECT_NAME(@@PROCID),@clientLanguage,'کد کالای ورودی در فروشگاه شما تعریف نشده است.'); 
goto fail;
end

if(@existingOpinionPollId is not null)
begin

UPDATE [dbo].[TB_STORE_ITEM_OPINIONPOLL]
   SET 
      [isActive] = @isActive
      ,[title] = @title
      ,[resultIsPublic] = @resultIsPublic
      ,[fk_document_picId] = @itemPicId_override
      ,[startDateTime] = @startDateTime
      ,[endDateTime] = @endDateTime
      ,[publish] = @publish
      ,[itemGrpTitle] = @itemGrp_title
      --,[saveDateTime] = <saveDateTime, datetime,>
      --,[saveIp] = <saveIp, varchar(50),>
      --,[fk_userSession_saveUserSessionId] = <fk_userSession_saveUserSessionId, bigint,>
 WHERE [id] = @existingOpinionPollId and [fk_store_id] = @storeId and (publishDateTime is null or dateadd(MINUTE,[dbo].[func_store_item_opinionpoll_editTimeout](), publishDateTime) > getdate())
 and not exists (select 1 from TB_STORE_ITEM_OPINIONPOLL_OPINIONS as oos
 join TB_STORE_ITEM_OPINIONPOLL_OPTIONS as oo on oos.pk_fk_opinionOption_id = oo.id where oo.fk_opinionpoll_id = @existingOpinionPollId)

 if(@@ROWCOUNT <> 1)
 begin
 set @rMsg = dbo.func_getSysMsg('invalidExistingOpinionPollId',OBJECT_NAME(@@PROCID),@clientLanguage,'امکان ویرایش نظر سنجی وجود ندارد.');
 goto fail;
 end
end

else begin

INSERT INTO [dbo].[TB_STORE_ITEM_OPINIONPOLL]
           ([fk_store_id]
           ,[fk_item_id]
           ,[isActive]
           ,[title]
           ,[resultIsPublic]
           ,[fk_document_picId]
           ,[startDateTime]
           ,[endDateTime]
           ,[publish]
           ,[itemGrpTitle]
		   ,[saveIp]
		   ,[fk_userSession_saveUserSessionId])
     VALUES
           (@storeId
           ,@itemId
           ,@isActive
           ,@title
           ,@resultIsPublic
           ,@itemPicId_override
           ,@startDateTime
           ,@endDateTime
           ,@publish
           ,@itemGrpTitle_override
		   ,@clientIp
		   ,@sessionId);

		   set @existingOpinionPollId = SCOPE_IDENTITY();

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