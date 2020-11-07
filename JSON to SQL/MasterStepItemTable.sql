DECLARE @TBL_Steps TABLE(ID INT IDENTITY(1,1),StepIName VARCHAR(100),StepItemName VARCHAR(100))
/*
TO DO: 
1.ADD ID INT WHICH IS A FK TO TO @TBL_STEPS
2. REMOVE StepItemName
3. ADD NEW TABLE FOR MULTI-LEVEL DEPENDENCY UNDER A STEP ITEM
*/
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

SELECT * FROM @TBL
ORDER BY ParentName
 
