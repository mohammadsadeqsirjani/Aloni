using Google.Maps;
using Google.Maps.Geocoding;
using Google.Maps.Places;
using Google.Maps.Shared;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Web;

namespace AloniServices.Tools
{
    public class mapTools
    {

        public static string GetLocationStr(Result[] arr1)
        {
            string text = "";
            string text2 = "";
            string text3 = "";
            string text4 = "";
            string a = "";
            string a2 = "";
            string a3 = "";
            string text5 = "";
            string text6 = "";
            try
            {
                if (arr1 == null)
                {
                    string result = "";
                    return result;
                }
                if (arr1.Length == 0)
                {
                    string result = "";
                    return result;
                }
                AddressComponent[] addressComponents = arr1[0].AddressComponents;
                if (addressComponents == null)
                {
                    string result = "";
                    return result;
                }
                for (int i = 0; i < addressComponents.Length; i++)
                {
                    string text7 = addressComponents[i].LongName;
                    text7 = text7.Trim();
                    if (!(text7 == ""))
                    {
                        try
                        {
                            switch (addressComponents[i].Types[0])
                            {
                                case AddressType.StreetAddress:
                                    if (text2 == "")
                                    {
                                        text2 = text7;
                                    }
                                    break;
                                case AddressType.Route:
                                    if (text3 == "" && text7.IndexOf("Unnamed", System.StringComparison.OrdinalIgnoreCase) < 0)
                                    {
                                        text3 = text7;
                                    }
                                    break;
                                case AddressType.Political:
                                    if (addressComponents[i].Types[1] == AddressType.Sublocality && text5 == "")
                                    {
                                        text5 = text7;
                                    }
                                    break;
                                case AddressType.Country:
                                    if (addressComponents[i].Types[1] == AddressType.Political && a2 == "")
                                    {
                                        a2 = text7;
                                    }
                                    break;
                                case AddressType.AdministrativeAreaLevel1:
                                    if (addressComponents[i].Types[1] == AddressType.Political && a3 == "")
                                    {
                                        a3 = text7;
                                    }
                                    break;
                                case AddressType.AdministrativeAreaLevel3:
                                    if (addressComponents[i].Types[1] == AddressType.Political && text4 == "")
                                    {
                                        text4 = text7;
                                    }
                                    break;
                                case AddressType.Locality:
                                    if (addressComponents[i].Types[1] == AddressType.Political && text4 == "")
                                    {
                                        text4 = text7;
                                    }
                                    break;
                                case AddressType.Sublocality:
                                    if (addressComponents[i].Types[1] == AddressType.Political && text4 == "")
                                    {
                                        text4 = text7;
                                    }
                                    break;
                                case AddressType.Neighborhood:
                                    if (addressComponents[i].Types[1] == AddressType.Political && text6 == "")
                                    {
                                        text6 = text7;
                                    }
                                    break;
                                case AddressType.PostalCode:
                                    if (a == "")
                                    {
                                        a = text7;
                                    }
                                    break;
                                case AddressType.PointOfInterest:
                                    if (text3 == "")
                                    {
                                        text3 = text7;
                                    }
                                    break;
                                case AddressType.StreetNumber:
                                    if (text == "")
                                    {
                                        text = text7;
                                    }
                                    break;
                                case AddressType.PostalCodePrefix:
                                    if (addressComponents[i].Types[1] == AddressType.PostalCode && a == "")
                                    {
                                        a = text7;
                                    }
                                    break;
                            }
                        }
                        catch (System.Exception)
                        {
                        }
                    }
                }
            }
            catch (System.Exception)
            {
            }
            string text8 = (text + " " + text2).Trim();
            if (text3 != "")
            {
                if (text8 != "")
                {
                    text8 += "-";
                }
                text8 += text3;
            }
            if (text8 == "" && text6 != "")
            {
                text8 = text6;
            }
            if (text8 == "" && text5 != "")
            {
                if (text8 != "")
                {
                    text8 += "-";
                }
                text8 = text5;
            }
            if (text8 == "" && text4 != "")
            {
                text8 = text4;
            }
            if (text8 == "")
            {
                a3 = "";
            }
            if (text8 == "")
            {
                text8 = "مشهد";
            }
            return text8;
        }

