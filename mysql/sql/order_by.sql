-- 只获取create_time，排序才会使用create_time索引
-- 否则是全表扫描
SELECT create_time
-- 强制使用选择度更高的索引
FROM order_info
FORCE INDEX (i_create_time)
ORDER BY create_time;

SHOW INDEX FROM order_info;

SHOW CREATE TABLE order_info;
DESC order_info;

SHOW TABLE STATUS LIKE 't_order';