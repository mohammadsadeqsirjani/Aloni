CREATE VIEW dbo.[vw_getPortalUsr]
AS
SELECT DISTINCT 
                         usr.id, ISNULL(usr.fname, 'خالی') AS fname, ISNULL(usr.lname, 'خالی') AS lname, ISNULL(usr.mobile, 'خالی') AS mobile, ISNULL(CAST(usr.fk_country_id AS varchar(50)), 'خالی') AS fk_country_id, ISNULL(country.title,
                          'خالی') AS countryTitle, ISNULL(CAST(usr.fk_language_id AS varchar(50)), 'خالی') AS fk_language_id, ISNULL(lang.title, 'خالی') AS languageTitle, ISNULL(CAST(usr.fk_introducer AS varchar(50)), 'خالی') 
                         AS fk_introducer, ISNULL(usrRef.fname, 'خالی') AS introducer, ISNULL(CAST(usr.fk_status_id AS varchar(50)), 'خالی') AS fk_status_id, ISNULL(sta.title, 'خالی') AS statusTitle, 
                         ISNULL(CAST(usr.fk_cityId AS varchar(50)), 'خالی') AS fk_cityId, ISNULL(city.title, 'خالی') AS cityTitle, ISNULL(CAST(usrStaff.id AS varchar(50)), 'خالی') AS usrStaffId, ISNULL(CAST(usrStaff.fk_staff_id AS varchar(50)), 
                         'خالی') AS fk_staff_id, ISNULL(staff.title, 'خالی') AS staffTitle
FROM            dbo.TB_USR AS usr LEFT OUTER JOIN
                         dbo.TB_COUNTRY AS country ON usr.fk_country_id = country.id LEFT OUTER JOIN
                         dbo.TB_LANGUAGE AS lang ON usr.fk_language_id = lang.id LEFT OUTER JOIN
                         dbo.TB_USR AS usrRef ON usr.fk_introducer = usrRef.id LEFT OUTER JOIN
                         dbo.TB_STATUS AS sta ON usr.fk_status_id = sta.id LEFT OUTER JOIN
                         dbo.TB_CITY AS city ON usr.fk_cityId = city.id LEFT OUTER JOIN
                         dbo.TB_USR_STAFF AS usrStaff ON usr.id = usrStaff.fk_usr_id LEFT OUTER JOIN
                         dbo.TB_STAFF AS staff ON usrStaff.fk_staff_id = staff.id INNER JOIN
                         dbo.TB_STATUS AS userStaffStatus ON usrStaff.fk_status_id = userStaffStatus.id AND usrStaff.fk_status_id = 37
WHERE        (3 IN
                             (SELECT DISTINCT fk_app_id
                               FROM            dbo.TB_USR_SESSION
                               WHERE        (fk_usr_id = usr.id))) AND (usrStaff.fk_staff_id IN
                             (SELECT        id
                               FROM            dbo.TB_STAFF
                               WHERE        (fk_app_id = 3)))
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getPortalUsr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'olumn = 0
         End
         Begin Table = "staff"
            Begin Extent = 
               Top = 138
               Left = 662
               Bottom = 251
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "userStaffStatus"
            Begin Extent = 
               Top = 252
               Left = 454
               Bottom = 382
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getPortalUsr';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "usr"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "country"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "lang"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 119
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "usrRef"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 136
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sta"
            Begin Extent = 
               Top = 120
               Left = 454
               Bottom = 250
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "city"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "usrStaff"
            Begin Extent = 
               Top = 138
               Left = 246
               Bottom = 268
               Right = 416
            End
            DisplayFlags = 280
            TopC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getPortalUsr';

