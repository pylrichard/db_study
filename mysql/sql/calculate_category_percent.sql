SELECT
	t2.name,
    # 计算每个类别的记录数占该表总记录数的百分比
	CAST (
		cnt * 100.0 / (
			SELECT
				COUNT(*)
			FROM
				table1
		-- 保留2位小数
		) AS float (2)
	) AS percent
FROM
	(
		SELECT
			category_id AS c_id,
			COUNT(*) AS cnt
		FROM
			table1
		GROUP BY
			c_id
		ORDER BY
			cnt DESC
	) AS t1
# 根据t2.type_code和t1.category_id进行关联
JOIN table2 AS t2 ON t2.type_code = t1.c_id
ORDER BY t1.cnt DESC;
