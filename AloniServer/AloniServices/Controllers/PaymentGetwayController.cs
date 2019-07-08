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
    /// ای پی آی مربوط به مدیریت درگاه پرداخت فروشگاه
    /// </summary>
    [RoutePrefix("Payment")]
    public class PaymentGetwayController : AdvancedApiController
    {
        /// <summary>
        /// سرویس دریافت لیست بانک ها
        /// </summary>
        /// <returns></returns>
        [Route("getBankList")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getBankList()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getBankList", "PaymentGetwayController_getBankList",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.ExecuteAdapter();
                var result = repo.ds.Tables[0];
                return Ok(result.AsEnumerable().Select(row => new { id = Convert.ToInt32(row.Field<object>("id")), title = Convert.ToString(row.Field<object>("title")) }).ToList());
            }
        }
        /// <summary>
        /// سرویس مربوط به درخواست تغییر شماره حساب 
        /// </summary>
        /// <returns></returns>
        [Route("requestToChangeStoreAccount")]
        [Exception]
        [HttpPost]
        public IHttpActionResult requestToChangeStoreAccount(StoreAccountModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_tryToSetStoreAccount", "PaymentGetwayController_requestToChangeStoreAccount"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@account", model.account.getDbValue());
                repo.cmd.Parameters.AddWithValue("@bankId", model.bankId);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                var outParam = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt64(outParam.Value) });
            }
        }
        /// <summary>
        /// سرویس ثبت شماره حساب فروشگاه در وضعیت بررسی
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        [Route("confirmStoreAccount")]
        [Exception]
        [HttpPost]
        public IHttpActionResult confirmStoreAccount(setStoreAccountModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_setStoreAccount", "PaymentGetwayController_confirmStoreAccount"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
            
                repo.cmd.Parameters.AddWithValue("@validationCode", model.validationCode);
                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس فعال/غیرفعال سازی امکان استفاده از درگاه آنلاین فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("changeOnlinePaymentStatus")]
        [Exception]
        [HttpPost]
        public IHttpActionResult changeOnlinePaymentStatus(changeOnlinePaymentStatusBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_changeOnlinePaymentStatus", "PaymentGetwayController_changeOnlinePaymentStatus"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@status",model.status);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس فعال سازی/غیرفعال سازی پرداخت امن فروشگاه 
        /// </summary>
        /// <returns></returns>
        [Route("changeSecurePaymentStatus")]
        [Exception]
        [HttpPost]
        public IHttpActionResult changeSecurePaymentStatus()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_changeSecurePaymentStatus", "PaymentGetwayController_changeSecurePaymentStatus"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس درخواست فعالسازی پرداخت امن فروشگاه
        /// </summary>
        /// <returns></returns>
        [Route("requestToActiveSecurePayment")]
        [Exception]
        [HttpPost]
        public IHttpActionResult requestToActiveSecurePayment()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_tryToActiveSecurePayment", "PaymentGetwayController_requestToActiveSecurePayment"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();
              
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                var outParam = repo.cmd.Parameters.Add("@id", SqlDbType.BigInt);
                outParam.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg, id = Convert.ToInt64(outParam.Value) });
            }
        }

       /// <summary>
       /// سرویس ثبت درخواست فعال سازی پرداخت امن
       /// وضعیت : در حال بررسی
       /// </summary>
       /// <param name="model"></param>
       /// <returns></returns>
        [Route("confirmActiveSecurePayment")]
        [Exception]
        [HttpPost]
        public IHttpActionResult confirmActiveSecurePayment(setStoreAccountModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_setActiveSecurePayment", "PaymentGetwayController_confirmActiveSecurePayment"))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@id", model.id);
                repo.cmd.Parameters.AddWithValue("@validationCode", model.validationCode);
                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId);
                repo.ExecuteNonQuery();
                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new { msg = repo.rMsg });
            }
        }
        /// <summary>
        /// سرویس دریافت گردش حساب کاربر/فروشگاه
        /// چنانچه فروشگاه مدنظر است شناسه فروشگاه  ست شود 
        /// </summary>
        /// <param name="model"></param>
        /// <returns>
        /// [
             /// {
             ///     "id": 89,
             ///     "regardDsc": "بدهکار سازي فروشنده به ميزان هزينه رديف سفارش در پ",
             ///     "debit": -3270,
             ///     "credit": 0,
             ///     "saveDatetime": "1397/09/18 15:51",
             ///     "amount": -3270,
             ///     "man": -3270
             /// },
             /// {
             ///     "id": 90,
             ///     "regardDsc": "بستانکاري فروشنده به ميزان قدرالسهم از رديف سفارش ",
             ///     "debit": 0,
             ///     "credit": 3270,
             ///     "saveDatetime": "1397/09/18 15:51",
             ///     "amount": 3270,
             ///     "man": 0
             /// }
       /// ]
       /// </returns>
        [Route("getTurnover")]
        [Exception]
        [HttpPost]
        public IHttpActionResult getTurnover(getTurnoverBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getTurnover", "PaymentGetwayController_getTurnover",initAsReader:true))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
                //if (!repo.hasAccess)
                //    return new ForbiddenActionResult();

                repo.cmd.Parameters.AddWithValue("@storeId", model.storeId.dbNullCheckLong());
                repo.ExecuteAdapter();
                var data = repo.ds.Tables[0].AsEnumerable();
                return Ok(data.Select(i=>
                    new
                    {
                        id = i.Field<object>("id"),
                        regardDsc = i.Field<object>("regardDsc"),
                        debit = i.Field<object>("debit"),
                        credit = i.Field<object>("credit"),
                        saveDatetime = i.Field<object>("saveDatetime"),
                        amount = i.Field<object>("man"),
                        man = i.Field<object>("sum")
                    }).ToList());
            }
        }
    }
    public class StoreAccountModel
    {
        public string account { get; set; }
        public int bankId { get; set; }
    }
    public class setStoreAccountModel
    {
        public string validationCode { get; set; }
        /// <summary>
        /// شناسه بازگزدانده شده از سرویس tryToSetStoreAccount
        /// </summary>
        public long id { get; set; }
    }
    public class getTurnoverBindingModel
    {
        public long? storeId { get; set; }
    }
    public class changeOnlinePaymentStatusBindingModel
    {
        public byte status { get; set; }
    }
}
