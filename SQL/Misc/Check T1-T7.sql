DECLARE @TBL TABLE(Impact VARCHAR(100),T1 VARCHAR(50),T2 VARCHAR(50),T3 VARCHAR(50),T4 VARCHAR(50),T5 VARCHAR(50),T6 VARCHAR(50),T7 VARCHAR(50))
DECLARE @TBL_Result TABLE(Impact VARCHAR(100),TVal VARCHAR(50),CheckVal VARCHAR(50),RowCnt INT)

INSERT INTO @TBL(Impact,T1,T2,T3,T4,T5,T6,T7)
SELECT 'Reputational','Catastrophic','Minor','Moderate','Minor','Catastrophic','Moderate','Minor'
UNION
SELECT 'Operational','Minor','Moderate','Moderate','Minor','Catastrophic','Moderate','Major'
UNION
SELECT 'Legal','Catastrophic','Minor','Catastrophic','Minor','Catastrophic','Catastrophic','Minor'
UNION
SELECT 'Regulatory','Catastrophic','Minor','Moderate','Minor','Catastrophic','Moderate','Minor'

	--SELECT * FROM @TBL
	DECLARE @CheckVal VARCHAR(50) = 'Moderate'

	INSERT INTO @TBL_Result(Impact,TVal,CheckVal,RowCnt)
		SELECT TOP 1 Impact,
		CASE WHEN T1=@CheckVal THEN 'T1'
			 WHEN T2=@CheckVal THEN 'T2'
			 WHEN T3=@CheckVal THEN 'T3'
			 WHEN T4=@CheckVal THEN 'T4'
			 WHEN T5=@CheckVal THEN 'T5'
			 WHEN T6=@CheckVal THEN 'T6'
			 WHEN T7=@CheckVal THEN 'T7'
		END AS TVal,
		@CheckVal,
		COUNT(*)OVER() AS CNT
		FROM @TBL WHERE T1=@CheckVal OR T2=@CheckVal OR T3=@CheckVal OR T4=@CheckVal OR
										T5=@CheckVal OR T6=@CheckVal OR T7=@CheckVal
		ORDER BY TVAL


IF (SELECT RowCnt FROM @TBL_Result) = 4
	SELECT * FROM @TBL_Result
ELSE --CHECK FOR MAJOR
BEGIN
	
	 DELETE FROM @TBL_Result

	 SET @CheckVal  = 'Major'

	INSERT INTO @TBL_Result(Impact,TVal,CheckVal,RowCnt)
		SELECT TOP 1 Impact,
		CASE WHEN T1=@CheckVal THEN 'T1'
			 WHEN T2=@CheckVal THEN 'T2'
			 WHEN T3=@CheckVal THEN 'T3'
			 WHEN T4=@CheckVal THEN 'T4'
			 WHEN T5=@CheckVal THEN 'T5'
			 WHEN T6=@CheckVal THEN 'T6'
			 WHEN T7=@CheckVal THEN 'T7'
		END AS TVal,
		@CheckVal,
		COUNT(*)OVER() AS CNT
		FROM @TBL WHERE T1=@CheckVal OR T2=@CheckVal OR T3=@CheckVal OR T4=@CheckVal OR
										T5=@CheckVal OR T6=@CheckVal OR T7=@CheckVal
		ORDER BY TVAL
		
	IF (SELECT RowCnt FROM @TBL_Result) = 4
		SELECT * FROM @TBL_Result
	ELSE --CHECK FOR Catastrophic
	BEGIN
		 
		DELETE FROM @TBL_Result

	 SET @CheckVal  = 'Catastrophic'

	INSERT INTO @TBL_Result(Impact,TVal,CheckVal,RowCnt)
		SELECT TOP 1 Impact,
		CASE WHEN T1=@CheckVal THEN 'T1'
			 WHEN T2=@CheckVal THEN 'T2'
			 WHEN T3=@CheckVal THEN 'T3'
			 WHEN T4=@CheckVal THEN 'T4'
			 WHEN T5=@CheckVal THEN 'T5'
			 WHEN T6=@CheckVal THEN 'T6'
			 WHEN T7=@CheckVal THEN 'T7'
		END AS TVal,
		@CheckVal,
		COUNT(*)OVER() AS CNT
		FROM @TBL WHERE T1=@CheckVal OR T2=@CheckVal OR T3=@CheckVal OR T4=@CheckVal OR
										T5=@CheckVal OR T6=@CheckVal OR T7=@CheckVal
		ORDER BY TVAL

		IF (SELECT RowCnt FROM @TBL_Result) = 4
			SELECT * FROM @TBL_Result

	END	--END OF ->--CHECK FOR Catastrophic

END	--END OF ->--CHECK FOR MAJOR


			IF (SELECT RowCnt FROM @TBL_Result) = 4 AND EXISTS(SELECT 1 FROM @TBL_Result WHERE TVal='T1')
			SELECT 
					CASE WHEN TVal = 'T1' THEN CheckVal END AS T1,
					CASE WHEN TVal = 'T2' THEN CheckVal END AS T2,
					CASE WHEN TVal = 'T3' THEN CheckVal END AS T3,
					CASE WHEN TVal = 'T4' THEN CheckVal END AS T4,
					CASE WHEN TVal = 'T5' THEN CheckVal END AS T5,
					CASE WHEN TVal = 'T6' THEN CheckVal END AS T6,
					CASE WHEN TVal = 'T7' THEN CheckVal END AS T7
			FROM @TBL_Result