CREATE VIEW [dbo].[vw_getPaymentStore]
	AS
	SELECT 
	S.id AS id
   ,S.title AS title
   ,S.fk_bank_id AS bankId
   ,B.title AS bankDsc
   ,S.fk_OnlinePayment_StatusId
   ,onSt.title AS online_status_dsc
   ,S.fk_securePayment_StatusId
   ,seSt.title AS secure_status_dsc
   ,S.GetwayPaymentValidationCode
   ,S.account
   ,CASE WHEN S.id IS NULL THEN ''
				      WHEN S.fk_OnlinePayment_StatusId = 12 THEN '<select class="form-control" name="status" id="st_' + CAST(S.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(S.id AS varchar(50)) 
                         + '''' + ')"><option value="12" selected>در انتظار بررسی</option><option value="13">فعال</option><option value="14">غیر فعال</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>' 
				      WHEN S.fk_OnlinePayment_StatusId = 13 THEN '<select class="form-control" name="status" id="st_' + CAST(S.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(S.id AS varchar(50)) 
                         + '''' + ')"><option value="12">در انتظار بررسی</option><option value="13" selected>فعال</option><option value="14">غیر فعال</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>'
					  WHEN S.fk_OnlinePayment_StatusId = 14 THEN '<select class="form-control" name="status" id="st_' + CAST(S.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(S.id AS varchar(50)) 
                         + '''' + ')"><option value="12">در انتظار بررسی</option><option value="13">فعال</option><option value="14" selected>غیر فعال</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>' 
				      END AS onlineStatus
,CASE WHEN S.id IS NULL THEN ''
				      WHEN S.fk_securePayment_StatusId = 12 THEN '<select class="form-control" name="status" id="st_' + CAST(S.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(S.id AS varchar(50)) 
                         + '''' + ')"><option value="12" selected>در انتظار بررسی</option><option value="13">فعال</option><option value="14">غیر فعال</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>' 
				      WHEN S.fk_securePayment_StatusId = 13 THEN '<select class="form-control" name="status" id="st_' + CAST(S.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(S.id AS varchar(50)) 
                         + '''' + ')"><option value="12">در انتظار بررسی</option><option value="13" selected>فعال</option><option value="14">غیر فعال</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>'
					  WHEN S.fk_securePayment_StatusId = 14 THEN '<select class="form-control" name="status" id="st_' + CAST(S.id AS varchar(50)) + '" onblur="changeStatus(' + '''' + CAST(S.id AS varchar(50)) 
                         + '''' + ')"><option value="12">در انتظار بررسی</option><option value="13">فعال</option><option value="14" selected>غیر فعال</option></select><img src = "/Content/img/ajax-loader.gif" id="lo_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="position:absolute; left:468px; top:59px;" /><p id="ms_'+ CAST(S.id AS varchar(50)) +'" class="hidden" style="font-size:13px; font-weight:500;"></p>' 
				      END AS secureStatus
	FROM TB_STORE AS S
	LEFT JOIN TB_STATUS AS onSt ON onSt.id = S.fk_OnlinePayment_StatusId
	LEFT JOIN TB_STATUS AS seSt ON seSt.id = S.fk_securePayment_StatusId
	LEFT JOIN TB_BANK AS B ON B.id = S.fk_bank_id
