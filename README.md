# Custom Python NBS Report Libraries

In NBS 6 SAS was used to allow STLTs to write custom report libraries.  In NBS 7 SAS has been phased out in favor of running report libraries using Python.  These Python libraries will be able to query existing databases and return results for viewing in the NBS 7 UI or to be exported to CSV files.

These new Python libraries will be executed by the **Report Execution** app which can be found in the `NEDSS-Modernization` repository:

[NEDSS-Modernization](https://github.com/CDCgov/NEDSS-Modernization)

Within the repository the Report Execution app is found at `app/report-execution` and the Python library files themselves are located at:

```
apps/report-execution/src/libraries        # builtin libraries
apps/report-execution/src/libraries/custom # STLT-made custom libraries
```

## Concepts

### Report

A report is the main entity which is used to run individual report libraries (previously written in SAS, now written in Python) using a configured data source in NBS.

### Report Library

Where the actual data lookup and handling logic of the report lives.  In NBS 7 the report libraries are Python files which adhere to a prescribed shape in order to be used in NBS via the Report Execution app.

A report library can either be:

- builtin: pre-built report libraries that are maintained by NBS devs
- custom: report libraries built by STLTs and used only within their NBS install

### Python Library

A single Python file that adheres to a prescribed shape (see example below) that is called when a report is run from NBS via the Report Execution app.

## Example Python Library

Here is a simple example of a Python library which returns unmodified data queried from a given data source:

```Python
from src.db_transaction import Transaction
from src.models import ReportResult, Table


def execute(
    trx: Transaction,
    subset_query: str,
    **kwargs,
) -> ReportResult:
    """Simple example of a Python report library."""

    content: Table = trx.query(subset_query)

    return ReportResult(content=content)
```

- `execute` is the entrypoint for all Python libraries and is how the Report Execution app calls each Python library
- `subset_query` is the SQL query that is given to the libary by NBS to act as the main data source for the report
- `Transaction` represents the database connection and has a method named `query` to execute SQL queries (results returned in a `Table` instance)
- `Table` is the data format which contains both column names and data which is used to return the result to NBS
- `ReportResult` is the data shape that is used to return the report's resulting data (via a `Table` instance, assigned to the `content` attribute) to either the NBS UI or the exported CSV


## Adding a Custom Library to NBS

There are 2 possible scenarios you can have for adding a custom library to NBS 7:

1. You have created a brand new Python library that has never been used before
2. You have converted an existing SAS library into Python and need to replace it

### Adding a Brand New Python Library

There is one table named `NBS_ODSE.dbo.Report_Library` that must be manually updated to include information about a given custom report library.  The following query should be used as a template for this task:

```sql
USE [NBS_ODSE];

INSERT INTO [dbo].[Report_Library] (
    library_name,
    desc_txt,
    runner,
    column_select_ind,
    is_builtin_ind,
    add_time,
    add_user_id,
    last_chg_time,
    last_chg_user_id
) VALUES (
    'example_library',  -- MUST be the Python library's filename without ".py"
    'This is an example library meant for instruction.',  -- Short description of library
    'python',  -- MUST have the value 'python'
    'N',
    'N',
    CURRENT_TIMESTAMP,
    99999999,
    CURRENT_TIMESTAMP,
    99999999
);
```

- For `library_name`, the value **MUST** be the Python libary's filename without the `.py` extension (e.g. `example_library.py` -> `example_library`).
- For `desc_txt`, write a descriptive sentence which will give meaning to anyone reading it from the NBS UI.
- For `runner` the value **MUST** be `python`.

### Replacing an Existing SAS Library With Python

If you are replacing an existing SAS library with Python, then the SAS library should already be present in the `NBS_ODSE.dbo.Report_Library` table.  Use the following query as a template to update the existing library to use the new Python library instead:

```sql
USE [NBS_ODSE];

UPDATE [dbo].[Report_Library]
SET
    library_name = 'example_library',  -- MUST be the Python library's filename without ".py"
    runner = 'python',  -- MUST have the value 'python'
    desc_txt = 'This is an example library meant for instruction.',  -- Short description of library
    last_chg_time = CURRENT_TIMESTAMP,
    last_chg_user_id = 99999999
WHERE
    UPPER(library_name) = 'EXISTING_LIBRARY.SAS';  -- MUST be the exact  SAS library file name in ALL CAPS
```

- For `library_name`, the value **MUST** be the Python libary's filename without the `.py` extension (e.g. `example_library.py` -> `example_library`).
- For `desc_txt`, write a descriptive sentence which will give meaning to anyone reading it from the NBS UI.
- For `runner` the value **MUST** be `python`.
- Make sure to match the existing `library_name` by putting the SAS library filename is ALL CAPS

### Deploying Custom Report Libraries

All custom report library files will need to be placed in the `/usr/report-execution/src/libraries/custom/` directory within the `report-execution` deployed docker container.

## Running the New Report Library

Once the new library has been written, the database has been updated properly, and the library file has been deployed you're now ready to run the report from the NBS UI.

If it is a brand new report library, you will need to create a new report in the NBS UI.  If you have replaced an existing SAS library with the new Python library, the report should run as-is from the NBS UI.

### Creating a Report With the New Python Library

Once the new Python library has been added to NBS by using the above steps, you will need to create a new Report in the NBS UI:

- Navigate to `System Management` > `Report Management`, click on `Manage Reports`.
- Click on `Create`
- Fill out the `Add report` configuration screen
- You will find the new custom Python library in the `Report execution library` dropdown (**NOTE: if it does not appear in the dropdown, be sure to clear out your browser's Local Storage as the values in the dropdown are cached there**)

  ![Add Report Configuration Library Dropdown](images/add_report_execution_library_dropdown.png)
- Your configured report will look something like this:
  ![Add Report Configuration](images/add_report_configuration.png)
- Click `Submit`
- Navigate to `Reports` and your new report will appear in the group and section that you configured them for:
  ![Reports List](images/reports_list.png)

### Accessing a Report That Was Updated From SAS to Python

Once the new Python library has been deployed to NBS and the proper database table has been updated as per the instracutions above, the existing report that used to use SAS will still appear in the same spot in the `Reports` section of the NBS UI.

Run the report in the same way as you did before and it will use the Python library that you have updated it with.
