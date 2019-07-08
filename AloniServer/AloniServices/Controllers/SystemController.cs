using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Http;

namespace AloniServices.Controllers
{
    /// <summary>
    /// سرویس های سیستمی
    /// </summary>
    [RoutePrefix("system")]
    public class SystemController : AdvancedApiController
    {
        /// <summary>
        /// مقدار دهی اولیه به اپلیکیشن ها
        /// </summary>
        /// <returns></returns>
        [Route("initApp")]
        [Exception]
        [HttpPost]
        public IHttpActionResult initApp(initAppBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_initApp", "system_initApp", autenticationMode.authenticateAsUser, checkAccess: false))
            {

                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@osType", repo.osType.HasValue ? repo.osType.Value : model.osType);
                repo.cmd.Parameters.AddWithValue("@inputAppVersion", appVersion.getDbValue());//ورژن ارسال شده از سوی اپ
                repo.cmd.Parameters.AddWithValue("@dbAppVersion", repo.appVersion.getDbValue());//ورژن فعلی موجوددر دیتابیس

                var par_isNewVersion = repo.cmd.Parameters.Add("@isNewVersion", SqlDbType.Bit);
                par_isNewVersion.Direction = ParameterDirection.Output;

                var par_newVer_version = repo.cmd.Parameters.Add("@newVer_version", SqlDbType.VarChar,60);
                par_newVer_version.Direction = ParameterDirection.Output;

                var par_newVer_releasNote = repo.cmd.Parameters.Add("@newVer_releasNote", SqlDbType.VarChar,-1);
                par_newVer_releasNote.Direction = ParameterDirection.Output;

                var par_newVer_releaseDateTime_dsc = repo.cmd.Parameters.Add("@newVer_releaseDateTime_dsc", SqlDbType.VarChar, 100);
                par_newVer_releaseDateTime_dsc.Direction = ParameterDirection.Output;

                var par_enhancementIsMandatory = repo.cmd.Parameters.Add("@enhancementIsMandatory", SqlDbType.Bit);
                par_enhancementIsMandatory.Direction = ParameterDirection.Output;

                var par_isNewTermsAndConditions = repo.cmd.Parameters.Add("@isNewTermsAndConditions", SqlDbType.Bit);
                par_isNewTermsAndConditions.Direction = ParameterDirection.Output;

                var par_newTC_termsAndConditions = repo.cmd.Parameters.Add("@newTC_termsAndConditions", SqlDbType.Money);
                par_newTC_termsAndConditions.Direction = ParameterDirection.Output;

                var par_newTC_title = repo.cmd.Parameters.Add("@newTC_title", SqlDbType.VarChar, 50);
                par_newTC_title.Direction = ParameterDirection.Output;

                var par_newTC_description = repo.cmd.Parameters.Add("@newTC_description", SqlDbType.VarChar,-1);
                par_newTC_description.Direction = ParameterDirection.Output;

                var par_newTC_saveDateTime_dsc = repo.cmd.Parameters.Add("@newTC_saveDateTime_dsc", SqlDbType.VarChar, 100);
                par_newTC_saveDateTime_dsc.Direction = ParameterDirection.Output;

                var par_downloadLink = repo.cmd.Parameters.Add("@downloadLink", SqlDbType.NVarChar, 500);
                par_downloadLink.Direction = ParameterDirection.Output;
                repo.ExecuteNonQuery();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new
                {
                    isNewVersion = par_isNewVersion.Value.dbNullCheckBoolean(),
                    newVer_version = par_newVer_version.Value,
                    newVer_releasNote = par_newVer_releasNote.Value,
                    newVer_releaseDateTime_dsc = par_newVer_releaseDateTime_dsc.Value,
                    enhancementIsMandatory = par_enhancementIsMandatory.Value.dbNullCheckBoolean(),
                    isNewTermsAndConditions = par_isNewTermsAndConditions.Value.dbNullCheckBoolean(),
                    newTC_termsAndConditions = par_newTC_termsAndConditions.Value,
                    newTC_title = par_newTC_title.Value,
                    newTC_description = par_newTC_description.Value,
                    newTC_saveDateTime_dsc = par_newTC_saveDateTime_dsc.Value,
                    downloadLink = par_downloadLink.Value
                });
            }
        }

