CREATE VIEW dbo.vw_storeCustomer_all
AS
SELECT        U.id,
              ISNULL(U.mobile, 'خالی') AS mobile,
			  ISNULL(U.fname, '') + ' ' + ISNULL(U.lname, '') AS name,
			  ISNULL(CAST(U.fk_cityId AS varchar(50)), 'خالی') AS fk_cityId,
			  ISNULL(C.title, 'خالی') AS city_title, 
              ISNULL(U2.fname, '') + ' ' + ISNULL(U2.lname, '') AS introducer_name,
			  ISNULL(CAST(U.fk_status_id AS varchar(50)), 'خالی') AS fk_status_id,
			  ISNULL(ST_TRAN.title, 'خالی') AS fk_status_title
FROM            dbo.TB_USR AS U INNER JOIN
                         dbo.TB_USR_STAFF AS US ON U.id = US.fk_usr_id AND US.fk_staff_id = 21 LEFT OUTER JOIN
                         dbo.TB_CITY AS C ON U.fk_cityId = C.id LEFT OUTER JOIN
                         dbo.TB_USR AS U2 ON U.fk_introducer = U2.id LEFT OUTER JOIN
                         dbo.TB_STATUS_TRANSLATIONS AS ST_TRAN ON ST_TRAN.id = U.fk_status_id AND ST_TRAN.lan = 'fa'

