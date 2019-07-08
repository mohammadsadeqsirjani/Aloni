CREATE PROCEDURE [dbo].[SP_sendSMS]
	 @userId as bigint
	,@countryId as int
	,@mobile VARCHAR(20)
	,@SYSTEMMESSAGE_msgKey VARCHAR (50)
	,@SYSTEMMESSAGE_objectName VARCHAR (60)
	,@SYSTEMMESSAGE_lan char(2)
	,@customMsgBody as varchar(max) = ''
	,@arg1 AS NVARCHAR(max) = ''
	,@arg2 AS NVARCHAR(max) = ''
	,@arg3 AS NVARCHAR(max) = ''
	,@arg4 AS NVARCHAR(max) = ''
	,@arg5 AS NVARCHAR(max) = ''
	,@arg6 AS NVARCHAR(max) = ''
	,@arg7 AS NVARCHAR(max) = ''
	,@arg8 AS NVARCHAR(max) = ''
	,@rCode as tinyint out
	,@rMsg as nvarchar(max) out
AS
	 

	 if(@SYSTEMMESSAGE_msgKey is not null)
	 begin
	 set @customMsgBody = null;
	 select @customMsgBody = body
	 from TB_SYSTEMMESSAGE with (nolock)
	 where 
	 msgKey = @SYSTEMMESSAGE_msgKey
	 and
	 objectName = @SYSTEMMESSAGE_objectName
	 and
	 lan = @SYSTEMMESSAGE_lan
	 and
	 isSms = 1;


	 end

	 if(@customMsgBody is null or @customMsgBody = '')
	 begin
	 set @rMsg = 'no body';
	 goto fail;
	 end


	 EXEC [dbo].[SP_stringFormat] @value = @customMsgBody
		,@arg1 = @arg1
		,@arg2 = @arg2
		,@arg3 = @arg3
		,@arg4 = @arg4
		,@arg5 = @arg5
		,@arg6 = @arg6
		,@arg7 = @arg7
		,@arg8 = @arg8
		,@result = @customMsgBody OUTPUT


		



		declare @smsPanel_id as int
		,@smsPanel_title as varchar(50)
		,@smsPanel_baseUrl as varchar(255)
		,@smsPanel_srcNo as varchar(50)
		,@smsPanel_userName as varchar(50)
		,@smsPanel_password as varchar(50)
		,@smsPanel_domain as varchar(50);

		declare @logSmsId as bigint,
		@trackingCode as varchar(50),
		@sendResult as varchar(max);
		

		select top(1) 
		 @smsPanel_id = id
		,@smsPanel_title = title
		,@smsPanel_baseUrl = baseUrl
		,@smsPanel_srcNo = srcNo
		,@smsPanel_userName = userName
		,@smsPanel_password = [password]
		,@smsPanel_domain = domain
		from
		TB_SMSPANEL with(nolock)
		where
		fk_country_id = @countryId
		and
		isActive = 1;


		insert into TB_LOG_SMS
		(dstNo,fk_smsPanel_id,fk_usr_userId,msgBody,sendTime,srcNo)
		values
		(@mobile,@smsPanel_id,@userId,@customMsgBody,GETDATE(),@smsPanel_srcNo);
		
		set @logSmsId = SCOPE_IDENTITY();
		

		if(@smsPanel_id is null)
		begin
		set @rMsg = 'no active sms panel found!';
		end
		if(@smsPanel_title = 'magfa_01')
		begin
		
		begin try
		  set @trackingCode = dbo.func_sendSms(@smsPanel_baseUrl,@smsPanel_userName,@smsPanel_password,@smsPanel_domain,@customMsgBody,@smsPanel_srcNo,@mobile);
		  set @sendResult = 'success';
		  --goto success;
		end try
		begin catch
		set @sendResult = ERROR_MESSAGE();
		goto fail;
		end catch

		update TB_LOG_SMS
		set trackingCode = @trackingCode,result = @sendResult,fk_smsPanel_id = @smsPanel_id
		where id = @logSmsId;

		end






	 success:
	 set @rCode = 1;
	 set @rMsg = 'success';
	 return 0;
	 fail:
	 set @rCode = 0;
	RETURN 0;