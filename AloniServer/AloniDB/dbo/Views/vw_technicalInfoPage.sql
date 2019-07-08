CREATE VIEW dbo.vw_technicalInfoPage
AS
SELECT        TIP.Id, ISNULL(TIP.title, 'خالی') AS title, ISNULL(TIP2.title, 'خالی') AS fk_technicalinfo_page_title, ISNULL(CAST(COUNT(TIP.Id) AS varchar(50)), 'خالی') AS co_child, CASE WHEN TIP.isActive IS NULL OR
                         TIP.isActive = 0 THEN 'غیر فعال' ELSE 'فعال' END AS status
FROM            dbo.TB_TECHNICALINFO_PAGE AS TIP LEFT OUTER JOIN
                         dbo.TB_TECHNICALINFO_PAGE AS TIP2 ON TIP.fk_technicalinfo_page_id = TIP2.Id LEFT OUTER JOIN
                         dbo.TB_TYP_TECHNICALINFO AS TI ON TI.fk_technicalinfo_page_id = TIP.Id
GROUP BY TIP.Id, TIP.title, TIP2.title, TIP.isActive