        public response<string> getLocationName(double latitude, double longitude,string Language,string Region)
        {
            GoogleSigned signingInstance = new GoogleSigned(ConfigurationManager.AppSettings["googleApiKey"]);
            GoogleSigned.AssignAllServices(signingInstance);

            GeocodingRequest geocodingRequest = new GeocodingRequest();
            geocodingRequest.Address = new LatLng(latitude, longitude); ;
            geocodingRequest.Language = Language;
            geocodingRequest.Region = Region;
            //geocodingRequest.Sensor = new bool?(false);
            GeocodeResponse response = new GeocodingService().GetResponse(geocodingRequest);
            if (response.Status == ServiceResponseStatus.Ok || response.Status == ServiceResponseStatus.ZeroResults)
            {
                Result[] array = response.Results.ToArray<Result>();
                if (array.Length > 0)
                {
                    response<string> result = new response<string>(GetLocationStr(array));
                    return result;
                }
            }
            return new response<string>(new Exception("no result found , or api key has limmited !"));
        }
        public List<placeModel> getPlaceAutocomplete_2(string keyword)
        {
            var retlist = new List<placeModel>();
            GoogleSigned signingInstance = new GoogleSigned(ConfigurationManager.AppSettings["googleApiKey"]);
            GoogleSigned.AssignAllServices(signingInstance);


            AutocompleteRequest autocompleteRequest = new AutocompleteRequest();

            //GeocodingRequest geocodingRequest = new GeocodingRequest();
            //autocompleteRequest.Address = new LatLng(latitude, longitude); ;
            autocompleteRequest.Language = "Fa";
            autocompleteRequest.Input = keyword;
            string loca = ConfigurationManager.AppSettings["placeAutocomplete_location"];

            autocompleteRequest.Location = new LatLng(double.Parse(loca.Split(',')[0]),
                double.Parse(loca.Split(',')[1]));
            autocompleteRequest.Radius = int.Parse(ConfigurationManager.AppSettings["placeAutocomplete_radius"]);
            //autocompleteRequest.Region = "IR";
            //autocompleteRequest.Sensor = new bool?(false);
            AutocompleteResponse response = new PlacesService().GetAutocompleteResponse(autocompleteRequest);
            if (response.Status == ServiceResponseStatus.Ok || response.Status == ServiceResponseStatus.ZeroResults)
            {
                foreach (var itm in response.Predictions)
                {
                    retlist.Add(new placeModel()
                    {
                        google_id = itm.Id,
                        google_place_id = itm.PlaceId,
                        id = 0,
                        lat = 0,
                        lng = 0,
                        name = itm.description,
                        //near = itm.
                    });
                }
            }
            return retlist;
        }










        public List<placeModel> getPlaceAutocomplete(string keyword)
        {
            var retlist = new List<placeModel>();
            string getResult = string.Empty;
            using (var client = new WebClient())
            {
                client.Encoding = System.Text.Encoding.UTF8;
                getResult = client.UploadString(string.Format("https://maps.googleapis.com/maps/api/place/autocomplete/json?input={0}&types{1}&location{2}&radius{3}&strictbounds{4}&key={5}",
                    keyword, ConfigurationManager.AppSettings["placeAutocomplete_types"],
                    ConfigurationManager.AppSettings["placeAutocomplete_location"],
                    ConfigurationManager.AppSettings["placeAutocomplete_radius"],
                    ConfigurationManager.AppSettings["placeAutocomplete_strictbounds"],
                    ConfigurationManager.AppSettings["googleApiKey_Autocomplete"]), "GET");
            }
            var result = (AutocompleteResult)getResult.Jdeserialize(typeof(AutocompleteResult));

            if (result.status != "OK" && result.status != "ZERO_RESULTS")
                throw new Exception("ERROR occured on getting Place Autocomplete");
            else if (result.status == "ZERO_RESULTS" || result.predictions.Count == 0)
                return new List<placeModel>();
            foreach (var itm in result.predictions)
            {
                retlist.Add(new placeModel()
                {
                    google_id = itm.id,
                    google_place_id = itm.place_id,
                    id = 0,
                    lat = 0,
                    lng = 0,
                    name = itm.description,
                    near = (itm.structured_formatting ?? new structured_formatting()).main_text
                });
            }
            return retlist;
        }

