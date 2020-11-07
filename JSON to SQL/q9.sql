SELECT * FROM TMP ORDER BY ID

SELECT * FROM TMP  WHERE [KEY]='label' ORDER BY ID

--1.
--GET THE FRAMEWORK/TABLE; GET THE PATH COL. VALUE FOR TYPE=4=ARRAY( THIS WILL HAVE THE HIERARCHY)
SELECT * FROM TMP WHERE PrePath='components[0]'

--2. USING THE PATH VALUE (components[0].components) FOUND ABOVE, APPLY THIS AS A FILTER IN PREPATH TO GET ITS CHILDREN
--USE THE PATH VALUE TO GET EACH OF THEIR CHILDREN
SELECT * FROM TMP WHERE PrePath='components[0].components' --NO. OF STEPS

--3.
--PARSE THE CHILDREN ONE BY ONE FOUND IN STEP# 2 ABOVE
SELECT * FROM TMP WHERE PrePath='components[0].components[0]'

--4. 
SELECT * FROM TMP WHERE PrePath='components[0].components[0].components'

--5. 
SELECT * FROM TMP WHERE PrePath='components[0].components[0].components[0]'

--6.
SELECT * FROM TMP WHERE PrePath='components[0].components[0].components[0].columns'

--7.
SELECT * FROM TMP WHERE PrePath='components[0].components[0].components[0].columns[0]'

--8.
SELECT * FROM TMP WHERE PrePath='components[0].components[0].components[0].columns[0].components'

-9.
SELECT * FROM TMP WHERE PrePath='components[0].components[0].components[0].columns[0].components[0]'

SELECT * FROM TMP WHERE hierarchyid =0x7ADAD580


