CREATE PROCEDURE [dbo].[SP_getOrderAddress]
	@clientLanguage as char(2),
	@appId as tinyint,
	@clientIp as varchar(50),
	@userId as bigint,
	@pageNo as int,
	@search as nvarchar(100),
	@parent as varchar(20)
AS
set nocount on
	set @pageNo = ISNULL(@pageNo,0)
	select 
		OA.id,
		OA.transfereeName,
		OA.transfereeMobile,
		OA.countryCode,
		OA.transfereeTell,
		OA.postalAddress,
		OA.postalCode,
		OA.[location].Lat lat,
		OA.[location].Long lng,
		S.id stateId,
		S.title stateTitle,
		C.id cityId,
		C.title cityTitle,
		OA.nationalCode
	from
		TB_ORDER_ADDRESS OA
		inner join TB_STATE S on OA.fk_state_id = s.id
		inner join TB_CITY C on c.id = OA.fk_city_id
	where
		(postalAddress like '%'+@search+'%' or @search is null or @search = '')
		AND
		(OA.id = cast(@parent as bigint) or @parent is null or @parent = '')
		AND
		fk_usr_id = @userId
		AND
		(OA.isDeleted is null or OA.isDeleted = 0)
	order by OA.id
	OFFSET (@pageNo * 10) rows
	fetch next 10 rows only

RETURN 0
