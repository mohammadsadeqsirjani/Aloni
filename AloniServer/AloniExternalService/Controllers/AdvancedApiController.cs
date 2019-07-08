using AloniExternalService.Tools;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.ServiceModel.Channels;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.Filters;
using System.Web.Http.ModelBinding;
namespace AloniExternalService.Controllers
{
    public abstract class AdvancedApiController : ApiController
    {
        #region common headers
        public object clientIp
        {
            get
            {
                try
                {

                    if (Request.Properties.ContainsKey("MS_HttpContext"))
                    {
                        return ((HttpContextWrapper)Request.Properties["MS_HttpContext"]).Request.UserHostAddress;
                    }
                    else if (Request.Properties.ContainsKey(RemoteEndpointMessageProperty.Name))
                    {
                        RemoteEndpointMessageProperty prop = (RemoteEndpointMessageProperty)Request.Properties[RemoteEndpointMessageProperty.Name];
                        return prop.Address;
                    }
                    else if (HttpContext.Current != null)
                    {
                        return HttpContext.Current.Request.UserHostAddress;
                    }
                    else
                    {
                        return DBNull.Value;
                    }
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object clientLanguage
        {
            get
            {
                try
                {
                    return (Request.Headers.AcceptLanguage.FirstOrDefault()
                        ?? new System.Net.Http.Headers.StringWithQualityHeaderValue("en")).Value.getDbValue();
                }
                catch { return DBNull.Value; }
            }
        }
        public object authorization
        {
            get
            {
                return Request.Headers.Authorization.Scheme.getDbValue();
            }
        }
        /// <summary>
        /// شناسه اپلیکیشن کلاینت
        /// 1: فروشنده
        /// 2: خریدار
        /// 3: پرتال
        /// </summary>
        public object appId
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("appId", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object storeId
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("storeId", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object orderId
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("orderId", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object sessionId
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("sessionId", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object pageNo
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("pageNo", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object search
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("search", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object parent
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("parent", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }
        public object appVersion
        {
            get
            {
                try
                {
                    return Request.Headers.FirstOrDefault(h => h.Key.Equals("appVersion", StringComparison.InvariantCultureIgnoreCase))
                        .Value.FirstOrDefault().getDbValue();
                }
                catch
                {
                    return DBNull.Value;
                }
            }
        }

        #endregion
        public string mobile
        {
            get; set;
        }
        public string otpCode
        {
            get; set;
        }
    }
    public static class extentions
    {
        public static object getDbValue(this string val)
        {
            return string.IsNullOrEmpty(val) ? DBNull.Value : (object)(val
                .Replace("۰", "0")
                .Replace("۱", "1")
                .Replace("۲", "2")
                .Replace("۳", "3")
                .Replace("۴", "4")
                .Replace("۵", "5")
                .Replace("۶", "6")
                .Replace("۷", "7")
                .Replace("۸", "8")
                .Replace("۹", "9")
                .Replace("ی", "ي")
                .Replace("ک", "ک").TrimStart().TrimEnd());
        }
        public static object getDbValue(this object val)
        {
            return val == null ? DBNull.Value : val;
        }
        public static object getDbValue(this Guid? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static object getDbValue(this int? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static object getDbValue(this DateTime? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static object getDbValue(this long? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static object getDbValue(this bool? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static object getDbValue(this byte? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static object getDbValue(this decimal? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static object getDbValue(this float? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }

        public static object getDbValue(this short? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }

        public static object getDbValue(this double? val)
        {
            return val.HasValue ? (object)val.Value : DBNull.Value;
        }
        public static string dbNullCheckString(this object val)
        {
            return val is DBNull || val == null ? null : val.ToString().TrimStart().TrimEnd();
        }
        public static long? dbNullCheckLong(this object val)
        {
            return val is DBNull ? new long?() : Convert.ToInt64(val);
        }
        public static int? dbNullCheckInt(this object val)
        {
            return val is DBNull ? new int?() : Convert.ToInt32(val);
        }
        public static short? dbNullCheckShort(this object val)
        {
            return val is DBNull ? new short?() : Convert.ToInt16(val);
        }
        public static DateTime? dbNullCheckDatetime(this object val)
        {
            return val is DBNull ? new DateTime?() : Convert.ToDateTime(val);
        }
        public static double? dbNullCheckDouble(this object val)
        {
            return val is DBNull ? new double?() : Convert.ToDouble(val);
        }

        public static byte? dbNullCheckByte(this object val)
        {
            return val is DBNull ? new byte?() : Convert.ToByte(val);
        }
        public static bool? dbNullCheckBoolean(this object val)
        {
            return val is DBNull ? new bool?() : Convert.ToBoolean(val);
        }
        public static decimal? dbNullCheckDecimal(this object val)
        {
            return val is DBNull ? new decimal?() : Convert.ToDecimal(val);
        }
        public static object getLongDbValue(this long? val)
        {
            return val.HasValue ? (object)val : DBNull.Value;
        }
        public static object getShortDbValue(this short? val)
        {
            return val.HasValue ? (object)val : DBNull.Value;
        }
    }

    #region database utilities
    public enum autenticationMode
    {
        authenticateAsUser = 0,
        authenticateAsAnonymous,
        NoAuthenticationRequired
        
    }

    public class messageModel
    {
        public messageModel(string _msg)
        {
            msg = _msg;
        }
        public string msg { get; set; }
    }

    public class Repo : IDisposable
    {
        public string spName_;
        public Repo(AdvancedApiController controller, string spName, string funcId, autenticationMode AuthMode = autenticationMode.authenticateAsUser, bool initAsReader = false, bool checkAccess = true)
        {
            spName_ = spName;
            theAutenticationMode = AuthMode;
            con = new SqlConnection(ConfigurationManager.ConnectionStrings["dbConStr"].ConnectionString);
            cmd = con.CreateCommand();
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandText = spName;
            cmd.Parameters.AddWithValue("@clientLanguage", controller.clientLanguage);
            cmd.Parameters.AddWithValue("@appId", controller.appId);
            cmd.Parameters.AddWithValue("@clientIp", controller.clientIp);
            if (initAsReader)
            {
                cmd.Parameters.AddWithValue("@pageNo", controller.pageNo);
                //   cmd.Parameters.AddWithValue("@search", controller.search);
                cmd.Parameters.AddWithValue("@parent", controller.parent);
            }
            else
            {

                par_rCode = cmd.Parameters.Add("@rCode", SqlDbType.TinyInt);
                par_rCode.Direction = ParameterDirection.Output;

                par_rMsg = cmd.Parameters.Add("@rMsg", SqlDbType.NVarChar, -1);
                par_rMsg.Direction = ParameterDirection.Output;


            }
            con.Open();

            if (theAutenticationMode == autenticationMode.NoAuthenticationRequired)
                return;

            cmdA = con.CreateCommand();
            cmdA.CommandType = CommandType.StoredProcedure;

            //par_sessionId = cmdA.Parameters.Add("@sessionId", SqlDbType.BigInt);
            //par_sessionId.Direction = ParameterDirection.InputOutput;
            //par_sessionId.Value = controller.sessionId;
            cmdA.Parameters.AddWithValue("@sessionId", controller.sessionId);
            // cmdA.Parameters.AddWithValue("@appVersion", controller.appVersion);
            // cmdA.Parameters.AddWithValue("@checkPermission", controller.checkPermission);
            //par_authorization = cmdA.Parameters.Add("@authorization", SqlDbType.Char, 128);
            //par_authorization.Direction = ParameterDirection.InputOutput;
            //par_authorization.Value = controller.authorization;
            cmdA.Parameters.AddWithValue("@authorization", controller.authorization);

            par_unauthorized = cmdA.Parameters.Add("@unauthorized", SqlDbType.Bit);
            par_unauthorized.Direction = ParameterDirection.Output;


            if (theAutenticationMode == autenticationMode.authenticateAsAnonymous)
            {
                cmdA.CommandText = "SP_authenticateReq";
                cmdA.Parameters.AddWithValue("@mobile", controller.mobile.getDbValue());
                cmdA.Parameters.AddWithValue("@otpCode", controller.otpCode.getDbValue());
                cmdA.Parameters.AddWithValue("@clientIp", controller.clientIp == null ? "0.0.0.0" : controller.clientIp);
                cmdA.ExecuteNonQuery();
            }
            else if (theAutenticationMode == autenticationMode.authenticateAsUser)
            {
                cmdA.CommandText = "SP_authenticateUser";
                cmdA.Parameters.AddWithValue("@funcId", funcId);
                cmdA.Parameters.AddWithValue("@checkAccess", checkAccess);
                cmdA.Parameters.AddWithValue("@storeId", controller.storeId.getDbValue());
                cmdA.Parameters.AddWithValue("@orderId", controller.orderId.getDbValue());
                cmdA.Parameters.AddWithValue("@clientIp", controller.clientIp == null ? "0.0.0.0":controller.clientIp);
                par_appId = cmdA.Parameters.Add("@appId", SqlDbType.TinyInt);
                par_appId.Direction = ParameterDirection.InputOutput;
                par_appId.Value = controller.appId;

                par_userId = cmdA.Parameters.Add("@userId", SqlDbType.BigInt);
                par_userId.Direction = ParameterDirection.Output;

                par_accessDenied = cmdA.Parameters.Add("@accessDenied", SqlDbType.Bit);
                par_accessDenied.Direction = ParameterDirection.Output;

                par_osType = cmdA.Parameters.Add("@osType", SqlDbType.TinyInt);
                par_osType.Direction = ParameterDirection.Output;

                par_appVersion = cmdA.Parameters.Add("@appVersion", SqlDbType.Money);
                par_appVersion.Direction = ParameterDirection.Output;


                //par_termsAndConditions_LastAccepted = cmdA.Parameters.Add("@termsAndConditions_LastAccepted", SqlDbType.BigInt);
                //par_termsAndConditions_LastAccepted.Direction = ParameterDirection.Output;


                par_staffId = cmdA.Parameters.Add("@staffId", SqlDbType.SmallInt);
                par_staffId.Direction = ParameterDirection.Output;

                cmdA.ExecuteNonQuery();
                //if (!unauthorized)
                //{
                cmd.Parameters.AddWithValue("@userId", par_userId.Value);
                //cmd.Parameters.AddWithValue("@appId", appId);
                //}

            }
            else
                throw new Exception("invalid autenticationMode");


        }
        #region Ado Objs
        public SqlConnection con;
        public SqlCommand cmd;
        private SqlCommand cmdA;
        public SqlDataReader sdr;
        public SqlDataAdapter sda;
        public DataSet ds;
        #endregion
        #region common SQL params
        SqlParameter par_appId;
        public byte appId
        {
            get
            {
                return Convert.ToByte(par_appId.Value);
            }
        }
        SqlParameter par_storeId;
        public long storeId
        {
            get
            {
                return Convert.ToInt64(par_storeId.Value);
            }
        }

        SqlParameter par_userId;
        public long userId
        {
            get
            {
                return Convert.ToInt64(par_userId.Value);
            }
        }
        SqlParameter par_osType;
        public byte? osType
        {
            get
            {
                return par_osType.Value.dbNullCheckByte(); //Convert.ToByte(par_osType.Value);
            }
        }


        SqlParameter par_appVersion;
        public byte? appVersion
        {
            get
            {
                return par_appVersion.Value.dbNullCheckByte(); //Convert.ToByte(par_appVersion.Value);
            }
        }



        //SqlParameter par_termsAndConditions_LastAccepted;
        //public long termsAndConditions_LastAccepted
        //{
        //    get
        //    {
        //        return Convert.ToInt64(par_termsAndConditions_LastAccepted.Value);
        //    }
        //}

        SqlParameter par_staffId;
        public short staffId
        {
            get
            {
                return Convert.ToInt16(par_staffId.Value);
            }
        }
        //SqlParameter par_sessionId;
        //public long sessionId
        //{
        //    get
        //    {
        //        return Convert.ToInt64(par_sessionId.Value);
        //    }
        //}
        private autenticationMode theAutenticationMode;
        SqlParameter par_authorization;
        public string authorization
        {
            get
            {
                return Convert.ToString(par_authorization.Value);
            }
        }
        SqlParameter par_unauthorized;
        public bool unauthorized
        {
            get
            {
                if (theAutenticationMode == autenticationMode.NoAuthenticationRequired)
                    return false;
                return Convert.ToBoolean(par_unauthorized.Value);
            }
        }
        SqlParameter par_rCode;
        public byte rCode
        {
            get
            {
                return Convert.ToByte(par_rCode.Value);
            }
        }
        SqlParameter par_rMsg;
        public string rMsg
        {
            get
            {
                return Convert.ToString(par_rMsg.Value);
            }
        }
        public messageModel operationMessage
        {
            get
            {
                return new messageModel(rMsg);
            }
        }

        SqlParameter par_accessDenied;
        public bool accessDenied
        {
            get
            {
                return Convert.ToBoolean(par_accessDenied.Value);
            }
        }
        #endregion
        public void Dispose()
        {
            if (cmdA != null)
                cmdA.Dispose();
            if (sdr != null)
                sdr.Dispose();
            if (cmd != null)
                cmd.Dispose();
            if (ds != null)
                ds.Dispose();
            if (sda != null)
                sda.Dispose();
            if (con != null)
            {
                con.Close();
                con.Dispose();
            }
        }

        #region Ado Functions
        public void ExecuteNonQuery()
        {
            //if (unauthorized)
            //    throw new Exception("unauthorized!");
            cmd.ExecuteNonQuery();
        }
        public void ExecuteReader()
        {
            if (unauthorized)
                throw new Exception("unauthorized!");
            sdr = cmd.ExecuteReader();
        }
        public void ExecuteAdapter()
        {
            if (unauthorized)
                throw new Exception("unauthorized!");
            sda = new SqlDataAdapter(cmd);
            ds = new DataSet();
            sda.Fill(ds);
        }
        #endregion
    }
    #endregion
    #region Advanced Action Results

    public class HttpActionResult : IHttpActionResult
    {
        private readonly string _message;
        private readonly HttpStatusCode _statusCode;

        public HttpActionResult(HttpStatusCode statusCode, string message)
        {
            _statusCode = statusCode;
            _message = string.Format("{{\"msg\" : \"{0}\"}}", message);
        }

        public Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            HttpResponseMessage response = new HttpResponseMessage(_statusCode)
            {
                Content = new StringContent(_message)
            };
            return Task.FromResult(response);
        }
    }
    public class ExceptionAttribute : ExceptionFilterAttribute
    {
        public override void OnException(HttpActionExecutedContext context)
        {
            //Debug.WriteLine(context.Exception);
            throw new HttpResponseException(new HttpResponseMessage(HttpStatusCode.InternalServerError)
            {
                Content = new StringContent(new messageModel( bool.Parse(ConfigurationManager.AppSettings["showUnhandledError"]) ?
                (context.Exception.Message + " inner: " + (context.Exception.InnerException ?? new Exception("no inner exception")).Message) :
                "با عرض پوزش، درحال حاضر عملکرد برنامه با مشکل مواجه شده است").Jserialize()),
                ReasonPhrase = "Deadly Exception"
            });
        }
    }
    public class NotFoundActionResult : IHttpActionResult
    {
        private readonly string _message;
        private readonly HttpStatusCode _statusCode;

        public NotFoundActionResult(string message)
        {
            _statusCode = HttpStatusCode.NotFound;
            _message = new messageModel(message).Jserialize();
        }

        public Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            HttpResponseMessage response = new HttpResponseMessage(_statusCode)
            {
                Content = new StringContent(_message)
            };
            return Task.FromResult(response);
        }
    }
    public class UnauthorizedActionResult : IHttpActionResult
    {
        private readonly string _message;
        private readonly HttpStatusCode _statusCode;

        public UnauthorizedActionResult(string message)
        {
            _statusCode = HttpStatusCode.Unauthorized;
            _message = new messageModel(message).Jserialize();
        }

        public Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            HttpResponseMessage response = new HttpResponseMessage(_statusCode)
            {
                Content = new StringContent(_message)
            };
            return Task.FromResult(response);
        }
    }

    public class ForbiddenActionResult : IHttpActionResult
    {
        private readonly string _message;
        private readonly HttpStatusCode _statusCode;

        public ForbiddenActionResult(string message = "access Denied")
        {
            _statusCode = HttpStatusCode.Forbidden;
            _message = string.Format("{{\"msg\" : \"{0}\"}}", message);
        }

        public Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            HttpResponseMessage response = new HttpResponseMessage(_statusCode)
            {
                Content = new StringContent(_message)
            };
            return Task.FromResult(response);
        }
    }
    public class BadRequestActionResult : IHttpActionResult
    {
        private readonly string _message;
        private readonly HttpStatusCode _statusCode;

        public BadRequestActionResult(string message)
        {
            _statusCode = HttpStatusCode.BadRequest;
            _message = string.Format("{{\"msg\" : \"{0}\"}}", message);
        }
        public BadRequestActionResult(ICollection<ModelState> modelstateValues)
        {
            _statusCode = HttpStatusCode.BadRequest;
            _message = string.Format("{{\"msg\" : \"{0}\"}}", string.Join("\n", modelstateValues.SelectMany(v => v.Errors).Select(s => s.ErrorMessage)));
        }

        public Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            HttpResponseMessage response = new HttpResponseMessage(_statusCode)
            {
                Content = new StringContent(_message)
            };
            return Task.FromResult(response);
        }
    }
    public class AutoActionResult<T> : IHttpActionResult
    {
        private readonly string _message;
        private readonly HttpStatusCode _statusCode;

        public AutoActionResult(int httpCode, string message, T value)
        {
            _statusCode = (HttpStatusCode)httpCode;
            _message = message;
        }

        public Task<HttpResponseMessage> ExecuteAsync(CancellationToken cancellationToken)
        {
            HttpResponseMessage response = new HttpResponseMessage(_statusCode)
            {
                Content = new StringContent(_message),

            };
            return Task.FromResult(response);
        }
    }
    /// <summary>
    /// فقط برای لیستهایی از جنس کلاس استفاده شود
    /// </summary>
    public static class ClassToDatatableConvertor
    {
        public static DataTable CreateDataTable<T>(IEnumerable<T> list)
        {
            Type type = typeof(T);
            var properties = type.GetProperties();

            DataTable dataTable = new DataTable();
            foreach (PropertyInfo info in properties)
            {
                dataTable.Columns.Add(new DataColumn(info.Name, Nullable.GetUnderlyingType(info.PropertyType) ?? info.PropertyType));
            }

            foreach (T entity in list)
            {
                object[] values = new object[properties.Length];
                for (int i = 0; i < properties.Length; i++)
                {
                    values[i] = properties[i].GetType().Name == "String" ? properties[i].GetValue(entity).ToString().getDbValue() : properties[i].GetValue(entity);
                }

                dataTable.Rows.Add(values);
            }

            return dataTable;
        }
    }
    #endregion
}