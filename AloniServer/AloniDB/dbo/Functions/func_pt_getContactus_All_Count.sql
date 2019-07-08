CREATE FUNCTION [dbo].[func_pt_getContactus_All_Count]
(
	@fk_deprtmentTypeId int,
	@answered bit
)
RETURNS  TABLE
AS
RETURN 
(
			select c.id
			 from TB_CONTACTUS AS c
			left join TB_TYP_CONTACTUS_DEPARTMENT AS cd on c.fk_deprtmentTypeId = cd.id
			left join TB_USR AS usr on c.fk_usr_answeredId = usr.id
			where (c.fk_deprtmentTypeId = @fk_deprtmentTypeId OR @fk_deprtmentTypeId IS NULL) 
			AND (( @answered = 0 AND c.answerDateTime IS NULL ) OR ( @answered = 1 AND c.answerDateTime IS NOT NULL ) OR @answered IS NULL)
)
