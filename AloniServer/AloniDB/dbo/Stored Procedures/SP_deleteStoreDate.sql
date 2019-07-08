create procedure SP_deleteStoreDate
(
	@storeId as bigint
)
AS
BEGIN
	
delete from TB_USR_STAFF where fk_store_id = @storeId
delete from TB_FINANCIAL_ACCOUNT where fk_store_id = @storeId
delete from TB_STORE_TEMPACCOUNTDATA where fk_store_id = @storeId
delete from TB_FINANCIAL_ACCOUNT  where fk_store_id = @storeId
delete from TB_STORE_VITRIN where fk_store_id = @storeId
delete from TB_ORDER_DTL where fk_orderHdr_id = (select id from TB_ORDER_HDR where fk_store_id = @storeId)
delete from TB_ORDER where fk_store_storeId = @storeId
delete from TB_STORE_ITEM_WARRANTY where pk_fk_store_id = @storeId
delete from TB_STORE_ITEM_GROUPING where pk_fk_store_id = @storeId
delete from TB_STORE_ITEM_COLOR where pk_fk_store_id = @storeId
delete from TB_STORE_ITEM_QTY where pk_fk_store_id = @storeId
delete from TB_STORE_REPORT where fk_store_id = @storeId
delete from TB_STORE_SOCIALNETWORK where fk_store_id = @storeId
delete from TB_STORE_MARKETING where fk_store_id = @storeId
delete from TB_STORE_EVALUATION where fk_store_id = @storeId
delete from TB_STORE_SCHEDULE where fk_store_id = @storeId
delete from TB_STORE_EMPLOYEE where fk_store_id = @storeId
delete from TB_STORE_DELIVERYTYPES where fk_store_id = @storeId
delete from TB_STORE_WARRANTY where fk_store_id = @storeId
delete from TB_STORE_GROUPING where fk_store_id = @storeId               
delete from TB_STORE_ABOUT where fk_store_id = @storeId
delete from TB_STORE_PHONE where fk_store_id = @storeId
delete from TB_STORE_ITEM_EVALUATION where fk_store_id = @storeId
delete from TB_STORE_CERTIFICATE where fk_store_id = @storeId
delete from TB_STORE_CUSTOMER where pk_fk_store_id = @storeId
delete from TB_STORE_EXPERTISE where pk_fk_store_id = @storeId
delete from TB_DOCUMENT_STORE where pk_fk_store_id = @storeId
delete from TB_MESSAGE where fk_store_destStoreId = @storeId or fk_store_senderStoreId = @storeId
delete from TB_USR_LOG where fk_store_id = @storeId
delete from TB_ADVERTISING where fk_store_id = @storeId 
delete from TB_INVITATION where fk_store_id = @storeId
delete from TB_APP_FUNC_USR where fk_store_id = @storeId
delete from TB_ITEM where fk_savestore_id = @storeId
delete from TB_STORE where id = @storeId
END