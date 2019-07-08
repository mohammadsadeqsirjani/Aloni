CREATE PROCEDURE [dbo].[SP_storeAdd]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@rCode as tinyint out,
	@rMsg as nvarchar(max) out,
	@title as nvarchar(150),
	@title_second as nvarchar(150),
	@store_typeId as int,
	@expertise as dbo.ExpertiseTableType readonly,
	@description as nvarchar(max),
	@keyword as nvarchar(max) = null,
	@id_str as varchar(50),
	@storeId as bigint out,
	@categoryId as int = NULL ,
	@ordersNeedConfimBeforePayment as bit,
	@onlyCustomersAreAbleToSetOrder as bit,
	@onlyCustomersAreAbleToSeeItems as bit,
	@customerJoinNeedsConfirm as bit,
	@storePersonalityType as int = null,
	@storeItemGrpPanelCategories as [dbo].[LongIdTitleType] readonly,
	@uid as uniqueidentifier = null
AS
	begin transaction T
	set nocount on
	declare @statusId int = 11
	if(dbo.func_GetUserStaffStore(@userId,@storeId) <> 11)
		begin
			set @rCode = 0
			set @rMsg = 'این عملیات برای شما مجاز نیست'
			return
		end
	-- check validation
	if(@title is null and (@storeId is null or @storeId = 0))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,'وارد کردن عنوان پنل الزامی است'); 
		goto fail;
	end
	if(@title like '%آلونی%' or @title like '%الونی%')
	begin
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,'عنوان فروشگاه نباید شامل کلمه آلونی باشد'); 
		goto fail;
	end
	if(@store_typeId is null )
	begin
		set @rMsg =dbo.func_getSysMsg('invalid store typeId',OBJECT_NAME(@@PROCID),@clientLanguage,'نوع پنل مشخص نشده شده است'); 
		goto fail;
	end

	if(@description is null and (@storeId is null or @storeId = 0))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid description',OBJECT_NAME(@@PROCID),@clientLanguage,'وارد کردن درباره پنل الزامی است'); 
		goto fail;
	end
	if(LEN(LTRIM(RTRIM(@title))) < 3)
	begin
		set @rMsg = dbo.func_getSysMsg('invalid title',OBJECT_NAME(@@PROCID),@clientLanguage,'عنوان پنل نمی تواند کمتر از 3 کاراکتر باشد');
		goto fail;
	end
	if(exists(select top 1 * from TB_STORE where id_str = @id_str and (id <> @storeId or @storeId is null or @storeId = 0)))
	begin
		set @rMsg = dbo.func_getSysMsg('invalid unique id',OBJECT_NAME(@@PROCID),@clientLanguage,'شناسه یکتای پنا تکراری می باشد');
		goto fail;
	end
	declare @title_secondCount int = (select count(id) from TB_STORE with(nolock)) + 1
	if(@id_str is not null and ( select count(id) from TB_STORE with(nolock) where title_second = @title_second) > 0)
	begin
		set @title_second += ' _ '+ cast(@title_secondCount as nvarchar(10))
	end

	begin try
		
		if(@storeId is null or @storeId = 0)
		begin
			insert into TB_STORE(title,title_second,fk_store_type_id,fk_store_category_id,[description],keyWords,fk_status_id,id_str,customerJoinNeedsConfirm,onlyCustomersAreAbleToSeeItems,onlyCustomersAreAbleToSetOrder,ordersNeedConfimBeforePayment,fk_storePersonalityType_id)
						 values(@title,@title_second,@store_typeId,@categoryId,@description,@keyword,@statusId,@id_str,@customerJoinNeedsConfirm,@onlyCustomersAreAbleToSeeItems,@onlyCustomersAreAbleToSetOrder,@ordersNeedConfimBeforePayment,@storePersonalityType)
			set @storeId = SCOPE_IDENTITY()
			insert into TB_STORE_EXPERTISE(pk_fk_store_id,pk_fk_expertise_id) select @storeId,ExpertiseId from @expertise
			insert into TB_STORE_ITEMGRP_PANEL_CATEGORY (pk_fk_store_id,pk_fk_itemGrp_id) select distinct @storeId,id from @storeItemGrpPanelCategories where id not in(select pk_fk_itemGrp_id from TB_STORE_ITEMGRP_PANEL_CATEGORY where  pk_fk_store_id = @storeId)
			--insert into TB_STORE_ITEMGRP_ITEMGRP_AND_SERVICES(pk_fk_store_id,pk_fk_itemGrp_id) select @storeId,id from @storeItemGrpItemGrpAndServices
			insert into TB_USR_STAFF (fk_usr_id,fk_staff_id,fk_store_id,fk_status_id) values (@userId,11,@storeId,8)

			if(@uid is not null and exists(select top 1 1 from TB_DOCUMENT where id = @uid))
			begin
				
				insert into TB_DOCUMENT_STORE(pk_fk_document_id,pk_fk_store_id,isDefault) values(@uid,@storeId,1)
			end

			INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNT]
           ([fk_typFinancialAccountType_id]
           ,[fk_usr_userId]
           ,[fk_store_id]
           ,[fk_status_id]
           ,[title]
           ,[fk_currency_id])
     VALUES
           (1
           ,NULL
           ,@storeId
           ,36
           ,dbo.func_stringFormat_1('حساب اصلی (جاری) پنل {0}',@title)
           ,null);

		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNT]
           ([fk_typFinancialAccountType_id]
           ,[fk_usr_userId]
           ,[fk_store_id]
           ,[fk_status_id]
           ,[title]
           ,[fk_currency_id])
     VALUES
           (2
           ,NULL
           ,@storeId
           ,36
           ,dbo.func_stringFormat_1('حساب راکد (پرداخت امن) پنل {0}',@title)
           ,null);

		   INSERT INTO [dbo].[TB_FINANCIAL_ACCOUNT]
           ([fk_typFinancialAccountType_id]
           ,[fk_usr_userId]
           ,[fk_store_id]
           ,[fk_status_id]
           ,[title]
           ,[fk_currency_id])
     VALUES
           (3
           ,NULL
           ,@storeId
           ,36
           ,dbo.func_stringFormat_1('حساب پروموشن پنل {0}',@title)
           ,null);
		    

			set @rCode = 1;
			set @rMsg = 'success'
			commit transaction T
			return 0;
		end
		else
		begin
			update TB_STORE
			SET 
			title = ISNULL(@title,title),
			title_second = ISNULL(@title_second,title_second),
			fk_store_type_id = case when  @store_typeId is null or @store_typeId = 0 then fk_store_type_id else @store_typeId END,
			--fk_store_category_id = @categoryId,
			[description] =ISNULL(@description,[description]),
			keyWords =ISNULL(@keyword,keyWords),
		--	fk_status_id =case when fk_status_id > @statusId then fk_status_id else @statusId end,
			id_str =ISNULL(@id_str,id_str),
			customerJoinNeedsConfirm = @customerJoinNeedsConfirm,
			onlyCustomersAreAbleToSeeItems = @onlyCustomersAreAbleToSeeItems,
			onlyCustomersAreAbleToSetOrder = @onlyCustomersAreAbleToSetOrder,
			ordersNeedConfimBeforePayment = @ordersNeedConfimBeforePayment,
			fk_storePersonalityType_id = case when  @storePersonalityType is null or @storePersonalityType = 0 then fk_storePersonalityType_id else @storePersonalityType END
			Where
				id = @storeId

			if((select COUNT(*) from @expertise) > 0)
			begin
				delete from TB_STORE_EXPERTISE where pk_fk_store_id = @storeId
				insert into TB_STORE_EXPERTISE(pk_fk_store_id,pk_fk_expertise_id) select @storeId,ExpertiseId from @expertise
			end
			if((select COUNT(*) from @storeItemGrpPanelCategories) > 0)
			begin
				delete from TB_STORE_ITEMGRP_PANEL_CATEGORY where pk_fk_store_id = @storeId
				insert into TB_STORE_ITEMGRP_PANEL_CATEGORY (pk_fk_store_id,pk_fk_itemGrp_id) select @storeId,id from @storeItemGrpPanelCategories
			END
			if(@uid is not null and exists(select top 1 1 from TB_DOCUMENT where id = @uid) and not exists(select pk_fk_document_id from TB_DOCUMENT_STORE where pk_fk_store_id = @storeId and pk_fk_document_id = @uid))
			begin
				update TB_DOCUMENT_STORE set isDefault = 0 where pk_fk_document_id in(select id from TB_DOCUMENT where fk_documentType_id = 5) and pk_fk_store_id = @storeId
				insert into TB_DOCUMENT_STORE(pk_fk_document_id,pk_fk_store_id,isDefault) values(@uid,@storeId,1)
			end
			-- برای اولین بار قوانین و مقررات اکسپت شوند
			declare @version money
			select @version = max(pk_version) from TB_TERMS_AND_CONDITIONS TC with(nolock) where pk_fk_app_id = 1 and isActive = 1 and TC.pk_version not in(select pk_version from TB_TERMS_AND_CONDITIONS_ACCEPT where pk_fk_app_id = 1 and fk_user_id = @userId)
			if(@version > 0)
			begin
				insert into TB_TERMS_AND_CONDITIONS_ACCEPT(pk_fk_app_id,pk_fk_version,fk_user_id,fk_store_id) select @appId,@version,@userId,@storeId
			end
			set @rCode = 1;
			set @rMsg = 'success'
			commit transaction T
			return 0;
		end
	end try
	begin catch
	    
		set @rMsg = dbo.func_getSysMsg('error',OBJECT_NAME(@@PROCID),@clientLanguage,ERROR_MESSAGE());
		goto fail;
	end catch
	
	fail:
		set @rCode = 0;
		rollback transaction T
		return 0;

RETURN 0
