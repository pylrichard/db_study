USE employees;

SELECT 
    *
FROM
    employees
WHERE
    emp_no IN (
		SELECT 
            emp_no
        FROM
            dept_emp
        WHERE
            dept_no = 'd005'
	)
LIMIT 10;

SELECT 
    *
FROM
    employees e
WHERE
    EXISTS(
		SELECT 
            *
        FROM
            dept_emp de
        WHERE
            dept_no = 'd005'
			AND e.emp_no = de.emp_no
	)
LIMIT 10;

USE dbt3;

-- group by只执行一次
-- 5.6之前把IN子查询改写成EXISTS子查询
-- 5.6会对IN子查询进行优化
SELECT 
    *
FROM
    orders
WHERE
    o_orderDATE IN (
		SELECT
			-- 得到每个月最后一个订单的订单时间
            MAX(o_orderDATE)
        FROM
            orders
        GROUP BY DATE_FORMAT(o_orderDATE, '%Y-%M')
	);

-- 相关子查询
-- group by执行150W次，因为orders表有150W行记录
-- a的每行记录都要与MAX(b.o_orderdate)进行比较
SELECT 
    *
FROM
    orders a
WHERE
    EXISTS(
		SELECT 
            MAX(o_orderDATE)
        FROM
            orders b
		GROUP BY DATE_FORMAT(o_orderDATE, '%Y-%M')
		HAVING MAX(o_orderDATE) = a.o_orderDATE
	);
