CREATE PROCEDURE [dbo].[SP_getColorList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20) = null
	
AS
	set nocount on
	select
		 c.id, 
		 ISNULL(ct.title,c.title) title
	from
		 TB_COLOR c with (nolock)
		 left join TB_COLOR_TRANSLATIONS ct with(nolock) on c.id = ct.id and ct.lan = @clientLanguage
	where
		c.isActive = 1
	ORDER BY c.id
	OFFSET (@pageNo * 10 ) ROWS
	FETCH NEXT 10 ROWS ONLY;
RETURN 0
