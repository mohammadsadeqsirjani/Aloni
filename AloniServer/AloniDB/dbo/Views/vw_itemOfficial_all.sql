CREATE VIEW [dbo].[vw_itemOfficial_all]
AS
select distinct
I.id , I.title as t,
case
	when d.id is null then ''
else
	'<img src="' + d.thumbcompeleteLink +'" width="50" height="50" onClick="showImageModal('''+ d.completeLink +''')"/>'
 end as tT,
  Ig.title grp, 
  ( ISNULL(U.fname , '' ) + ' ' + ISNULL ( U.lname , '' ) ) as n ,
  ( ISNULL(U2.fname , '' ) + ' ' + ISNULL ( U2.lname , '' ) ) as nm ,
  dbo.[func_udf_Gregorian_To_Persian_withTime](I.saveDateTime) as [save],
  ISNULL(dbo.[func_udf_Gregorian_To_Persian_withTime](I.modifyDateTime),'') as [modify]
 , ISNULL(ST.title ,  S.title ) status
 from TB_ITEM I
inner join TB_TYP_ITEM_GRP  IG
on I.fk_itemGrp_id = IG.id
left join TB_DOCUMENT_ITEM di
on I.id = di.pk_fk_item_id and di.isDefault = 1
left join TB_DOCUMENT d
on di.pk_fk_document_id  = d.id
left join TB_USR U 
on I.fk_usr_saveUser = U.id
left join TB_USR U2
on I.fk_modify_usr_id = U2.id
left join TB_STATUS S
on I.fk_status_id = S.id
left join TB_STATUS_TRANSLATIONS ST
on S.id = ST.id and ST.lan = 'fa'

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_itemOfficial_all';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'      DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "city"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 208
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_itemOfficial_all';


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
         Begin Table = "orderHdr"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "orderDocType"
            Begin Extent = 
               Top = 6
               Left = 441
               Bottom = 102
               Right = 611
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "store"
            Begin Extent = 
               Top = 102
               Left = 441
               Bottom = 232
               Right = 713
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "usrCustomer"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "usrSession"
            Begin Extent = 
               Top = 138
               Left = 246
               Bottom = 268
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "statusOrderHdr"
            Begin Extent = 
               Top = 234
               Left = 454
               Bottom = 364
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "statusPayment"
            Begin Extent = 
               Top = 234
               Left = 662
               Bottom = 364
               Right = 832
            End
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_itemOfficial_all';

