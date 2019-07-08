CREATE PROCEDURE [dbo].[SP_addConvertFileLog]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@grpId as bigint,
	@totalRecord as int,
	@file as nvarchar(350),
	@id as bigint out

AS
	set nocount on
	begin try
		insert into tb_store_convert_file_log(fk_store_id, fk_groupId, totalRecord,document) values(@storeId,@grpId,@totalRecord,@file)
		set @id = SCOPE_IDENTITY()
			set @rCode = 1;
			return 0
		end try
		begin catch
			set @rMsg = dbo.func_getSysMsg('',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE());
			set @rCode = 0
			rollback transaction T
			return 0
		end catch
	
RETURN 0
