CREATE FUNCTION [dbo].[func_pt_getItems_All]
(
	@storeId AS bigint,
	@statusId AS int,
	@itemType AS smallint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT DISTINCT 
                         I.id,
						 I.title AS t,
						 STO.id AS storeId,
						 I.unitName AS unit,
						 ISNULL(STO.title, '') AS storeTitle,
						 CASE WHEN d .id IS NULL THEN '' ELSE '<img src=' + '"' + d .thumbcompeleteLink + '"' + 'width=' + '"' + '50' + '"' + 'height=' + '"' + '50' + '"' + ' onclick=' + '"' + 'showImageModal(' + '''' + CAST(I.id AS varchar(50)) 
                         + '''' + ')' + '"' + 'style=' + '"' + 'cursor:pointer;' + '"' + '/><span style=' + '"' + 'position:absolute; background-color: #3c8dbc;color: #ffffff;padding: 2px 9px 2px 9px;border-radius: 30px; margin-right: -10px;' + '"' + '>' + CAST((imgCount.countOfImg)
                          AS varchar(MAX)) + '</span>' END AS tT,
						 IG.title AS grp,
						 ISNULL(U.fname, '') + ' ' + ISNULL(U.lname, '') AS n,
						 ISNULL(U2.fname, '') + ' ' + ISNULL(U2.lname, '') AS nm, 
                         --dbo.func_udf_Gregorian_To_Persian_withTime(I.saveDateTime) AS [save],
						 --ISNULL(dbo.func_udf_Gregorian_To_Persian_withTime(I.modifyDateTime), '') AS modify,
						 convert(nvarchar(MAX), I.saveDateTime, 20) AS [save],
						 convert(nvarchar(MAX), I.modifyDateTime, 20) AS [modify],
						 I.fk_status_id AS fk_status_id,
						 ISNULL(ST.title, S.title) AS status,
						 ISNULL(I.technicalTitle, '') AS technicalTitle,
						 CASE WHEN I.sex = 0 THEN 'زن' ELSE 'مرد' END AS sex,
						 CASE WHEN I.id IS NULL THEN '' 
						      WHEN I.fk_status_id = 15 THEN '<select class="form-control" name="status" id="st_' + CAST(I.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(I.id AS varchar(50)) 
                         + '''' + ')"><option value="15" selected>فعال</option><option value="16">غیر فعال</option><option value="20">در انتظار تائید</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(I.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(I.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>' 
						      WHEN I.fk_status_id = 16 THEN '<select class="form-control" name="status" id="st_' + CAST(I.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(I.id AS varchar(50)) 
                         + '''' + ')"><option value="15">فعال</option><option value="16" selected>غیر فعال</option><option value="20">در انتظار تائید</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(I.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(I.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>' 
						      WHEN I.fk_status_id = 20 THEN '<select class="form-control" name="status" id="st_' + CAST(I.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(I.id AS varchar(50)) 
                         + '''' + ')"><option value="15">فعال</option><option value="16">غیر فعال</option><option value="20"  selected>در انتظار تائید</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(I.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(I.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>' END AS teStatus
FROM                     dbo.TB_ITEM AS I with(nolock) INNER JOIN
                         dbo.TB_TYP_ITEM_GRP AS IG with(nolock) ON I.fk_itemGrp_id = IG.id LEFT OUTER JOIN
                         dbo.TB_DOCUMENT_ITEM AS di with(nolock) ON I.id = di.pk_fk_item_id AND di.isDefault = 1 LEFT OUTER JOIN
                         dbo.TB_DOCUMENT AS d with(nolock) ON di.pk_fk_document_id = d.id LEFT OUTER JOIN
                         dbo.TB_USR AS U with(nolock) ON I.fk_usr_saveUser = U.id LEFT OUTER JOIN
                         dbo.TB_USR AS U2 with(nolock) ON I.fk_modify_usr_id = U2.id LEFT OUTER JOIN
                         dbo.TB_STATUS AS S with(nolock) ON I.fk_status_id = S.id LEFT OUTER JOIN
                         dbo.TB_STATUS_TRANSLATIONS AS ST with(nolock) ON S.id = ST.id AND ST.lan = 'fa' LEFT OUTER JOIN
						 dbo.func_pt_countOfImgItem() As imgCount ON I.id = imgCount.fk_item_id LEFT OUTER JOIN
                         dbo.TB_STORE_ITEM_QTY AS Q ON I.id = Q.pk_fk_item_id INNER JOIN
                         dbo.TB_STORE AS STO ON Q.pk_fk_store_id = STO.id
						 where (STO.id = @storeId OR @storeId IS NULL) AND (S.id = @statusId OR @statusId IS NULL) AND I.itemType = @itemType
)