CREATE PROCEDURE [dbo].[SP_getBankList]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@pageNo as int = null,
	@search as nvarchar(100) = null,
	@parent as varchar(20) = null,
	@userId as bigint
AS
	SET NOCOUNT ON
	declare @countryId as int = (select fk_country_id from TB_USR where id = @userId)
	select id,title from TB_BANK with(nolock)
	where
	 fk_country_id = @countryId and title like case when @search is not null and @search <> '' then '%'+@search+'%' ELSE title END
	
RETURN 0
