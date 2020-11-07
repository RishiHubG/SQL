DECLARE @TBL TABLE(StepItemName VARCHAR(100),PropertyName VARCHAR(100),DataType VARCHAR(100),ParentName VARCHAR(100))

INSERT INTO @TBL
(
    StepItemName,
    PropertyName,
	DataType,
	ParentName
)
SELECT 'Name','tooltip','boolean',NULL
UNION
SELECT 'Name','prefix','textfield',NULL
UNION
SELECT 'Name','suffix','textfield',NULL
UNION
SELECT 'Name','hideLabel','boolean',NULL
UNION
SELECT 'Description','true','boolean',NULL
UNION
SELECT 'Description','maxLength','int',NULL
UNION
SELECT 'Description','hidden','boolean',NULL
UNION
SELECT 'RiskCategory','hideOnChildrenHidden','boolean',NULL
UNION
SELECT 'RiskCategory','maxLength','int',NULL
UNION
SELECT 'RiskCategory','hidden','boolean',NULL
UNION
SELECT 'Red','','multiselect','RiskCategory'
UNION
SELECT 'Blue','','multiselect','RiskCategory'
UNION
SELECT 'Black','','multiselect','RiskCategory'

--SELECT * FROM @TBL
--ORDER BY ParentName
 


DECLARE @XML XML ='<root>
	<TableName label="Framework">
		<Step label="General" key="general">
			<StepItem label="Name" key="name" type="textfield">
				<description>abcd</description> 
				<tooltip>efgh</tooltip>
				<prefix>aa</prefix> 
				<suffix>bb</suffix>
				<hideLabel>true</hideLabel>
			</StepItem>	
			<StepItem label = "Description"  key="description" type="textfield">
				<tableView>true</tableView>
				<hideOnChildrenHidden>true</hideOnChildrenHidden>			
			</StepItem>			
			<StepItem label="RiskCategory" key="RiskCategory" type="dropdown">
				<hideOnChildrenHidden>false</hideOnChildrenHidden>									
				<StepItemChild label="Red" key="Red" type="multiselect">Red</StepItemChild>
				<StepItemChild label="Blue" key="Blue" type="multiselect">Blue</StepItemChild>
				<StepItemChild label="Black" key="Black" type="multiselect">Black</StepItemChild>
			</StepItem>
		</Step>
	</TableName>
</root>'

SELECT * FROM @TBL ORDER BY [@TBL].ParentName 
SELECT 	
	  Tbl.Col.value('@label[1]', 'VARCHAR(100)') AS StepItemName,
	  T.C.value('@label', 'VARCHAR(100)') AS ChildLabel,
	  T.C.value('@key', 'VARCHAR(100)') AS ChildKey,
	  T.C.value('@type', 'VARCHAR(100)') AS ChildType 	 
FROM @XML.nodes('/root/TableName/Step/StepItem') AS Tbl(Col) 
	 CROSS APPLY Tbl.Col.nodes ('./StepItemChild') as t(C)

SELECT *
FROM
(
SELECT 
	   --Tbl.Col.value('hideLabel[1]', 'bit') AS hideLabel ,	 
	 -- Tbl.Col.value('(./Step/@label)[1]', 'varchar(100)') AS StepLabel,
	 -- Tbl.Col.value('(./Step/@key)[1]', 'varchar(100)') AS StepKey,
	  Tbl.Col.value('@label[1]', 'VARCHAR(100)') AS StepItemName	 
FROM @XML.nodes('/root/TableName/Step/StepItem') AS Tbl(Col) 	 
)TAB
	LEFT JOIN @TBL A ON A.StepItemName = TAB.StepItemName
ORDER BY ParentName

--SELECT 
--	   Tbl.Col.value('hideLabel[1]', 'bit') AS hideLabel ,	 
--	 -- Tbl.Col.value('(./Step/@label)[1]', 'varchar(100)') AS StepLabel,
--	 -- Tbl.Col.value('(./Step/@key)[1]', 'varchar(100)') AS StepKey,
--	  Tbl.Col.value('@label[1]', 'VARCHAR(100)') AS StepItemName	 
--FROM @XML.nodes('/root/TableName/Step/StepItem') AS Tbl(Col) 	