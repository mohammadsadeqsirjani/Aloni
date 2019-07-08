using AloniServices.Tools;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// سرویس های مرتبط با نقشه
    /// </summary>
    [RoutePrefix("Map")]
    public class MapController : AdvancedApiController
    {
        /// <summary>
        /// دریافت آدرس یک نقطه بر روی نقشه
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        [Route("getAddress")]
        [Exception]
        [HttpPost]
        public async Task<IHttpActionResult> getAddress(locationModel input)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);

            using (var repo = new Repo(this, "", "Map_getAddress", autenticationMode.authenticateAsUser, false, false))
            {
                if (repo.unauthorized)
                    return new UnauthorizedActionResult("Unauthorized!");
            }
            var result = await Task.Run(() => new mapTools().getLocationName(input.lat, input.lng,clientLanguage.ToString(),"IR"));
            if (result.status)
            {
                input.address = result.body;
                return Ok(input);
            }
            else
                return Ok("no address");
            // return new NotFoundActionResult(result.message);


        }


        /// <summary>
        /// جست و جوی آدرس بر اساس کلید واژه
        /// توضیح : برخی از آیتم های این سرویس فاقد مختصات جغرافیایی می باشد
        /// در مورد این دست موارد
        /// جهت دریافت مختصات جغرافیایی ، می بایست با ارایه شناسه ردیف انتخاب شده توسط کاربر 
        /// به سرویس
        /// getPlaceDetails
        /// دریافت شود.
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        [Route("getPlaceAutocomplete")]
        [Exception]
        [HttpPost]
        public async Task<IHttpActionResult> getPlaceAutocomplete(srchAddressBindingModel input)
        {
            return new ForbiddenActionResult();
            //check token
            var googleResults = await Task.Run(() => new mapTools().getPlaceAutocomplete(input.key));
            return Ok(googleResults);
        }


        /// <summary>
        /// دریافت اطلاعات جئوگرافیک یک محل با شناسه گوگل
        /// لطفا مقادیر
        /// viewport
        /// نیز مورد استفاده قرار گیرد
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        [Route("getPlaceDetails")]
        [Exception]
        [HttpPost]
        public async Task<IHttpActionResult> getPlaceDetails(placeModel input)
        {
            return new ForbiddenActionResult();
            //check token

            var res = await Task.Run(() => new mapTools().getPlaceDetails(input));
            if (res != null)
                return Ok(res);
            else
                return NotFound();
        }
    }
}

