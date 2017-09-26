-- 通过tables表查询不是属于InnoDB的表
USE information_schema;
SELECT 
    table_schema,
    table_name,
    engine,
    -- 格式化输出表大小
    sys.format_bytes(data_length) AS data_size
FROM
    tables
WHERE
    -- engine = 'InnoDB'
    engine <> 'InnoDB'
    -- 排除MySQL系统库
	AND table_schema NOT IN ('mysql' , 'information_schema',
	'performance_schema');