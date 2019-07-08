CREATE PROCEDURE [dbo].[SP_defineFamily]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@mobile as varchar(50),
	@title as nvarchar(150),
	@id as bigint out
AS
	if(not exists(select id from TB_USR where mobile = @mobile))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'کاربر یافت نشد')
		return
	end
	if(@title is null)
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'عنوان نباید خالی باشد')
		return
	end
	declare @usrAsFamily as bigint = (select id from TB_USR where mobile = @mobile)
	
	if(exists(select id from TB_USR_FAMILY where ((fk_usr_id = @usrAsFamily and fk_usr_requester_usr_id = @userId) or(fk_usr_id = @userId and fk_usr_requester_usr_id = @usrAsFamily) ) and fk_status_id in(45,46)))
	begin
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,'قبلا درخواست عضویت صادر شده است.')
		return
	end
	begin try
		insert into TB_USR_FAMILY(fk_usr_id,fk_usr_requester_usr_id,fk_status_id,title,reqTitle) values(@usrAsFamily,@userId,45,@title,NULL)
		set @rCode = 1
		set @rMsg = 'success'
		set @id = SCOPE_IDENTITY()
	end try
	begin catch
		set @rCode = 0
		set @rMsg = dbo.func_getSysMsg('errore',OBJECT_NAME(@@procId),@clientLanguage,ERROR_MESSAGE())
	end catch
RETURN 0