        public placeDetails getPlaceDetails(placeModel im)
        {

            string getResult = string.Empty;
            using (var client = new WebClient())
            {
                client.Encoding = System.Text.Encoding.UTF8;
                getResult = client.UploadString(string.Format("https://maps.googleapis.com/maps/api/place/details/json?placeid={0}&key={1}",
                    im.google_place_id, ConfigurationManager.AppSettings["googleApiKey"]), "GET");
            }
            var result = (PlaceDetailsResult)getResult.Jdeserialize(typeof(PlaceDetailsResult));

            if (result.status != "OK")
                //throw new Exception("ERROR occured on getting Place Details");
                return null;
            //else if (result.status == "ZERO_RESULTS" || result.predictions.Count == 0)
            return new placeDetails()
            {
                lat = result.result.geometry.location.lat,
                lng = result.result.geometry.location.lng,
                viewport_northeast_lat = (result.result.geometry.viewport ?? new viewport() { northeast = new location(), southwest = new location() }).northeast.lat,
                viewport_northeast_lng = (result.result.geometry.viewport ?? new viewport() { northeast = new location(), southwest = new location() }).northeast.lng,
                viewport_southwest_lat = (result.result.geometry.viewport ?? new viewport() { northeast = new location(), southwest = new location() }).southwest.lat,
                viewport_southwest_lng = (result.result.geometry.viewport ?? new viewport() { northeast = new location(), southwest = new location() }).southwest.lng
            };


        }
        public class PlaceDetailsResult
        {
            public List<string> html_attributions { get; set; }
            public result result { get; set; }
            public string status { get; set; }

        }
        public class result
        {
            public List<address_component> address_components { get; set; }
            public string adr_address { get; set; }
            public string formatted_address { get; set; }
            public geometry geometry { get; set; }

            public string icon { get; set; }
            public string id { get; set; }
            public string name { get; set; }
            public List<photo> photos { get; set; }
            public string place_id { get; set; }
            public string reference { get; set; }
            public string scope { get; set; }
            public List<string> types { get; set; }
            public string url { get; set; }
            public int utc_offset { get; set; }
            public string vicinity { get; set; }
        }
        public class photo
        {
            public int height { get; set; }
            public List<string> html_attributions { get; set; }
            public string photo_reference { get; set; }
            public int width { get; set; }
        }
        public class geometry
        {
            public location location { get; set; }
            public viewport viewport { get; set; }
        }
        public class location
        {
            public double lat { get; set; }
            public double lng { get; set; }
        }
        public class viewport
        {
            public location northeast { get; set; }
            public location southwest { get; set; }
        }

        public class address_component
        {
            public string long_name { get; set; }
            public string short_name { get; set; }
            public List<string> types { get; set; }
        }







        public class AutocompleteResult
        {
            public List<prediction> predictions { get; set; }
            public string status { get; set; }
        }
        public class prediction
        {
            public string description { get; set; }
            public string id { get; set; }
            public List<matched_substring> matched_substrings { get; set; }
            public string place_id { get; set; }
            public string reference { get; set; }
            public structured_formatting structured_formatting { get; set; }
            public List<matched_substring> terms { get; set; }
            public List<string> types { get; set; }
        }
        public class matched_substring
        {
            public int length { get; set; }
            public int offset { get; set; }
        }
        public class structured_formatting
        {
            public string main_text { get; set; }
            public List<matched_substring> main_text_matched_substrings { get; set; }
            public string secondary_text { get; set; }
        }
    }



    public class response<T>
    {
        public bool status { get; set; }
        public String message { get; set; }
        public T body { get; set; }

        public response()
        {
            this.status = true;
        }

        public response(T _t)
        {
            this.status = true;
            this.body = _t;
        }

        public response(Exception err)
        {
            this.status = false;
            this.message = err.Message;
        }

        public override string ToString()
        {
            return String.Format("[ result : {0} , message : {1} , value {2}"
                , this.status, this.message ?? " - ", this.body == null ? "" : this.body.ToString()
                );
        }
    }
    public class getAddressBindingModel
    {
        public double lat { get; set; }
        public double lng { get; set; }
    }
    public class srchAddressBindingModel
    {
        public string key { get; set; }
    }
    public class placeModel
    {
        public long id { get; set; }
        public string google_id { get; set; }
        public string google_place_id { get; set; }
        public double lat { get; set; }
        public double lng { get; set; }
        public short type { get; set; }
        public string name { get; set; }
        public string near { get; set; }

    }

    public class placeDetails
    {
        public double lat { get; set; }
        public double lng { get; set; }
        public double viewport_northeast_lat { get; set; }
        public double viewport_northeast_lng { get; set; }
        public double viewport_southwest_lat { get; set; }
        public double viewport_southwest_lng { get; set; }

    }
}