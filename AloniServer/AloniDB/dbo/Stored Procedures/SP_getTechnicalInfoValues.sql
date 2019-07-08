CREATE PROCEDURE [dbo].[SP_getTechnicalInfoValues]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint, 
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20),
	@technicalInfoId as bigint
AS
	set nocount on

	declare @technicalinfo_table_id int;
	
	select @technicalinfo_table_id = TI.fk_technicalinfo_page_id from TB_TYP_TECHNICALINFO TI with (nolock)
	where TI.id = @technicalInfoId


	SELECT t.id,t.val  from TB_TECHNICALINFO_VALUES t with (nolock) 
	where t.fk_technicalinfo_table_id = @technicalinfo_table_id and (@search is null or @search = '' or t.val like '%'+@search+'%' ) and t.isActive = 1
	order by t.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
