USE dbt3;
SELECT 
    DATE_FORMAT(o_orderDATE, '%Y-%m') AS date,
    o_clerk,
    COUNT(1),
    SUM(o_totalprice),
    AVG(o_totalprice)
FROM
    orders
GROUP BY date , o_clerk;