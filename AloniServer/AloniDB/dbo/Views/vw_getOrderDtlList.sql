CREATE VIEW dbo.vw_getOrderDtlList
AS
SELECT        ordDtl.id, ordDtl.fk_order_id AS orderId, ordDtl.fk_orderHdr_id AS orderHdrId, ordDtl.rowId, ordDtl.fk_store_id, ISNULL(store.title, '') AS stTitle, ordDtl.fk_item_id, ISNULL(item.title, '') AS itemTitle, REPLACE(CONVERT(varchar, 
                         ordDtl.qty, 1), '.00', '') AS qty, REPLACE(CONVERT(varchar, ordDtl.delivered, 1), '.00', '') AS delivered, ISNULL(CAST(warranty.warrantyDays AS varchar(50)) + 'روز' + ' -- ' + 'هزینه:' + REPLACE(CONVERT(varchar, 
                         warranty.warrantyCost, 1), '.00', ''), '') AS warrant, CASE WHEN ordDtl.isVoid IS NULL OR
                         ordDtl.isVoid = 0 THEN '<small class="label label-success" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>  فعال</small>'
                          WHEN ordDtl.isVoid = 1 THEN '<small class="label label-danger" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>  ابطال شده</small><br/>'
                          ELSE '' END AS isVoid
FROM            dbo.TB_ORDER_DTL AS ordDtl LEFT OUTER JOIN
                         dbo.TB_STORE AS store ON ordDtl.fk_store_id = store.id LEFT OUTER JOIN
                         dbo.TB_ITEM AS item ON ordDtl.fk_item_id = item.id LEFT OUTER JOIN
                         dbo.TB_STORE_ITEM_WARRANTY AS warranty ON ordDtl.vfk_store_item_warranty = warranty.pk_fk_storeWarranty_id
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getOrderDtlList';


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
         Begin Table = "ordDtl"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "store"
            Begin Extent = 
               Top = 6
               Left = 292
               Bottom = 136
               Right = 564
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "item"
            Begin Extent = 
               Top = 6
               Left = 602
               Bottom = 136
               Right = 824
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "warranty"
            Begin Extent = 
               Top = 6
               Left = 862
               Bottom = 136
               Right = 1073
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
         Alias = 1530
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getOrderDtlList';

