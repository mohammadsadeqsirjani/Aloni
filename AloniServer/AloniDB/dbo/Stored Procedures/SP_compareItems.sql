CREATE PROCEDURE [dbo].[SP_compareItems]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100)=null,
	@parent as varchar(20) = null ,
	@userId as bigint,
	@items as [dbo].[LongType] readonly
AS
BEGIN
	SET NOCOUNT ON;
	declare @itemId1 as bigint = (select top 1 id from @items order by id asc)
	declare @itemId2 as bigint = (select top 1 id from @items order by id desc)
;with technicalItems
as
(
select IT.pk_fk_technicalInfo_id from

	TB_ITEM_TECHNICALINFO IT inner join TB_ITEM_TECHNICALINFO IT1 on IT.pk_fk_technicalInfo_id = IT1.pk_fk_technicalInfo_id

where it.pk_fk_item_id  = @itemId1 and IT1.pk_fk_item_id = @itemId2
)

select * into #temp from technicalItems

select id itemId from @items

select iti.pk_fk_item_id itemId, TI2.id , TI2.title , TI3.id c_id  ,TI3.title c_title ,
	 TI3.[type] c_type , TI3.fk_technicalinfo_table_id c_fk_technicalinfo_table_id 
	 ,ITI.fk_technicalInfoValues_tblValue , TIV.val fk_technicalInfoValues_tblValue_dsc  , ITI.strValue
	from
	 TB_TYP_TECHNICALINFO TI1
	inner join TB_TYP_TECHNICALINFO TI2
	on TI1.fk_technicalinfo_page_id in ( select fk_technicalinfo_page_id from TB_TYP_TECHNICALINFO where id in(select pk_fk_technicalInfo_id from #temp) ) and TI1.fk_ref = TI2.id 
	inner join TB_TYP_TECHNICALINFO TI3
	on TI3.id = TI1.id
	inner join TB_ITEM_TECHNICALINFO ITI
	on TI3.id = ITI.pk_fk_technicalInfo_id and ITI.pk_fk_technicalInfo_id in(select pk_fk_technicalInfo_id from #temp) and ITI.pk_fk_item_id in(@itemId1,@itemId2)
	inner join TB_TECHNICALINFO_VALUES TIV
	on TIV.id = ITI.fk_technicalInfoValues_tblValue
	order by TI1.[order] , TI2.[order]

END
RETURN 0
