-- 不同会话的值不同
SHOW VARIABLES LIKE 'join_buffer_size';
SHOW VARIABLES LIKE 'read_rnd_buffer_size';
SHOW VARIABLES LIKE 'sort_buffer_size';
SHOW VARIABLES LIKE 'tmp_table_size';
SHOW PROCESSLIST;

--
-- 慢查询3板斧：
-- 1.explain 2.show processlist 3.performance_schema
--
-- SQL执行顺序
-- 1 FROM 找到要查询的表
-- 2 JOIN ON 关联表
-- 3 WHERE 过滤条件
-- 4 GROUP BY 分组
-- 5 HAVING 分组过滤
-- 6 ORDER BY 排序
-- 7 LIMIT
-- 8 SELECT
--
-- 输出结果中的execution和fetching分别代表服务器执行sql的时间和数据传输到客户端的时间
--
-- query cache在OLTP建议开启
--
-- 表关联拆分成多个小SQL，然后在服务中拼装数据，DB只做存储，不做计算
-- 把表关联获取的数据存储在Redis
-- 调大join buffer，限制数据库连接，避免高并发下内存OOM，buffer都位于线程本地内存
--
-- MRR只对OLAP有效果，OLTP中有MRR是不好的预兆
--
SET optimizer_switch = 'mrr=on,mrr_cost_based=off,batched_key_access=on';
SET join_buffer_size = 134217728;
SET read_rnd_buffer_size = 33554432;
SET sort_buffer_size = 134217728;

-- 使用sys库分析SQL
-- MySQL Workbench中Performance Reports可视化查看sys库分析结果
USE sys;
-- 查看自增字段使用情况
SELECT *
FROM schema_auto_increment_columns;

-- 全表扫描
SELECT *
FROM statements_with_full_table_scans
WHERE db = 'xxx';

-- 哪些SQL语句使用了磁盘临时表，关注disk_tmp_tables
SELECT *
FROM statements_with_temp_tables
WHERE db = 'xxx';

-- 排序
SELECT *
FROM statements_with_sorting
WHERE db = 'xxx';

-- 哪些语句延迟较大
SELECT *
FROM statement_analysis
WHERE db = 'xxx';
