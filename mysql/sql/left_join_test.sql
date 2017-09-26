use dbt3;
-- desc orders;
-- desc nation;
-- desc customer;

-- 返回加拿大1997年没有生成订单的客户
-- 以下语句返回空
SELECT 
    c.c_name, c.c_address, c.c_phone
FROM
    customer c
        LEFT JOIN
    orders o ON c.c_custkey = o.o_custkey
        LEFT JOIN
    nation n ON c.c_nationkey = n.n_nationkey
WHERE
	-- 关注where条件之间的互斥性
    o.o_orderkey IS NULL
	-- o_orderkey为NULL的记录，o_orderDATE也为NULL
	AND o.o_orderDATE >= '1997-01-01'
	AND o.o_orderDATE < '1998-01-01'
	AND n.n_name = 'CANADA';

-- 先取出1997年的订单，再与customer进行左连接，结果包含customer表中1997年没有生成订单的客户记录
-- 通过where o.o_orderkey IS NULL条件过滤得到这些记录
SELECT 
    c.c_name, c.c_address, c.c_phone
FROM
    customer c
LEFT JOIN
    (
		SELECT 
			*
		FROM
			orders
		WHERE
			o_orderDATE >= '1997-01-01'
			AND o_orderDATE < '1998-01-01'
	) o ON c.c_custkey = o.o_custkey
LEFT JOIN
	nation n ON c.c_nationkey = n.n_nationkey
WHERE
    o.o_orderkey IS NULL
	AND n.n_name = 'CANADA';