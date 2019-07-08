using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مرتبط با نظر سنجی های فروشگاه ها در ارتباط با کالا
    /// </summary>
    [RoutePrefix("StoreItemOpinionPoll")]
    public class StoreItemOpinionPollController : AdvancedApiController
    {
        /// <summary>
        /// ایجاد یا ویرایش یک نظرسنجی
        /// </summary>
        /// <param name="model">مدل ورودی</param>
        /// <returns></returns>
        [Route("AddUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult AddUpdate(opinionpolBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_opinionpoll_AddUpdate", "opinionpoll_AddUpdate", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGrpTitle_override", model.itemGrpTitle_override.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemPicId_override", model.itemPicId_override.getDbValue());
                repo.cmd.Parameters.AddWithValue("@startDateTime", model.startDateTime.getDbValue());
                repo.cmd.Parameters.AddWithValue("@endDateTime", model.endDateTime.getDbValue());
                repo.cmd.Parameters.AddWithValue("@resultIsPublic", model.resultIsPublic.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.getDbValue());
                repo.cmd.Parameters.AddWithValue("@publish", model.publish.getDbValue());
                var par_existingOpinionPollId = repo.cmd.Parameters.Add("@existingOpinionPollId", SqlDbType.BigInt);
                par_existingOpinionPollId.Direction = ParameterDirection.InputOutput;
                par_existingOpinionPollId.Value = model.existingOpinionPollId.getDbValue();
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { opinionPollId = par_existingOpinionPollId.Value });
            }

        }
        /// <summary>
        /// ایجاد یا ویرایش یک نظرسنجی_ورژن 2 (لیست گزینه ها / سوالات نیز به صورت همزمان دریافت وایجاد / بروزرسانی میش ود)
        /// </summary>
        /// <param name="model">مدل ورودی</param>
        /// <returns></returns>
        [Route("AddUpdate/v2")]
        [Exception]
        [HttpPost]
        public IHttpActionResult AddUpdate_v2(opinionpolBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_opinionpoll_AddUpdate_v2", "opinionpoll_AddUpdate_v2", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");


                DataTable dtOptions = ClassToDatatableConvertor.CreateDataTable(model.options ?? new List<optionAddUpdateBindingModel>());
                var p_tOpinions = repo.cmd.Parameters.AddWithValue("@options", dtOptions);
                p_tOpinions.SqlDbType = SqlDbType.Structured;


                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGrpTitle_override", model.itemGrpTitle_override.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemPicId_override", model.itemPicId_override.getDbValue());
                repo.cmd.Parameters.AddWithValue("@startDateTime", model.startDateTime.getDbValue());
                repo.cmd.Parameters.AddWithValue("@endDateTime", model.endDateTime.getDbValue());
                repo.cmd.Parameters.AddWithValue("@resultIsPublic", model.resultIsPublic.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.getDbValue());
                repo.cmd.Parameters.AddWithValue("@publish", model.publish.getDbValue());
                var par_existingOpinionPollId = repo.cmd.Parameters.Add("@existingOpinionPollId", SqlDbType.BigInt);
                par_existingOpinionPollId.Direction = ParameterDirection.InputOutput;
                par_existingOpinionPollId.Value = model.existingOpinionPollId.getDbValue();
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { opinionPollId = par_existingOpinionPollId.Value });
            }

        }
        /// <summary>
        /// ایجاد یا ویرایش یک سوال / گزینه در نظر سنجی موجود
        /// </summary>
        /// <param name="model">مدل ورودی</param>
        /// <returns></returns>
        [Route("optionAddUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult optionAddUpdate(optionAddUpdateBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_opinionpoll_option_AddUpdate", "opinionpoll_option_AddUpdate", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@opinionpollId", model.opinionpollId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.getDbValue());
                repo.cmd.Parameters.AddWithValue("@orderingNo", model.orderingNo.getDbValue());
                var par_existingOpinionPoolOptionId = repo.cmd.Parameters.Add("@existingOpinionPoolOptionId", SqlDbType.BigInt);
                par_existingOpinionPoolOptionId.Direction = ParameterDirection.InputOutput;
                par_existingOpinionPoolOptionId.Value = model.existingOpinionPoolOptionId.getDbValue();
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { opinionPoolOptionId = par_existingOpinionPoolOptionId.Value });
            }

        }
        /// <summary>
        /// دریافت لیست نظر سنجی ها
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList(StoreItemOpinionPollGetListBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_opinionpoll_getList", "opinionpoll_getList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@opinionPollId", model.opinionPollId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", appId == (object)2 ? model.storeId.getDbValue() : storeId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemBarcode", model.itemBarcode.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGrpId", model.itemGrpId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemGrpType", model.itemGrpType.getDbValue());
                repo.cmd.Parameters.AddWithValue("@itemType", model.itemType.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sex", model.sex.getDbValue());
                repo.cmd.Parameters.AddWithValue("@publish", model.publish.getDbValue());
                repo.cmd.Parameters.AddWithValue("@resultIsPublic", model.resultIsPublic.getDbValue());
                repo.cmd.Parameters.AddWithValue("@startDateTime", model.startDateTime.getDbValue());
                repo.cmd.Parameters.AddWithValue("@endDateTime", model.endDateTime.getDbValue());
                repo.cmd.Parameters.AddWithValue("@opinionPollIsRunning", model.opinionPollIsRunning.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sort_countOfparticipants", model.sort_countOfparticipants.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sort_totalAvg", model.sort_totalAvg.getDbValue());
                repo.cmd.Parameters.AddWithValue("@sort_startDateTime", model.sort_startDateTime.getDbValue());

                repo.ExecuteAdapter();


                //DataTable dt_options =
                //    repo.ds.Tables[1].AsEnumerable().Select(i =>
                //                                            new
                //                                            {
                //                                                a = 1
                //                                            });

                var dt_options = repo.ds.Tables.Count >= 2 ? repo.ds.Tables[1] : null;
                var dt_userComment = repo.ds.Tables.Count >= 3 ? repo.ds.Tables[2] : null;
                var dt_commentCount = repo.ds.Tables.Count >= 4 ? repo.ds.Tables[3] : null;

                return Ok(

                    repo.ds.Tables[0].AsEnumerable().Select(i =>
                                                            new
                                                            {
                                                                id = i.Field<object>("id"),
                                                                title = i.Field<object>("title"),
                                                                createDateTime = i.Field<object>("createDateTime"),
                                                                store_id = i.Field<object>("store_id"),
                                                                store_title = i.Field<object>("store_title"),
                                                                store_titleSecond = i.Field<object>("store_titleSecond"),
                                                                startDate = i.Field<object>("startDate"),
                                                                endDate = i.Field<object>("endDate"),



                                                                startDateTime = i.Field<object>("startDateTime"),
                                                                endDateTime = i.Field<object>("endDateTime"),

                                                                isActive = i.Field<object>("isActive"),
                                                                publish = i.Field<object>("publish").dbNullCheckBoolean(),
                                                                opinionPollIsRunning = i.Field<object>("opinionPollIsRunning").dbNullCheckBoolean(),

                                                                resultIsPublic = i.Field<object>("resultIsPublic"),
                                                                itemId = i.Field<object>("itemId"),
                                                                sex =  i.Field<object>("sex").dbNullCheckBoolean(),
                                                                itemBarcode = i.Field<object>("itemBarcode"),
                                                                itemGrpType = i.Field<object>("itemType"),
                                                                item_title = i.Field<object>("item_title"),
                                                                itemGrp_title = i.Field<object>("itemGrp_title"),
                                                                itemType = i.Field<object>("itemType"),
                                                                picUrl_thumb = i.Field<object>("picUrl_thumb"),
                                                                picUrl_full = i.Field<object>("picUrl_full"),
                                                                totalAvg = i.Field<object>("totalAvg"),
                                                                countOfparticipants = i.Field<object>("countOfparticipants"),
                                                                isEditable = i.Field<object>("isEditable"),
                                                                options = dt_options != null ? (dt_options.AsEnumerable().Select(j => new
                                                                {
                                                                    id = j.Field<object>("id"),
                                                                    title = j.Field<object>("title"),
                                                                    isActive = j.Field<object>("isActive"),
                                                                    optionAvg = j.Field<object>("optionAvg"),
                                                                    userScore = j.Field<object>("userScore")
                                                                })) : null,
                                                                //userComment = new
                                                                //{
                                                                //    userId = i.Field<object>("userId"),
                                                                //    name = i.Field<object>("name"),
                                                                //    comment = i.Field<object>("comment"),
                                                                //    avgOfScores = i.Field<object>("avgOfScores"),
                                                                //    time = i.Field<object>("time"),
                                                                //    edited = i.Field<object>("edited"),
                                                                //    p1_thumbcompeleteLink = i.Field<object>("p1_thumbcompeleteLink"),
                                                                //    p1_completeLink = i.Field<object>("p1_completeLink"),
                                                                //    p2_thumbcompeleteLink = i.Field<object>("p2_thumbcompeleteLink"),
                                                                //    p2_completeLink = i.Field<object>("p2_completeLink"),
                                                                //    p3_thumbcompeleteLink = i.Field<object>("p3_thumbcompeleteLink"),
                                                                //    p3_completeLink = i.Field<object>("p3_completeLink"),
                                                                //    p4_thumbcompeleteLink = i.Field<object>("p4_thumbcompeleteLink"),
                                                                //    p4_completeLink = i.Field<object>("p4_completeLink"),
                                                                //    p5_thumbcompeleteLink = i.Field<object>("p5_thumbcompeleteLink"),
                                                                //    p5_completeLink = i.Field<object>("p5_completeLink"),

                                                                //},
                                                                userComment = dt_userComment != null ? dt_userComment.AsEnumerable().Select(j => new
                                                                {
                                                                    userId = j.Field<object>("userId"),
                                                                    name = j.Field<object>("name"),
                                                                    comment = j.Field<object>("comment"),
                                                                    avgOfScores = j.Field<object>("avgOfScores"),
                                                                    time = j.Field<object>("time"),
                                                                    edited = j.Field<object>("edited"),
                                                                    d1 = j.Field<object>("d1"),
                                                                    p1_thumbcompeleteLink = j.Field<object>("p1_thumbcompeleteLink"),
                                                                    p1_completeLink = j.Field<object>("p1_completeLink"),
                                                                    d2 = j.Field<object>("d2"),
                                                                    p2_thumbcompeleteLink = j.Field<object>("p2_thumbcompeleteLink"),
                                                                    p2_completeLink = j.Field<object>("p2_completeLink"),
                                                                    d3 = j.Field<object>("d3"),
                                                                    p3_thumbcompeleteLink = j.Field<object>("p3_thumbcompeleteLink"),
                                                                    p3_completeLink = j.Field<object>("p3_completeLink"),
                                                                    d4 = j.Field<object>("d4"),
                                                                    p4_thumbcompeleteLink = j.Field<object>("p4_thumbcompeleteLink"),
                                                                    p4_completeLink = j.Field<object>("p4_completeLink"),
                                                                    d5 = j.Field<object>("d5"),
                                                                    p5_thumbcompeleteLink = j.Field<object>("p5_thumbcompeleteLink"),
                                                                    p5_completeLink = j.Field<object>("p5_completeLink"),

                                                                }).FirstOrDefault() : null,
                                                                commentCount = dt_commentCount == null ? null : dt_commentCount.AsEnumerable().Select(j => j.Field<object>("commentCount")).FirstOrDefault()






                                                                //comments = dt_comments != null ? (dt_comments.AsEnumerable().Select(j => new
                                                                //{
                                                                //    userId = j.Field<object>("userId"),
                                                                //    name = j.Field<object>("name"),
                                                                //    comment = j.Field<object>("comment"),
                                                                //    avgOfScores = j.Field<object>("avgOfScores"),
                                                                //    time = j.Field<object>("time"),
                                                                //    edited = j.Field<object>("edited"),
                                                                //    p1_thumbcompeleteLink = j.Field<object>("p1_thumbcompeleteLink"),
                                                                //    p1_completeLink = j.Field<object>("p1_completeLink"),
                                                                //    p2_thumbcompeleteLink = j.Field<object>("p2_thumbcompeleteLink"),
                                                                //    p2_completeLink = j.Field<object>("p2_completeLink"),
                                                                //    p3_thumbcompeleteLink = j.Field<object>("p3_thumbcompeleteLink"),
                                                                //    p3_completeLink = j.Field<object>("p3_completeLink"),
                                                                //    p4_thumbcompeleteLink = j.Field<object>("p4_thumbcompeleteLink"),
                                                                //    p4_completeLink = j.Field<object>("p4_completeLink"),
                                                                //    p5_thumbcompeleteLink = j.Field<object>("p5_thumbcompeleteLink"),
                                                                //    p5_completeLink = j.Field<object>("p5_completeLink"),

                                                                //}
                                                            })



                );
            }
        }
        /// <summary>
        /// دریافت لیست کامنت های یک نظرسنجی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("commentsGetList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult commentsGetList(StoreItemOpinionPollCommentGetListBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_opinionpoll_comments_getList", "opinionpoll_comments_getList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@opinionPollId", model.opinionPollId.getDbValue());
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(j => new
                {
                    id = j.Field<object>("id"),
                    userId = j.Field<object>("userId"),
                    name = j.Field<object>("name"),
                    comment = j.Field<object>("comment"),
                    avgOfScores = j.Field<object>("avgOfScores"),
                    time = j.Field<object>("time"),
                    edited = j.Field<object>("edited"),
                    p1_thumbcompeleteLink = j.Field<object>("p1_thumbcompeleteLink"),
                    p1_completeLink = j.Field<object>("p1_completeLink"),
                    p2_thumbcompeleteLink = j.Field<object>("p2_thumbcompeleteLink"),
                    p2_completeLink = j.Field<object>("p2_completeLink"),
                    p3_thumbcompeleteLink = j.Field<object>("p3_thumbcompeleteLink"),
                    p3_completeLink = j.Field<object>("p3_completeLink"),
                    p4_thumbcompeleteLink = j.Field<object>("p4_thumbcompeleteLink"),
                    p4_completeLink = j.Field<object>("p4_completeLink"),
                    p5_thumbcompeleteLink = j.Field<object>("p5_thumbcompeleteLink"),
                    p5_completeLink = j.Field<object>("p5_completeLink"),
                    userAndStoreConversationId = j.Field<object>("userAndStoreConversationId")
                }));
            }
        }
        /// <summary>
        /// پاسخ / ویرایش پاسخ نظرسنجی در اپ خریدار
        /// </summary>
        /// <param name="model">مدل ورودی</param>
        /// <returns></returns>
        [Route("opinionAddUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult opinionAddUpdate(opinionAddUpdateBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_opinionpoll_opinion_AddUpdate", "opinionpoll_opinion_AddUpdate", checkAccess: false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@opinionPollId", model.opinionpollId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@comment", (model.comment.Length < 900 ? model.comment : model.comment.Substring(0, 899)).getDbValue());

                repo.cmd.Parameters.AddWithValue("@d1", model.d1.getDbValue());
                repo.cmd.Parameters.AddWithValue("@d2", model.d2.getDbValue());
                repo.cmd.Parameters.AddWithValue("@d3", model.d3.getDbValue());
                repo.cmd.Parameters.AddWithValue("@d4", model.d4.getDbValue());
                repo.cmd.Parameters.AddWithValue("@d5", model.d5.getDbValue());


                DataTable dtOptions = ClassToDatatableConvertor.CreateDataTable(model.options);
                var p_tOpinions = repo.cmd.Parameters.AddWithValue("@options", dtOptions);
                p_tOpinions.SqlDbType = SqlDbType.Structured;

                //var par_existingOpinionPoolOptionId = repo.cmd.Parameters.Add("@existingOpinionPoolOptionId", SqlDbType.BigInt);
                //par_existingOpinionPoolOptionId.Direction = ParameterDirection.InputOutput;
                //par_existingOpinionPoolOptionId.Value = model.existingOpinionPoolOptionId;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(repo.operationMessage);
            }

        }
        /// <summary>
        /// کپی اطلاعات یک نظرسنجی موجود برای چند کالا
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("copyToMultipleItems")]
        [Exception]
        [HttpPost]
        public IHttpActionResult copyToMultipleItems(copyToMultipleItemsBindingModel model)

        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_opinionpoll_copyToMultipleItems", "opinionpoll_copyToMultipleItems", checkAccess: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable dtItemIds = new DataTable();// = ClassToDatatableConvertor.CreateDataTable(model.itemIds);
                dtItemIds.Columns.Add(new DataColumn("id", typeof(long)));
                DataRow dr;
                foreach (long id in (model.itemIds ?? new List<long>()))
                {
                    dr = dtItemIds.NewRow();
                    dr["id"] = id;
                    dtItemIds.Rows.Add(dr);
                }


                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@srcOpinionPollId", model.srcOpinionPollId.getDbValue());

                var param = repo.cmd.Parameters.AddWithValue("@itemIds", dtItemIds);
                param.SqlDbType = SqlDbType.Structured;


                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(repo.operationMessage);
            }

        }
        /// <summary>
        /// دریافت لیست ریز نظرات یک شخص
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getUserRateDetailes")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getUserRateDetailes(getUserRateDetailesBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getUserRateDetailes", "opinionpoll_getUserRateDetailes", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@opinionPollId", model.opinionPollId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@targetUserId", model.userId.dbNullCheckLong());
                repo.ExecuteAdapter();
                return Ok(repo.ds.Tables[0].AsEnumerable().Select(j => new
                {
                    title = j.Field<object>("title"),
                    score = j.Field<object>("score"),
                   
                }));
            }
        }

        /// <summary>
        /// دریافت لیست کامنت های نظرسنجی و ارزیابی پنل
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getPanelOpinionReport")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getPanelOpinionReport(getPanelOpinionReportBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "", "opinionpoll_getPanelOpinionReport", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@fk_status_id", model.statusId.dbNullCheckInt());
                repo.ExecuteAdapter();
                var comment = repo.ds.Tables[0].AsEnumerable();
                var evaluation = repo.ds.Tables[1].AsEnumerable();
                return Ok(new
                {
                    comments = comment.Select(j => new {
                        itemId = j.Field<object>("itemId"),
                        itemTitle = j.Field<object>("itemTitle"),
                        storeId = j.Field<object>("storeId"),
                        storeTitle = j.Field<object>("storeTitle"),
                        opinionId = j.Field<object>("opinionId"),
                        opinionTitle = j.Field<object>("opinionTitle"),
                        comment = j.Field<object>("comment"),
                        dateTime = j.Field<object>("dateTime"),
                        userId = j.Field<object>("userId"),
                        userName = j.Field<object>("userName")
                    }).ToList(),
                    evaluation = evaluation.Select(j => new
                    {
                        itemId = j.Field<object>("itemId"),
                        itemTitle = j.Field<object>("itemTitle"),
                        storeId = j.Field<object>("storeId"),
                        storeTitle = j.Field<object>("storeTitle"),
                        evaluationId = j.Field<object>("evaluationId"),
                        comment = j.Field<object>("comment"),
                        dateTime = j.Field<object>("dateTime"),
                        userId = j.Field<object>("userId"),
                        userName = j.Field<object>("userName")
                    }).ToList()
                });
            }
        }
    }
    public class getUserRateDetailesBindingModel
    {
        public long? opinionPollId { get; set; }
        public long userId { get; set; }
    }
    /// <summary>
    /// مدل سربرگ نظرسنجی
    /// </summary>
    public class opinionpolBindingModel
    {
        /// <summary>
        /// شناسه نظرسنجی موجود به منظور ویرایش
        /// </summary>
        public long? existingOpinionPollId { get; set; }
        /// <summary>
        /// شناسه کالای وابسته به نظر سنجی
        /// </summary>
        public long? itemId { get; set; }
        /// <summary>
        /// عنوان نظر سنجی
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// عنوان گروه کالا - عنوان گروه کالای مرتبط با نظر سنجی را بازنویسی می کند
        /// </summary>
        public string itemGrpTitle_override { get; set; }
        /// <summary>
        /// شناسه تصویر کالا / نظرسنجی - تصویر کالا را بازنویسی می کند
        /// </summary>
        public string itemPicId_override { get; set; }
        /// <summary>
        /// زمان آغاز نظرسنجی
        /// </summary>
        public DateTime? startDateTime { get; set; }
        /// <summary>
        /// زمان پایان نظر سنجی
        /// </summary>
        public DateTime? endDateTime { get; set; }
        /// <summary>
        /// نتایج عمومی است؟
        /// </summary>
        public bool? resultIsPublic { get; set; }
        /// <summary>
        /// فعال؟
        /// </summary>
        public bool? isActive { get; set; }
        /// <summary>
        /// انتشار؟
        /// </summary>
        public bool? publish { get; set; }
        /// <summary>
        /// لیست سوالات / گزینه ها
        /// نیازی به مقدار دهی opinionpollId نیست
        /// </summary>

        public List<optionAddUpdateBindingModel> options { get; set; }
    }
    /// <summary>
    /// مدل گزینه / سوال نظر سنجی
    /// </summary>

    public class optionAddUpdateBindingModel
    {
        /// <summary>
        /// شناسه گزینه / سوال موجود به منظور ویرایش
        /// </summary>
        public long? existingOpinionPoolOptionId { get; set; }

        /// <summary>
        /// عنوان سوال / گزینه
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// شناسه نظرسنجی متناظر
        /// </summary>
        //[Required(ErrorMessage = "opinionpollId is required")]
        public long? opinionpollId { get; set; }
        /// <summary>
        /// فعال؟
        /// </summary>
        public bool? isActive { get; set; }
        /// <summary>
        /// شماره ترتیب
        /// </summary>
        public int? orderingNo { get; set; }
       
    }
    /// <summary>
    /// 
    /// </summary>
    public class getPanelOpinionReportBindingModel
    {
        /// <summary>
        /// 106 : منتشر شده
        /// 107 : در انتظار بررسی
        /// 108 : ریجکت شده
        /// </summary>
        public int statusId { get; set; }
    }
    public class opinionModel
    {
        /// <summary>
        /// شناسه
        /// </summary>
        public long? id { get; set; }
        /// <summary>
        /// امتیاز کاربر
        /// </summary>
        public decimal? userScore { get; set; } = 0;
    }
    public class opinionAddUpdateBindingModel
    {


        /// <summary>
        /// نظر
        /// </summary>
        public string comment { get; set; }
        /// <summary>
        /// شناسه نظرسنجی متناظر
        /// </summary>
        //[Required(ErrorMessage = "opinionpollId is required")]
        public long? opinionpollId { get; set; }
        /// <summary>
        /// مستند 1
        /// </summary>
        public Guid? d1 { get; set; }
        /// <summary>
        /// مستند 2
        /// </summary>
        public Guid? d2 { get; set; }
        /// <summary>
        /// مستند 3
        /// </summary>
        public Guid? d3 { get; set; }
        /// <summary>
        /// مستند 4
        /// </summary>
        public Guid? d4 { get; set; }
        /// <summary>
        /// مستند 5
        /// </summary>
        public Guid? d5 { get; set; }
        /// <summary>
        /// لیست گزینه ها و پاسخ ها
        /// </summary>
        public List<opinionModel> options { get; set; }
    }
    /// <summary>
    /// مدل فیلتر لیست نظرسنجی ها
    /// </summary>
    public class StoreItemOpinionPollGetListBindingModel : searchParameterModel
    {
        /// <summary>
        /// فیلتر_شناسه نظرسنجی
        /// </summary>
        public long? opinionPollId { get; set; }
        /// <summary>
        /// فیلتر_شناسه فروشگاه
        /// </summary>
        public long? storeId { get; set; }
        /// <summary>
        /// فیلتر_شناسه کالای مرتبط
        /// </summary>
        public long? itemId { get; set; }
        /// <summary>
        /// فیلتر_بارکد کالای مرتبط
        /// </summary>
        public string itemBarcode { get; set; }
        /// <summary>
        /// فیلتر_شناسه گروه کالای مرتبط
        /// </summary>
        public long? itemGrpId { get; set; }
        /// <summary>
        /// فیلتر_وضعیت فعال یا غیر فعال بودن
        /// </summary>
        public bool? isActive { get; set; }
        /// <summary>
        /// فیلتر_جنسیت 1 زن 2 مرد نال هردو
        /// </summary>
        public bool? sex { get; set; }
        /// <summary>
        /// فیلتر_نوع گروه کالا
        /// kala = 1 , personel = 2 , job = 3 , shey = 4
        /// </summary>
        public byte? itemGrpType { get; set; }
        /// <summary>
        /// فیلتر_وضعیت انتشار
        /// </summary>
        public bool? publish { get; set; }
        /// <summary>
        /// فیلتر_نتایج عمومی یا اختصاصی
        /// </summary>
        public bool? resultIsPublic { get; set; }
        /// <summary>
        /// فیلتر_زمان شروع نظر سنجی
        /// </summary>
        public DateTime? startDateTime { get; set; }
        /// <summary>
        /// فیلتر_زمان خاتمه نظرسنجی
        /// </summary>
        public DateTime? endDateTime { get; set; }
        /// <summary>
        /// فیلتر_نظرسنجی در جریان است
        /// </summary>
        public bool? opinionPollIsRunning { get; set; }
        /// <summary>
        /// مرتب سازی_بر اساس تعداد شرکت کنندگان
        /// </summary>
        public bool? sort_countOfparticipants { get; set; }
        /// <summary>
        /// مرتب سازی_بر اساس میانگین امتیازها
        /// </summary>
        public bool? sort_totalAvg { get; set; }
        /// <summary>
        /// مرتب سازی_بر اساس زمان آغاز نظرسنجی
        /// </summary>
        public bool? sort_startDateTime { get; set; }
        /// <summary>
        /// نوع موجودیت
        /// </summary>
        public short? itemType { get; set; }
    }
    public class StoreItemOpinionPollCommentGetListBindingModel
    {
        /// <summary>
        /// شناسه نظرسنجی
        /// </summary>
        public long? opinionPollId { get; set; }
    }
    /// <summary>
    /// مدل کپی یک نظر سنجی موجود برای چند کالا
    /// </summary>
    public class copyToMultipleItemsBindingModel
    {
        /// <summary>
        /// لیست شناسه کالا
        /// </summary>
        public List<long> itemIds { get; set; }
        /// <summary>
        /// شناسه فروشگاه
        /// </summary>
        public long? storeId { get; set; }
        /// <summary>
        /// شناسه نظر سنجی مرجع
        /// </summary>
        public long? srcOpinionPollId { get; set; }
    }

}
