CREATE PROCEDURE [dbo].[SP_getTechnicalInfoListAndValuesByItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null ,
	@userId as bigint,
	@item as bigint
AS
BEGIN
	SET NOCOUNT ON;
	declare @fromIndex int ,@toIndex int;
	IF ISNULL(@pageNo,0) > -1
	BEGIN
		set @fromIndex = (@pageNo * 10 )
		set @toIndex = 10
	END
	ELSE
	BEGIN
		set @fromIndex = 0
		set @toIndex = 1000
	END

declare @technicalInfoTempTable TABLE (  id  bigint,  title varchar ( max ) ,fk_ref bigint   ,[type] smallint  , fk_technicalinfo_table_id int , [order] smallint ,  fk_technicalinfo_page_id int )


insert into @technicalInfoTempTable
select 
TI.id , TI.title , TI.fk_ref , TI.type , TI.fk_technicalinfo_table_id , TI.[order] , TIP.fk_technicalinfo_page_id as parentPageId

from TB_ITEM I
inner join TB_TYP_ITEM_GRP IG
on I.fk_itemGrp_id = IG.id
inner join TB_TECHNICALINFO_PAGE TIP
on IG.fk_technicalinfo_page_id = TIP.Id
inner join TB_TYP_TECHNICALINFO TI
on TI.fk_technicalinfo_page_id = TIP.Id
where I.id = @item


IF EXISTS ( select * from @technicalInfoTempTable where fk_technicalinfo_page_id IS NOT NULL ) 
BEGIN

	select TI2.id , TI2.title , TI3.id c_id  ,TI3.title c_title ,
	 TI3.[type] c_type , TI3.fk_technicalinfo_table_id c_fk_technicalinfo_table_id 
	 ,ITI.fk_technicalInfoValues_tblValue ,ITI.isPublic, TIV.val fk_technicalInfoValues_tblValue_dsc  , ITI.strValue
	from TB_TYP_TECHNICALINFO TI1
	inner join TB_TYP_TECHNICALINFO TI2
	on TI1.fk_technicalinfo_page_id = ( select top 1 fk_technicalinfo_page_id from @technicalInfoTempTable ) and TI1.fk_ref = TI2.id 
	inner join TB_TYP_TECHNICALINFO TI3
	on TI3.id = TI1.id
	left join TB_ITEM_TECHNICALINFO ITI
	on TI3.id = ITI.pk_fk_technicalInfo_id and ITI.pk_fk_item_id = @item
	left join TB_TECHNICALINFO_VALUES TIV
	on TIV.id = ITI.fk_technicalInfoValues_tblValue
	where TI1.id NOT IN (select fk_ref from @technicalInfoTempTable)  and (@search is null or @search = '' or TI3.title like '%'+@search+'%' ) AND
									(((ITI.isPublic = 1 or ITI.isPublic is null) and @appId = 2) or @appId <> 2)
	order by TI1.[order] , TI2.[order]
	OFFSET @fromIndex ROWS
	FETCH NEXT @toIndex ROWS ONLY;
	
END
ELSE IF NOT EXISTS (select * from @technicalInfoTempTable)
BEGIN
	select TI2.id , TI2.title , TI3.id c_id  ,TI3.title c_title ,
	 TI3.[type] c_type , TI3.fk_technicalinfo_table_id c_fk_technicalinfo_table_id 
	 ,ITI.fk_technicalInfoValues_tblValue,ITI.isPublic , TIV.val fk_technicalInfoValues_tblValue_dsc  , ITI.strValue
	from TB_ITEM I
	inner join TB_TYP_ITEM_GRP IG
	on I.fk_itemGrp_id = IG.id
	inner join TB_TECHNICALINFO_PAGE TIP
	on IG.fk_technicalinfo_page_id = TIP.Id
	inner join TB_TYP_TECHNICALINFO TI1
	on TI1.fk_technicalinfo_page_id = TIP.fk_technicalinfo_page_id
	inner join TB_TYP_TECHNICALINFO TI2
	on TI1.fk_technicalinfo_page_id = TIP.fk_technicalinfo_page_id and TI1.fk_ref = TI2.id 
	inner join TB_TYP_TECHNICALINFO TI3
	on TI3.id = TI1.id
	left join TB_ITEM_TECHNICALINFO ITI
	on TI3.id = ITI.pk_fk_technicalInfo_id and ITI.pk_fk_item_id = I.id
	left join TB_TECHNICALINFO_VALUES TIV
	on TIV.id = ITI.fk_technicalInfoValues_tblValue
	where I.id = @item  and (@search is null or @search = '' or TI3.title like '%'+@search+'%')  AND
								(((ITI.isPublic = 1 or ITI.isPublic is null) and @appId = 2) or @appId <> 2)
	order by TI1.[order] , TI2.[order]
	OFFSET @fromIndex ROWS
	FETCH NEXT @toIndex ROWS ONLY;
END
ELSE
BEGIN

	
select TI.id , TI.title , TI2.id c_id  ,TI2.title c_title ,
	 TI2.[type] c_type , TI2.fk_technicalinfo_table_id c_fk_technicalinfo_table_id 
	 ,ITI.fk_technicalInfoValues_tblValue , TIV.val fk_technicalInfoValues_tblValue_dsc,case when  ITI.isPublic is not null then ITI.isPublic else ITI1.isPublic END isPublic  ,case when ITI.strValue is not null then ITI.strValue else ITI1.strValue end strValue
	from @technicalInfoTempTable temp
	inner join TB_TYP_TECHNICALINFO TI
	on temp.fk_ref = TI.id
	inner join TB_TYP_TECHNICALINFO TI2
	on TI2.id = temp.id
	left join TB_ITEM_TECHNICALINFO ITI
	on TI.id = ITI.pk_fk_technicalInfo_id and ITI.pk_fk_item_id = @item
	left join TB_ITEM_TECHNICALINFO ITI1
	on TI2.id = ITI1.pk_fk_technicalInfo_id and ITI1.pk_fk_item_id = @item
	left join TB_TECHNICALINFO_VALUES TIV
	on TIV.id = ITI.fk_technicalInfoValues_tblValue
	where (@search is null or @search = '' or TI2.title like '%'+@search+'%')  AND
								((((ITI.isPublic <> 0 or ITI1.isPublic <> 0) or (ITI.isPublic is null and ITI1.isPublic is null)) and @appId = 2) or @appId <> 2)
	order by TI.[order] , TI2.[order]
	OFFSET @fromIndex ROWS
	FETCH NEXT @toIndex ROWS ONLY;

END

END
RETURN 0
