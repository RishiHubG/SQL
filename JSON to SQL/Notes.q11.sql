/*
type field at stepitem level=
textfield - can't have any child items under it
selectboxes - will have child items under it
select      - will have child items under it

inputType field at child level of a stepitem=
checkbox (provided type field is selectboxes)
*/

--GENERAL
	SELECT * FROM TMP_CTE WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[0]%' ESCAPE '\'

--GENERAL-> NAME
------------------------------------------------------------------------------------
SELECT * FROM TMP_CTE WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[0].components\[0].columns\[0].components\[0]%' ESCAPE '\'

--ALL PROPERTIES OF NAME
SELECT * FROM TMP_CTE WHERE PrePath LIKE 'components\[0].components\[0].components\[0].columns\[0].components\[0]%' ESCAPE '\' AND [key]!='label'
------------------------------------------------------------------------------------

--GENERAL-> Reference
------------------------------------------------------------------------------------
SELECT * FROM TMP_CTE WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[0].components\[0].columns\[0].components\[1]%' ESCAPE '\'

--ALL PROPERTIES OF Reference
SELECT * FROM TMP_CTE WHERE PrePath LIKE 'components\[0].components\[0].components\[0].columns\[0].components\[1]%' ESCAPE '\' AND [key]!='label'
------------------------------------------------------------------------------------

--Details-> Risk Description
------------------------------------------------------------------------------------
SELECT * FROM TMP_CTE WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[1].components\[0]%' ESCAPE '\'

--ALL PROPERTIES OF Risk Description
SELECT * FROM TMP_CTE WHERE PrePath LIKE 'components\[0].components\[1].components\[0]%' ESCAPE '\' AND [key]!='label'

------------------------------------------------------------------------------------

--Details-> Risk Category 1
------------------------------------------------------------------------------------
SELECT * FROM TMP_CTE WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[1].components\[1].columns\[1].components\[0]%' ESCAPE '\'

--ALL PROPERTIES OF Risk Category 1
SELECT * FROM TMP_CTE WHERE PrePath LIKE 'components\[0].components\[1].components\[1].columns\[1].components\[0]%' ESCAPE '\' AND [key]!='label'

--ALL PROPERTIES OF Nature under Risk Category 1
SELECT * FROM TMP_CTE WHERE PrePath LIKE 'components\[0].components\[1].components\[1].columns\[1].components\[0].data.values\[0]%' ESCAPE '\' AND [key]!='label'
------------------------------------------------------------------------------------

--DETAILS-> APPLICABLE FACTOR
------------------------------------------------------------------------------------
SELECT * FROM TMP_CTE WHERE [key]='Label' AND PrePath LIKE 'components\[0].components\[1].components\[1].columns\[0].components\[0]%' ESCAPE '\'

SELECT * FROM TMP_CTE WHERE  PrePath LIKE 'components\[0].components\[1].components\[1].columns\[0].components\[0]%' ESCAPE '\'

SELECT * FROM TMP_CTE WHERE PrePath LIKE 'components\[0].components\[1].components\[1].columns\[0].components\[0].values\[0]%' ESCAPE '\'
------------------------------------------------------------------------------------
