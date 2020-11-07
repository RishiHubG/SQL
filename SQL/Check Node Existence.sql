--https://dba.stackexchange.com/questions/152680/see-if-xml-element-exists-at-any-level-in-document-with-a-specific-value
SET NOCOUNT ON;

DROP TABLE IF EXISTS #Table
CREATE TABLE #Table (ID INT NOT NULL, XmlCol XML);

INSERT INTO #Table (ID, XmlCol) VALUES (6, N'
<root>
<MCTClientName>John</MCTClientName>
<MCTClientCity>Palm Beach</MCTClientCity>
<MCTLocations>
    <MCTLocation>
        <Address>1234 Main Street</Address>
        <ContactFName>Chris</ContactFName>
    </MCTLocation>
    <NewerElement>
    </NewerElement>
</MCTLocations>
</root>
<ContactLName>Brandt</ContactLName>
');

DECLARE @NodeName NVARCHAR(50) = N'root/MCTLocations/MCTLocation/ContactFName',
        @NodeText NVARCHAR(500) = N'Chris';


SELECT *
FROM   #Table tmp
WHERE  tmp.[XmlCol].exist(N'//.[local-name()=sql:variable("@NodeName")][text()=sql:variable("@NodeText")]') = 1;

--USING VARIABLE
SELECT *
FROM   #Table tmp
WHERE  tmp.[XmlCol].exist(N'//.[local-name()=sql:variable("@NodeName")]') = 1;


--USING IN-LINE STRING
SELECT *
FROM   #Table tmp
WHERE  tmp.[XmlCol].exist(N'//.[local-name()="ContactLName"]') = 1;

--USING IN-LINE STRING
SELECT [XmlCol].exist(N'//.[local-name()="ContactLName"]') IsAvailable,*
FROM   #Table tmp
WHERE  tmp.[XmlCol].exist(N'//.[local-name()="ContactLName"]') = 1;



 