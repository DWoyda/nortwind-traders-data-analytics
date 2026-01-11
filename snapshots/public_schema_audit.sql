/* 
PURPOSE: Snapshot the PostgreSQL schema metadata for the `public` schema.
This script helps document the starting state of a database by listing:
1) tables (names + types), 2) columns (structure), 3) PK/FK constraints (relationships).
Typical use: baseline documentation before modeling/cleaning/ETL or auditing changes over time.
*/

-- 1) Tables in `public` (base tables, views, etc.)
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema."tables"
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2) Column-level structure for tables in `public` (order preserved via ordinal_position)
SELECT
    table_schema,
    table_name,
    column_name,
    ordinal_position,   -- reflects the defined order of columns in each table
    data_type,
    udt_name,
    is_nullable,
    column_default
FROM information_schema."columns"
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position ASC;

-- 3) PK/FK constraints for `public` (basic relationship & key documentation)
SELECT
    tc.table_schema,
    ccu.table_name,
    ccu.column_name,
    kcu.ordinal_position,   -- position inside multi-column keys
    tc.constraint_type,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON tc.constraint_name = ccu.constraint_name
LEFT JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY ccu.table_name, tc.constraint_type, kcu.ordinal_position;
