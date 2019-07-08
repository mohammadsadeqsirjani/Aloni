CREATE VIEW dbo.vw_storePerson_all
AS
SELECT        U.id, ISNULL(CAST(US.id AS varchar(50)), 'خالی') AS us_id, ISNULL(U.fname, '') + ' ' + ISNULL(U.lname, '') AS name, ISNULL(U.mobile, 'خالی') AS mobile, ISNULL(ST.title, 'خالی') AS staff_title, 
                         ISNULL(CAST(S.id AS varchar(50)), 'خالی') AS store_id, ISNULL(S.title, 'خالی') AS store_title, ISNULL(CAST(S.fk_city_id AS varchar(50)), 'خالی') AS fk_city_id, ISNULL(CAST(S.fk_country_id AS varchar(50)), 'خالی') 
                         AS fk_country_id, ISNULL(CAST(S.fk_status_id AS varchar(50)), 'خالی') AS fk_status_id, ISNULL(U_STATUS.title, 'خالی') AS fk_status_title
FROM            dbo.TB_USR AS U WITH (nolock) INNER JOIN
                         dbo.TB_USR_STAFF AS US WITH (nolock) ON U.id = US.fk_usr_id AND US.fk_staff_id BETWEEN 10 AND 19 INNER JOIN
                         dbo.TB_STAFF_TRANSLATIONS AS ST WITH (nolock) ON US.fk_staff_id = ST.id AND ST.lan = 'fa' INNER JOIN
                         dbo.TB_STORE AS S WITH (nolock) ON US.fk_store_id = S.id INNER JOIN
                         dbo.TB_STATUS_TRANSLATIONS AS U_STATUS ON U.fk_status_id = U_STATUS.id AND U_STATUS.lan = 'fa'