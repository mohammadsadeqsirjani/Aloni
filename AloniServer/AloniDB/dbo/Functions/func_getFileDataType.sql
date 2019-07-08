CREATE FUNCTION [dbo].[func_getFileDataType]
(
	@fileName as nvarchar(500)
)
RETURNS nvarchar(10)
AS
BEGIN
	
	Declare @individual varchar(20) = null
	declare @result nvarchar(10)
	WHILE LEN(@fileName) > 0
	BEGIN
		IF PATINDEX('%.%', @fileName) > 0
		BEGIN
			SET @individual = SUBSTRING(@fileName,0,PATINDEX('%.%', @fileName))
			SET @fileName = SUBSTRING(@fileName,LEN(@individual + '.') + 1,LEN(@fileName))
		END
		ELSE
		BEGIN
			SET @individual = @fileName
			SET @fileName = NULL
			set @result = @individual
		END
	END
	return @result
END
