CREATE VIEW dbo.vw_getCity
AS
SELECT        city.id, ISNULL(city.title, 'خالی') AS title, CASE WHEN city.isActive IS NULL OR
                         city.isActive = 0 THEN 'غیرفعال' WHEN city.isActive = 1 THEN 'فعال' END AS isActive, ISNULL(CAST(city.fk_country_id AS varchar(50)), 'خالی') AS fk_country_id, ISNULL(CAST(city.fk_state_id AS varchar(50)), 'خالی') 
                         AS fk_state_id, ISNULL(country.title, 'خالی') AS countryTitle, ISNULL(stat.title, 'خالی') AS stateTitle
FROM            dbo.TB_CITY AS city LEFT OUTER JOIN
                         dbo.TB_COUNTRY AS country ON city.fk_country_id = country.id LEFT OUTER JOIN
                         dbo.TB_STATE AS stat ON city.fk_state_id = stat.Id


