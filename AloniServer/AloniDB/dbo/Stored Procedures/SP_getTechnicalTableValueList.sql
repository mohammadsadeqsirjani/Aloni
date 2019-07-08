CREATE PROCEDURE [dbo].[SP_getTechnicalTableValueList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100) = null,
	@parent as varchar(20),
	@userId as bigint,
	@id as int
	
AS
	set nocount on
	set @pageNo = ISNULL(@pageNo,0)
	SELECT val,id from TB_TECHNICALINFO_VALUES where fk_technicalinfo_table_id = @id and isActive = 1
	order by id
	OFFSET (@pageNo * 10) ROWS
	FETCH NEXT 10 ROWS ONLY

RETURN 0
GO
