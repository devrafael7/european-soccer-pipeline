
CREATE OR REPLACE PROCEDURE UTILS.COUNT_DUPLICATE(
    TABLE_NAME STRING,
    COLUMN_NAME STRING
)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
var sql = `
    SELECT COUNT(*)
    FROM (
        SELECT "${COLUMN_NAME}"
        FROM ${TABLE_NAME}
        GROUP BY "${COLUMN_NAME}"
        HAVING COUNT(*) > 1
    )
`;

var stmt = snowflake.createStatement({sqlText: sql});
var rs = stmt.execute();

rs.next();

return "Duplicates values found: " + rs.getColumnValue(1);
$$;