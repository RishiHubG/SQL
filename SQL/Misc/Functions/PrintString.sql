create procedure PrintString (@str varchar(max))
as
begin
	declare @line varchar(max), @StartLocation int, @Length int, @TotalLength int, @Current int
	select @StartLocation = 1, @TotalLength = datalength(@str), @Current = 1, @Length = 0
	declare @PrintLine nvarchar(max) =
'declare @pos int = 1
while @pos <= len(@line)
begin
	print substring(@line, @pos, 8000)
	select @pos = @pos + 8000
end'
	while @Current <= @TotalLength
	begin
		if(substring(@str, @Current, 2) in( char(0x0d) + char(0x0a), char(0x0a) + char(0x0d)))
		begin
			if @Length <= 0
				print ''
			else
			begin -- line
				select @line = substring(@str, @StartLocation, @Length)
				exec sp_executesql @PrintLine, N'@Line varchar(max)' , @line
			end
			select @StartLocation = @Current + 2, @Current = @Current + 2, @Length = 0
			continue;
		end
		else if (substring(@str, @Current, 1) in(char(0x0d) , char(0x0a)))
		begin
			if @Length <= 0
				print ''
			else
			begin
				select @line = substring(@str, @StartLocation, @Length)
				exec sp_executesql @PrintLine, N'@Line varchar(max)' , @line
			end
			select @StartLocation = @Current + 1, @Current = @Current + 1, @Length = 0
			continue;
		end
		select @Current = @Current + 1, @Length = @Length + 1
	end
	if(@StartLocation <= datalength(@str))
		print substring(@str, @StartLocation, datalength(@str))
end
go
declare @str nvarchar(max) = Replicate(cast('0123456789' as varchar(max)), 800)+'abc
'
select @str = replicate(@str, 3)
exec PrintString @str
/*
01234567890...
abc
01234567890...
abc
01234567890...
abc

*/