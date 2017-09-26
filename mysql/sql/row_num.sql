USE dbt3;
-- 需要分两次执行，而且必须同时执行，单独执行第二条语句@num会从之前的值开始计算
SET @num:=0;
SELECT @num:=@num+1 AS row_num, c_custkey, c_name FROM customer LIMIT 10;

-- SELECT @num:=0产生只有1行记录的表，与customer表(有n条记录)进行关联，产生1*n的笛卡尔积
SELECT @num:=@num+1 AS row_num, c_custkey, c_name FROM customer, (SELECT @num:=0) tmp LIMIT 10;

USE employees;
SELECT 
    emp_no,
    -- 相关子查询，计算代价很大
    (SELECT 
		-- 计算小于每一条记录的记录数，即为行号
		COUNT(1)
	FROM
		employees t2
	WHERE
		t2.emp_no <= t1.emp_no) AS row_num
FROM
    employees t1
-- 要进行排序
ORDER BY emp_no
-- 没有order by，limit随机取结果
LIMIT 10;
