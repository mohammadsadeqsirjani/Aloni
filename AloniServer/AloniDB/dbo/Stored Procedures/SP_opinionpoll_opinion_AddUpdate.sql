CREATE PROCEDURE [dbo].[SP_opinionpoll_opinion_AddUpdate]
		@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@sessionId as bigint,
	@opinionPollId as bigint,
	@options as [dbo].[UDT_opinionType] readonly,
	@comment as varchar(max),
	@d1 as uniqueidentifier,
	@d2 as uniqueidentifier,
	@d3 as uniqueidentifier,
	@d4 as uniqueidentifier,
	@d5 as uniqueidentifier,
    @rCode as tinyint out,
	@rMsg as nvarchar(max) out
	
AS

-- لیست امتیاز ها باید کامل باشد اما این موضوع سمت اپ کنترل می شود


--if(@opinion is null)
--begin
--set @rMsg = 'opinion list cannot be null!'; -- dbo.func_getSysMsg('oneDtlRequiredAtLeast', OBJECT_NAME(@@PROCID), @clientLanguage, 'oneDtlRequiredAtLeast');
--goto fail;
--end

	declare @storeId as bigint = (select fk_store_id from TB_STORE_ITEM_OPINIONPOLL where id = @opinionPollId)
	declare @fk_status_id as int = case when (select itemOpinionCommentNeedConfirm from TB_STORE where id = @storeId) = 1 then 107 else 106 END

if((select count(1) from @options) = 0)
begin
set @rMsg = dbo.func_getSysMsg('opinionCntIzZero', OBJECT_NAME(@@PROCID), @clientLanguage, 'پاسخگویی به تمامی سوالات نظرسنجی الزامی می باشد.');;
goto fail;
end

if(@appId is null or @appId <> 2)
begin
set @rMsg = 'only customers are able to Participation in opinionpoll'; -- dbo.func_getSysMsg('oneDtlRequiredAtLeast', OBJECT_NAME(@@PROCID), @clientLanguage, 'oneDtlRequiredAtLeast');
goto fail;
end




declare 
@opinionPollIsActive as bit,
@opinionPollStartDateTime as datetime,
@opinionPollEndDateTime as datetime,
@opinionPollPublish as bit;

select @opinionPollIsActive = isActive,
@opinionPollStartDateTime = startDateTime,
@opinionPollEndDateTime = endDateTime,
@opinionPollPublish = publish
from TB_STORE_ITEM_OPINIONPOLL with(nolock)
where id = @opinionPollId;

if(@opinionPollIsActive is null)
begin
set @rMsg = 'invalid opinionPollId';
goto fail;
end



if(@opinionPollIsActive = 0 or @opinionPollPublish = 0)
begin
set @rMsg = dbo.func_getSysMsg('opinionPollIsDisabled', OBJECT_NAME(@@PROCID), @clientLanguage, 'باعرض پوزش ، نظرسنجی موردنظر موقتا غیرفعال می باشد.');;
goto fail;
end

if(@opinionPollStartDateTime > getdate())
begin
set @rMsg = dbo.func_getSysMsg('timeErr_Notyet', OBJECT_NAME(@@PROCID), @clientLanguage, 'لطفا در زمان مشخص شده اقدام به ثبت نظر بفرمائید.');;
goto fail;
end


if(@opinionPollEndDateTime < getdate())
begin
set @rMsg = dbo.func_getSysMsg('timeErr_finished', OBJECT_NAME(@@PROCID), @clientLanguage, 'زمان مجاز به منظور شرکت در نظر سنجی به اتمام رسیده است.');;
goto fail;
end



if(exists(select 1 from @options as mo left join TB_STORE_ITEM_OPINIONPOLL_OPTIONS as ops on mo.id = ops.id and ops.fk_opinionpoll_id = @opinionPollId where ops.id is null))
begin
set @rMsg = 'invalid opinion items.'; --dbo.func_getSysMsg('optionError', OBJECT_NAME(@@PROCID), @clientLanguage, 'زمان مجاز به منظور شرکت در نظر سنجی به اتمام رسیده است.');;
goto fail;
end







begin try
begin tran t1;

declare
@opinionOptionId as bigint,
@score as money;


