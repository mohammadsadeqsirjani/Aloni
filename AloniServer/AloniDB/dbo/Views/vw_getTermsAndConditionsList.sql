CREATE VIEW dbo.vw_getTermsAndConditionsList
AS
SELECT        REPLACE(dbo.func_addThousandsSeperator(teco.pk_version), '.', '-') + ',' + CAST(teco.pk_fk_app_id AS varchar(20)) AS id, teco.pk_fk_app_id, ISNULL(app.title, '') AS appTitle, ISNULL(CAST(teco.pk_version AS varchar(18)), '') 
                         AS versionCode, ISNULL(teco.title, '') AS title, ISNULL(teco.description, '') AS description, ISNULL(dbo.func_udf_Gregorian_To_Persian_withTime(teco.saveDateTime), '') AS saveDateTime, ISNULL(usr.fname, '') AS usrTitle, 
                         teco.isActive, 
                         CASE WHEN teco.isActive = 0 THEN '<small class="label label-danger" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>غیرفعال</small>'
                          WHEN teco.isActive = 1 THEN '<small class="label label-success" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>  فعال</small>'
                          ELSE '' END AS Active
FROM            dbo.TB_TERMS_AND_CONDITIONS AS teco LEFT OUTER JOIN
                         dbo.TB_APP AS app ON teco.pk_fk_app_id = app.id LEFT OUTER JOIN
                         dbo.TB_USR AS usr ON teco.fk_usr_saveUser = usr.id
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getTermsAndConditionsList';


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
         Begin Table = "teco"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "app"
            Begin Extent = 
               Top = 6
               Left = 247
               Bottom = 102
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "usr"
            Begin Extent = 
               Top = 6
               Left = 455
               Bottom = 136
               Right = 625
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
         Column = 2475
         Alias = 1635
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getTermsAndConditionsList';



