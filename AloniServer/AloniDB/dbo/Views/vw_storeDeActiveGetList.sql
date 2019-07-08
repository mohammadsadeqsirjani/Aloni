CREATE VIEW dbo.vw_storeDeActiveGetList
AS
SELECT        S.id, ISNULL(S.title, 'خالی') AS title, ISNULL(ST.title, 'خالی') AS status_title, ISNULL(S.title_second, 'خالی') AS title_second, ISNULL
                             ((SELECT        title
                                 FROM            dbo.func_getCityById(S.fk_city_id) AS func_getCityById_1), 'خالی') AS city
FROM            dbo.TB_STORE AS S WITH (nolock) LEFT OUTER JOIN
                         dbo.TB_TYP_STORE_TYPE_TRANSLATIONS AS ST WITH (nolock) ON S.fk_store_type_id = ST.id AND ST.lan = 'fa'
WHERE        (S.fk_status_id = 14)