CREATE PROCEDURE [dbo].[SP_deleteCustomeCategory]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@customcategoryId as bigint,
	@itemId as bigint = null
	
AS
	begin try
	if(@itemId is not null and @itemId > 0)
	begin
		delete from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @customcategoryId and pk_fk_item_id = @itemId
	end
	else
	begin
		delete from TB_STORE_CUSTOMCATEGORY_ITEM where pk_fk_custom_category_id = @customcategoryId
		delete from TB_STORE_CUSTOM_CATEGORY where id = @customcategoryId
	end
		if(@@ROWCOUNT > 0)
		begin
			set @rCode = 1
			set @rMsg = 'success'
		end
	end try
	begin catch
		set @rCode = 0
		set @rMsg = ERROR_MESSAGE()
	end catch
RETURN 0
