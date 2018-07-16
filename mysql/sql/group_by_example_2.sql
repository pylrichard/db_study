USE employees;

-- 得到员工最新的头衔信息
SELECT 
    e.emp_no, t.title
FROM
    employees e,
    (
    SELECT 
        emp_no, title
    FROM
        titles
    WHERE
        (emp_no , title) IN (
			SELECT 
                emp_no, MAX(to_date)
            FROM
                titles
            GROUP BY emp_no
		)
	) t
WHERE
    e.emp_no = t.emp_no;

-- 得到员工最新的薪资信息
-- 统计分组结果中大于1条的记录
SELECT 
    emp_no, to_date, COUNT(1)
FROM
    salaries
GROUP BY emp_no , to_date
HAVING COUNT(1) > 1;

-- from_date等于to_date，该员工当天调薪即离职
SELECT 
    *
FROM
    salaries
WHERE
    (emp_no , to_date) IN (
		SELECT 
            emp_no, to_date
        FROM
            salaries
        GROUP BY emp_no , to_date
        HAVING COUNT(1) > 1
	);

-- 扫描salaries表2次
SELECT 
    emp_no, salary
FROM
    salaries
WHERE
    (emp_no , from_date, to_date) IN (
		SELECT 
            emp_no, MAX(from_date), MAX(to_date)
        FROM
            salaries
        GROUP BY emp_no
	);

-- 扫描salaries表1次，更高效
SELECT 
    emp_no,
    -- to_date和from_date最大的才是最新的薪资，将string转化为int
    CAST(SUBSTRING_INDEX(GROUP_CONCAT(salary
                    ORDER BY to_date DESC , from_date DESC), ',', 1)
        AS UNSIGNED) AS salary
FROM
    salaries
GROUP BY emp_no;