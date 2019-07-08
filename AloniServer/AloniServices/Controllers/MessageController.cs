using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به ماژول پیام ها
    /// </summary>
    [RoutePrefix("Message")]
    public class MessageController : AdvancedApiController
    {
        /// <summary>
        /// سرویس اضافه کردن پیام
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("add")]
        [Exception]
        [HttpPost]
        public IHttpActionResult add(modelBinding model)
        {
            if(!ModelState.IsValid)
                 return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addaMessage", "MessageController_add"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@message", model.message.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@fk_usr_destUserId", model.fk_usr_destUserId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@fk_store_destStoreId", model.fk_store_destStoreId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@fk_orderHdr_RelatedOrderId", model.fk_orderHdr_RelatedOrderId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@displayAsTicket", model.displayAsTicket.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@messageAsStore", model.messageAsStore.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@conversationWithStore", model.conversationWithStore.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@conversationWithPortal", model.conversationWithPortal.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@conversationId", model.conversationId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@conversationAbout_ItemId", model.fk_conversationAbout_itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@conversationAbout_oppinionId", model.fk_conversationAbout_itemOppinion_commentId.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }
            
        }
        /// <summary>
        /// سرویس دریافت لیست پیام های مربوط به کاربر یا فروشگاه به ترتیب تاریخ از جدید به قدیم
        /// فقط یکی از پارامترهای ورودی باید ست  شود 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult GetList(LongItemModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getMessage", "MessageController_getList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@spicialUserId",model.userId);
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();
                List<modelBinding> result = new List<modelBinding>();
                while(repo.sdr.Read())
                {
                    var item = new modelBinding();
                    item.id = Convert.ToInt64(repo.sdr["id"]);
                    item.message = repo.sdr["message"].ToString();
                    if (!object.ReferenceEquals(repo.sdr["fk_usr_destUserId"], DBNull.Value))
                        item.fk_usr_destUserId = Convert.ToInt64(repo.sdr["fk_usr_destUserId"]);
                    if (!object.ReferenceEquals(repo.sdr["fk_store_destStoreId"], DBNull.Value))
                        item.fk_store_destStoreId = Convert.ToInt64(repo.sdr["fk_store_destStoreId"]);
                    item.fk_usr_senderUser = Convert.ToInt64(repo.sdr["fk_usr_senderUser"]);
                    item.saveDateTime = Convert.ToDateTime(repo.sdr["saveDateTime"]);
                    if (!object.ReferenceEquals(repo.sdr["seenDateTime"], DBNull.Value))
                        item.seenDateTime = Convert.ToDateTime(repo.sdr["seenDateTime"]);
                    item.deleted = Convert.ToBoolean(repo.sdr["deleted"]);
                    if (!object.ReferenceEquals(repo.sdr["fk_staff_destStaffId"], DBNull.Value))
                        item.fk_staff_id = Convert.ToInt16(repo.sdr["fk_staff_destStaffId"]);
                    result.Add(item);
                }
              
                return Ok(result);
            }
        }
        /// <summary>
        /// سرویس ویرایش تاریخ و ساعت فیلد دیده شدن پیام
        /// </summary>
        /// <param name="ids">لیست از آی دی پیام هایی که خوانده شده </param>
        /// <returns></returns>
        [Route("update")]
        [Exception]
        [HttpPost]
        public IHttpActionResult SetSeenMessage(List<LongKeyModel> ids)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateMessage", "MessageController_update"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dt = new DataTable();
                DataRow row;
                dt.Columns.Add("msgId");
                foreach (var i in ids)
                {
                    row = dt.NewRow();
                    row["msgId"] = i.id;
                    dt.Rows.Add(row);
                }
               
               var param =  repo.cmd.Parameters.AddWithValue("@ids", dt);
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok();
            }
        }
        /// <summary>
        /// سرویس اعلام خوانده شدن پیام ها
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("seenMessage")]
        [Exception]
        [HttpPost]
        public IHttpActionResult SetSeenMessage_V2(SetSeenMessageBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_seenMessage", "MessageController_seenMessage"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@messageId", model.msgId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@orderId", model.orderId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@conversationId", model.conversationId.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }

        /// <summary>
        /// سرویس دریافت conversation های کاربر جاری
        /// شناسه فروشگاه در صورت استفاده در هدر ست شود
        /// </summary>
        /// <returns></returns>
        [Route("getMyMessageList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getMyMessageList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getMyMessageList", "MessageController_getMyMessageList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(
                            result.AsEnumerable().Select(
                                row => new
                                {
                                    sentUserId = row.Field<long?>("sentUserId"),
                                    sentStoreId = row.Field<long?>("sentStoreId"),
                                    title = row.Field<string>("title"),
                                    sent = row.Field<string>("sent"),
                                    dest = Convert.ToString(row.Field<string>("dest")),
                                    destStoreId = row.Field<long?>("destStoreId"),
                                    destUserId = row.Field<long?>("destUserId"),
                                    message = Convert.ToString(row.Field<object>("message")),
                                    datetime = Convert.ToString(row.Field<object>("date_")),
                                    convId = Convert.ToInt64(row.Field<object>("fk_conversation_id")),
                                    unreadMessageCount = repo.ds.Tables[1].AsEnumerable().Where(i => Convert.ToInt64(row.Field<object>("sentUserId") is DBNull ? 0 : row.Field<object>("sentUserId")) == Convert.ToInt64(i.Field<object>("sentId")) | Convert.ToInt64(row.Field<object>("sentStoreId") is DBNull ? 0 : row.Field<object>("sentStoreId")) == Convert.ToInt64(i.Field<object>("sentId"))).Select(i=> Convert.ToInt32(i.Field<object>("unread"))).FirstOrDefault(),
                                    fk_conversationAbout_ItemId = Convert.ToInt64(row.Field<object>("fk_conversationAbout_ItemId")),
                                    conversationWithPortal = Convert.ToBoolean(row.Field<object>("conversationWithPortal")),
                                    conversationWithStore = Convert.ToBoolean(row.Field<object>("conversationWithStore")),
                                    fk_conversationAbout_opinionPollId = Convert.ToInt64(row.Field<object>("fk_conversationAbout_opinionPollId")),
                                    fk_conversationAbout_ItemEvaluationId = Convert.ToInt64(row.Field<object>("fk_conversationAbout_ItemEvaluationId"))
                                }).ToList()
                         );
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getMessageListInConversation")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getMessageListInSpecialConversation(getMessageListInConversationModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getMessageListInSpecialConversation", "MessageController_getMessageListInSpecialConversation", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@convId", model.convId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@commentId", model.fk_Opinion_CommnetId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@evalId", model.fk_Item_EvaluationId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@convAsPortal", model.convAsPortal.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(
                            result.AsEnumerable().Select(
                                row => new
                                {
                                    id = Convert.ToInt64(row.Field<object>("id")),
                                    saveDate = string.IsNullOrEmpty(row.Field<string>(1)) ? "" : row.Field<string>(1),
                                    saveTime = string.IsNullOrEmpty(row.Field<string>(2)) ? "" : row.Field<string>(2),
                                    message = string.IsNullOrEmpty(row.Field<string>(3)) ? "" : row.Field<string>(3),
                                    seenDate = string.IsNullOrEmpty(row.Field<string>(4)) ? "" : row.Field<string>(4),
                                    seenTime = string.IsNullOrEmpty(row.Field<string>(5)) ? "" : row.Field<string>(5),
                                    isMine = Convert.ToBoolean(row.Field<int>(6)),
                                    
                                }).ToList()
                         );
            }
        }
        /// <summary>
        /// سرویس دریافت پیام های یک گفتگو پیرامون کامنت ها و ارزیابی ها
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getCommentMessageListConversation")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getCommentMessageListConversation(getMessageListInConversationModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getCommentMessageListConversation", "MessageController_getCommentMessageListConversation", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@commentId", model.fk_Opinion_CommnetId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@evalId", model.fk_Item_EvaluationId.dbNullCheckLong());
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(
                            result.AsEnumerable().Select(
                                row => new
                                {
                                    id = Convert.ToInt64(row.Field<object>("id")),
                                    saveDate = string.IsNullOrEmpty(row.Field<string>(1)) ? "" : row.Field<string>(1),
                                    saveTime = string.IsNullOrEmpty(row.Field<string>(2)) ? "" : row.Field<string>(2),
                                    message = string.IsNullOrEmpty(row.Field<string>(3)) ? "" : row.Field<string>(3),
                                    seenDate = string.IsNullOrEmpty(row.Field<string>(4)) ? "" : row.Field<string>(4),
                                    seenTime = string.IsNullOrEmpty(row.Field<string>(5)) ? "" : row.Field<string>(5),
                                    isMine = Convert.ToBoolean(row.Field<int>(6)),
                                    senderName = string.IsNullOrEmpty(row.Field<string>(7)) ? "" : row.Field<string>(7)
                                }).ToList()
                         );
            }
        }
        /// <summary>
        /// سرویس اضافه کردن پیام پیرامون کامنت و یا نظرسنجی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addMessageOppinion")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addMessageOppinion(modelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addMessageAboutPoll", "MessageController_SP_addMessageAboutPoll"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@message", model.message.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                //repo.cmd.Parameters.AddWithValue("@fk_usr_destUserId", model.fk_usr_destUserId.getLongDbValue());
                repo.cmd.Parameters.AddWithValue("@conversationId", model.conversationId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@conversationAbout_ItemEvaluationId", model.fk_conversationAbout_itemEvaluationId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@conversationAbout_ItemOppinionPollId", model.fk_conversationAbout_itemOppinion_commentId.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }

        /// <summary>
        /// 
        /// </summary>
        public class modelBinding
        {
            /// <summary>
            /// ای دی پیام
            /// </summary>
            public long? id { get; set; }
            /// <summary>
            /// متن پیام
            /// </summary>
            /// 
            public string message { get; set; }
            /// <summary>
            /// کد کاربر دریافت کننده پیام
            /// </summary>
            public long? fk_usr_destUserId { get; set; }
            /// <summary>
            /// کد فروشگاه دریافت کننده پیام
            /// </summary>
            public long? fk_store_destStoreId { get; set; }
            /// <summary>
            /// کد ارسال کننده پیام
            /// </summary>
            public long? fk_usr_senderUser { get; set; }
            /// <summary>
            /// تاریخ و زمان ایجاد پیام
            /// نیاز به ارسال به سرور نیست(پارامتر اختیاری)
            /// </summary>
            public DateTime? saveDateTime { get; set; }
            /// <summary>
            /// تاریخ و زمان دیدن پیام
            /// </summary>
            public DateTime? seenDateTime { get; set; }
            /// <summary>
            /// وضعیت پیام (حذف شده یا فعال)
            /// 
            /// </summary>
            public bool? deleted { get; set; }
            /// <summary>
            /// سمت کاربر
            /// </summary>
            public short?  fk_staff_id { get; set; }
            /// <summary>
            /// ای دی سفارشی که پیام مرتبط با آن است
            /// </summary>
            public long? fk_orderHdr_RelatedOrderId { get; set; }
            /// <summary>
            /// ذخیره به عنوان تیکت
            /// </summary>
            public bool displayAsTicket { get; set; }
            /// <summary>
            /// شناسه فروشگاه ارسال کننده
            /// </summary>
            public long? fk_store_senderStoreId { get; set; }
            /// <summary>
            /// پیام از طرف فروشگاه هست یا خیر
            /// </summary>
            public bool messageAsStore { get; set; }
            public bool conversationWithStore { get; set; }
            public bool conversationWithPortal { get; set; }
            public long? conversationId { get; set; }
            /// <summary>
            /// چنانچه مکالمه پیرامون یک کالاست و میخواهید در یک گفتگوی مجزا ذخیره شود شناسه آیتم مورد نظر را وارد نمایید
            /// </summary>
            public long? fk_conversationAbout_itemId { get; set; }
            /// <summary>
            /// مکالمه مدیران یک پنل پیرامون یک کامنت
            /// </summary>
            public long? fk_conversationAbout_itemEvaluationId { get; set; }
            /// <summary>
            /// مکالمه مدیران یک پنل پیرامون یک کامنت نظرسنجی
            /// </summary>
            public long? fk_conversationAbout_itemOppinion_commentId { get; set; }
        }
        public class ShortKeyModel
        {
            public short? id { get; set; }
        }
        public class LongItemModel:searchParameterModel
        {
            public long storeId { get; set; }
            public long userId { get; set; }
        }
        public class getMessageListInConversationModel:searchParameterModel
        {
            public long? convId { get; set; }
            public bool convAsPortal { get; set; }
            public long? fk_Item_EvaluationId { get; set; }
            public long? fk_Opinion_CommnetId { get; set; }
        }
        public class SetSeenMessageBindingModel
        {
            /// <summary>
            /// شناسه جدیدترین پیام خوانده نشده
            /// </summary>
            public long msgId { get; set; }
            /// <summary>
            /// شناسه گفتگو
            /// </summary>
            public long conversationId { get; set; }
            /// <summary>
            /// شناسه سفارش
            /// </summary>
            public long orderId { get; set; }
        }
    }
}
