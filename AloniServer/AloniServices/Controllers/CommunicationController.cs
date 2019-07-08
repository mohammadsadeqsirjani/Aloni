using AloniServices.com.magfa.sms;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// ارتباطات
    /// </summary>
    [RoutePrefix("Communication")]
    public class CommunicationController : ApiController
    {
        /// <summary>
        /// ارسال پیام کوتاه
        /// </summary>
        /// <param name="userName">نام کاربری</param>
        /// <param name="password">رمز عبور</param>
        /// <param name="domain">دامنه</param>
        /// <param name="msgBody">بدنه پیام</param>
        /// <param name="srcNo">شماره مبدا</param>
        /// <param name="dstNo">شماره مقصد</param>
        /// <returns>کد رهگیری یا پیغام خطا</returns>
        [Route("sendsms")]
        [Exception]
        [HttpGet]
        public string sendSms(string userName, string password, string domain, string msgBody, string srcNo, string dstNo)
        {
            try
            {
                var sq = new SoapSmsQueuableImplementationService();
                //sq.Credentials = new System.Net.NetworkCredential("aloni-co97500055", "lzgeWwPjnBagYwDL");
                //sq.PreAuthenticate = true;
                //var res = sq.enqueue("magfa", new string[] { "سلام. ایتز وورکینگ!" }, new string[] { "+989353753855" }, new string[] { "98300042336" }, new int[] { -1 }, new string[] { "" }, new int[] { -1 }, new int[] { -1 }, new long[] { 200 });
                sq.Credentials = new System.Net.NetworkCredential(userName, password);
                sq.PreAuthenticate = true;
                var res = sq.enqueue(domain, new string[] { msgBody }, new string[] { dstNo }, new string[] { srcNo }, new int[] { -1 }, new string[] { "" }, new int[] { -1 }, new int[] { -1 }, new long[] { 200 });
                return res[0].ToString();

            }
            catch (Exception ex) { return ex.Message.PadRight(36, ' ').Substring(0, 36); }
        }
    }
    

}
