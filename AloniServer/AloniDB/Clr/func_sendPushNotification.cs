using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Net;
using System.IO;
using System.Text;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlString func_sendPushNotification(
        string address,
        string authorization,
        string appId,
        string playerIds,
        string section,
        string action,
        string targetId,
        string par1,
        string par2,
         string par3,
        string par4,
        string heading,
        string content,
        byte provider,
        string proxy_host,
        int? proxy_port,
        string proxy_username,
        string proxy_password,
        byte OStype)
    {
        //address = "https://onesignal.com/api/v1/notifications";
        var request = WebRequest.Create(address) as HttpWebRequest;
        #region proxy server
        //request.Proxy = new WebProxy("nrayvarz.ir", 8585);
        //request.Proxy.Credentials = new NetworkCredential("rayvarz", "rayvarz");
        if (!string.IsNullOrEmpty(proxy_host) && proxy_port.HasValue)
        {
            request.Proxy = new WebProxy(proxy_host, proxy_port.Value);
            request.Proxy.Credentials = new NetworkCredential(proxy_username, proxy_password);
        }
        #endregion

        content = content.Replace("\"", "\\\"");
        heading = heading.Replace("\"", "\\\"");
        string body = string.Empty;

        if (provider == 1)
        {//GCM
            body = "";
        }
        else if (provider == 2)
        {//FCM
            request.KeepAlive = true;
            request.Method = "POST";
            request.ContentType = "application/json; charset=utf-8";
            //authorization = "key=AIzaSyAzlUBfPAlPfoOq_lm0QLDfvh1bpotRLS4";
            request.Headers.Add("authorization", authorization);

            if (OStype == 1)//android
            {
                string data = string.Format("{{\"body\":\"{0}\",\"title\" : \"{1}\",\"sound\" : \"{2}\",\"priority\" : \"high\",\"section\" : \"{3}\",\"action\" : \"{4}\",\"targetId\" : \"{5}\" , \"par1\" : \"{6}\" , \"par2\" : \"{7}\", \"par3\" : \"{8}\" , \"par4\" : \"{9}\"}}", content, heading, "default", section, action, targetId, par1, par2, par3, par4);
                body = "{"
                            + "\"priority\" : \"high\""
                            + string.Format(",\"data\" : {0}", data)
                            + string.Format(",\"to\" : \"{0}\"", playerIds)
                       + "}";
            }
            else if (OStype == 2)//IOS
            {
                string data = string.Format("{{\"section\" : \"{0}\",\"action\" : \"{1}\",\"targetId\" : \"{2}\" , \"par1\" : \"{3}\" , \"par2\" : \"{4}\", \"par3\" : \"{5}\" , \"par4\" : \"{6}\"}}", section, action, targetId, par1, par2,par3,par4);
                body =
                        "{"
                                + "\"notification\":{"
                                + string.Format("\"body\":\"{0}\",\"title\" : \"{1}\",\"sound\" : \"{2}\",\"priority\" : \"high\"", content, heading, "default")
                                + "}"
                            + string.Format(",\"data\" : {0}", data)
                            + string.Format(",\"to\" : \"{0}\"", playerIds)
                       + "}";


            }

        }
        else if (provider == 3)
        {//ONESIGNAL

            request.KeepAlive = true;
            request.Method = "POST";
            request.ContentType = "application/json; charset=utf-8";
            //authorization = "Basic N2U3NWFhNDItYjFlMC00NWM4LTkwYzgtOTM1ZDY5YWRjNTVl";
            request.Headers.Add("authorization", authorization);
            string data = string.Format("{{\"section\" : \"{0}\",\"action\" : \"{1}\",\"targetId\" : \"{2}\" , \"par1\" : \"{3}\" , \"par2\" : \"{4}\", \"par3\" : \"{5}\" , \"par4\" : \"{6}\"}}", section, action, targetId, par1, par2,par3,par4);
            body =
                "{"
                + string.Format("\"app_id\": \"{0}\"", appId)
                + string.Format(",\"include_player_ids\": [{0}]", playerIds)//\"6392d91a-b206-4b7b-a620-cd68e32c3a76\",\"76ece62b-bcfe-468c-8a78-839aeaa8c5fa\",\"8e0f21fa-9a5a-4ae7-a9a6-ca1f24294b86\"
                + string.Format(",\"data\" : {0}", data)
                + string.Format(",\"contents\": {{\"en\": \"{0}\"}}", content)
                + string.Format(",\"headings\": {{\"en\": \"{0}\"}}", heading)
                + "}";
        }




        byte[] byteArray = Encoding.UTF8.GetBytes(body);

        string responseContent = null;

        try
        {
            using (var writer = request.GetRequestStream())
            {
                writer.Write(byteArray, 0, byteArray.Length);
            }

            using (var response = request.GetResponse() as HttpWebResponse)
            {
                using (var reader = new StreamReader(response.GetResponseStream()))
                {
                    responseContent = reader.ReadToEnd();
                }
            }
        }
        catch (WebException ex)
        {
            //System.Diagnostics.Debug.WriteLine(ex.Message);
            //System.Diagnostics.Debug.WriteLine(new StreamReader(ex.Response.GetResponseStream()).ReadToEnd());

            responseContent = ex.Message + " " + (ex.Response != null ? new StreamReader(ex.Response.GetResponseStream()).ReadToEnd() : "");
        }
        catch (Exception ex)
        {
            responseContent = ex.Message;
        }
        return new SqlString(responseContent);
        //select dbo.func_sendPushNotification('https://onesignal.com/api/v1/notifications','Basic N2U3NWFhNDItYjFlMC00NWM4LTkwYzgtOTM1ZDY5YWRjNTVl','0b0308d0-d613-4af8-ad3d-213d28abb01e','"60f5f4fb-a2b1-4b84-a0aa-d88e7f9d5d8d"','sec','ac','targid','par1','par2','aaaaa')
    }
}
