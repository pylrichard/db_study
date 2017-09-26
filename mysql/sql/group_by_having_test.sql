USE dbt3;

SELECT 
    DATE_FORMAT(o_orderDATE, '%Y-%m') AS month,
    COUNT(*) AS cnt,
    SUM(o_totalprice) AS sum
FROM
    orders
-- 执行较快，先对orders表进行where过滤，再进行group by
-- 最后进行having过滤
WHERE
    o_orderDATE >= '1992-01-01' 
    AND o_orderDATE < '1993-01-01'
GROUP BY DATE_FORMAT(o_orderDATE, '%Y-%m')
-- having后面可以跟聚合函数、过滤字段(必须是临时表的字段)
HAVING cnt > 19000;

SELECT 
    DATE_FORMAT(o_orderDATE, '%Y-%m') AS month,
    COUNT(*) AS cnt,
    SUM(o_totalprice) AS sum
FROM
    orders
GROUP BY DATE_FORMAT(o_orderDATE, '%Y-%m')
-- 执行出错，group by生成的临时表没有o_orderDATE字段
HAVING cnt > 19000
    AND o_orderDATE >= '1992-01-01'
    AND o_orderDATE < '1993-01-01';

SELECT 
    DATE_FORMAT(o_orderDATE, '%Y-%m') AS month,
    COUNT(*) AS cnt,
    SUM(o_totalprice) AS sum
FROM
    orders
GROUP BY DATE_FORMAT(o_orderDATE, '%Y-%m')
-- 执行较慢，因为先对orders表进行group by，再进行having过滤
HAVING cnt > 19000
    AND month >= '1992-01'
    AND month < '1993-01';