create view VW_storeCommentOpinion as select 
i.id itemId,
i.title itemTitle,
s.id storeId,
s.title storeTitle,
op.id opinionId,
op.title opinionTitle,
opop.id opinionCommentId,
opop.comment,
opop.saveDateTime,
opop.fk_status_id statusId,
u.id userId,
u.fname + ' '+u.lname userName
from 
	TB_ITEM i
	inner join TB_STORE_ITEM_OPINIONPOLL op on i.id = op.fk_item_id
	inner join TB_STORE s on s.id = op.fk_store_id
	inner join TB_STORE_ITEM_OPINIONPOLL_COMMENTS opop on op.id = opop.fk_opinionpoll_id
	inner join TB_USR u on u.id = opop.fk_usr_commentUserId