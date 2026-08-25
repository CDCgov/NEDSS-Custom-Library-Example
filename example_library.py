from src.db_transaction import Transaction
from src.models import ReportResult, Table


def execute(
    trx: Transaction,
    subset_query: str,
    column_map: list[list[str]],
    **kwargs,
) -> ReportResult:
    """Simple example of a Python report library that groups on the selected columns
    and counts the number of records for each group."""

    query = f"""
    WITH subset AS ({subset_query})
    SELECT {', '.join([f"{col[0]} AS [{col[1]}]" for col in column_map])}, COUNT(*) AS record_count
    FROM subset
    GROUP BY {', '.join([f'{col[0]}' for col in column_map])}
    """

    sort_by = kwargs.get('sort_by')
    if sort_by:
        query += ' ORDER BY ' + sort_by

    content: Table = trx.query(query)

    return ReportResult(content=content)
