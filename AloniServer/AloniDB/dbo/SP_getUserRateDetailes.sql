CREATE PROCEDURE [dbo].[SP_getUserRateDetailes]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@opinionPollId as bigint
	,@pageNo AS INT = NULL
	,@search AS NVARCHAR(100) = null
	,@parent AS VARCHAR(20) = NULL,
	@targetUserId as bigint
AS
	select 
		II.title,
		I.score
	from 
		[dbo].[TB_STORE_ITEM_OPINIONPOLL_OPINIONS] I
	    inner join [dbo].[TB_STORE_ITEM_OPINIONPOLL_OPTIONS] II on I.pk_fk_opinionOption_id = II.id
	where 
		fk_opinionPollId = @opinionPollId
		and
		pk_fk_usr_id = @targetUserId
RETURN 0
