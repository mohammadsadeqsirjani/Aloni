CREATE PROCEDURE [dbo].[SP_LP_addContactUs]
    @clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@subject as varchar(50),
	@mobile as varchar(50),
	@email as varchar(20),
	@message as text,
	--@answer as text,
	@saveIp as varchar(50),
	--@fk_usr_answeredId as bigint,
	@fk_deprtmentTypeId as int,
	@trackingCode as varchar(6) out,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS
		set nocount on

	if(@subject is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid subject',OBJECT_NAME(@@PROCID),@clientLanguage,'عنوان نمی تواند خالی باشد'); 
		goto fail;
	end
		if(@mobile is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid mobile',OBJECT_NAME(@@PROCID),@clientLanguage,'شماره همراه نمی تواند خالی باشد'); 
		goto fail;
	end
		if(@message is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid message',OBJECT_NAME(@@PROCID),@clientLanguage,'پیام نمی تواند خالی باشد'); 
		goto fail;
	end
		if(@fk_deprtmentTypeId is null)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid fk_deprtmentTypeId',OBJECT_NAME(@@PROCID),@clientLanguage,'بخش نمی تواند خالی باشد'); 
		goto fail;
	end

	  begin try
		set @trackingCode = (select (dbo.func_RandomString(6,1)));
		
		insert into TB_CONTACTUS (subject,mobile,email,message,trackingCode,saveDateTime,saveIp,fk_deprtmentTypeId)
		                  values (@subject,@mobile,@email,@message,@trackingCode,GETDATE(),@saveIp,@fk_deprtmentTypeId)
	
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
