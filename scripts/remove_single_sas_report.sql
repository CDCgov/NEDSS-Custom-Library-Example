/**
* Remove SAS reports that use the `sas` report library matching the name specified.
* This includes removal of the impacted reports' filter values, filter validation rows,
* report filters, sort columns, and display columns before removing the reports and
* finally, the actual Report Library itself.
*/
USE [NBS_ODSE]

-- NOTE: Replace <insert-library-name-here> with the name of the actual SAS
-- report library to be deleted, i.e. CA01_DIAGNOSIS.SAS
DECLARE @LIBRARY_NAME NVARCHAR(255) = '<insert-library-name-here>'

IF NOT EXISTS (SELECT 1 FROM dbo.Report_Library WHERE runner = 'sas' AND library_name = @LIBRARY_NAME)
  BEGIN
      RAISERROR('No SAS report library found with the name %s.  Did you specify the correct library name?', 16, 1, @LIBRARY_NAME);
  END

-- Drop impacted filter values
DELETE fv FROM dbo.Filter_Value fv
    LEFT JOIN dbo.Report_Filter rf ON fv.report_filter_uid = rf.report_filter_uid
    LEFT JOIN dbo.Report r ON rf.report_uid = r.report_uid
        AND rf.data_source_uid = r.data_source_uid
    LEFT JOIN dbo.Report_Library rl ON r.library_uid = rl.library_uid
        WHERE rl.runner = 'sas' AND rl.library_name = @LIBRARY_NAME;

-- Drop impacted report filter validation rows
DELETE rfv FROM dbo.Report_Filter_Validation rfv
    LEFT JOIN dbo.Report_Filter rf ON rfv.report_filter_uid = rf.report_filter_uid
    LEFT JOIN dbo.Report r ON rf.report_uid = r.report_uid
        AND rf.data_source_uid = r.data_source_uid
    LEFT JOIN dbo.Report_Library rl ON r.library_uid = rl.library_uid
        WHERE rl.runner = 'sas' AND rl.library_name = @LIBRARY_NAME;

-- Drop impacted report filters
DELETE rf FROM dbo.Report_Filter rf
    LEFT JOIN dbo.Report r ON rf.report_uid = r.report_uid
        AND rf.data_source_uid = r.data_source_uid
    LEFT JOIN dbo.Report_Library rl ON r.library_uid = rl.library_uid
        WHERE rl.runner = 'sas' AND rl.library_name = @LIBRARY_NAME;

-- Drop impacted report sort columns
DELETE rsc FROM dbo.Report_Sort_Column rsc
    LEFT JOIN dbo.Report r ON rsc.report_uid = r.report_uid
        AND rsc.data_source_uid = r.data_source_uid
    LEFT JOIN dbo.Report_Library rl ON r.library_uid = rl.library_uid
        WHERE rl.runner = 'sas' AND rl.library_name = @LIBRARY_NAME;

-- Drop impacted display columns
DELETE dc FROM dbo.Display_Column dc
    LEFT JOIN dbo.Report r ON dc.report_uid = r.report_uid
        AND dc.data_source_uid = r.data_source_uid
    LEFT JOIN dbo.Report_Library rl ON r.library_uid = rl.library_uid
        WHERE rl.runner = 'sas' AND rl.library_name = @LIBRARY_NAME;

-- Drop impacted reports
DELETE r FROM dbo.Report r
    LEFT JOIN dbo.Report_Library rl ON r.library_uid = rl.library_uid
        WHERE rl.runner = 'sas' AND rl.library_name = @LIBRARY_NAME;

-- Finally, drop specified SAS report library
DELETE rl FROM dbo.Report_Library rl WHERE rl.runner = 'sas' AND rl.library_name = @LIBRARY_NAME;