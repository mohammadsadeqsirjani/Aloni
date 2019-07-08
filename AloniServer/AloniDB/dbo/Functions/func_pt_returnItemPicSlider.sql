CREATE FUNCTION [dbo].[func_pt_returnItemPicSlider]
(
	@itemId bigint
)
RETURNS varchar(max)
AS
BEGIN

	 declare @html as varchar(max);
     set @html =  '<div id=' + '''' + 'carousel-example-generic' + '''' + ' class=' + '''' + 'carousel slide' + '''' + ' data-ride=' + '''' + 'carousel' + '''' + '><ol class=' + '''' + 'carousel-indicators' + '''' + '>@s1</ol><div class=' + '''' + 'carousel-inner' + '''' + '>@s2</div></div>' ;
			 declare @s1 as varchar(max),@s2 as varchar(max);
			 set @s1 = '';
			 set @s2 = '';
			 declare @sActive1 as int, @sActive2 as int;
			 set @sActive1 = 0;
			 set @sActive2 = 0;
	 declare @imageUrl as varchar(255),@caption as varchar(100);
	 declare @i as int;
	 set @i = 0;

	 declare c cursor for
	 select d.completeLink,d.caption
	 from
	 TB_DOCUMENT_ITEM as di
	 join TB_DOCUMENT as d
	 on di.pk_fk_document_id = d.id
	 where di.pk_fk_item_id = @itemId
	 order by di.isDefault desc;

	 open c;
	 fetch next from c into @imageUrl,@caption;

	 while @@FETCH_STATUS = 0
	 begin

	IF (@sActive1 = 0)
	begin
    set @s1 = @s1 + '<li data-target=' + '''' + '#carousel-example-generic' + '''' + ' data-slide-to=' + '''' + CAST(@i AS varchar(10)) + '''' + ' class=' + '''' + 'active' + '''' + '></li>';
	set @i = @i + 1;
	set @sActive1 = 1;
	end
	ELSE
	begin
	set @s1 = @s1 + '<li data-target=' + '''' + '#carousel-example-generic' + '''' + ' data-slide-to=' + '''' + CAST(@i AS varchar(10)) + '''' + '></li>';
	set @i = @i + 1;
	end

	IF(@sActive2 = 0)
	begin
	set @s2 = @s2 + '<div class=' + '''' + 'item active' + '''' + '><img src=' + '''' + isnull(@imageUrl,'')  + '''' + ' height=' + '''' + '300' + '''' + ' alt=' + '''' + isnull(@caption,'') + '''' + '><div class=' + '''' + 'carousel-caption' + '''' + '>' + isnull(@caption,'') + '</div></div>';
	set @sActive2 = 1;
	end
	ELSE
	begin
	set @s2 = @s2 + '<div class=' + '''' + 'item' + '''' + '><img src=' + '''' +  isnull(@imageUrl,'')  + '''' + ' height=' + '''' + '300' + '''' + ' alt=' + '''' + isnull(@caption,'') + '''' + '><div class=' + '''' + 'carousel-caption' + '''' + '>' + isnull(@caption,'') + '</div></div>';
	end

	fetch next from c into @imageUrl,@caption;
	end
	close c;
	deallocate c;

	if(@s1 != '' OR @s2 != '')
	begin
	set @html = REPLACE(@html, '@s1', @s1);
	set @html = REPLACE(@html, '@s2', @s2);
	end
	else
	begin
	set @html = ''; 
	end

	return isnull(@html,'');

END