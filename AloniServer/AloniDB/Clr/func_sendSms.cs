using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Net;
using System.IO;

public partial class UserDefinedFunctions
{
    [SqlFunction]
    public static SqlString func_sendSms(string url, string userName, string password, string domain, string msgBody, string srcNo, string dstNo)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(string.Format("{0}/sendsms?userName={1}&password={2}&domain={3}&msgBody={4}&srcNo={5}&dstNo={6}", url, userName, password, domain, msgBody, srcNo, dstNo));
        //request.ContentType = "application/json; charset=utf-8";
        request.Method = "GET";
        //request.Headers.Add(HttpRequestHeader.Authorization, Authorization);

        //        using (var streamWriter = new StreamWriter(request.GetRequestStream()))
        //        {
        //            string json = string.Format("{{\"srcNumber\":\"{0}\",\"userName\":\"{1}\",\"password\":\"{2}\",\"ip\":\"{3}\",\"company\":\"{4}\",\"destNumber\":\"{5}\",\"msg\":\"{6}\",\"flash\":\"{7}\"}}"
        ////string.Format(@"{{""srcNumber"" : ""{0}"", ""userName"" : ""{1}"", ""password"" : ""{2}"", ""ip"" : ""{3}"", ""company"" : ""{4}"", ""destNumber"" : ""{5}"", ""msg"" : ""{6}"", ""flash"" : {7}}}"
        //, srcNumber, userName, password, ip, company, destNumber, msg, flash /*? 1 : 0*/);

        //            //return new SqlString(json);
        //            streamWriter.Write(json);
        //            streamWriter.Flush();
        //        }
        using (var httpResponse = (HttpWebResponse)request.GetResponse())
        {
            using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
            {
                return new SqlString(streamReader.ReadToEnd());
                //return !string.IsNullOrEmpty(result) && result.Contains("\"success\":1");
            }
        }
    }
}