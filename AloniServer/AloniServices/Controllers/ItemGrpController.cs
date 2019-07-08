using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی آی مربوط به گروه های کالایی
    /// </summary>
    [System.Web.Http.RoutePrefix("ItemGrp")]
    public class ItemGrpController : AdvancedApiController
    {

        private List<ItemGrpModel> BuildTree(List<ItemGrpModel> source)
        {
            var groups = source.GroupBy(i => i.parentValue);
            List<ItemGrpModel> roots = null;
            try
            {
                roots = groups.FirstOrDefault(g => g.Key.HasValue == false).ToList();
            }
            catch (ArgumentNullException)
            {
                roots = groups.FirstOrDefault(g => g.Key.HasValue == true).ToList();
            }
            if (roots.Count > 0)
            {
                var dict = groups.Where(g => g.Key.HasValue).ToDictionary(g => g.Key.Value, g => g.ToList());
                for (int i = 0; i < roots.Count; i++)
                    AddChildren(roots[i], dict);
            }

            return roots;
        }

        private void AddChildren(ItemGrpModel node, IDictionary<int, List<ItemGrpModel>> source)
        {
            if (source.ContainsKey(node.value))
            {
                node.nodes = source[node.value];
                node.ChildMember = node.nodes.Count;
                for (int i = 0; i < node.nodes.Count; i++)
                    AddChildren(node.nodes[i], source);
            }
            else
            {
                node.nodes = new List<ItemGrpModel>();
            }
        }
        /// <summary>
        /// سرویس ساختار درختی گروه های کالایی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [System.Web.Http.Route("getList")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult GetList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemGrpModel> result = new List<ItemGrpModel>();
            // موقتا در حالت بدون هویت سنجی 
            using (var repo = new Repo(this, "SP_getAllitemGrp", "ItemGrpController_getList", autenticationMode.NoAuthenticationRequired, true, false))
            {
                //if(repo.unauthorized)
                //    return new UnauthorizedActionResult("Unauthorized!");
                //if (repo.accessDenied)
                //    return new AccessDeniedResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    ItemGrpModel item = new ItemGrpModel();
                    item.value = Convert.ToInt16(repo.sdr["id"]);
                    item.text = Convert.ToString(repo.sdr["title"]);
                    if (!object.ReferenceEquals(repo.sdr["fk_item_grp_ref"], DBNull.Value))
                        item.parentValue = Convert.ToInt16(repo.sdr["fk_item_grp_ref"]);
                    result.Add(item);
                }
            }
            return Ok(BuildTree(result));
        }
        /// <summary>
        /// سرویس دریافت لیست گروه های کالایی متناظر با حوزه فعالیت فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns > list of ItemGrpModel
        /// در این لیست فقط کد و عنوان گروه ست میشود
        /// </returns>
        [System.Web.Http.Route("getItemGroupIncludingItem")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult getItemGroupIncludingItem(searchParameterModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemGrpModel> result = new List<ItemGrpModel>();

            using (var repo = new Repo(this, "SP_getItemGroupIncludingItem", "ItemGrpController_getItemGroupIncludingItem", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    ItemGrpModel item = new ItemGrpModel();
                    item.value = Convert.ToInt16(repo.sdr["id"]);
                    item.text = Convert.ToString(repo.sdr["title"]);
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس دریافت همه گروه های کالایی متناسب با حوزه فعالیت فروشگاه به همراه آمار زیر شاخه ها و تعداد کالاهای موجود در آن گروه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [System.Web.Http.Route("getStatisticItemGroup")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult getStatisticItemGroup(getItemStatisticItemGroupModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemGrpModel> result = new List<ItemGrpModel>();

            using (var repo = new Repo(this, "SP_getStatisticItemGroup", "ItemGrpController_getStatisticItemGroup", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@withoutExistsItems", model.withoutExistsItems);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.cmd.Parameters.AddWithValue("@catId", model.catId.dbNullCheckLong());

                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i =>
                new ItemGrpModel
                {

                    value = Convert.ToInt16(i.Field<object>("id")),
                    text = Convert.ToString(i.Field<object>("title")),
                    parentValue = Convert.ToInt16(i.Field<object>("Parent") is DBNull ? 0 : i.Field<object>("Parent")),
                    ChildMember = Convert.ToInt32(i.Field<object>("childMember")),
                    itemCount = model.catId > 0 & model.withoutExistsItems == true ? Convert.ToInt32(i.Field<object>("itemCount")) : repo.ds.Tables[1].AsEnumerable().Where(c => Convert.ToInt64(c.Field<object>("fk_itemGrp_id")) == Convert.ToInt16(i.Field<object>("id"))).Select(c => Convert.ToInt32(c.Field<object>("itemCnt"))).FirstOrDefault()


                }).ToList());
        
            }
           
        }
        /// <summary>
        /// سرویس دریافت لیست کالاها براساس
        /// شناسه فروشگاه در هدر ست شود
        /// </summary>
        /// <param name="model"> لیست گروه های انتخاب شده
        /// فقط ای دی ست شود
        /// </param>
        /// <returns>لیستی از کالاها </returns>
        [System.Web.Http.Route("getItemListbyGroupItem")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult getItemListbyGroupItem(getItemListbyGroupItemModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemModel> result = new List<ItemModel>();

            using (var repo = new Repo(this, "SP_getItemListbyItemGroup", "ItemGrpController_getItemListbyGroupItem", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dt = new DataTable();
                DataRow row;
                dt.Columns.Add("id");
                foreach (var i in model.groupIdList)
                {
                    row = dt.NewRow();
                    row["id"] = i.id;
                    dt.Rows.Add(row);
                }
                var param = repo.cmd.Parameters.AddWithValue("@itemGroups", dt);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@withoutExistsItems", model.withoutExistsItems.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    ItemModel item = new ItemModel();
                    item.id = Convert.ToInt64(repo.sdr["id"] is DBNull ? 0 : repo.sdr["id"]);
                    item.title = Convert.ToString(repo.sdr["title"] is DBNull ? "" : repo.sdr["title"]);
                    item.groupId = Convert.ToInt64(repo.sdr["fk_itemGrp_id"] is DBNull ? 0 : repo.sdr["fk_itemGrp_id"]);
                    item.groupName = Convert.ToString(repo.sdr["itemGroupTitle"] is DBNull ? "" : repo.sdr["itemGroupTitle"]);
                    item.saveDateTime = Convert.ToDateTime(repo.sdr["saveDateTime"] is DBNull ? 0 : repo.sdr["saveDateTime"]);
                    item.userId = Convert.ToInt64(repo.sdr["fk_usr_saveUser"] is DBNull ? 0 : repo.sdr["fk_usr_saveUser"]);
                    item.barCode = Convert.ToString(repo.sdr["barcode"] is DBNull ? "" : repo.sdr["barcode"]);
                    item.statusId = Convert.ToInt32(repo.sdr["fk_status_id"] is DBNull ? 0 : repo.sdr["fk_status_id"]);
                    item.countryManufacturer = Convert.ToInt32(repo.sdr["fk_country_Manufacturer"] is DBNull ? 0 : repo.sdr["fk_country_Manufacturer"]);
                    item.unitId = Convert.ToInt32(repo.sdr["fk_unit_id"] is DBNull ? 0 : repo.sdr["fk_unit_id"]);
                    item.ManufacturerCo = Convert.ToString(repo.sdr["manufacturerCo"] is DBNull ? "" : repo.sdr["manufacturerCo"]);
                    item.technicalTitle = Convert.ToString(repo.sdr["technicalTitle"] is DBNull ? "" : repo.sdr["technicalTitle"]);
                    item.ImporterCo = Convert.ToString(repo.sdr["importerCo"] is DBNull ? "" : repo.sdr["importerCo"]);
                    item.isTemplate = Convert.ToBoolean(repo.sdr["isTemplate"]);
                    item.document = new DocumentItemTab { downloadLink = Convert.ToString(repo.sdr["completeLink"]), thumbImageUrl = Convert.ToString(repo.sdr["thumbcompeleteLink"]) };
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس دریافت لیست کالاهای فروشگاه خاص که در دسته بندی سفارشی فروشگاه اضافه نشده اند
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [System.Web.Http.Route("getCustomCategoryStoreItemList")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult getCustomCategoryStoreItemList(getCustomCategoryStoreItemListModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemModel> result = new List<ItemModel>();

            using (var repo = new Repo(this, "SP_getCustomCategoryStoreItemList", "ItemGrpController_getCustomCategoryStoreItemList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                DataTable dt = new DataTable();
                DataRow row;
                dt.Columns.Add("id");
                foreach (var i in model.groupIdList)
                {
                    row = dt.NewRow();
                    row["id"] = i.id;
                    dt.Rows.Add(row);
                }
                var param = repo.cmd.Parameters.AddWithValue("@itemGroups", dt);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@customCategoryId", model.customCategoryId);
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                param.SqlDbType = SqlDbType.Structured;
                repo.ExecuteAdapter();

                return Ok(repo.ds.Tables[0].AsEnumerable().Select(i => new
                {
                    id = Convert.ToInt64(i.Field<object>("id") is DBNull ? 0 : i.Field<object>("id")),
                    title = Convert.ToString(i.Field<object>("title")),
                    groupId = Convert.ToInt64(i.Field<object>("fk_itemGrp_id") is DBNull ? 0 : i.Field<object>("fk_itemGrp_id")),
                    groupName = Convert.ToString(i.Field<object>("itemGroupTitle")),
                    saveDateTime = Convert.ToDateTime(i.Field<object>("saveDateTime") is DBNull ? 0 : i.Field<object>("saveDateTime")),
                    userId = Convert.ToInt64(i.Field<object>("fk_usr_saveUser") is DBNull ? 0 : i.Field<object>("fk_usr_saveUser")),
                    barCode = Convert.ToString(i.Field<object>("barcode")),
                    statusId = Convert.ToInt32(i.Field<object>("fk_status_id") is DBNull ? 0 : i.Field<object>("fk_status_id")),
                    countryManufacturer = Convert.ToInt32(i.Field<object>("fk_country_Manufacturer") is DBNull ? 0 : i.Field<object>("fk_country_Manufacturer")),
                    unitId = Convert.ToInt32(i.Field<object>("fk_unit_id") is DBNull ? 0 : i.Field<object>("fk_unit_id")),
                    ManufacturerCo = Convert.ToString(i.Field<object>("manufacturerCo")),
                    technicalTitle = Convert.ToString(i.Field<object>("technicalTitle")),
                    ImporterCo = Convert.ToString(i.Field<object>("importerCo")),
                    isTemplate = i.Field<object>("isTemplate").dbNullCheckBoolean(),
                    document = new DocumentItemTab { downloadLink = i.Field<object>("completeLink").dbNullCheckString(), thumbImageUrl = i.Field<object>("thumbcompeleteLink").dbNullCheckString() },
                    cnt = i.Field<object>("cnt").dbNullCheckInt()
                }).ToList());
            }

        }
        /// <summary>
        /// سرویس مربوط به ثبت گروهی کالا
        /// </summary>
        /// <param name="model"> </param>
        /// <returns></returns>
        [System.Web.Http.Route("addItemsToStore")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult addItemsToStore(ItemGrpModel_Add model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addItems", "ItemController_additemsToStore"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                DataTable dt = new DataTable();
                DataRow row;
                dt.Columns.Add("id");
                foreach (var i in model.itemIds)
                {
                    row = dt.NewRow();
                    row["id"] = i;
                    dt.Rows.Add(row);
                }
                var param = repo.cmd.Parameters.AddWithValue("@itemIds", dt);
                param.SqlDbType = SqlDbType.Structured;
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId);
                repo.cmd.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس دریافت لیست گروه های کالایی _ اپ خریدار
        /// </summary>
        /// <param name="model">
        /// شناسه سرگروه کالایی که میتواند نال باشد
        /// parent در هدر ست شود
        /// </param>
        /// <returns></returns>
        [System.Web.Http.Route("getGroupItemList")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult getGroupItemList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<GroupModel> result = new List<GroupModel>();
            using (var repo = new Repo(this, "SP_getItemGroupList", "ItemController_getGroupItemList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    GroupModel item = new GroupModel();
                    item.id = Convert.ToInt64(repo.sdr["id"] is DBNull ? 0 : repo.sdr["id"]);
                    item.title = Convert.ToString(repo.sdr["title"]);
                    item.imageUrl = Convert.ToString(repo.sdr["completeLink"]);
                    item.thumbImageUrl = Convert.ToString(repo.sdr["thumbcompeleteLink"]);
                    item.hasChild = repo.sdr["hasChild"].dbNullCheckBoolean();
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        /// <summary>
        /// سرویس دریافت لیست گروه های مرتبط با شعبه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [System.Web.Http.Route("getObjectGroupList")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult getObjectGroupList(searchParameterModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemGrpModel> result = new List<ItemGrpModel>();

            using (var repo = new Repo(this, "SP_getObjectGroupList", "ItemGrpController_getObjectGroupList", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.cmd.Parameters.AddWithValue("@type", model.type.dbNullCheckShort());
                repo.ExecuteAdapter();
                return Ok(
                    repo.ds.Tables[0].AsEnumerable().Select(i => new
                    {
                        id = i.Field<long>("id"),
                        title = i.Field<string>("title")
                    }).ToList()
                    );
            }
        }
        /// <summary>
        /// سرویس دریافت لیست مشخصه فنی بر اساس شناسه گروه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [System.Web.Http.Route("getTechnicalInfoBaseItemGroupId")]
        [Exception]
        [System.Web.Http.HttpPost]
        public IHttpActionResult getTechnicalInfoBaseItemGroupId(LongKeyModel model)
        {

            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<ItemGrpModel> result = new List<ItemGrpModel>();

            using (var repo = new Repo(this, "SP_getTechnicalInfoBaseItemGroupId", "ItemGrpController_getTechnicalInfoBaseItemGroupId", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                repo.ExecuteAdapter();
                return Ok(
                    repo.ds.Tables[0].AsEnumerable().Select(i => new
                    {
                        id = i.Field<long>("id"),
                        title = i.Field<string>("title"),
                        type = i.Field<object>("type")
                    }).ToList()
                    );
            }
        }
    }
    /// <summary>
    /// مدل پایه
    /// </summary>
    public class ItemGrpModel
    {
        /// <summary>
        /// کد گروه
        /// </summary>
        public int value { get; set; }
        /// <summary>
        /// نام گروه
        /// </summary>
        public string text { get; set; }
        /// <summary>
        /// کد سرگروه ، چنانچه خالی بود، خودش سرگروهه
        /// </summary>
        public int? parentValue { get; set; }
        /// <summary>
        /// لیست از فرزندان 
        /// </summary>
        public List<ItemGrpModel> nodes { get; set; }
        /// <summary>
        /// تعداد فرزند در هر سطح
        /// </summary>
        public int ChildMember { get; set; }
        /// <summary>
        /// تعداد کالاهای ادد نشده به فروشگاه
        /// </summary>
        public int itemCount { get; set; }
    }
    /// <summary>
    /// مدل پایه
    /// </summary>
    public class ItemModel
    {
        /// <summary>
        /// کد کالا
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// نام کالا
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// کد گروه 
        /// </summary>
        public long groupId { get; set; }
        /// <summary>
        /// نام گروه
        /// </summary>
        public string groupName { get; set; }
        /// <summary>
        /// تاریخ ایجاد
        /// </summary>
        public DateTime saveDateTime { get; set; }
        /// <summary>
        /// کد کاربر ثبت کننده
        /// </summary>
        public long userId { get; set; }
        /// <summary>
        /// شناسه بارکد
        /// </summary>
        public string barCode { get; set; }
        /// <summary>
        /// وضعیت
        /// </summary>
        public int statusId { get; set; }
        /// <summary>
        /// کد کشور سازنده
        /// </summary>
        public int countryManufacturer { get; set; }
        /// <summary>
        ///کد واحد کالا
        /// </summary>
        public int unitId { get; set; }
        /// <summary>
        /// دذباره سازنده
        /// </summary>
        public string ManufacturerCo { get; set; }
        /// <summary>
        /// توضیحات فنی
        /// </summary>
        public string technicalTitle { get; set; }
        /// <summary>
        /// توضیحات وارد کننده
        /// </summary>
        public string ImporterCo { get; set; }
        /// <summary>
        /// کالای پیش فرض
        /// </summary>
        public bool isTemplate { get; set; }
        /// <summary>
        /// شناسه محلی بارکد
        /// </summary>
        public string localBarcode { get; set; }
        /// <summary>
        /// مدل اسناد
        /// </summary>
        public DocumentItemTab document { get; set; }
    }
    /// <summary>
    /// 
    /// </summary>
    public class LongKeyModel : searchParameterModel
    {
        /// <summary>
        /// شناسه آیتم
        /// </summary>
        public long id { get; set; }

    }
    /// <summary>
    /// 
    /// </summary>
    public class LongModel
    {
        /// <summary>
        /// 
        /// </summary>
        public long id { get; set; }

    }
    /// <summary>
    /// مدل گروه کالایی در اپ خریدار
    /// </summary>
    public class GroupModel
    {
        /// <summary>
        /// شناسه
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// عنوان
        /// </summary>
        public string title { get; set; }
        /// <summary>
        /// ادرس تصویر گروه
        /// </summary>
        public string imageUrl { get; set; }
        /// <summary>
        /// آدرس تصویر کوچیک
        /// </summary>
        public string thumbImageUrl { get; set; }
        /// <summary>
        /// فرزند دارد
        /// </summary>
        public bool? hasChild { get; set; }
    }
    /// <summary>
    /// مدل سرویس دریافت لیست کالاها بر اساس گروه های کالایی
    /// </summary>
    public class getItemListbyGroupItemModel : searchParameterModel
    {
        /// <summary>
        /// لیستی از شناسه های گروه کالایی
        /// </summary>
        public List<GroupModel> groupIdList { get; set; }
        /// <summary>
        /// پارامتر سرچ
        /// </summary>

        public bool withoutExistsItems { get; set; }
    }
    /// <summary>
    /// مدل دریافت دسته بندی شخصی
    /// </summary>
    public class getCustomCategoryStoreItemListModel : searchParameterModel
    {
        /// <summary>
        /// شناسه دسته بندی شخصی
        /// </summary>
        public long customCategoryId { get; set; }
        /// <summary>
        /// لیست گروه ها
        /// </summary>
        public List<GroupModel> groupIdList { get; set; }
    }
    /// <summary>
    /// 
    /// </summary>
    public class ItemGrpModel_Add
    {
        /// <summary>
        /// شناسه پنل
        /// </summary>
        public long storeId { get; set; }
        /// <summary>
        /// لیستی از ای دی ها
        /// </summary>
        public List<long> itemIds { get; set; }
    }
    /// <summary>
    /// مدل پایه
    /// </summary>
    public class getItemStatisticItemGroupModel : searchParameterModel
    {
        /// <summary>
        /// فلگ شامل یا عدم شامل شدن کالای موجود
        /// </summary>
        public bool withoutExistsItems { get; set; }
        /// <summary>
        /// شناسه دسته بندی شخصی
        /// </summary>
        public long catId { get; set; }
    }

}