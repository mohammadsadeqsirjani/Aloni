CREATE VIEW dbo.vw_storePerson_notActive
AS
SELECT        U.id, ISNULL(CAST(US.id AS varchar(50)), 'خالی') AS us_id, ISNULL(U.fname, '') + ' ' + ISNULL(U.lname, '') AS name, ISNULL(U.mobile, 'خالی') AS mobile, ISNULL(ST.title, 'خالی') AS staff_title, 
                         ISNULL(CAST(S.id AS varchar(50)), 'خالی') AS store_id, ISNULL(S.title, 'خالی') AS store_title, ISNULL(CAST(S.fk_city_id AS varchar(50)), 'خالی') AS fk_city_id, ISNULL(CAST(S.fk_country_id AS varchar(50)), 'خالی') 
                         AS fk_country_id, ISNULL(CAST(S.fk_status_id AS varchar(50)), 'خالی') AS fk_status_id, ISNULL(U_STATUS.title, 'خالی') AS fk_status_title
FROM            dbo.TB_USR AS U WITH (nolock) INNER JOIN
                         dbo.TB_USR_STAFF AS US WITH (nolock) ON U.id = US.fk_usr_id AND US.fk_staff_id BETWEEN 10 AND 19 INNER JOIN
                         dbo.TB_STAFF_TRANSLATIONS AS ST WITH (nolock) ON US.fk_staff_id = ST.id AND ST.lan = 'fa' INNER JOIN
                         dbo.TB_STORE AS S WITH (nolock) ON US.fk_store_id = S.id INNER JOIN
                         dbo.TB_STATUS_TRANSLATIONS AS U_STATUS ON U.fk_status_id = U_STATUS.id AND U_STATUS.lan = 'fa'
WHERE        (U.fk_status_id = 2)
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_storePerson_notActive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_storePerson_notActive';


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
         Begin Table = "U"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "US"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ST"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 251
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S"
            Begin Extent = 
               Top = 252
               Left = 38
               Bottom = 382
               Right = 310
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U_STATUS"
            Begin Extent = 
               Top = 138
               Left = 246
               Bottom = 251
               Right = 416
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_storePerson_notActive';

