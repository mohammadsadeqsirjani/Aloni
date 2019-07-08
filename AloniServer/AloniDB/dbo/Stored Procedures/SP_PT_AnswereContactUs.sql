CREATE PROCEDURE [dbo].[SP_PT_AnswereContactUs]
    @clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@id as bigint,
	@answer as text,
	@fk_usr_answeredId as bigint,

	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
			set nocount on

	if(@id is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid id',OBJECT_NAME(@@PROCID),@clientLanguage,'رکورد مورد نظر پیدا نشد'); 
		goto fail;
	end
		if(@answer is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid answer',OBJECT_NAME(@@PROCID),@clientLanguage,'پاسخ نمی تواند خالی باشد'); 
		goto fail;
	end
			if(@fk_usr_answeredId is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid fk_usr_answeredId',OBJECT_NAME(@@PROCID),@clientLanguage,'کاربر پاسخ دهنده نمی تواند خالی باشد'); 
		goto fail;
	end

	  begin try		
	       update TB_CONTACTUS 
		   set answer = @answer,
		       fk_usr_answeredId = @fk_usr_answeredId,
			   answerDateTime = GETDATE()
		  where id = @id

			set @rCode = 1;

			return 0
		end try
		begin catch
			set @rMsg = dbo.func_getSysMsg('',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE());
			set @rCode = 0
			return 0
		end catch
		fail:
		set @rCode = 0;

		return 0;
RETURN 0
