CREATE VIEW dbo.vw_getOrderList
AS
SELECT        ord.id, ord.fk_usr_customerId, ISNULL(customer.fname, '') AS custTitle, ISNULL(customer.mobile, '') AS custMobile, ord.fk_store_storeId, ISNULL(store.title, '') AS stTitle, ISNULL(storeCity.title, '') AS stloc, 
                         stat.id as fk_status_statusId, ISNULL(stat.title, '') AS ordStatus, CASE WHEN ord.reviewDateTime IS NULL 
                         THEN '<small class="label label-warning" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-question-sign"></i>  بررسی نشده</small>'
                          ELSE '<small class="label label-primary" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-question-sign"></i>  بررسی شده</small>'
                          END + CASE WHEN ord.isSecurePayment IS NULL OR
                         ord.isSecurePayment = 0 THEN '<small class="label label-danger" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>  امن نیست</small><br/>'
                          WHEN ord.isSecurePayment = 1 THEN '<small class="label label-success" style="display:inline-block; margin-left:2px; margin-bottom:1px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-flash"></i>  امن است</small> <br/>'
                          ELSE '' END + CASE WHEN ord.isTwoStepPayment IS NULL OR
                         ord.isTwoStepPayment = 0 THEN '<small class="label label-primary" style="display:inline-block; margin-left:2px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-tag"></i>  یک مرحله ای</small>'
                          WHEN ord.isTwoStepPayment = 1 THEN '<small class="label label-default" style="display:inline-block; margin-left:2px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300; color:#ffffff;"><i class="glyphicon glyphicon-tags"></i>  دو مرحله ای</small>'
                          ELSE '' END + CASE WHEN ord.fk_paymentMethode_id = 1 THEN '<small class="label label-warning" style="display:inline-block; margin-left:2px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-credit-card"></i>  نقدی</small>'
                          WHEN ord.fk_paymentMethode_id = 2 THEN '<small class="label label-info" style="display:inline-block; margin-left:2px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-briefcase"></i>  اعتباری</small>'
                          WHEN ord.fk_paymentMethode_id = 3 THEN '<small class="label label-success" style="display:inline-block; margin-left:2px; padding:4px 4px 5px 4px; font-size:10px; font-weight:300;"><i class="glyphicon glyphicon-globe"></i>  آنلاین</small>'
                          ELSE '' END AS paymentType, ISNULL(CAST(dbo.func_udf_Gregorian_To_Persian_withTime(ord.saveDateTime) AS varchar(50)), '') AS saveTime
FROM            dbo.TB_ORDER AS ord LEFT OUTER JOIN
                         dbo.TB_USR AS customer ON ord.fk_usr_customerId = customer.id LEFT OUTER JOIN
                         dbo.TB_STORE AS store ON ord.fk_store_storeId = store.id LEFT OUTER JOIN
                         dbo.TB_STATUS AS stat ON [dbo].[func_getOrderStatus](ord.id,ord.fk_status_statusId,ord.lastDeliveryDateTime) = stat.id LEFT OUTER JOIN
                         dbo.TB_TYP_PAYMENT_METHODE AS payment ON ord.fk_paymentMethode_id = payment.id LEFT OUTER JOIN
                         dbo.TB_CITY AS storeCity ON store.fk_city_id = storeCity.id



