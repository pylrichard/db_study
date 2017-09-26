-- 找出没有创建主键的表
SELECT 
    *
FROM
    information_schema.TABLES t
LEFT JOIN
    information_schema.STATISTICS s
	ON t.table_schema = s.table_schema
	AND t.table_name = s.table_name
	AND s.index_name = 'PRIMARY'
WHERE
    t.table_schema NOT IN ('mysql', 'performance_schema',
							'information_schema', 'sys')
	AND table_type = 'BASE_TABLE'
	AND s.index_name IS NULL;

