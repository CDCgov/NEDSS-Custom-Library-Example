# 🧹 Legacy SAS Report Database Cleanup Guide

This document details how to safely delete legacy SAS report definitions and 
library metadata from the `NBS_ODS` database when migrating to Python 
report libraries.

```
WARNING: Executing these scripts permanently deletes report configurations, user 
display choices, and saved filter values. Always back up the NBS_ODS database 
before running cleanup scripts in production environments.
```

## 🛠️ Available Scripts
| Script                         | Purpose                                                           | Scope                    | 
|--------------------------------|-------------------------------------------------------------------|--------------------------|
| `remove_single_sas_report.sql` | Removes a specific legacy SAS report and its associated metadata. | Targeted single report   |
| `remove_all_sas_reports.sql`   | Bulk removes **ALL** legacy SAS reports and associated metadata.  | Full legacy report purge |

##  🚀 Script Execution Instructions
### 🎯 Delete a Single SAS Report (`remove_single_sas_report.sql`)

   Use this script when converting an individual SAS report to Python and 
   you prefer to purge the existing SAS configuration before creating the 
   new Python report in the NBS UI.
   1. Open `remove_single_sas_report.sql` in a database client (ex. SQL Server Management Studio (SSMS))
   2. Update the `@LIBRARY_NAME` parameter to match the exact name of the SAS file
   3. Execute the script
   4. Verify that the query returns a successful execution message without foreign key constraint errors.

### 🗑️ Delete All SAS Reports (`remove_all_sas_reports.sql`)
   
   Use this script during a bulk migration phase when all legacy SAS reporting functionality is being retired across the system.
   1. Verify that all custom SAS library logic needed for conversion to Python has been documented or archived.
   2. Open `remove_all_sas_reports.sql` in a database client (ex. SQL Server Management Studio (SSMS))
   3. Execute the script
   4. Verify that the query returns a successful execution message without foreign key constraint errors.

## 🔄 Cascading Deletion Order

To prevent foreign key constraint failures, the cleanup scripts execute deletions across tables in the following strict order:

1. `dbo.Filter_Value`: Removes filter inputs saved for the target SAS reports. 
2. `dbo.Report_Filter_Validation`: Clears validation rules attached to report filters. 
3. `dbo.Report_Filter`: Drops the filter configurations associated with the reports. 
4. `dbo.Report_Sort_Column`: Purges user and default sort column selections. 
5. `dbo.Display_Column`: Deletes visible column preferences configured for the reports. 
6. `dbo.Report`: Deletes the core report entities linked to the library. 
7. `dbo.Report_Library`: Drops the SAS library registration entry.
