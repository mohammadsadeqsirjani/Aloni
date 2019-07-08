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
    /// ای پی آی مربوط به تبلیغات 
    /// </summary>
    [RoutePrefix("advertisement")]
    public class AdvertisementController : AdvancedApiController
    {
        /// <summary>
        /// سرویس دریافت لیست تبلیغات کاربر
        /// </summary>
        /// <returns></returns>
        [Route("getAdvertisementList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getAdvertisementList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "SP_getAdvertisementList", "AdvertisementController_getAdvertisementList", checkAccess: false, initAsReader: true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteAdapter();
                DataTable dataResult = repo.ds.Tables[0];
                //var dataResult = repo.ds.Tables[0];
                var storeExpertise = repo.ds.Tables[1];
                if (dataResult.AsEnumerable().Count() > 0)
                {
                    return Ok(
                        dataResult.AsEnumerable().Select(row => new
                        {
                            id = Convert.ToInt64(row.Field<object>("id") is DBNull ? 0 : row.Field<object>("id")),
                            dsc = Convert.ToString(row.Field<object>("dsc")),
                            docBanerUrl = Convert.ToString(row.Field<object>("banerUrl")),
                            thumbDocbanerUrl = Convert.ToString(row.Field<object>("thumbBanerurl")),
                            webUrl = Convert.ToString(row.Field<object>("url")),
                            //
                            store = new IdTitleValue<long?> { id = Convert.ToInt64(row.Field<object>("storeId") is DBNull ? 0 : row.Field<object>("storeId")), title = Convert.ToString(row.Field<string>("storeTitle")) },
                            storeAddress = Convert.ToString(row.Field<object>("address")),
                            //
                            storExp = storeExpertise.AsEnumerable().Where(c => Convert.ToInt64(c.Field<object>("id")) == Convert.ToInt64(row.Field<object>("storeId"))).Select(i => new IdTitleValue<int> { id = Convert.ToInt32(i.Field<object>("storeExpertiseId") is DBNull ? 0 : i.Field<object>("storeExpertiseId")), title = Convert.ToString(i.Field<object>("storeExpertiseTitle")) }).ToList(),
                            //
                            category = repo.ds.Tables[2].AsEnumerable().Where(c => Convert.ToInt64(c.Field<object>("id")) == Convert.ToInt64(row.Field<object>("storeId"))).Select(i => new IdTitleValue<long> { id = Convert.ToInt64(i.Field<object>("categoryId") is DBNull ? 0 : i.Field<object>("categoryId")), title = Convert.ToString(i.Field<object>("title")) }).ToList(),
                            //
                            item = new IdTitleValue<long?> { id = row.Field<long?>("itemId").GetValueOrDefault(), title = Convert.ToString(row.Field<string>("itemTitle")) },
                            //discountPer = row.Field<decimal?>("discount_percent").GetValueOrDefault(),
                            //price =Convert.ToString(row.Field<object>("price_")),
                            //purePrice = Convert.ToString(row.Field<object>("purePrice")),
                            price = row.Field<object>("price").dbNullCheckDecimal(),
                            price_dsc = row.Field<object>("price_dsc").dbNullCheckString(),
                            discount = row.Field<object>("discount").dbNullCheckDecimal(),
                            discount_dsc = row.Field<object>("discount_dsc").dbNullCheckString(),
                            priceAfterDiscount = row.Field<object>("priceAfterDiscount").dbNullCheckDecimal(),
                            priceAfterDiscount_dsc = row.Field<object>("priceAfterDiscount_dsc").dbNullCheckString(),

                            selectEvent = Convert.ToInt16(row.Field<object>("selectEvent")),
                            type = Convert.ToInt16(row.Field<object>("type")),
                            lat = Convert.ToSingle(row.Field<object>("Lat") is DBNull ? 0 : row.Field<object>("Lat")),
                            lng = Convert.ToSingle(row.Field<object>("Long") is DBNull ? 0 : row.Field<object>("Long"))
                        }).ToList()

                    );
                }
                return Ok(new { msg = "no result!" });
            }

        }


    }
    /// <summary>
    /// مدل تبلیغات
    /// </summary>
    public class AdvertisementModel
    {
        /// <summary>
        /// شناسه تبلیغ
        /// </summary>
        public long id { get; set; }
        /// <summary>
        /// شرح تبلیغ
        /// </summary>
        public string dsc { get; set; }
        /// <summary>
        /// تصویر بنر تبلیغ
        /// </summary>
        public string docBanerUrl { get; set; }
        /// <summary>
        /// لینک صفحه وب
        /// </summary>
        public string webUrl { get; set; }
        /// <summary>
        /// شناسه و نام فروشگاه
        /// </summary>
        public IdTitleValue<long?> store { get; set; }
        /// <summary>
        /// آدرس فروشگاه
        /// </summary>
        public string storeAddress { get; set; }
        /// <summary>
        /// لوگوی فروشگاه
        /// </summary>
        public string logoStoreUrl { get; set; }
        /// <summary>
        /// حوزه فعالیت شاخص فروشگاه
        /// </summary>
        public IdTitleValue<int> storExp { get; set; }
        /// <summary>
        /// شناسه و نام کالا
        /// </summary>
        public IdTitleValue<long?> item { get; set; }
        /// <summary>
        /// درصد تخفیف کالا
        /// </summary>
        public decimal discountPer { get; set; }
        /// <summary>
        /// قیمت کالا
        /// </summary>
        public decimal price { get; set; }
        /// <summary>
        /// قیمت ÷س از کسر تخفیف
        /// </summary>
        public decimal purePrice { get; set; }
        /// <summary>
        /// تصویر کالا
        /// </summary>
        public string itemPicUrl { get; set; }
        /// <summary>
        /// انتخاب بعد از لمس
        /// </summary>
        public short selectEvent { get; set; }
        /// <summary>
        /// نوع تبلیغ
        /// </summary>
        public int type { get; set; }

    }
    /// <summary>
    /// مدل مرجع جستجو
    /// </summary>
    public class searchParameterModel
    {
        /// <summary>
        /// عبارت جستجو
        /// </summary>
        public string search { get; set; }
        /// <summary>
        /// نوع موجودیت جستجو شونده
        /// 1 : kala
        /// 2: personel
        /// 3: shoghl
        /// 4: shey
        /// 5:sazman
        /// 6:sho'be
        /// 7:makan
        /// </summary>
        public short? type { get; set; }
        
    }
}
