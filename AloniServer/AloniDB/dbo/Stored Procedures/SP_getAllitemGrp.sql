CREATE PROCEDURE [dbo].[SP_getAllitemGrp]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	--@userId as bigint, temprory commented
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null
AS
  set nocount on
if(@parent is not null  and @parent <> '')
begin
	select id,title,fk_item_grp_ref from TB_TYP_ITEM_GRP with (nolock)
	where
		title like case when @search is not null and @search <> '' then '%'+@search+'%' else title  end 
		and
	   fk_item_grp_ref = CAST(@parent as int) or id = CAST(@parent as int)
	   and
		isActive <> 0
	   order by id
end
else
begin
	select id,title,fk_item_grp_ref from TB_TYP_ITEM_GRP with (nolock)
	where

		title like case when @search is not null and @search <> '' then '%'+@search+'%' else title  end 
		and
		isActive <> 0
end
RETURN 0
