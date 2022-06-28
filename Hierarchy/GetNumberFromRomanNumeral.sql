

DROP FUNCTION IF EXISTS dbo.GetNumberFromRomanNumeral
go

/*

SELECT * FROM dbo.GetNumberFromRomanNumeral('i')
*/

CREATE FUNCTION dbo.GetNumberFromRomanNumeral
(@RomanNumeral VARCHAR(10))
RETURNS @TABLE TABLE(RomanNumeral VARCHAR(10), Number INT)
AS
BEGIN

declare @Length int
set @Length = len(@RomanNumeral)
declare @Counter int = 1
declare @Character char(1)
declare @CurrentValue int = 0
declare @LastValue int = 0
declare @Value int = 0

while (@Counter <= @Length)
begin
set @Character = substring(@RomanNumeral, @Counter, 1)
set @CurrentValue =
(case when @Character = 'I' then 1
when @Character = 'V' then 5
when @Character = 'X' then 10
when @Character = 'L' then 50
when @Character = 'C' then 100
when @Character = 'D' then 500
when @Character = 'M' then 1000
else 0 end)

if @LastValue = 0
begin
set @LastValue = @CurrentValue
end
else if (@LastValue >= @CurrentValue)
begin
set @Value += @LastValue
set @LastValue = @CurrentValue
end
else if (@LastValue <= @CurrentValue)
begin
set @Value += (@CurrentValue - @LastValue)
set @LastValue = 0
end

-- For next loop
set @Counter = @Counter + 1
end

if @LastValue > 0
set @Value += @LastValue

INSERT INTO @TABLE(RomanNumeral,Number)
	select @RomanNumeral as RomanNumeral, @Value as 'Answer'

RETURN

END
go