CREATE PROCEDURE [dbo].[SP_addItemTechnicalInfo]
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
	   if((select isTemplate from TB_ITEM where id = @itemId) = 1)
		begin
			set @rCode = 0
			set @rMsg = dbo.func_getSysMsg('invalid action',OBJECT_NAME(@@PROCID),@clientLanguage,'شما قادر به اختصاص مشخصه فنی به کالای پیشفرض نیستید!')
			return
		end
		if(exists (select pk_fk_technicalInfo_id from TB_ITEM_TECHNICALINFO where pk_fk_item_id = @itemId and pk_fk_technicalInfo_id in(select childTechnicalInfoId from @TechnicalInfoItem)))
		begin
			
			update TB_ITEM_TECHNICALINFO set fk_technicalInfoValues_tblValue =case when t.technicalTableValueId = 0 then I.fk_technicalInfoValues_tblValue else t.technicalTableValueId END,strValue = NULL,isPublic = T.isPublic from @TechnicalInfoItem T join TB_ITEM_TECHNICALINFO I on T.childTechnicalInfoId = I.pk_fk_technicalInfo_id and I.pk_fk_item_id = @itemId where T.[type] = 4
			update TB_ITEM_TECHNICALINFO set strValue = T.strValue,fk_technicalInfoValues_tblValue = NULL,isPublic = T.isPublic from @TechnicalInfoItem T join TB_ITEM_TECHNICALINFO I on T.childTechnicalInfoId = I.pk_fk_technicalInfo_id and I.pk_fk_item_id = @itemId where T.[type] <> 4
		end
		else
		begin
			insert into TB_ITEM_TECHNICALINFO(pk_fk_item_id,pk_fk_technicalInfo_id,fk_technicalInfoValues_tblValue,isPublic) select @itemId,childTechnicalInfoId,case when technicalTableValueId = 0 then NULL else technicalTableValueId END,isPublic from @TechnicalInfoItem where [type] = 4
			insert into TB_ITEM_TECHNICALINFO(pk_fk_item_id,pk_fk_technicalInfo_id,strValue,isPublic) select @itemId,childTechnicalInfoId,t.strValue,isPublic from @TechnicalInfoItem T where [type] <> 4
		end
	    set @rCode = 1
		if(@@ROWCOUNT > 0)
		begin
		   set @rMsg = 'success'
		end
		else
		begin
			set @rMsg = 'هیچ رکوردی تحت تاثیر قرار نگرفت'
		end
	end try
	begin catch
			set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
			set @rCode = 0
	end catch	
RETURN 0