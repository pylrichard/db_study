-- MySQL版本5.6.20
-- 表记录5775万行

-- 统计所有行数，包含NULL
-- 优化器对count(*)有时会选择使用二级索引，不用回表
SELECT count(*);
SELECT count(1);
SELECT count(0);
SELECT count(主键);

-- 统计不为NULL的行数
-- 统计行数要求二级索引列满足NOT NULL
SELECT count(二级索引列);
-- 全表扫描
SELECT count(非索引列);
