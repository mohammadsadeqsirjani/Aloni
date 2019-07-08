CREATE PROCEDURE [dbo].[SP_getAllDocumentListAboutStore]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100) = NULL,
	@parent as varchar(20) = null,
	@storeId as bigint,
	@justStore as bit = 0
AS
		SET NOCOUNT ON;
		if(@justStore = 0) 
		begin
		with result
		as
		(
		 select distinct doc.id,doc.completeLink ImageUrl,doc.thumbcompeleteLink thumbImageUrl,doc.fk_documentType_id,caption,creationDate,dstr.isDefault from TB_DOCUMENT as doc with (nolock)
		 inner join TB_DOCUMENT_STORE as dstr with (nolock) on doc.id = dstr.pk_fk_document_id
		 where 
			  dstr.pk_fk_store_id = @storeId
			  and
			  doc.isDeleted <> 1
			   and
			  doc.fk_documentType_id = 3
		 union all
		select distinct
		 doc.id,doc.completeLink ImageUrl,doc.thumbcompeleteLink thumbImageUrl,doc.fk_documentType_id,caption,creationDate,DI.isDefault from TB_DOCUMENT as doc with (nolock)
		 inner join TB_DOCUMENT_ITEM as DI with(nolock) on doc.id = DI.pk_fk_document_id
		 inner join TB_STORE_ITEM_QTY as SIQ with(nolock) on DI.pk_fk_item_id = SIQ.pk_fk_item_id and SIQ.pk_fk_store_id = @storeId
		where 
			  doc.isDeleted <> 1
			  and
			  doc.fk_documentType_id = 2
		)
		select  id,ImageUrl,thumbImageUrl,fk_documentType_id,isDefault from result
		where
	     caption like case when @search is not null and @search <> '' then '%'+@search+'%' else caption end
		ORDER BY creationDate desc
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
	   end
		else
		begin
			
		 select doc.id,doc.completeLink ImageUrl,doc.thumbcompeleteLink thumbImageUrl,doc.fk_documentType_id,dstr.isDefault from TB_DOCUMENT as doc with (nolock)
		 inner join TB_DOCUMENT_STORE as dstr with (nolock) on doc.id = dstr.pk_fk_document_id
		 where 
			  dstr.pk_fk_store_id = @storeId
			  and
			  doc.isDeleted <> 1
			   and
			  doc.fk_documentType_id = 3
		
		ORDER BY creationDate desc
		OFFSET (@pageNo * 10 ) ROWS
		FETCH NEXT 10 ROWS ONLY;
		end
	
RETURN 0