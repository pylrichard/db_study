-- 只获取create_time，会使用create_time索引进行index全索引扫描
-- 获取*则是全表扫描
SELECT create_time
-- 强制使用选择度更高的索引
FROM order_info
FORCE INDEX (i_create_time)
ORDER BY create_time;

-- 获取*有LIMIT会使用create_time索引进行index全索引扫描，否则是全表扫描
-- (product_id, create_time)可以建立复合索引，不能满足只有order by create_time的场景
-- 需要(product_id, create_time)、create_time两个索引
-- 复合索引中选择度更高、查询次数更多的字段在前
SELECT *
FROM order_info
WHERE product_id > 1000
-- DESC会逆序扫描索引，索引默认是ASC升序排列
ORDER BY create_time DESC
LIMIT 100;

SHOW INDEX FROM order_info;

SHOW CREATE TABLE order_info;
DESC order_info;

SHOW TABLE STATUS LIKE 'order_info';