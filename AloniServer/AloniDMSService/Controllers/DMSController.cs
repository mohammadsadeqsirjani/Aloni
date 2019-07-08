using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.ServiceModel.Channels;
using System.Web.Configuration;
using Newtonsoft.Json;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;

namespace AloniDMSService.Controllers
{
    /// <summary>
    /// ای پی آی آپلود مستندات
    /// </summary>
    [RoutePrefix("DMS")]
    public class DMSController : ApiController
    {
        public class modelBinding
        {
            public string file_Name { get; set; }
            public string caption { get; set; }
            public int fk_documentType_id { get; set; }
            public string description { get; set; }
            public long fk_EntityId { get; set; }
            public bool isDefault { get; set; }
            public string uid { get; set; }
            public string dmsUrl { get; set; }
            public string downloadLink { get; set; }
        }
        /// <summary>
        /// سرویس اپلود مستندات
        /// </summary>
        /// <returns></returns>
        [Route("add")]
        [HttpPost]
        public async Task<IHttpActionResult> Add()
        {
            try
            {
                // Check if the request contains multipart/form-data.  
                if (!Request.Content.IsMimeMultipartContent())
                {
                    throw new HttpResponseException(HttpStatusCode.UnsupportedMediaType);
                }
                var provider = await Request.Content.ReadAsMultipartAsync<Models.InMemoryMultipartFormDataStreamProvider>(new Models.InMemoryMultipartFormDataStreamProvider());
                //access form data  
                NameValueCollection formData = provider.FormData;
                //access files  
                IList<HttpContent> files = provider.Files;

                HttpContent file1 = files[0];
                string guid = Guid.NewGuid().ToString();
                string [] arrayFileName = file1.Headers.ContentDisposition.FileName.Trim('\"').Split('.');
                var thisFileName = guid + "." + arrayFileName[arrayFileName.Length - 1];

                string filename = String.Empty;
                Stream input = await file1.ReadAsStreamAsync();
                var filetype = file1.Headers.ContentDisposition.FileName.Trim('\"').Split('.')[1];
                var imageFileType = "jpg png jpeg gif bmp svg tiff".Split(' ');
                string URL = String.Empty;
                string docUrl = WebConfigurationManager.AppSettings["physicaluploadpath"];
                string tumpDocUrl = WebConfigurationManager.AppSettings["physicaluploadthumbpath"];
                //Deletion exists file  
                if (File.Exists(docUrl))
                {
                    File.Delete(thisFileName);
                }
                URL = docUrl + thisFileName;
                var tumpUrl = tumpDocUrl + thisFileName;
                using (Stream file = File.OpenWrite(URL))
                {
                    input.CopyTo(file);
                    file.Close();
                    if (imageFileType.Contains(filetype))
                    {
                        Image image = System.Drawing.Image.FromStream(input);
                        image = ResizeImage(image, 150, 150);
                        image.Save(tumpUrl);
                    }
                }
                modelBinding obj = new modelBinding()
                {
                    file_Name = file1.Headers.ContentDisposition.FileName.Trim('\"'),
                    caption = formData["caption"],
                    fk_documentType_id = Convert.ToInt16(formData["fk_documentType_id"]),
                    description = formData["description"],
                    uid = guid,
                    fk_EntityId = Convert.ToInt64(formData["fk_EntityId"]),
                    isDefault = Convert.ToBoolean(formData["isDefault"]),
                    dmsUrl = WebConfigurationManager.AppSettings["dmsServerUrl"],
                    downloadLink = WebConfigurationManager.AppSettings["dmsServerUrl"] + thisFileName 

                };
                // call server 
                using (var client = new WebClient())
                {
                    var jsonObj = JsonConvert.SerializeObject(obj);
                    // Set the header so it knows we are sending JSON.
                    client.Headers[HttpRequestHeader.ContentType] = "application/json;charset=UTF-8";
                    client.Headers.Add("authorization", Request.Headers.GetValues("authorization").First());
                    client.Headers.Add("appId", Request.Headers.GetValues("appId").First());
                    client.Headers.Add("Accept-Language", Request.Headers.GetValues("Accept-Language").First());
                    client.Headers.Add("sessionId", Request.Headers.GetValues("sessionId").First());
                    // Make the request
                    string webserverUrl = WebConfigurationManager.AppSettings["webServerUrl"];
                    var response = client.UploadString(webserverUrl, "POST", jsonObj);
                }
                
                return Ok(obj);
            }

            catch (Exception ex)
            {
                return Unauthorized();
                throw;
            }
        }
        private Image ResizeImage(Image img, int maxWidth, int maxHeight)
        {
            if (img.Height < maxHeight && img.Width < maxWidth) return img;
            using (img)
            {
                Double xRatio = (double)img.Width / maxWidth;
                Double yRatio = (double)img.Height / maxHeight;
                Double ratio = Math.Max(xRatio, yRatio);
                int nnx = (int)Math.Floor(img.Width / ratio);
                int nny = (int)Math.Floor(img.Height / ratio);
                Bitmap cpy = new Bitmap(nnx, nny, PixelFormat.Format32bppArgb);
                using (Graphics gr = Graphics.FromImage(cpy))
                {
                    gr.Clear(Color.Transparent);

                    // This is said to give best quality when resizing images
                    gr.InterpolationMode = InterpolationMode.HighQualityBicubic;

                    gr.DrawImage(img,
                        new Rectangle(0, 0, nnx, nny),
                        new Rectangle(0, 0, img.Width, img.Height),
                        GraphicsUnit.Pixel);
                }
                return cpy;
            }

        }
    }
}
