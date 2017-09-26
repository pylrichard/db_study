SET @s = 'SELECT * FROM employees WHERE emp_no = ?';
SET @a = 100080;
#数据库会执行成功，得到100080的记录
#@s中的emp_no是int，会将@a转换为int
#Java/Python会报错
#SET @a = '100080 or 1=1';
PREPARE stmt FROM @s;
EXECUTE stmt USING @a;
DEALLOCATE PREPARE stmt;


#SQL注入进行拖库，得到全表数据
SELECT 
    *
FROM
    employees
WHERE
    emp_no = 100080 OR 1 = 1;
    

#WHERE 1=1可以实现动态组合查询条件，后面拼接查询条件即可
SET @s = 'SELECT * FROM employees WHERE 1=1';
SET @s = CONCAT(@s, 'AND gender = "m"');
SET @s = CONCAT(@s, 'AND birth_date >= "1960-01-01"');

PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


SET @s = 'SELECT * FROM employees WHERE 1=1';
SET @s = CONCAT(@s, 'AND gender = "m"');
SET @s = CONCAT(@s, 'AND birth_date >= "1960-01-01"');
SET @s = CONCAT(@s, 'ORDER BY emp_no LIMIT ?, ?');
SET @page_no = 0;
SET @page_count = 10;

PREPARE stmt FROM @s;
EXECUTE stmt USING @page_no, @page_count;
DEALLOCATE PREPARE stmt;