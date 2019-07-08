CREATE PROCEDURE [dbo].[SP_voteToComment]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@evalId as bigint,
	@like as bit,
	@disLike as bit,
	@count as bigint out
	
AS
	if((select fk_store_id from TB_STORE_EVALUATION where id = @evalId) <> @storeId)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'نظر مربوط به پنل شما نیست'); 
		set @rCode = 0
		return
	end
	if(not exists(select top 1 1 from TB_STORE_EVALUATION where id = @evalId))
	BEGIN
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'هیچ نظری با شناسه مذکور یافت نشد'); 
		set @rCode = 0
		return
	END
	if((@like is null and @disLike is null) or (@like = 1 and @disLike = 1) or (@like = 0 and @disLike = 0))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'تایید و عدم تایید دارای مقدار معتبر  نمی باشند'); 
		set @rCode = 0
		return
	end
	begin try
		if(exists(select top 1 1 from TB_STORE_EVALUATION_VOTE where fk_store_evaluation_id = @evalId and fk_usr_voteUsrId = @userId))
		begin
			update TB_STORE_EVALUATION_VOTE set [like] = @like,dislike = @disLike where fk_store_evaluation_id = @evalId and fk_usr_voteUsrId = @userId
		end
		else
		begin
			insert TB_STORE_EVALUATION_VOTE(fk_usr_voteUsrId,fk_store_evaluation_id,[like],dislike) values(@userId,@evalId,@like,@disLike)
		end
		set @rMsg = case when @like = 1 then 'likeCount' else 'disLikecount' end
		set @count = case when @like = 1 then (select count([like]) from TB_STORE_EVALUATION_VOTE where fk_store_evaluation_id = @evalId and [like] = 1 ) else (select count(dislike) from TB_STORE_EVALUATION_VOTE where fk_store_evaluation_id = @evalId and dislike = 1 ) end
		set @rCode = 1
	end try
	begin catch
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE()); 
		set @rCode = 0
	end catch
	
RETURN 0
