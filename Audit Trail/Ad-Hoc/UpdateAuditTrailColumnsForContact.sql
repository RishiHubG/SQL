		UPDATE AuditTrailColumns
		SET SqlString ='UPDATE TMP           SET OldValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.OldValue AND TMP.Column_Name = ''ContactId'';
						UPDATE TMP           SET NewValue = Cnt.DisplayName          FROM #TMPHistData TMP            INNER JOIN dbo.Contact Cnt ON Cnt.ContactID = TMP.NewValue AND TMP.Column_Name = ''ContactId'';
						UPDATE TMP           SET StepItemName = Hist.OperationType   FROM #TMPHistData TMP            INNER JOIN dbo.ContactInst_History Hist ON Hist.HistoryID = TMP.NewHistoryID AND TMP.Column_Name = ''ContactId'';'
		WHERE ColumnName ='ContactId'

		UPDATE AuditTrailColumns
		SET SqlString ='UPDATE TMP            SET OldValue = RT.Name           FROM #TMPHistData TMP             INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.OldValue AND TMP.Column_Name = ''RoleTypeID'';          
						UPDATE TMP            SET NewValue = RT.Name           FROM #TMPHistData TMP             INNER JOIN dbo.RoleType RT ON RT.RoleTypeID = TMP.NewValue AND TMP.Column_Name = ''RoleTypeID'';'
		WHERE ColumnName ='RoleTypeID'