declare cr_opinion cursor local
for
select id,userScore from @options;
open cr_opinion;
fetch next from cr_opinion into @opinionOptionId,@score;
WHILE @@FETCH_STATUS = 0  
BEGIN

if(exists (select 1 from TB_STORE_ITEM_OPINIONPOLL_OPINIONS where pk_fk_usr_id = @userId and pk_fk_opinionOption_id = @opinionOptionId))
begin

update [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPINIONS]
set 
	 [score] = @score
	 where [pk_fk_usr_id] = @userId and [pk_fk_opinionOption_id] = @opinionOptionId;

	 end
	 else --insert
	 begin
	 INSERT INTO [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPINIONS]
           ([pk_fk_usr_id]
           ,[pk_fk_opinionOption_id]
           ,[score]
           ,[saveDateTime]
           ,[saveIp]
           ,[fk_opinionPollId])
    VALUES
           (@userId
           ,@opinionOptionId
           ,@score
           ,getdate()
           ,@clientIp
           ,@opinionPollId);
		   --(select @userId,
	 --opinionOptionId,
	 --score,
	 --getdate(),
	 --@clientIp,
	 --@opinionPollId)
	 end

		  




		  fetch next from cr_opinion into @opinionOptionId,@score;
END
close cr_opinion;
deallocate cr_opinion;


declare @existingCommentId as bigint;
set @existingCommentId = (select top 1 id from TB_STORE_ITEM_OPINIONPOLL_COMMENTS with(nolock) where fk_usr_commentUserId = @userId and fk_opinionpoll_id = @opinionPollId);

if(@existingCommentId is null)
begin
				 INSERT INTO [dbo].[TB_STORE_ITEM_OPINIONPOLL_COMMENTS]
						   ([fk_usr_commentUserId]
						   ,[fk_opinionpoll_id]
						   ,[comment]
						   ,[fk_document_doc1]
						   ,[fk_document_doc2]
						   ,[fk_document_doc3]
						   ,[fk_document_doc4]
						   ,[fk_document_doc5]
						   ,[saveDateTime]
						   ,[saveIp]
						   ,[edited]
						   ,[fk_status_id])
					 VALUES
						   (@userId
						   ,@opinionPollId
						   ,@comment
						   ,@d1
						   ,@d2
						   ,@d3
						   ,@d4
						   ,@d5
						   ,getdate()
						   ,@clientIp
						   ,0
						   ,@fk_status_id);
		   end
		   else begin
		   declare @emtyGuid as varchar(36);
		   set @emtyGuid = '00000000-0000-0000-0000-000000000000';



						   UPDATE [dbo].[TB_STORE_ITEM_OPINIONPOLL_COMMENTS]
				   SET -- [fk_usr_commentUserId] = <fk_usr_commentUserId, bigint,>
					  --,[fk_opinionpoll_id] = <fk_opinionpoll_id, bigint,>
					   [comment] = @comment
					  ,[fk_document_doc1] = @d1
					  ,[fk_document_doc2] = @d2
					  ,[fk_document_doc3] = @d3
					  ,[fk_document_doc4] = @d4
					  ,[fk_document_doc5] = @d5
					  --,[saveDateTime] = <saveDateTime, datetime,>
					  --,[saveIp] = <saveIp, varchar(50),>
					  ,[edited] = 1
					  ,[fk_status_id] = @fk_status_id
				 WHERE id = @existingCommentId and ( isnull([comment],'') <> isnull( @comment,'')   or isnull([fk_document_doc1],@emtyGuid) <> isnull(@d1,@emtyGuid) or isnull([fk_document_doc2],@emtyGuid) <> isnull(@d2,@emtyGuid) or isnull([fk_document_doc3],@emtyGuid) <> isnull(@d3,@emtyGuid) or isnull([fk_document_doc4],@emtyGuid) <> isnull(@d4,@emtyGuid) or isnull([fk_document_doc5],@emtyGuid) <> isnull(@d5,@emtyGuid))
		   end











commit tran t1;
end try
begin catch
rollback tran t1;
set @rMsg = ERROR_MESSAGE();
goto fail;
end catch



success:
--commit tran t1;
SET @rCode = 1;
SET @rMsg = 'عملیات با موفقیت انجام شد';
RETURN 0;
fail:
--ROLLBACK TRAN t1;
SET @rCode = 0;
RETURN 0;