DECLARE @XML XML ='<root>
	<TableName label="Framework">
		<Step label="General" key="general">
			<StepItem description="abcd" tooltip="efgh" prefix="aa" suffix="bb" hidden="true" hideLabel="true" showWordCount="true" showCharCount="true" mask="true" tableView="true" key="name" type="textfield" input="true" hideOnChildrenHidden="false"
				  required="true" minLength="3" maxLength="500">Name
			</StepItem>	
			<StepItem  tableView="true" key="description" type="textfield" input="true" hideOnChildrenHidden="false"
				  required="true">Description
			</StepItem>
			<StepItem dataType="dropdown" tableView="true" key="description" type="multiselect" input="true" hideOnChildrenHidden="false"
				  required="true">
				<StepItemChild name="Red"></StepItemChild>
				<StepItemChild name="blue"></StepItemChild>
				<StepItemChild name="black"></StepItemChild>
				RiskCategory
			</StepItem>
		</Step>
	</TableName>
</root>'

SELECT Tbl.Col.value('@label', 'varchar(100)') AS TableName ,
	  Tbl.Col.query('./child::node()') AS Demographics,
	  Tbl.Col.value('(text())[1]', 'nvarchar(max)') as Value2,
	  Tbl.Col.value('(./Step/@label)[1]', 'varchar(100)') AS StepLabel,
	  Tbl.Col.value('(./Step/@key)[1]', 'varchar(100)') AS StepKey,
	  Tbl.Col.value('(./Step/StepItem)[1]', 'varchar(100)') AS StepItem1,
	  Tbl.Col.value('(./Step/StepItem/@description)[1]', 'varchar(100)') AS Stepdescription
FROM @XML.nodes('/root/TableName') AS Tbl(Col)

GO


DECLARE @XML XML ='<root>
	<TableName label="Framework">
		<Step label="General" key="general">
			<StepItem label="Name" key="name" type="textfield">
				<description>abcd</description> 
				<tooltip>efgh</tooltip>
				<prefix>aa</prefix> 
				<suffix>bb</suffix>
			</StepItem>	
			<StepItem label = "Description"  key="description" type="textfield">
				<tableView>true</tableView>
				<hideOnChildrenHidden>true</hideOnChildrenHidden>				
			</StepItem>			
			<StepItem label="RiskCategory" key="RiskCategory" type="dropdown">
				<hideOnChildrenHidden>false</hideOnChildrenHidden>									
				<StepItemChild label="Red" key="Red" type="multiselect"></StepItemChild>
				<StepItemChild label="Blue" key="Blue" type="multiselect"></StepItemChild>
				<StepItemChild label="Black" key="Black" type="multiselect"></StepItemChild>
			</StepItem>
		</Step>
	</TableName>
</root>'

SELECT 
		--Tbl.Col.value('@label', 'varchar(100)') AS TableName ,	 
	 -- Tbl.Col.value('(./Step/@label)[1]', 'varchar(100)') AS StepLabel,
	 -- Tbl.Col.value('(./Step/@key)[1]', 'varchar(100)') AS StepKey,
	  Tbl.Col.value('@label[1]', 'VARCHAR(100)') AS StepItems
FROM @XML.nodes('/root/TableName/Step/StepItem') AS Tbl(Col) 

SELECT DISTINCT  CAST(x.v.query('local-name(.)') AS VARCHAR(100)) AS AttributeName
 ,x.v.value('.', 'VARCHAR(100)') AttributeValue
FROM @XML.nodes('/root/TableName/Step/StepItem') AS Tbl(Col) 
	CROSS APPLY Tbl.Col.nodes('//@*') x(v)

--SELECT 
--		--Tbl.Col.value('@label', 'varchar(100)') AS TableName ,	 
--	 -- Tbl.Col.value('(./Step/@label)[1]', 'varchar(100)') AS StepLabel,
--	 -- Tbl.Col.value('(./Step/@key)[1]', 'varchar(100)') AS StepKey,
--	  TblStepItem.Col.value('@label[1]', 'varchar(100)') AS StepItems
--FROM @XML.nodes('/root/TableName') AS Tbl(Col)
--	CROSS APPLY tbl.col.nodes('/root/TableName/Step/StepItem') AS TblStepItem(Col)

GO


DECLARE @XML XML ='<EmployeeDetails>
  <BusinessEntityID>3</BusinessEntityID>
  <NationalIDNumber>509647174</NationalIDNumber>
  <JobTitle>Engineering Manager</JobTitle>
  <BirthDate>1974-11-12</BirthDate>
  <MaritalStatus>M</MaritalStatus>
  <Gender>M</Gender>
  <StoreDetail>
    <Store>
      <AnnualSales>800000</AnnualSales>
      <AnnualRevenue>80000</AnnualRevenue>
      <BankName>Guardian Bank</BankName>
      <BusinessType>BM</BusinessType>
      <YearOpened>1987</YearOpened>
      <Specialty>Touring</Specialty>
      <SquareFeet>21000</SquareFeet>
    </Store>
    <Store>
      <AnnualSales>300000</AnnualSales>
      <AnnualRevenue>30000</AnnualRevenue>
      <BankName>International Bank</BankName>
      <BusinessType>BM</BusinessType>
      <YearOpened>1982</YearOpened>
      <Specialty>Road</Specialty>
      <SquareFeet>9000</SquareFeet>
    </Store>
  </StoreDetail>
</EmployeeDetails>'


SELECT  
    X.Y.value('(BankName)[1]', 'VARCHAR(20)') as BankName,
    X.Y.value('(AnnualRevenue)[1]', 'VARCHAR(20)') as AnnualRevenue,
    X.Y.value('(BusinessType)[1]', 'VARCHAR(256)') as BusinessType,
    X.Y.value('(Specialty)[1]', 'VARCHAR(128)') as Specialty
FROM  @XML.nodes('EmployeeDetails/StoreDetail/Store') as X(Y)