create function [dbo].[func_RandomString](
    @pStringLength int = 10, --set desired string length
	@mode tinyint = 0
) returns varchar(max)
/* Requires View create view dbo.vw_getNewID as select newid() as NewIDValue;
By Lynn Pettis in SQL Musings from the Desert | 04-04-2009 10:01 PM */
as begin
    declare  @RandomString varchar(max),
	@x as varchar(100);

	if(@mode = 0)
	set @x = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	else if(@mode = 1)
	set @x = '0123456789012345678901234567890123456789'
	else if(@mode = 2)
	set @x = 'ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ';


    with
    a1 as (select 1 as N union all
           select 1 union all
           select 1 union all
           select 1 union all
           select 1 union all
           select 1 union all
           select 1 union all
           select 1 union all
           select 1 union all
           select 1),
    a2 as (select
                1 as N
           from
                a1 as a
                cross join a1 as b),
    a3 as (select
                1 as N
           from
                a2 as a
                cross join a2 as b),
    a4 as (select
                1 as N
           from
                a3 as a
                cross join a2 as b),
    Tally as (select
                row_number() over (order by N) as N
              from
                a4)
    , cteRandomString (
        RandomString
    ) as (
    select top (@pStringLength)
        substring(x,(abs(checksum((select NewIDValue from vw_getNewID)))%36)+1,1)
    from
        Tally cross join (select x = @x) a
    )
     select @RandomString = 
    replace((select
        ',' + RandomString
    from
        cteRandomString
    for xml path ('')),',','');
    return (@RandomString);
end