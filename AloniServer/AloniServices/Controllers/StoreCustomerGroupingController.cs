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
    /// رنگ بندی مشتریان فروشگاه
    /// </summary>

    [RoutePrefix("StoreCustomerGrouping")]
    public class StoreCustomerGroupingController : AdvancedApiController
    {
        /// <summary>
        /// اضافه کردن گروه 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("Add")]
        public IHttpActionResult Add(StoreCustomerGroupingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addStoreCustomerGrouping", "StoreCustomerGroupingController_Add"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                var param = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                param.Direction = ParameterDirection.Output;
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@color", model.color.getDbValue());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@discountPercent", model.discountPercent.dbNullCheckDecimal());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = param.Value });
            }
        }
        /// <summary>
        /// ویرایش
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("Update")]
        public IHttpActionResult Update(StoreCustomerGroupingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_updateStoreCustomerGrouping", "StoreCustomerGroupingController_Update"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@color", model.color.getDbValue());
                repo.cmd.Parameters.AddWithValue("@title", model.title.getDbValue());
                repo.cmd.Parameters.AddWithValue("@discountPercent", model.discountPercent.dbNullCheckDecimal());
                repo.cmd.Parameters.AddWithValue("@isActive", model.isActive.dbNullCheckBoolean());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg});
            }
        }
        /// <summary>
        /// دریافت لیست گروه های مشتری فروشگاه
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        [HttpPost]
        [Exception]
        [Route("getList")]
        public IHttpActionResult getList(searchParameterModel input)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getStoreCustomerGrouping", "StoreCustomerGroupingController_Get",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@search", input.search);
                repo.ExecuteAdapter();
                DataTable info = repo.ds.Tables[0];
                return Ok(
                    info.AsEnumerable().Select(i=> new StoreCustomerGroupingModel {
                        id = Convert.ToInt64(i.Field<object>("id")),
                        title = Convert.ToString(i.Field<object>("title")),
                        discountPercent = Convert.ToDecimal(i.Field<object>("discountPercent")),
                        isActive = Convert.ToBoolean(i.Field<object>("isActive")),
                        color = i.Field<object>("color").dbNullCheckString()
                    }).ToList()
                    
                    );
            }
        }

    }
    /// <summary>
    /// مدل پایه گروه بندی مشتریان
    /// </summary>
    public class StoreCustomerGroupingModel
    {
        public long? id { get; set; }
        public string title { get; set; }
        public decimal discountPercent { get; set; }
        public bool isActive { get; set; }
        /// <summary>
        /// رنگ
        /// </summary>
        public string color { get; set; }
    }
}
