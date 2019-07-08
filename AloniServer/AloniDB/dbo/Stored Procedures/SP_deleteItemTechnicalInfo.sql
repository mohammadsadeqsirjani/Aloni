CREATE PROCEDURE [dbo].[SP_deleteItemTechnicalInfo]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@itemId as bigint,
	@TechnicalInfoItem as [dbo].[TechnicalInfoItemType] readonly
AS
begin try 
	-- delete technical info
	  if((select isTemplate from TB_ITEM where id = @itemId) = 1)
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'شما قادر به حذف مشخصه فنی  کالای پیشفرض نیستید!')
			return
		end
	  delete from TB_ITEM_TECHNICALINFO where pk_fk_item_id = @itemId and pk_fk_technicalInfo_id in( select technicalInfoId from @TechnicalInfoItem)
	    set @rCode = 1
		   set @rMsg = 'success'
	end try
	begin catch
			set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
			set @rCode = 0
	end catch	
RETURN 0