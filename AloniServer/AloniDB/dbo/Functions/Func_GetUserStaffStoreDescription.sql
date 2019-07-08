CREATE FUNCTION [dbo].[Func_GetUserStaffStoreDescription]
(
	@clientLanguage as char(2),
	@userId as bigint,
	@storeId as bigint
)
RETURNS nvarchar(50)
AS
BEGIN
	declare @result as nvarchar(50)
	select 
		@result = isnull(stt.title,s.title)
	from
	    TB_USR_STAFF US inner join TB_STAFF S on us.fk_staff_id = s.id left join TB_STAFF_TRANSLATIONS STT on s.id = STT.id and stt.lan = @clientLanguage
	where
		 US.fk_usr_id = @userId 
		 and
		 US.fk_store_id = @storeId
		
	return @result
END