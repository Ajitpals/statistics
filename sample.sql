-- Method 1: Using SELECT INTO with WHERE FALSE
-- This copies both schema and indexes but no data
SELECT *
INTO #TempTable1
FROM SourceTable
WHERE 1 = 2;

-- Method 2: Using LIKE - copies constraints and defaults
CREATE TABLE #TempTable2
LIKE SourceTable;

-- Method 3: Most detailed - explicitly copying schema with specific modifications
SELECT  
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE
INTO #SchemaInfo
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'SourceTable';

-- Generate CREATE TABLE statement dynamically
DECLARE @sql NVARCHAR(MAX) = 'CREATE TABLE #TempTable3 (';
SELECT @sql = @sql + 
    COLUMN_NAME + ' ' + 
    DATA_TYPE + 
    CASE 
        WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL 
        THEN '(' + CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10)) + ')'
        WHEN NUMERIC_PRECISION IS NOT NULL AND NUMERIC_SCALE IS NOT NULL 
        THEN '(' + CAST(NUMERIC_PRECISION AS VARCHAR(10)) + ',' + CAST(NUMERIC_SCALE AS VARCHAR(10)) + ')'
        ELSE ''
    END + 
    CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE ' NULL' END + ', '
FROM #SchemaInfo;

SET @sql = LEFT(@sql, LEN(@sql) - 1) + ')';
EXEC sp_executesql @sql;

-- Example usage with data insertion
INSERT INTO #TempTable1
SELECT * FROM SourceTable WHERE [some_condition];

-- Example join using the temp table
SELECT t.*, s.AdditionalColumn
FROM #TempTable1 t
JOIN SomeOtherTable s ON t.ID = s.ID;

-- Clean up
DROP TABLE #TempTable1;
DROP TABLE #TempTable2;
DROP TABLE #TempTable3;
DROP TABLE #SchemaInfo;
