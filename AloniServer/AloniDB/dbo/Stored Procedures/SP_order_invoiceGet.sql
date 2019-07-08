CREATE PROCEDURE [dbo].[SP_order_invoiceGet]
	 @clientLanguage AS CHAR(2)
	,@appId AS TINYINT
	,@clientIp AS VARCHAR(50)
	,@pageNo AS INT
	,@search AS VARCHAR(100) = null
	,@parent AS VARCHAR(20)
	,@userId AS BIGINT
	,@orderId AS bigint
	,@storeId AS BIGINT 
AS
--TODO  هزینه ارسال در فاکتور صحیح نمی باشد



select d.rowId
      ,d.sum_qty as qty
	  ,ISNULL(siq.localBarcode,i.barcode) + ' ' +isnull(i_trn.title,i.title)  as title
	  ,[dbo].[func_addThousandsSeperator]( d.cost_payable_withTax_withDiscount) as debit
	  ,'0' as credit
	  ,d.cost_payable_withTax_withDiscount as debit_val
	  ,0 as credit_val
	  ,isnull(u_trn.title, u.title) as unit_title
from dbo.func_getOrderDtls(@orderId,null) as d
 join TB_ORDER as o on d.orderId = o.id
 join TB_STORE_ITEM_QTY as siq on siq.pk_fk_store_id = @storeId and siq.pk_fk_item_id = d.itemId 
 join TB_ITEM as i on d.itemId = i.id
 left join TB_ITEM_TRANSLATIONS as i_trn on d.itemId = i_trn.id and i_trn.lan = @clientLanguage
 left join TB_TYP_UNIT as u on i.fk_unit_id = u.id
 left join TB_TYP_UNIT_TRANSLATIONS as u_trn on i.fk_unit_id = u_trn.id and u_trn.lan = @clientLanguage
 where o.fk_store_storeId = @storeId
 union all
 select null as rowId
      ,null as qty
	  ,sd.title as title
	  ,[dbo].[func_addThousandsSeperator](h.sum_cost_delivery) as debit
	  ,'0' as credit
	  ,h.sum_cost_delivery as debit_val
	  ,0 as credit_val
	  ,'ارسال' as unit_title
from dbo.func_getOrderHdrs(@orderId) as h
join TB_ORDER_HDR as oh on oh.fk_order_orderId = @orderId and oh.fk_docType_id = 1
join TB_STORE_DELIVERYTYPES as sd on oh.fk_deliveryTypes_id = sd.id



 union all
 select
null as rowId
,null as qty
,ISNULL(odt_trn.title,odt.title) as title
,[dbo].[func_addThousandsSeperator](abs(sum(fa.debit))) as debit
,'0' as credit
,abs(sum(fa.debit)) as debit_val
,0 as credit_val
,'-' as unit_title
from 
TB_ORDER_HDR as oh
join TB_TYP_ORDER_DOC_TYPE as odt on oh.fk_docType_id = odt.id
left join TB_TYP_ORDER_DOC_TYPE_TRANSLATIONS as odt_trn on oh.fk_docType_id = odt_trn.Id and odt_trn.lan = @clientLanguage
left join
TB_FINANCIAL_ACCOUNTING as fa on oh.id = fa.fk_orderHdr_id and fa.fk_order_orderId = @orderId and fa.fk_typFinancialRegardType_id in (10001,10011,10041,10051,10061,10071,10081,10091,10101,10111,10121,10131)
where oh.fk_order_orderId = @orderId and  oh.fk_docType_id in (2,3,4,5,6,9,10,11,12)
group by ISNULL(odt_trn.title,odt.title)




select total_remaining_payment_payable from dbo.func_getOrderHdrs(@orderId)


select [dbo].[func_getCurrencyTitleByLanguage](@clientLanguage,@storeId)