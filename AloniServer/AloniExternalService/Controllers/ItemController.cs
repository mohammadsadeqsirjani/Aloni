using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniExternalService.Controllers
{
   
    [RoutePrefix("Item")]
    public class ItemController : AdvancedApiController
    {
        /// <summary>
        /// سرویس بروزرسانی قیمت و موجودی کالا
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("update")]
        [Exception]
        [HttpPost]
        public IHttpActionResult update(updateItemBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateItemPriceQty", "ItemController_update"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
             
                repo.cmd.Parameters.AddWithValue("@barcode", model.barcode.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@unitId", model.itemInfo.unitId);
                repo.cmd.Parameters.AddWithValue("@quantity", model.itemInfo.quantity.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@orderPoint", model.itemInfo.orderPoint.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@prepaymentPercentage", model.itemInfo.prepaymentPercentage.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@penaltyCancellationPercentage", model.itemInfo.penaltyCancellationPercentage.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@price", model.itemInfo.price.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@periodicValidDayOrder", model.itemInfo.periodicValidDayOrder.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@discountPerPurcheseNumeric", model.itemInfo.discountPerPurcheseNumeric.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@discountPerPurchesePercently", model.itemInfo.discountPerPurchesePercently.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@notForSellingItem", model.itemInfo.notForSellingItem.dbNullCheckBoolean());
                repo.cmd.Parameters.AddWithValue("@includesTax", model.itemInfo.includesTax.dbNullCheckBoolean());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
         /// <summary>
        /// سرویس دریافت لیست واحد های  فعال شمارش کالا
        /// </summary>
        /// <returns>[{id:0,title:''}]</returns>
        [Route("getActiveUnitList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult GetActiveUnitList(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            List<UnitModel> result = new List<UnitModel>();

            using (var repo = new Repo(this, "SP_getActiveUnit", "UnitItemController_GetActiveUnitList",autenticationMode.NoAuthenticationRequired,initAsReader:true))
            {
                repo.cmd.Parameters.AddWithValue("@search", model.search.getDbValue());
                repo.ExecuteReader();

                while (repo.sdr.Read())
                {
                    UnitModel item = new UnitModel();
                    item.id = Convert.ToInt32(repo.sdr["id"]);
                    item.title = Convert.ToString(repo.sdr["title"]);
                    result.Add(item);
                }
            }
            return Ok(result);
        }
        public class UnitModel
        {
            public int id { get; set; }
            public string title { get; set; }
        }
       
    }
    public class updateItemBindingModel
    {
        /// <summary>
        /// بارکد رسمی
        /// </summary>
        public string barcode { get; set; }
        /// <summary>
        /// مدل اطلاعات مربوط به قیمت و موجودی
        /// </summary>
        public SohInfoItem itemInfo { get; set; }
    }
    public class SohInfoItem
    {
        /// <summary>
        /// شناسه واحد پولی کالا
        /// </summary>
        public int unitId { get; set; }
        /// <summary>
        /// تعداد
        /// </summary>
        public decimal quantity { get; set; }
        /// <summary>
        /// نقطه سفارش
        /// </summary>
        public decimal orderPoint { get; set; }
        /// <summary>
        /// درصد پیش پرداخت
        /// </summary>
        public int prepaymentPercentage { get; set; }
        /// <summary>
        /// درصد جریمه کنسلی
        /// </summary>
        public int penaltyCancellationPercentage { get; set; }
        /// <summary>
        /// قیمت
        /// </summary>
        public decimal price { get; set; }
        /// <summary>
        /// نعداد روز مجاز
        /// </summary>
        public int periodicValidDayOrder { get; set; }
        /// <summary>
        /// تخفیف بر پایه خرید
        /// </summary>
        public int discountPerPurcheseNumeric { get; set; }
        /// <summary>
        ///  درصد خرید بر پایه خرید
        /// </summary>
        public decimal discountPerPurchesePercently { get; set; }
        /// <summary>
        /// غیرقابل فروش
        /// </summary>
        public bool notForSellingItem { get; set; }
        /// <summary>
        /// شامل مالیات
        /// </summary>
        public bool includesTax { get; set; }
       

    }
    public class searchParameterModel
    {
        public string search { get; set; }
    }

}