        /// مقدار دهی اولیه به اپلیکیشن ها
        /// </summary>
        /// <returns></returns>
        [Route("initApplication")]
        [Exception]
        [HttpPost]
        public IHttpActionResult initApplication(initAppBindingModel model)
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_initApplication", "system_initApplication", autenticationMode.authenticateAsUser, checkAccess: false))
            {

                repo.cmd.Parameters.AddWithValue("@sessionId", sessionId.getDbValue());
                repo.cmd.Parameters.AddWithValue("@osType", repo.osType.HasValue ? repo.osType.Value : model.osType);
                repo.cmd.Parameters.AddWithValue("@inputAppVersion", appVersion.getDbValue());//وروژن ارسال شده از سوی اپ
                repo.cmd.Parameters.AddWithValue("@dbAppVersion", repo.appVersion.getDbValue());//ورژن فعلی موجوددر دیتابیس

                var par_isNewVersion = repo.cmd.Parameters.Add("@isNewVersion", SqlDbType.Bit);
                par_isNewVersion.Direction = ParameterDirection.Output;

                var par_newVer_version = repo.cmd.Parameters.Add("@newVer_version", SqlDbType.VarChar,60);
                par_newVer_version.Direction = ParameterDirection.Output;

                var par_newVer_releasNote = repo.cmd.Parameters.Add("@newVer_releasNote", SqlDbType.VarChar, -1);
                par_newVer_releasNote.Direction = ParameterDirection.Output;

                var par_newVer_releaseDateTime_dsc = repo.cmd.Parameters.Add("@newVer_releaseDateTime_dsc", SqlDbType.VarChar, 100);
                par_newVer_releaseDateTime_dsc.Direction = ParameterDirection.Output;

                var par_enhancementIsMandatory = repo.cmd.Parameters.Add("@enhancementIsMandatory", SqlDbType.Bit);
                par_enhancementIsMandatory.Direction = ParameterDirection.Output;

                var par_isNewTermsAndConditions = repo.cmd.Parameters.Add("@isNewTermsAndConditions", SqlDbType.Bit);
                par_isNewTermsAndConditions.Direction = ParameterDirection.Output;

                var par_newTC_termsAndConditions = repo.cmd.Parameters.Add("@newTC_termsAndConditions", SqlDbType.Money);
                par_newTC_termsAndConditions.Direction = ParameterDirection.Output;

                var par_newTC_title = repo.cmd.Parameters.Add("@newTC_title", SqlDbType.VarChar, 50);
                par_newTC_title.Direction = ParameterDirection.Output;

                var par_newTC_description = repo.cmd.Parameters.Add("@newTC_description", SqlDbType.VarChar, -1);
                par_newTC_description.Direction = ParameterDirection.Output;

                var par_newTC_saveDateTime_dsc = repo.cmd.Parameters.Add("@newTC_saveDateTime_dsc", SqlDbType.VarChar, 100);
                par_newTC_saveDateTime_dsc.Direction = ParameterDirection.Output;

                var par_downloadLink = repo.cmd.Parameters.Add("@downloadLink", SqlDbType.NVarChar, 500);
                par_downloadLink.Direction = ParameterDirection.Output;
                repo.ExecuteAdapter();

                if (repo.rCode != 1)
                    return new NotFoundActionResult(repo.rMsg);
                return Ok(new
                {
                    isNewVersion = par_isNewVersion.Value.dbNullCheckBoolean(),
                    newVer_version = par_newVer_version.Value,
                    newVer_releasNote = par_newVer_releasNote.Value,
                    newVer_releaseDateTime_dsc = par_newVer_releaseDateTime_dsc.Value,
                    enhancementIsMandatory = par_enhancementIsMandatory.Value.dbNullCheckBoolean(),
                    isNewTermsAndConditions = par_isNewTermsAndConditions.Value.dbNullCheckBoolean(),
                    newTC_termsAndConditions = par_newTC_termsAndConditions.Value,
                    newTC_title = par_newTC_title.Value,
                    newTC_description = par_newTC_description.Value,
                    newTC_saveDateTime_dsc = par_newTC_saveDateTime_dsc.Value,
                    downloadLink = par_downloadLink.Value,
                    userProfile = repo.ds.Tables[0].AsEnumerable().Select(row => new
                    {
                        name = Convert.ToString(row.Field<object>("NAME")),
                        mobile = Convert.ToString(row.Field<string>("mobile")),
                        countryId = Convert.ToInt32(row.Field<object>("COUNTRYID") is DBNull ? 0 : row.Field<object>("COUNTRYID")),
                        countryName = Convert.ToString(row.Field<object>("COUNTRYNAME")),
                        cityId = Convert.ToInt32(row.Field<object>("CITYID") is DBNull ? 0 : row.Field<object>("CITYID")),
                        cityName = Convert.ToString(row.Field<object>("CITYNAME")),
                        provinceId = Convert.ToInt32(row.Field<object>("PROVINCEID") is DBNull ? 0 : row.Field<object>("PROVINCEID")),
                        provinceName = Convert.ToString(row.Field<object>("PROVINCENAME"))
                    }).FirstOrDefault()
                });
            }
        }
        /// <summary>
        /// دریافت تنظیمات اولیه پنل
        /// </summary>
        /// <returns></returns>
        [Route("getBasicPanelSettings")]
        [HttpPost]
        [Exception]
        public IHttpActionResult getBasicPanelSettings()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_getBasicPanelSettings", "systemController_getBasicPanelSettings", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new NotFoundActionResult(repo.rMsg);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                var storeLogo = repo.ds.Tables[0].AsEnumerable();
                var storeInfo = repo.ds.Tables[1].AsEnumerable();
                var itemGrpAccessLevel = repo.ds.Tables[2].AsEnumerable();
                var userAccessLevel = repo.ds.Tables[3].AsEnumerable();
                var promotion = repo.ds.Tables[4].AsEnumerable();
                var termsAndConditions = repo.ds.Tables[5].AsEnumerable();
                return Ok(storeInfo.Select(i => new
                {

                    logo = storeLogo.Select(v => new DocumentItemTab
                    {
                        downloadLink = Convert.ToString(v.Field<object>("ImageUrl")),
                        thumbImageUrl = Convert.ToString(v.Field<object>("thumbImageUrl")),
                        isDefault = Convert.ToBoolean(v.Field<object>("isDefault")),
                        id = Guid.Parse(v.Field<object>("id").ToString())
                    }).FirstOrDefault(),
                    id = i.Field<object>("id"),
                    title = i.Field<object>("title"),
                    currency_dsc = i.Field<object>("crTITLE"),
                    accessLevel = i.Field<object>("accessLevel"),
                    shiftStartTime = i.Field<object>("shiftStartTime"),
                    shiftEndTime = i.Field<object>("shiftEndTime"),
                    canSalesNegativeQty = i.Field<object>("canSalesNegativeQty"),
                    itemEvaluationNeedConfirm = i.Field<object>("itemEvaluationNeedConfirm"),
                    itemEvaluationShowName = i.Field<object>("itemEvaluationShowName"),
                    taxRate = i.Field<object>("taxRate"),
                    calculateTax = i.Field<object>("calculateTax"),
                    taxIncludedInPrices = i.Field<object>("taxIncludedInPrices"),
                    rialCurencyUnit = i.Field<object>("rialCurencyUnit"),
                    storeIsClose = i.Field<object>("storeIsClose"),
                    autoSyncTimePeriod = i.Field<object>("autoSyncTimePeriod"),
                    reducedQtyPercent = i.Field<object>("reducedQtyPercent"),
                    itemGrpAcceccLevel = itemGrpAccessLevel.Select(c => Convert.ToInt64(c.Field<object>("id"))).ToList(), //itemGrpAccessLevel.Where(c=> c.Field<object>("id") == 0).Count() > 0 ? new List<long>() : itemGrpAccessLevel.Select(c =>Convert.ToInt64(c.Field<object>("id"))).ToList(),
                    userAccessLevel = userAccessLevel.Select(m => new
                    {
                        id = m.Field<object>("id"),
                        description = m.Field<object>("description"),
                        area = m.Field<object>("area"),
                        hasAccess = m.Field<object>("hasAccess")
                    }
                    ).ToList(),
                    storePromotion = promotion.Select(c => new
                    {
                        id = c.Field<object>("id"),
                        fk_store_id = c.Field<object>("fk_store_id"),
                        promotionPercent = c.Field<object>("promotionPercent"),
                        promotionDsc = c.Field<object>("promotionDsc"),
                        isActive = c.Field<object>("isActive"),
                    }

                    ).FirstOrDefault(),
                    termAndConditions = termsAndConditions.Select(c => new
                    {
                        newTC_termsAndConditions = c.Field<object>("newTC_termsAndConditions"),
                        newTC_title = c.Field<object>("newTC_title"),
                        newTC_description = c.Field<object>("newTC_description"),
                        newTC_saveDateTime_dsc = c.Field<object>("newTC_saveDateTime_dsc")
                    }).FirstOrDefault()

                }).FirstOrDefault());
            }
        }
        /// <summary>
        /// سرویس بررسی پنل 
        /// </summary>
        /// <returns></returns>
        [Route("checkPanel")]
        [Exception]
        [HttpPost]
        public IHttpActionResult checkPanel()
        {
            if (!ModelState.IsValid)
                return new BadRequestActionResult(ModelState.Values);
            using (var repo = new Repo(this, "SP_checkPanel", "systemController_checkPanel", initAsReader: true))
            {
                if (repo.unauthorized)
                    return new NotFoundActionResult(repo.rMsg);
                repo.cmd.Parameters.AddWithValue("@storeId", storeId);
                repo.ExecuteAdapter();
                var info = repo.ds.Tables[0].AsEnumerable();
               
                return Ok(info.Select(i => new
                {
                    id = i.Field<object>("id"),
                    title = i.Field<object>("title"),
                }).ToList());
            }
        }

    }
    #region models
    /// <summary>
    /// مدل ورودی سرویس مقدار دهی اولیه به اپ
    /// </summary>
    public class initAppBindingModel
    {
        /// <summary>
        /// os type. values:
        /// 1 : android , 2 : IOS , 3 : portal , 4 : windows
        /// </summary>
        public byte osType { get; set; }
    }
    #endregion


}
