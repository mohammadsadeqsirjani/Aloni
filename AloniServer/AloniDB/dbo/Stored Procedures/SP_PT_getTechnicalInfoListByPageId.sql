-- =============================================
-- Author:		saeed m khorsand
-- Create date: 1396 10 13
-- =============================================
CREATE PROCEDURE [dbo].[SP_PT_getTechnicalInfoListByPageId]
	@clientLanguage as char(2) = 'fa',
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@pageId as smallint
AS
BEGIN
	SET NOCOUNT ON;

select distinct TI.id , 
ISNULL(TIT.title , TI.title) title,
isNULL(
case
	TI.type
	when 1 then 'حرفی'
	when 2 then 'عددی'
	when 3 then 'انتخابی'
	when 4 then 'جدولی'
	when 5 then 'سرفصل'
	else null
end , 
case
	TIT_fkRefR.type
	when 1 then 'حرفی'
	when 2 then 'عددی'
	when 3 then 'انتخابی'
	when 4 then 'جدولی'
	when 5 then 'سرفصل'
	else ''
end)


[type] , 
ISNULL(TITB.title ,  ISNULL(TIT_fkRefTbl.title , '') ) table_title,
ISNULL(TIT_fkRef.title , '' ) fk_ref_title ,
ISNULL(TI.[order] , TIT_fkRefR.[order]) as [order] ,
ISNULL(TI.type , TIT_fkRefR.type)  type_id

from TB_TECHNICALINFO_PAGE TIP
inner join TB_TYP_TECHNICALINFO TI
on TIP.Id = TI.fk_technicalinfo_page_id
left join TB_TYP_TECHNICALINFO_TRANSLATIONS TIT
on TIT.id = TI.id and TIT.lan = 'fa'
left join TB_TECHNICALINFO_TABLE TITB
on TI.fk_technicalinfo_table_id = TITB.id
left join TB_TYP_TECHNICALINFO_TRANSLATIONS TIT_fkRef
on TI.fk_ref = TIT_fkRef.id and TIT_fkRef.lan='fa'
left join TB_TYP_TECHNICALINFO TIT_fkRefR
on TI.fk_ref = TIT_fkRefR.id
left join TB_TECHNICALINFO_TABLE TIT_fkRefTbl
on TIT_fkRefR.fk_technicalinfo_table_id = TIT_fkRefTbl.id
where TIP.Id = @pageId
--order by TI.[order]

END