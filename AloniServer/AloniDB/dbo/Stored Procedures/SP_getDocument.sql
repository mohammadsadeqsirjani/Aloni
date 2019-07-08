CREATE PROCEDURE [dbo].[SP_getDocument]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null,
	@fk_EntityId as bigint,
	@fk_TypeId as int,
	@storeId as bigint
AS
	SET NOCOUNT ON
	set @pageNo = isnull(@pageNo,0)
	if(@fk_EntityId = 0)
	begin
		select doc.id,doc.completeLink ImageUrl,doc.thumbcompeleteLink thumbImageUrl,0 isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) 
		where  doc.isDeleted <> 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = @fk_TypeId and fk_usr_saveUserId in (select fk_usr_id from TB_USR_STAFF where fk_store_id = @storeId and fk_staff_id in(11,12,13,14))
		ORDER BY doc.creationDate desc
		OFFSET (@pageNo * 15 ) ROWS
		FETCH NEXT 15 ROWS ONLY;
		return
	end
	if(@fk_TypeId = 1 or @fk_TypeId = 3)
	begin
		select doc.id,doc.completeLink ImageUrl,doc.thumbcompeleteLink thumbImageUrl,dstr.isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) inner join TB_DOCUMENT_STORE as dstr with (nolock) on doc.id = dstr.pk_fk_document_id
		where dstr.pk_fk_store_id = @fk_EntityId and doc.isDeleted <> 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = @fk_TypeId and fk_usr_saveUserId in (select fk_usr_id from TB_USR_STAFF where fk_store_id = @storeId and fk_staff_id in(11,12,13,14))
		ORDER BY doc.creationDate desc
		OFFSET (@pageNo * 15 ) ROWS
		FETCH NEXT 15 ROWS ONLY;
	end
	else if(@fk_TypeId = 2)
		begin
			select doc.id, doc.completeLink ImageUrl,doc.thumbcompeleteLink thumbImageUrl,ditm.isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) inner join TB_DOCUMENT_ITEM as ditm with (nolock) on doc.id = ditm.pk_fk_document_id
			where ditm.pk_fk_item_id = @fk_EntityId and doc.isDeleted <> 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = @fk_TypeId-- and fk_usr_saveUserId in (select fk_usr_id from TB_USR_STAFF where fk_store_id = @storeId and fk_staff_id in(11,12,13,14))
			ORDER BY doc.creationDate desc
			OFFSET (@pageNo * 15 ) ROWS
			FETCH NEXT 15 ROWS ONLY;
		end
	else if(@fk_TypeId = 4)
		begin
			select doc.id, doc.completeLink as ImageUrl,doc.thumbcompeleteLink thumbImageUrl,dusr.isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) inner join TB_DOCUMENT_USR as dusr with (nolock) on doc.id = dusr.pk_fk_document_id
			where dusr.pk_fk_usr_id = @fk_EntityId and doc.isDeleted <> 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = @fk_TypeId and fk_usr_saveUserId in (select fk_usr_id from TB_USR_STAFF where fk_store_id = @storeId and fk_staff_id in(11,12,13,14))
			ORDER BY doc.creationDate desc
			OFFSET (@pageNo * 15 ) ROWS
			FETCH NEXT 15 ROWS ONLY;
		end
	else if(@fk_TypeId = 5)
		begin
			select doc.id, doc.completeLink as ImageUrl,doc.thumbcompeleteLink thumbImageUrl, isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) inner join TB_DOCUMENT_STORE as s with (nolock) on doc.id = s.pk_fk_document_id
			where s.pk_fk_store_id = @fk_EntityId and doc.isDeleted <> 1 and isDefault = 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = @fk_TypeId 
			ORDER BY doc.creationDate desc
			OFFSET (@pageNo * 15 ) ROWS
			FETCH NEXT 15 ROWS ONLY;
		end
	else if(@fk_TypeId = 7)
		begin
			select doc.id, doc.completeLink as ImageUrl,doc.thumbcompeleteLink thumbImageUrl,1 isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) inner join TB_TYP_ITEM_GRP as tyg with (nolock) on doc.id = tyg.fk_document_id
			where tyg.id = @fk_EntityId and doc.isDeleted <> 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = @fk_TypeId and fk_usr_saveUserId in (select fk_usr_id from TB_USR_STAFF where fk_store_id = @storeId and fk_staff_id in(11,12,13,14))
			ORDER BY doc.creationDate desc
			OFFSET (@pageNo * 15 ) ROWS
			FETCH NEXT 15 ROWS ONLY;
		end
	else if(@fk_TypeId = 9)
		begin
			select doc.id, doc.completeLink as ImageUrl,doc.thumbcompeleteLink thumbImageUrl,1 isDefault,fk_documentType_id from TB_DOCUMENT as doc with (nolock) inner join TB_DOCUMENT_STORE_VITRIN as V with (nolock) on doc.id = V.pk_fk_document_id
			where V.pk_fk_vitrin_id = @fk_EntityId and doc.isDeleted <> 1 and  (caption like '%'+@search+'%' or @search is null) and fk_documentType_id = @fk_TypeId and fk_usr_saveUserId in (select fk_usr_id from TB_USR_STAFF where fk_store_id = @storeId and fk_staff_id in(11,12,13,14))
			ORDER BY doc.creationDate desc
			OFFSET (@pageNo * 15 ) ROWS
			FETCH NEXT 15 ROWS ONLY;
		end
RETURN 0

