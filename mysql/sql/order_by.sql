-- 只获取create_time，排序才会使用create_time索引
-- 否则是全表扫描
SELECT create_time
-- 强制使用选择度更高的索引
FROM order_info
FORCE INDEX (i_create_time)
ORDER BY create_time;

-- 有LIMIT，排序才会使用create_time索引
-- 否则是全表扫描
-- 如果product_id上有索引，但create_time上没有索引，也会全表扫描
SELECT *
FROM order_info
WHERE product_id > 1000
ORDER BY create_time
LIMIT 100;

SHOW INDEX FROM order_info;

SHOW CREATE TABLE order_info;
DESC order_info;

SHOW TABLE STATUS LIKE 'order_info';