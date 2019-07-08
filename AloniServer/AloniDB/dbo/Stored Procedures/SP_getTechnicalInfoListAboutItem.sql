CREATE PROCEDURE [dbo].[SP_getTechnicalInfoListAboutItem]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@itemGrpId as bigint
AS
	set nocount on
	--SELECT t.id,t.title,t.[type]  from TB_TECHNICALINFO_ITEMGRP tg with (nolock) inner join TB_TYP_TECHNICALINFO t with(nolock) on tg.pk_fk_technicalInfo_id = t.id
	--where tg.pk_fk_itemGrp_id = @itemGrpId and (@search is null or @search = '' or t.title like '%'+@search+'%' )
	--order by t.id
	--OFFSET (@pageNo * 10 ) ROWS
	--FETCH NEXT 10 ROWS ONLY;
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

from
 TB_TYP_ITEM_GRP IG
 inner join TB_TECHNICALINFO_PAGE TIP
 on IG.fk_technicalinfo_page_id = TIP.Id
 inner join TB_TYP_TECHNICALINFO TI
 on TI.fk_technicalinfo_page_id = TIP.Id
 where ig.id = @itemGrpId


IF EXISTS ( select * from @technicalInfoTempTable where fk_technicalinfo_page_id IS NOT NULL ) 
BEGIN

	select TI2.id , TI2.title , TI3.id c_id  ,TI3.title c_title ,
	 TI3.[type] c_type , TI3.fk_technicalinfo_table_id c_fk_technicalinfo_table_id 
	 
	from TB_TYP_TECHNICALINFO TI1
	inner join TB_TYP_TECHNICALINFO TI2
	on TI1.fk_technicalinfo_page_id = ( select top 1 fk_technicalinfo_page_id from @technicalInfoTempTable ) and TI1.fk_ref = TI2.id 
	inner join TB_TYP_TECHNICALINFO TI3
	on TI3.id = TI1.id
	left join TB_TECHNICALINFO_ITEMGRP ITI
	on TI3.id = ITI.pk_fk_technicalInfo_id and ITI.pk_fk_itemGrp_id = @itemGrpId
	where TI1.id NOT IN (select fk_ref from @technicalInfoTempTable) and TI2.title like case when @search is not null and @search <> '' then '%'+@search+'%' else TI2.title end
	order by TI1.[order] , TI2.[order]
	OFFSET @fromIndex ROWS
	FETCH NEXT @toIndex ROWS ONLY;
	
END
ELSE IF NOT EXISTS (select * from @technicalInfoTempTable)
BEGIN
	select TI2.id , TI2.title , TI3.id c_id  ,TI3.title c_title ,
	 TI3.[type] c_type , TI3.fk_technicalinfo_table_id c_fk_technicalinfo_table_id 
	 
	from 
	TB_TYP_ITEM_GRP IG
	inner join TB_TECHNICALINFO_PAGE TIP
	on IG.fk_technicalinfo_page_id = TIP.Id
	inner join TB_TYP_TECHNICALINFO TI1
	on TI1.fk_technicalinfo_page_id = TIP.fk_technicalinfo_page_id
	inner join TB_TYP_TECHNICALINFO TI2
	on TI1.fk_technicalinfo_page_id = TIP.fk_technicalinfo_page_id and TI1.fk_ref = TI2.id 
	inner join TB_TYP_TECHNICALINFO TI3
	on TI3.id = TI1.id
	
	where Ig.id = @itemGrpId and  TI2.title like case when @search is not null and @search <> '' then '%'+@search+'%' else TI2.title end
	order by TI1.[order] , TI2.[order]
	OFFSET @fromIndex ROWS
	FETCH NEXT @toIndex ROWS ONLY;
END
ELSE
BEGIN

	select TI.id , TI.title , TI2.id c_id  ,TI2.title c_title ,
	 TI2.[type] c_type , TI2.fk_technicalinfo_table_id c_fk_technicalinfo_table_id 
	from @technicalInfoTempTable temp
	inner join TB_TYP_TECHNICALINFO TI
	on temp.fk_ref = TI.id
	inner join TB_TYP_TECHNICALINFO TI2
	on TI2.id = temp.id
	left join TB_TECHNICALINFO_ITEMGRP ITI
	on TI.id = ITI.pk_fk_technicalInfo_id and ITI.pk_fk_itemGrp_id = @itemGrpId
	where
	 TI2.title like case when @search is not null and @search <> '' then '%'+@search+'%' else TI2.title end
	order by TI.[order] , TI2.[order]
	OFFSET @fromIndex ROWS
	FETCH NEXT @toIndex ROWS ONLY;

END
RETURN 0
