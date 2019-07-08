CREATE PROCEDURE [dbo].[SP_PT_updateUser]
	@clientLanguage as char(2),
	@appId AS TINYINT,
	@clientIp AS VARCHAR(50),
	@userId AS bigint,
	@fname As varchar(50),
	@mobile AS varchar(20),
	@email AS varchar(50),
	@fk_country_id AS int,
	@fk_city_id AS int,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out
AS

		if(@userId IS NULL)
		begin
		set @rMsg = dbo.func_getSysMsg('dontExistUser',OBJECT_NAME(@@PROCID),@clientLanguage,'کاربر ایجاد نشده است.');
		goto fail;
		end

		if(@fname IS NULL)
		begin
		set @rMsg = dbo.func_getSysMsg('EmptyField',OBJECT_NAME(@@PROCID),@clientLanguage,'نام و نام خانوادگی نمی تواند خالی باشد');
		goto fail;
		end

	    if(@mobile IS NULL)
		begin
		set @rMsg = dbo.func_getSysMsg('EmptyField',OBJECT_NAME(@@PROCID),@clientLanguage,'شماره همراه نمی تواند خالی باشد');
		goto fail;
		end

		begin try
		update TB_USR
		set fname = ISNULL(@fname,fname),
		    mobile = ISNULL(@mobile,mobile),
			email = @email,
			fk_country_id = @fk_country_id,
			fk_cityId = @fk_city_id
			where id = @userId
		end try
		begin catch
		set @rMsg = ERROR_MESSAGE();
		goto fail;
		end catch

			success:
			set @rCode = 1;
			set @rMsg = 'اطلاعات کاربر با موفقیت بروزرسانی شد'; --dbo.func_getSysMsg('success',OBJECT_NAME(@@PROCID),@clientLanguage,'the validation code sent.');
			return 0;
			fail:
			set @rCode = 0;
			--set @rMsg = 'fail!';
			return 0;
RETURN 0
