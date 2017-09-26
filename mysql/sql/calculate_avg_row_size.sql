-- 计算orders表每行记录的大小
-- show table status like 'orders'\G
-- 输出结果Data_length/Rows得到的单行大小并不精确，Data_length包含空洞
USE dbt3;

SELECT 
    ROUND(AVG(row), 2)
FROM
    (SELECT 
		-- length()计算字符串类型字段大小，length()传入int类型字段(会进行隐式转换)，得到的结果有4也有5
        (4 + 4 + 1 + 8 + 8 + LENGTH(o_orderpriority) + LENGTH(o_clerk) + 4 + LENGTH(o_comment)) AS row
    FROM
        orders
    LIMIT 150000) a;