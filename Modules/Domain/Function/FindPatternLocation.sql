CREATE OR ALTER FUNCTION dbo.FindPatternLocation
(
    @string NVARCHAR(MAX),
    @term   NVARCHAR(255)
)
RETURNS TABLE
AS
    RETURN 
    (
      SELECT pos = Number - LEN(@term) 
      FROM (SELECT Number, Item = LTRIM(RTRIM(SUBSTRING(@string, Number, 
      CHARINDEX(@term, @string + @term, Number) - Number)))
      FROM (SELECT ROW_NUMBER() OVER (ORDER BY [object_id])
      FROM sys.all_objects) AS n(Number)
      WHERE Number > 1 AND Number <= CONVERT(INT, LEN(@string)+1)
      AND SUBSTRING(@term + @string, Number, LEN(@term)) = @term
    ) AS y);