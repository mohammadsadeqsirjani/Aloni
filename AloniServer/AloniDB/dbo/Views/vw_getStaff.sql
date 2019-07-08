CREATE VIEW dbo.vw_getStaff
AS
SELECT        staff.id, ISNULL(staff.title, 'خالی') AS title, staff.fk_app_id , ISNULL(app.title, 'خالی') AS appTitle
FROM            dbo.TB_STAFF AS staff LEFT OUTER JOIN
                         dbo.TB_APP AS app ON staff.fk_app_id = app.id




