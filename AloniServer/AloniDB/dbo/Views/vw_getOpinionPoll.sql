CREATE VIEW dbo.vw_getOpinionPoll
AS
SELECT        opinionPoll.id, CASE WHEN document.id IS NULL 
                         THEN '' ELSE '<img src="' + document.thumbcompeleteLink + '" width="50" height="50" onClick="showImageModal(''' + document.completeLink + ''')"/>' END AS pic, ISNULL(opinionPoll.title, '') AS title, 
                         opinionPoll.fk_store_id, ISNULL(store.title, '') AS storeTitle, opinionPoll.fk_item_id, ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(opinionPoll.saveDateTime) AS varchar(50)), '') AS saveDateTime, 
                         CASE WHEN opinionPoll.isActive IS NULL OR
                         opinionPoll.isActive = 0 THEN 'غیر فعال' WHEN opinionPoll.isActive = 1 THEN 'فعال' ELSE '' END AS Active, opinionPoll.isActive, CASE WHEN opinionPoll.resultIsPublic IS NULL OR
                         opinionPoll.resultIsPublic = 0 THEN 'غیر عمومی' WHEN opinionPoll.resultIsPublic = 1 THEN 'عمومی' ELSE '' END AS resultIsPublic
FROM            dbo.TB_STORE_ITEM_OPINIONPOLL AS opinionPoll LEFT OUTER JOIN
                         dbo.TB_STORE AS store ON opinionPoll.fk_store_id = store.id LEFT OUTER JOIN
                         dbo.TB_DOCUMENT AS [document] ON opinionPoll.fk_document_picId = [document].id
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getOpinionPoll';


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
         Begin Table = "opinionPoll"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 303
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "store"
            Begin Extent = 
               Top = 6
               Left = 341
               Bottom = 136
               Right = 613
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "document"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 241
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
         Alias = 1155
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getOpinionPoll';

