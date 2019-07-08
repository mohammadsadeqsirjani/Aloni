using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ای پی ای رنگ
    /// </summary>
    [RoutePrefix("color")]
    public class ColorController : AdvancedApiController
    {
        /// <summary>
        /// سرویس اضافه کردن رنگ برای کالای خاص در فروشگاه خاص
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdate(colorModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_colorAddUpdate", "colorController_addUpdate"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@colorId", model.colorId.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@colorCost", model.colorCost.dbNullCheckDecimal());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس حذف یک رنگ از فروشگاه خاص
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(colorModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_colordelete", "colorController_delete"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@itemId", model.itemId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@colorId", model.colorId.dbNullCheckString());
               
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { repo.rMsg });
            }

        }
        /// <summary>
        /// دریافت لیست رنگهای  آیتم ها در فروشگاه
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("getStoreItemColorList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getStoreItemColorList(getColorListModelBinding model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);


            using (var repo = new Repo(this, "SP_getStoreItemColorList", "colorController_getStoreItemColorList", initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@justActiveColors", model.justActiveColors.dbNullCheckBoolean());
                repo.ExecuteAdapter();
                var items = repo.ds.Tables[0].AsEnumerable();
                var colors = repo.ds.Tables[1].AsEnumerable();
                return Ok(
                        items.Select(row => new {
                        item = new IdTitleValue<long> { id = Convert.ToInt64(row.Field<object>("id")),title = Convert.ToString(row.Field<object>("title"))},
                        colorList = colors.Where(c  => Convert.ToInt64(row.Field<object>("id")) == Convert.ToInt64(c.Field<object>("itemId"))).Select(m => new ItemColorModel {
                            color = Convert.ToString(m.Field<object>("id")),
                            colorName = Convert.ToString(m.Field<object>("title")),
                            isActive = Convert.ToBoolean(m.Field<object>("isActive")),
                            colorCost = Convert.ToDecimal(row.Field<object>("colorCost"))
                        }).ToList()
                        
                    }).ToList()
                    
                    );
            }

        }
        /// <summary>
        /// سرویس دریافت لیست رنگ ها
        /// </summary>
        /// <returns></returns>
        [Route("getList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getColorList", "colorController_getList", autenticationMode.NoAuthenticationRequired, initAsReader: true, checkAccess: false))
            {
               
                repo.ExecuteAdapter();
                DataTable result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(row => new ItemColorModel
                {
                    color = Convert.ToString(row.Field<object>("id")),
                    colorName = Convert.ToString(row.Field<object>("title"))
                    
                }).ToList());
            }
        }
    }
    /// <summary>
    /// مدل پایه برای افزودن و ویرایش رنگ
    /// </summary>
    public class colorModelBinding
    {
        /// <summary>
        /// شناسه پنل
        /// </summary>
        public long storeId { get; set; }
        /// <summary>
        /// شناسه کالا
        /// </summary>
        public long itemId { get; set; }
        /// <summary>
        /// شناسه رنگ
        /// </summary>
        public string colorId { get; set; }
        /// <summary>
        /// فلگ فعال/غیرفعال
        /// </summary>
        public bool isActive { get; set; }
        /// <summary>
        ///مشخص کننده مبلغ مازاد بر مبلغ پایه کالا در هنگام سفارشات مشتری
        /// </summary>
        public decimal colorCost { get; set; }
    }
    /// <summary>
    /// مدل پایه قابل استفاده برای سرویس های رنگ
    /// </summary>
    public class getColorListModelBinding
    {
        /// <summary>
        /// 
        /// 0 : all
        /// 1 : just available
        /// </summary>
        public bool justActiveColors { get; set; }
    }

}
