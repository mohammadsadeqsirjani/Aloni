using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AloniServices.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            DateTime today = DateTime.Now;
            DateTime next = new DateTime(2018, 1, 20 ,0 , 0 ,0);

            if (next < today)
                next = next.AddYears(1); 
            ViewBag.Day = (next - today).Days;
            ViewBag.H = (next - today).Hours;
            ViewBag.M = (next - today).Minutes;
            ViewBag.S = (next - today).Seconds;
            return View();
        }
    }
}
