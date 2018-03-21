-- 添加索引
ALTER TABLE order_info ADD INDEX i_start_time(start_time);

-- 执行计划中type为range，可以使用start_time索引
SELECT start_time <= now();

-- 索引列在函数中会失效，过滤条件要获取当天数据，又想使用START_DATE索引加快过滤
-- 注意是左闭右开区间，<在Mybatis中要转义为&lt;，否则会报错Tag name expected
-- Extra中显示select tables optimized away表示
-- 1 数据已经在内存中可以直接读取
-- 2 数据可以被认为是一个经计算后的结果,如函数或表达式的值
-- 3 查询的结果被优化器预判可以不执行就可以得到结果
-- 见MySQL查询优化技术的一点儿问答.png
SELECT start_time >= curdate() AND start_time < date_add(curdate(), INTERVAL 1 day);

SELECT date_format(curdate(), '%Y-%m-%d %T');

use sys;
-- 冗余索引
SELECT *
FROM schema_redundant_indexes
WHERE table_schema = 'xxx';

-- 无用索引
SELECT *
FROM schema_unused_indexes
WHERE object_schema = "xxx";