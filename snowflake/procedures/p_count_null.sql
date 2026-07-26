
USE DATABASE EUROPEAN_SOCCER_DB;
USE SCHEAM UTILS;

CREATE OR REPLACE PROCEDURE UTILS.COUNT_NULLS(
    TABLE_NAME STRING,
    COLUMN_NAME STRING
)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS
$$
var sql =
`SELECT COUNT(*)
 FROM ${TABLE_NAME}
 WHERE "${COLUMN_NAME}" IS NULL`;

var stmt = snowflake.createStatement({sqlText: sql});
var rs = stmt.execute();

rs.next();

return "Nulls found: " + rs.getColumnValue(1);
$$;