CREATE VIEW dbo.[vw_getItemsOpinionPollInactive]
AS
SELECT        item.id,
CASE WHEN document.id IS NULL THEN '' ELSE '<img src="' + document.thumbcompeleteLink + '" width="50" height="50" onClick="showImageModal(''' + document.completeLink + ''')"/>' END AS pic, 
                         ISNULL(item.title, '') AS title,
						 ISNULL(item.technicalTitle, '') AS technicalTitle,
						 ISNULL(sta_t.title, sta.title) AS statusTitle
FROM            dbo.TB_ITEM AS item LEFT OUTER JOIN
                         dbo.TB_STATUS AS sta ON item.fk_status_id = sta.id LEFT OUTER JOIN
						 dbo.TB_STATUS_TRANSLATIONS sta_t ON sta_t.id = sta.id AND sta_t.lan = 'fa' LEFT OUTER JOIN
                         dbo.TB_DOCUMENT_ITEM AS documentItem ON item.id = documentItem.pk_fk_item_id AND documentItem.isDefault = 1 LEFT OUTER JOIN
                         dbo.TB_DOCUMENT AS [document] ON documentItem.pk_fk_document_id = [document].id
WHERE        (item.id IN
                             (SELECT        fk_item_id
                               FROM            dbo.TB_STORE_ITEM_OPINIONPOLL
                               WHERE        (isActive IS NULL) OR
                                                         (isActive = 0)))


