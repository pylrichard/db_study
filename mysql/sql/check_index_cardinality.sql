USE information_schema;

SELECT 
    t.table_schema,
    t.table_name,
    index_name,
    cardinality,
    table_rows,
    cardinality / table_rows AS selectivity
FROM
    TABLES t, (
		SELECT 
			table_schema,
			table_name,
			index_name,
			cardinality
		FROM
			STATISTICS
        -- 统计复合索引每一列的选择性
		WHERE
			(table_schema, table_name, index_name, seq_in_index) IN (
                -- MAX(seq_in_index)表示复合索引共有多少列
				SELECT 
					table_schema,
					table_name,
					index_name,
					MAX(seq_in_index)
				FROM
					STATISTICS
				GROUP BY table_schema, table_name, index_name
			)
	) s
WHERE
    t.table_schema = s.table_schema
	AND t.table_name = s.table_name
	AND t.table_schema = 'employees'
ORDER BY selectivity;

-- 检查所有表的索引选择性，selectivity小于0.1的选择性较差
SELECT 
    t.table_schema,
    t.table_name,
    index_name,
    cardinality,
    table_rows,
    cardinality / table_rows AS selectivity
FROM
    TABLES t, (
		SELECT 
			table_schema,
			table_name,
			index_name,
			cardinality
		FROM
			STATISTICS
        -- 简化，取复合索引的第1列
		WHERE seq_in_index = 1
	) s
WHERE
    t.table_schema = s.table_schema
	AND t.table_name = s.table_name
    AND t.table_rows != 0
	AND t.table_schema NOT IN ('mysql', 'information_schema',
								'performance_schema', 'sys')
ORDER BY selectivity;
