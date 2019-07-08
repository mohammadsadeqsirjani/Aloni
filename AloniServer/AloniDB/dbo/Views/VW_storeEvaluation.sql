create view VW_storeEvaluation as select 
i.id itemId,
i.title itemTitle,
s.id storeId,
s.title storeTitle,
eval.id evaluationId,
eval.fk_usr_id userId,
eval.comment,
eval.saveDateTime,
eval.fk_status_id statusId,
u.fname + ' '+ u.lname userName
from 
	TB_ITEM i
	inner join TB_STORE_ITEM_EVALUATION eval on i.id = eval.fk_item_id
	inner join TB_STORE s on s.id = eval.fk_store_id
	inner join TB_USR u on u.id = eval.fk_usr_id