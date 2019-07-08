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
    /// 
    /// </summary>
    [RoutePrefix("OrderAddress")]
    public class OrderAddressController : AdvancedApiController
    {
        /// <summary>
        /// سرویس افزودن و ویرایش آدرس
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("addUpdate")]
        [Exception]
        [HttpPost]
        public IHttpActionResult addUpdate(orderAddressModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_addUpdateOrderAddress", "OrderAddressController_SP_addUpdateOrderAddress"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                var param = repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                param.Direction = System.Data.ParameterDirection.InputOutput;
                repo.cmd.Parameters.AddWithValue("@transfereeName", model.transfereeName.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@transfereeMobile", model.transfereeMobile.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@countryCode", model.countryCode.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@transfereeTell", model.transfereeTell.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@state", model.state.id.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@city", model.city.id.dbNullCheckInt());
                repo.cmd.Parameters.AddWithValue("@postalCode", model.postalCode.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@postalAddress", model.postalAddress.dbNullCheckString());
                repo.cmd.Parameters.AddWithValue("@lat", model.lat.dbNullCheckDouble());
                repo.cmd.Parameters.AddWithValue("@lng", model.lng.dbNullCheckDouble()); 
                repo.cmd.Parameters.AddWithValue("@nationalCode", model.nationalCode.dbNullCheckString());
                repo.ExecuteNonQuery();
                if(repo.rCode !=1)
                {
                    return new NotFoundActionResult(repo.rMsg);
                }
                return Ok(new { id = param.Value, msg = repo.rMsg });
            }

        }

        /// <summary>
        /// سرویس  حذف آدرس
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("delete")]
        [Exception]
        [HttpPost]
        public IHttpActionResult delete(deleteOrderAddressModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_deleteOrderAddress", "OrderAddressController_SP_deleteOrderAddress"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@id", model.id.dbNullCheckLong());
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                {
                    return new NotFoundActionResult(repo.rMsg);
                }
                return Ok(new {  msg = repo.rMsg });
            }

        }
        /// <summary>
        /// سرویس دریافت لیست آدرس های کاربر 
        /// </summary>
        /// <returns></returns>
        [Route("get")]
        [Exception]
        [HttpPost]
        public IHttpActionResult Get(searchParameterModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getOrderAddress", "OrderAddressController_SP_getOrderAddress",initAsReader:true,checkAccess:false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@search", model.search.dbNullCheckString());
                repo.ExecuteAdapter();
                var info = repo.ds.Tables[0];
                return Ok(
                        info.AsEnumerable().Select(c => new orderAddressModel
                        {
                            id = Convert.ToInt64(c.Field<object>("id").dbNullCheckLong()),
                            transfereeName = Convert.ToString(c.Field<object>("transfereeName")),
                            transfereeMobile = Convert.ToString(c.Field<object>("transfereeMobile")),
                            countryCode = Convert.ToString(c.Field<object>("countryCode")),
                            transfereeTell = Convert.ToString(c.Field<object>("transfereeTell")),
                            postalAddress = Convert.ToString(c.Field<object>("postalAddress")),
                            postalCode = Convert.ToString(c.Field<object>("postalCode")),
                            state = new IdTitleValue<int> { id = Convert.ToInt32(c.Field<object>("stateId").dbNullCheckLong()),title = Convert.ToString(c.Field<object>("stateTitle")) },
                            city = new IdTitleValue<int> { id = Convert.ToInt32(c.Field<object>("cityId").dbNullCheckLong()), title = Convert.ToString(c.Field<object>("cityTitle")) },
                            lat = Convert.ToSingle(c.Field<object>("lat").dbNullCheckDecimal()),
                            lng = Convert.ToSingle(c.Field<object>("lng").dbNullCheckDecimal()),
                            nationalCode = Convert.ToString(c.Field<object>("nationalCode"))
                        }).ToList()
                    );
            }

        }
    }

    /// <summary>
    /// مدل پایه آدرس سفارش
    /// </summary>
    public class orderAddressModel
    {
        public long id { get; set; }
        public string transfereeName { get; set; }
        public string transfereeMobile { get; set; }
        public string transfereeTell { get; set; }
        [Required(ErrorMessage = "state is required")]
        public IdTitleValue<int> state { get; set; }
        [Required(ErrorMessage = "city is required")]
        public IdTitleValue<int> city { get; set; }
        public string postalCode { get; set; }
        public string postalAddress { get; set; }
        public float lat { get; set; }
        public float lng { get; set; }
        public string nationalCode { get; set; }
        /// <summary>
        /// کد تلفن کشور در صورتی که نال باشد +98 در نظر گرفته میشود
        /// </summary>
        public string countryCode { get; set; }
    }
    public class deleteOrderAddressModel
    {
        public long id { get; set; }
    }
}
