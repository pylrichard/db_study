-- 通过columns表查询字符编码不是utf8mb4的表
-- 执行以下语句后，TABLE_COLLATION会变为utf8mb4，表中对应字段还是之前的字符集
-- alter table t1 charset = utf8mb4;
USE information_schema;

SELECT 
    CONCAT(table_schema, '.', table_name),
    column_name,
    character_set_name
FROM
    columns
WHERE
	-- 限定字段类型，不是所有的字段都跟字符集有关，比如int类型就没有
    data_type IN ('char' , 'varchar',
        'text',
        'mediumtext',
        'longtext')
	-- 关注COLUMNS.CHARACTER_SET_NAME
	AND character_set_name <> 'utf8mb4'
	AND table_schema NOT IN ('mysql' , 'sys',
        'information_schema',
        'performance_schema');

SELECT 
    CONCAT(table_schema, '.', table_name) AS name,
    character_set_name,
    -- 每个分组下属于一种字符集的字段名集合
    GROUP_CONCAT(column_name
        SEPARATOR ':') AS column_list
FROM
    columns
WHERE
    data_type IN ('char' , 'varchar',
        'text',
        'mediumtext',
        'longtext')
	AND character_set_name <> 'utf8mb4'
	AND table_schema NOT IN ('mysql' , 'sys',
        'information_schema',
        'performance_schema')
GROUP BY name , character_set_name;