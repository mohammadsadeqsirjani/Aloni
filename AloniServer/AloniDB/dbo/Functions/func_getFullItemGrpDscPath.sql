-- =============================================
-- Author:		Saeed Khorsand
-- Create date: 13960829
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[func_getFullItemGrpDscPath]
(
	@itemGrp as bigint,
	@first as bit = 1
)
RETURNS varchar(max)
AS
BEGIN

	declare @itemGrpDsc varchar(max)
	declare @item_grp_ref bigint
	if @itemGrp IS NOT NULL
	BEGIN
	select @itemGrpDsc = ISNULL(title , ' _ ') , @item_grp_ref = fk_item_grp_ref from TB_TYP_ITEM_GRP where id = @itemGrp
	
	if @item_grp_ref is not null
	begin
		set @itemGrpDsc = @itemGrpDsc + ' < ' + dbo.func_getFullItemGrpDscPath(@item_grp_ref ,0)

	end
	end

	RETURN ISNULL(@itemGrpDsc,'')

END