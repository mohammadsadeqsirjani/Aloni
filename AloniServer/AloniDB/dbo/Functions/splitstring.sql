﻿CREATE FUNCTION dbo.splitstring ( @stringToSplit VARCHAR(MAX),@matchcase varchar(max))
RETURNS varchar(max)

AS
BEGIN
 declare  @returnList TABLE ([Name] [nvarchar] (500))
 DECLARE @name NVARCHAR(255)
 DECLARE @pos INT

 WHILE CHARINDEX(',', @stringToSplit) > 0
 BEGIN
  SELECT @pos  = CHARINDEX(',', @stringToSplit)  
  SELECT @name = SUBSTRING(@stringToSplit, 1, @pos-1)

  INSERT INTO @returnList 
  SELECT @name

  SELECT @stringToSplit = SUBSTRING(@stringToSplit, @pos+1, LEN(@stringToSplit)-@pos)
 END

 INSERT INTO @returnList
 SELECT @stringToSplit
 
 RETURN (select Name from @returnList where Name like '%'+@matchcase+'%')
END