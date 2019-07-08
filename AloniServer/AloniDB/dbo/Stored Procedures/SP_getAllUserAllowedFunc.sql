-- =============================================
-- Author:		Saeed Khornsad
-- Create date: 13960827
-- Description:	get All User Allowed Func
-- =============================================

CREATE PROCEDURE [dbo].[SP_getAllUserAllowedFunc]
	@userId bigint
AS
BEGIN
	SET NOCOUNT ON
		select distinct FUNC.id from TB_USR_STAFF USTF with(nolock)
		inner join TB_STAFF STF with(nolock)
		on USTF.fk_staff_id = STF.id
		inner join TB_APP_FUNC_USR UFUNC with(nolock)
		on STF.id = UFUNC.fk_staff_id and UFUNC.fk_staff_id in (select id from TB_STAFF WHERE fk_app_id = 3 OR fk_app_id = 0)
		inner join TB_APP_FUNC FUNC with(nolock)
		on UFUNC.fk_func_id = FUNC.id
		where USTF.fk_usr_id = @userId
END