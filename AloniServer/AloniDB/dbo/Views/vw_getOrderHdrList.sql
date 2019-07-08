CREATE VIEW dbo.vw_getOrderHdrList
AS
SELECT        ordHdr.id, ordHdr.fk_order_orderId AS orderId, ordHdr.fk_docType_id, ISNULL(docType.title, '') AS docTitle, ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(ordHdr.saveDateTime) AS varchar(50)), '') AS saveTime, 
                         ISNULL(CAST(ordHdr.fk_deliveryTypes_id AS varchar(20)), '') AS fk_deliveryTypes_id, ISNULL(delivery.title, '') AS deliveryTitle, ISNULL(stat.title, '') + ' -- ' + ISNULL(city.title, '') AS loc, ISNULL(oa.transfereeTell, '') 
                         AS delCallNo, ISNULL(oa.postalAddress, '') AS deladdress, CASE WHEN ordHdr.isVoid IS NULL OR
                         ordHdr.isVoid = 0 THEN '<small class="label label-success" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>  فعال</small>'
                          WHEN ordHdr.isVoid = 1 THEN '<small class="label label-danger" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>  ابطال شده</small><br/>'
                          ELSE '' END AS isVoid
FROM            dbo.TB_ORDER_HDR AS ordHdr 
join TB_ORDER_ADDRESS as oa on ordHdr.fk_address_id = oa.id
LEFT OUTER JOIN
                         dbo.TB_TYP_ORDER_DOC_TYPE AS docType ON ordHdr.fk_docType_id = docType.id LEFT OUTER JOIN
                         dbo.TB_STORE_DELIVERYTYPES AS delivery ON ordHdr.fk_deliveryTypes_id = delivery.id LEFT OUTER JOIN
                         dbo.TB_CITY AS city ON oa.fk_city_id = city.id LEFT OUTER JOIN
                         dbo.TB_STATE AS stat ON oa.fk_state_id = stat.Id
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getOrderHdrList';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getOrderHdrList';


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
         Begin Table = "ordHdr"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 249
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "delivery"
            Begin Extent = 
               Top = 6
               Left = 495
               Bottom = 136
               Right = 701
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "city"
            Begin Extent = 
               Top = 6
               Left = 739
               Bottom = 136
               Right = 909
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "stat"
            Begin Extent = 
               Top = 6
               Left = 947
               Bottom = 136
               Right = 1117
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "docType"
            Begin Extent = 
               Top = 6
               Left = 287
               Bottom = 102
               Right = 457
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
         Alias = 1815
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
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_getOrderHdrList';

