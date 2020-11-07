SET ANSI_NULLS ON
SET ANSI_WARNINGS ON
SET NOCOUNT ON
 
 
declare @T  table ([id] int,[func] nvarchar(max),[start] datetime null,[end] datetime null,[size] int,[value] nvarchar(max))
declare @s  nvarchar(max)
declare @r  nvarchar(max)
declare @m  int
declare @id int
declare @i  int=0
declare @t1 datetime
declare @t2 datetime

select @m=count(id) from jdata

set @i=0
while (@i<@m) begin
    select @id=id,@s=value from jdata order by id offset @i rows fetch first 1 row only
    set @t1=getdate()
    set @r=convert(nvarchar(max),( select count(*) from Factor_parseJSON(@s)))
    set @t2=getdate()
    insert into @T([id],[func],[start],[end],[size],[value])
    select @id,'NON-PROC',@t1,@t2,len(@s),@r
    set @i=@i+1
end

set @i=0
while (@i<@m) begin
    select @id=id,@s=value from jdata order by id offset @i rows fetch first 1 row only
    set @t1=getdate()
    set @r=convert(nvarchar(max),( select count(*) from json_Parse(@s)))
    set @t2=getdate()
    insert into @T([id],[func],[start],[end],[size],[value])
    select @id,'PROC',@t1,@t2,len(@s),@r
    set @i=@i+1
end

select [id],[func],round([size]/1024,2) [Json text in KB],[value] [Json Nodes],DATEDIFF (second,[start],[end]) as seconds from @T

