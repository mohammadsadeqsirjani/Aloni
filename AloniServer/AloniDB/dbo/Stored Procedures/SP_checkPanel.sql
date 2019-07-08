CREATE PROCEDURE [dbo].[SP_checkPanel]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int = 0,
	@search as nvarchar(100) = NULL,
	@parent as varchar(20) = null,
	@storeId as bigint
AS
SET NOCOUNT ON
declare @result as table(id int,title nvarchar(200))

if not exists(select top 1 1 from TB_ITEM where fk_savestore_id = @storeId and fk_status_id <> 16) or not exists(select top 1 1 from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId)
begin
	insert into @result select 1,'هیچ آیتمی در پنل ثبت نشده است'
end
if (select location from TB_STORE where id = @storeId) is null
begin
	insert into @result select 2,'موقعیت مکانی پنل ثبت نشده است'
end
if (select fk_status_shiftStatus from TB_STORE where id = @storeId) is null
begin
	insert into @result select 3,'ساعت فعالیت پنل مشخص نشده است'
end
if not exists(select top 1 1 from TB_DOCUMENT_STORE ds inner join TB_DOCUMENT d on ds.pk_fk_document_id = d.id where d.fk_documentType_id = 3 and ds.pk_fk_store_id = @storeId)
begin
	insert into @result select 4,'هیچ گواهینامه و مجوزی برای پنل تعریف نشده است'
end

select * from @result