CREATE PROCEDURE [dbo].[SP_updatePanelCommentSetting]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@storeId as bigint,
	@itemEvaluationShowName as bit, 
	@itemEvaluationNeedConfirm as bit
    AS
	set nocount on
	
		begin try
				
				update TB_STORE set itemEvaluationShowName =ISNULL(@itemEvaluationShowName,itemEvaluationShowName),itemEvaluationNeedConfirm =ISNULL(@itemEvaluationNeedConfirm,itemEvaluationNeedConfirm) where id = @storeId
				set @rCode = 1
				return 
		end try
		begin catch
				set @rMsg = dbo.func_getSysMsg('Error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE())
				goto faild
		end catch
		faild:
				rollback transaction T
				set @rCode = 0
				return 0
	
	
RETURN 0

