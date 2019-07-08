-- =============================================
-- Author:		Faramarz Bayatzadeh
-- Create date: 1397 02 02
-- Description:	return 4 table of user data
-- =============================================
CREATE PROCEDURE [dbo].[SP_getInformationOpinionPoll]
	@clientLanguage as char(2) = null,
	@appId as tinyint = null,
	@clientIp as varchar(50) = null,
	@opinionPullId as bigint
AS
BEGIN
	SET NOCOUNT ON;

SELECT 
opinionPoll.id AS id,
opinionPoll.fk_store_id AS fk_store_id,
ISNULL(store.title, '') AS storeTitle,
opinionPoll.fk_item_id AS fk_item_id,
ISNULL(item.title, '') AS itemTitle,
opinionPoll.isActive,
CASE WHEN opinionPoll.isActive IS NULL OR opinionPoll.isActive = 0 THEN 'غیر فعال' WHEN opinionPoll.isActive = 1 THEN 'فعال' ELSE '' END AS Active,
ISNULL(opinionPoll.title, '') AS title,
CASE WHEN opinionPoll.resultIsPublic IS NULL OR opinionPoll.resultIsPublic = 0 THEN 'غیر عمومی' WHEN opinionPoll.resultIsPublic = 1 THEN 'عمومی' ELSE '' END AS resultIsPublic,
ISNULL(document.completeLink, '') AS picCompleteLink,
ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(opinionPoll.startDateTime) AS varchar(50)), '') AS startDateTime,
ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(opinionPoll.endDateTime) AS varchar(50)), '') AS endDateTime,
CASE WHEN opinionPoll.publish IS NULL OR opinionPoll.publish = 0 THEN 'منتشر نشده' WHEN opinionPoll.publish = 1 THEN 'منتشر شده' ELSE '' END AS publish,
ISNULL(opinionPoll.itemGrpTitle, '') AS itemGrpTitle,
ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(opinionPoll.saveDateTime) AS varchar(50)), '') AS saveDateTime,
ISNULL(opinionPoll.saveIp, '') AS saveIp,
ISNULL(usr.fname,'') AS usrTitle
FROM TB_STORE_ITEM_OPINIONPOLL AS opinionPoll
LEFT JOIN TB_STORE AS store
ON  opinionPoll.fk_store_id = store.id
LEFT JOIN TB_ITEM AS item
ON opinionPoll.fk_item_id = item.id
LEFT JOIN TB_DOCUMENT AS document
ON opinionPoll.fk_document_picId = document.id
LEFT JOIN TB_USR_SESSION AS usrSession
ON opinionPoll.fk_userSession_saveUserSessionId = usrSession.id
LEFT JOIN TB_USR AS usr
ON usrSession.fk_usr_id = usr.id
WHERE opinionPoll.id = @opinionPullId


select
comments.id AS id,
comments.fk_usr_commentUserId AS fk_usr_commentUserId,
ISNULL(usr.fname, '') AS usrTitle,
ISNULL(comments.comment, '') AS comment,
ISNULL(document1.completeLink, '') AS completeLinkOne,
ISNULL(document1.thumbcompeleteLink, '') AS thumbcompeleteLinkOne,
ISNULL(document2.completeLink, '') AS completeLinkTwo,
ISNULL(document2.thumbcompeleteLink, '') AS thumbcompeleteLinkTwo,
ISNULL(document3.completeLink, '') AS completeLinkThree,
ISNULL(document3.thumbcompeleteLink, '') AS thumbcompeleteLinkThree,
ISNULL(document4.completeLink, '') AS completeLinkFour,
ISNULL(document4.thumbcompeleteLink, '') AS thumbcompeleteLinkFour,
ISNULL(document5.completeLink, '') AS completeLinkFive,
ISNULL(document5.thumbcompeleteLink, '') AS thumbcompeleteLinkFive,
ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(comments.saveDateTime) AS varchar(50)), '') AS saveDateTime,
ISNULL(CAST(dbo.func_udf_Gregorian_To_PersianLetters(comments.saveDateTime) AS varchar(50)) + '  ' + SUBSTRING(Cast(Cast(comments.saveDateTime AS Time) AS varchar(50)),1,5), '') AS saveDateTimeLatters,
ISNULL(comments.saveIp, '') AS saveIp,
CAST(comments.edited AS int) AS edited,
CASE WHEN comments.edited IS NULL OR comments.edited = 0 THEN 'ویرایش نشده' WHEN  comments.edited = 1 THEN 'ویرایش شده' ELSE '' END AS editedTitle
from TB_STORE_ITEM_OPINIONPOLL_COMMENTS AS comments
LEFT JOIN TB_USR AS usr
ON comments.fk_usr_commentUserId = usr.id
LEFT JOIN TB_DOCUMENT AS document1
ON comments.fk_document_doc1 = document1.id
LEFT JOIN TB_DOCUMENT AS document2
ON comments.fk_document_doc2 = document2.id
LEFT JOIN TB_DOCUMENT AS document3
ON comments.fk_document_doc3 = document3.id
LEFT JOIN TB_DOCUMENT AS document4
ON comments.fk_document_doc4 = document4.id
LEFT JOIN TB_DOCUMENT AS document5
ON comments.fk_document_doc5 = document5.id
WHERE comments.fk_opinionpoll_id = @opinionPullId

select 
id,
ISNULL(title, '') AS title,
CAST(isActive AS int) AS isActive,
CASE WHEN isActive IS NULL OR isActive = 0 THEN 'غیر فعال' WHEN isActive = 1 THEN 'فعال' ELSE '' END AS Active,
orderingNo,
cntOpinions,
replace(convert(varchar,avgOpinions,1),'.00','') AS avgOpinions
from TB_STORE_ITEM_OPINIONPOLL_OPTIONS
WHERE fk_opinionpoll_id = @opinionPullId

select 
opinions.pk_fk_usr_id AS pk_fk_usr_id,
ISNULL(usr.fname, '') AS usrTitle,
ISNULL(options.title, '') AS optionsTitle,
replace(convert(varchar,opinions.score,1),'.00','') AS score,
ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(opinions.saveDateTime) AS varchar(50)), '') AS saveDateTime,
ISNULL(opinions.saveIp, '') AS saveIp
from TB_STORE_ITEM_OPINIONPOLL_OPINIONS AS opinions
LEFT JOIN TB_USR AS usr
ON opinions.pk_fk_usr_id = usr.id
LEFT JOIN TB_STORE_ITEM_OPINIONPOLL_OPTIONS AS options
ON opinions.pk_fk_opinionOption_id = options.id
WHERE opinions.fk_opinionPollId = @opinionPullId


END