CREATE FUNCTION [dbo].[func_pt_getContactus_All]
(
	@fk_deprtmentTypeId int,
	@answered bit
)
RETURNS  TABLE
AS
RETURN 
(
			select 
			c.id,
			ISNULL(c.subject,'') AS [subject],
			ISNULL(c.email, '') AS email,
			ISNULL(c.trackingCode, '') AS trackingCode,
			ISNULL(c.mobile, '') AS mobile,
			c.fk_deprtmentTypeId,
			ISNULL(cd.title, '') AS departmentTitle,
			c.fk_usr_answeredId,
			ISNULL(usr.fname, '') AS usrTitle,
			dbo.func_udf_Gregorian_To_Persian_withTime(c.saveDateTime) AS saveDateTimeDsc,
			ISNULL(dbo.func_udf_Gregorian_To_Persian_withTime(c.answerDateTime), '') AS answerDateTimeDsc,
			c.answerDateTime
			 from TB_CONTACTUS AS c
			left join TB_TYP_CONTACTUS_DEPARTMENT AS cd on c.fk_deprtmentTypeId = cd.id
			left join TB_USR AS usr on c.fk_usr_answeredId = usr.id
			where (c.fk_deprtmentTypeId = @fk_deprtmentTypeId OR @fk_deprtmentTypeId IS NULL) 
			AND (( @answered = 0 AND c.answerDateTime IS NULL ) OR ( @answered = 1 AND c.answerDateTime IS NOT NULL ) OR @answered IS NULL)
)
