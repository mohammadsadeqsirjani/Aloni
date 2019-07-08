CREATE VIEW [dbo].[vw_getTypContactusDepartment]
	AS 
select 
id,
title,
CASE WHEN isActive IS NULL OR isActive = 0 THEN 'غیرفعال' WHEN isActive = 1 THEN 'فعال' END AS isActive
from TB_TYP_CONTACTUS_DEPARTMENT
