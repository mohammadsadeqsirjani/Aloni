CREATE PROCEDURE [dbo].[SP_opinionpoll_copyToMultipleItems]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),

	@userId as bigint,
	@sessionId as bigint,
	@storeId as bigint,

	@srcOpinionPollId as bigint,
	@itemIds as [dbo].[LongType] readonly,


	@rCode as tinyint out,
	@rMsg as nvarchar(max) out


AS



if(@appId <> 1)
begin
set @rMsg = 'forbidden operation';
goto fail;
end;



--insert into TB_STORE_ITEM_OPINIONPOLL
--			([fk_store_id]
--           ,[fk_item_id]
--           ,[isActive]
--           ,[title]
--           ,[resultIsPublic]
--           ,[fk_document_picId]
--           ,[startDateTime]
--           ,[endDateTime]
--           ,[publish]
--           ,[itemGrpTitle]
--           ,[saveDateTime]
--           ,[saveIp]
--           ,[fk_userSession_saveUserSessionId])

with opHdrs as(
			select 
			--o.fk_store_id
			its.id as fk_item_id
			,o.isActive
			,o.title
			,o.resultIsPublic
			,o.startDateTime
			,o.endDateTime
			,o.publish
			--,o.itemGrpTitle
			--,GETDATE() as saveDateTime
			--,@clientIp  as saveIp
			--,@sessionId as fk_userSession_saveUserSessionId
			--,@srcOpinionPollId as fk_this_templateOpId
			from TB_STORE_ITEM_OPINIONPOLL as o
			join TB_STORE_ITEM_QTY as siq on o.fk_store_id = siq.pk_fk_store_id
			join @itemIds as its on siq.pk_fk_item_id = its.id

			left join TB_STORE_ITEM_OPINIONPOLL as eo on eo.fk_this_templateOpId is not null and eo.fk_this_templateOpId = @srcOpinionPollId and eo.fk_item_id = its.id

			where o.id = @srcOpinionPollId and o.fk_store_id = @storeId and eo.id is null)

		--	and not exists(select 1 from TB_STORE_ITEM_OPINIONPOLL where fk_this_templateOpId is not null and fk_this_templateOpId = @srcOpinionPollId and fk_store_id = @storeId and id in (select id from @itemIds)))


				SELECT *
					INTO #tmp
					FROM opHdrs;



select *
into #options
from TB_STORE_ITEM_OPINIONPOLL_OPTIONS
where fk_opinionpoll_id = @srcOpinionPollId;


					declare @fk_item_id as bigint
					, @isActive as bit
					,@title as varchar(max)
					,@resultIsPublic as bit
					,@startDateTime as datetime
					,@endDateTime as datetime
					,@publish as bit;
			
					
				    declare c cursor
					for select * from #tmp;


					OPEN c  

FETCH NEXT FROM c   
INTO @fk_item_id, @isActive  ,@title,@resultIsPublic,@startDateTime,@endDateTime,@publish

 WHILE @@FETCH_STATUS = 0  
    BEGIN  

	begin try
	begin tran tr

			insert into TB_STORE_ITEM_OPINIONPOLL
			([fk_store_id]
           ,[fk_item_id]
           ,[isActive]
           ,[title]
           ,[resultIsPublic]
           --,[fk_document_picId]
           ,[startDateTime]
           ,[endDateTime]
           ,[publish]
           --,[itemGrpTitle]
           ,[saveDateTime]
           ,[saveIp]
           ,[fk_userSession_saveUserSessionId]
		   ,[fk_this_templateOpId])
		  values
		  (
		  @storeId,
		  @fk_item_id,
		  @isActive,
		  @title,
		  @resultIsPublic,
		  @startDateTime,
		  @endDateTime,
		  @publish,
		  getdate(),
		  @clientIp,
		  @sessionId,
		  @srcOpinionPollId
		  )

		  		    INSERT INTO [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS]
           ([title]
           ,[fk_opinionpoll_id]
           ,[isActive]
           ,[orderingNo])
		  select 
		  title
		  ,SCOPE_IDENTITY()
		  ,isActive
		  ,orderingNo
		  from #options
		  commit tran tr;
		  end try
		  begin catch
		  rollback tran tr
		  end catch

        FETCH NEXT FROM c INTO @fk_item_id, @isActive  ,@title,@resultIsPublic,@startDateTime,@endDateTime,@publish  
        END  

    CLOSE c  
    DEALLOCATE c  




		--insert into TB_STORE_ITEM_OPINIONPOLL
		--	([fk_store_id]
  --         ,[fk_item_id]
  --         ,[isActive]
  --         ,[title]
  --         ,[resultIsPublic]
  --         ,[fk_document_picId]
  --         ,[startDateTime]
  --         ,[endDateTime]
  --         ,[publish]
  --         ,[itemGrpTitle]
  --         ,[saveDateTime]
  --         ,[saveIp]
  --         ,[fk_userSession_saveUserSessionId]
		--   ,[fk_this_templateOpId])
		--   select 
		--   [fk_store_id]
  --         ,[fk_item_id]
  --         ,[isActive]
  --         ,[title]
  --         ,[resultIsPublic]
  --         ,[fk_document_picId]
  --         ,[startDateTime]
  --         ,[endDateTime]
  --         ,[publish]
  --         ,[itemGrpTitle]
  --         ,[saveDateTime]
  --         ,[saveIp]
  --         ,[fk_userSession_saveUserSessionId]
		--   ,[fk_this_templateOpId] from #tmp;




		--    INSERT INTO [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS]
  --         ([title]
  --         ,[fk_opinionpoll_id]
  --         ,[isActive]
  --         ,[orderingNo])
  --   select
	 --ops.title
	 --,t.id

	 --from TB_STORE_ITEM_OPINIONPOLL_OPTIONS as ops
	 --join #tmp as t on ops.fk_opinionpoll_id = @srcOpinionPollId



success:
--commit tran t1;
SET @rCode = 1;
SET @rMsg = 'success.';
RETURN 0;
fail:
--ROLLBACK TRAN t1;
SET @rCode = 0;
RETURN 0;


