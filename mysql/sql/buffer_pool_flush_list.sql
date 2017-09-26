-- 查看Buffer Pool的Flush List
-- 不要在线上操作该SQL语句，开销较大
SELECT
    pool_id,
    lru_position,
    space,
    page_number,
    table_name,
    oldest_modification,
    newest_modification
FROM
    information_schema.INNODB_BUFFER_PAGE_LRU
WHERE
    oldest_modification <> 0
    -- 如果没有脏页，结果集为空
	AND oldest_modification <> newest_modification;
