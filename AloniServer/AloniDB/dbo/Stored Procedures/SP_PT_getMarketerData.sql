-- =============================================
-- Author:		saeed m khorsand
-- Create date: 1396 10 10
-- =============================================
CREATE PROCEDURE [dbo].[SP_PT_getMarketerData]
	@clientLanguage as char(2) = 'fa',
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@userStaffId as bigint
AS
BEGIN
	SET NOCOUNT ON;

			select U.id 
			, ISNULL(U.fname,'') + ' ' + ISNULL(U.lname,'') as name 
			, U.mobile 
			, U.fk_country_id 
			, CO.title fk_country_title
			, U.fk_introducer
			, ISNULL(U2.fname,'') + ' ' + ISNULL(U2.lname,'') as fk_introducer_name
			, U.fk_status_id 
			, U_STATUS.title fk_status_title
			, US.fk_staff_id fk_staff_id
			, ST.title fk_staff_title 
			,US.fk_store_id fk_store_id
			, S.title fk_store_title
			 from TB_USR_STAFF US
			inner join TB_USR U with (nolock)
			on US.fk_usr_id = U.id
			inner join TB_STAFF_TRANSLATIONS ST with (nolock)
			on US.fk_staff_id = ST.id and ST.lan = 'fa'
			inner join TB_STORE S with (nolock)
			on S.id = US.fk_store_id
			left join TB_COUNTRY CO with (nolock)
			on U.fk_country_id = CO.id
			left join TB_USR U2 with (nolock)
			on U.fk_introducer = U2.id
			left join TB_STATUS_TRANSLATIONS U_STATUS with (nolock)
			on U.fk_status_id = U_STATUS.id and U_STATUS.lan = 'fa'
			WHERE US.id = @userStaffId

	select distinct [USE].id, cast([USE].otpCode as varchar(10)) otpCode , [USE].loginIp , [USE].deviceInfo , [USE].fk_status_id  , USE_STATUS.title fk_status_title
	from TB_USR_STAFF US with (nolock)
	inner join TB_USR_SESSION [USE] with (nolock)
	on US.fk_usr_id = [USE].fk_usr_id
	inner join TB_STATUS_TRANSLATIONS USE_STATUS
	on [USE].fk_status_id = USE_STATUS.id and USE_STATUS.lan = 'fa'
	where US.id = @userStaffId

END