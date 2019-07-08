using System;
using System.Web.Script.Serialization;

namespace AloniExternalService.Tools
{
    public static class Extentions
    {
        #region object

        public static string Jserialize(this object obj)
        {
            return new JavaScriptSerializer() { MaxJsonLength = int.MaxValue }.Serialize(obj);
        }
        public static object Jdeserialize(this string str, Type destinationTyp)
        {

            var js = new JavaScriptSerializer();
            return js.Deserialize(str, destinationTyp);
        }
        #endregion

        #region date time
        public static long ToUnixTimeStamp(this DateTime dt)
        {
            return (long)(TimeZoneInfo.ConvertTimeToUtc(dt) - new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc)).TotalSeconds;
        }
        #endregion
    }
}