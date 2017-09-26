desc information_schema.INNODB_BUFFER_PAGE_LRU;

-- 查找Buffer Pool中的压缩页
SELECT 
    table_name,
    space,
    page_number,
    index_name,
    compressed,
    compressed_size
FROM
    information_schema.INNODB_BUFFER_PAGE_LRU
WHERE
    compressed = 'yes'
LIMIT 10;

-- 根据以上输出结果的space字段，查看压缩表信息
SELECT 
    table_id,
    name,
    space,
    row_format,
    zip_page_size
FROM
    information_schema.INNODB_SYS_TABLES
WHERE
    space = xxx;

-- 根据以上输出结果的name字段，查看表结构
-- show create table xxx\G