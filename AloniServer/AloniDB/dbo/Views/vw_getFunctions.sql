CREATE VIEW [dbo].[vw_getFunctions]
	AS SELECT 
	id
	,[description]
	,area
	,fk_app_id
	FROM TB_APP_FUNC
